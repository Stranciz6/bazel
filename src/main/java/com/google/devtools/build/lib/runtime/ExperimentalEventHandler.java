// Copyright 2015 The Bazel Authors. All rights reserved.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//    http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
package com.google.devtools.build.lib.runtime;

import com.google.common.eventbus.Subscribe;
import com.google.common.primitives.Bytes;
import com.google.devtools.build.lib.actions.ActionCompletionEvent;
import com.google.devtools.build.lib.actions.ActionStartedEvent;
import com.google.devtools.build.lib.actions.ActionStatusMessage;
import com.google.devtools.build.lib.analysis.AnalysisPhaseCompleteEvent;
import com.google.devtools.build.lib.analysis.NoBuildEvent;
import com.google.devtools.build.lib.buildtool.buildevent.BuildCompleteEvent;
import com.google.devtools.build.lib.buildtool.buildevent.BuildStartingEvent;
import com.google.devtools.build.lib.buildtool.buildevent.ExecutionProgressReceiverAvailableEvent;
import com.google.devtools.build.lib.buildtool.buildevent.TestFilteringCompleteEvent;
import com.google.devtools.build.lib.events.Event;
import com.google.devtools.build.lib.events.EventKind;
import com.google.devtools.build.lib.pkgcache.LoadingPhaseCompleteEvent;
import com.google.devtools.build.lib.skyframe.LoadingPhaseStartedEvent;
import com.google.devtools.build.lib.util.Clock;
import com.google.devtools.build.lib.util.io.AnsiTerminal;
import com.google.devtools.build.lib.util.io.AnsiTerminalWriter;
import com.google.devtools.build.lib.util.io.LineCountingAnsiTerminalWriter;
import com.google.devtools.build.lib.util.io.LineWrappingAnsiTerminalWriter;
import com.google.devtools.build.lib.util.io.OutErr;
import com.google.devtools.build.lib.vfs.Path;
import com.google.devtools.build.lib.view.test.TestStatus.BlazeTestStatus;

import java.io.IOException;
import java.io.OutputStream;
import java.nio.charset.StandardCharsets;
import java.util.Arrays;
import java.util.logging.Logger;

/**
 * An experimental new output stream.
 */
public class ExperimentalEventHandler extends BlazeCommandEventHandler {
  private static Logger LOG = Logger.getLogger(ExperimentalEventHandler.class.getName());
  /** Latest refresh of the progress bar, if contents other than time changed */
  static final long MAXIMAL_UPDATE_DELAY_MILLIS = 200L;
  /** Periodic update interval of a time-dependent progress bar if it can be updated in place */
  static final long SHORT_REFRESH_MILLIS = 1000L;
  /** Periodic update interval of a time-dependent progress bar if it cannot be updated in place */
  static final long LONG_REFRESH_MILLIS = 5000L;

  private final long minimalDelayMillis;
  private final boolean cursorControl;
  private final Clock clock;
  private final AnsiTerminal terminal;
  private final boolean debugAllEvents;
  private final ExperimentalStateTracker stateTracker;
  private final long minimalUpdateInterval;
  private final boolean showProgress;
  private long lastRefreshMillis;
  private long mustRefreshAfterMillis;
  private int numLinesProgressBar;
  private boolean buildComplete;
  private boolean progressBarNeedsRefresh;
  private Thread updateThread;
  private byte[] stdoutBuffer;
  private byte[] stderrBuffer;

  public final int terminalWidth;

  public ExperimentalEventHandler(
      OutErr outErr, BlazeCommandEventHandler.Options options, Clock clock) {
    super(outErr, options);
    this.cursorControl = options.useCursorControl();
    this.terminal = new AnsiTerminal(outErr.getErrorStream());
    this.terminalWidth = (options.terminalColumns > 0 ? options.terminalColumns : 80);
    this.showProgress = options.showProgress;
    this.clock = clock;
    this.debugAllEvents = options.experimentalUiDebugAllEvents;
    // If we have cursor control, we try to fit in the terminal width to avoid having
    // to wrap the progress bar. We will wrap the progress bar to terminalWidth - 1
    // characters to avoid depending on knowing whether the underlying terminal does the
    // line feed already when reaching the last character of the line, or only once an
    // additional character is written. Another column is lost for the continuation character
    // in the wrapping process.
    this.stateTracker =
        this.cursorControl
            ? new ExperimentalStateTracker(clock, this.terminalWidth - 2)
            : new ExperimentalStateTracker(clock);
    this.numLinesProgressBar = 0;
    this.minimalDelayMillis = Math.round(options.showProgressRateLimit * 1000);
    this.minimalUpdateInterval = Math.max(this.minimalDelayMillis, MAXIMAL_UPDATE_DELAY_MILLIS);
    this.stdoutBuffer = new byte[] {};
    this.stderrBuffer = new byte[] {};
    // The progress bar has not been updated yet.
    ignoreRefreshLimitOnce();
  }

  @Override
  public synchronized void handle(Event event) {
    try {
      if (debugAllEvents) {
        // Debugging only: show all events visible to the new UI.
        clearProgressBar();
        terminal.flush();
        outErr.getOutputStream().write((event + "\n").getBytes(StandardCharsets.UTF_8));
        outErr.getOutputStream().flush();
        addProgressBar();
        terminal.flush();
      } else {
        switch (event.getKind()) {
          case STDOUT:
          case STDERR:
            OutputStream stream =
                event.getKind() == EventKind.STDOUT
                    ? outErr.getOutputStream()
                    : outErr.getErrorStream();
            if (buildComplete) {
              stream.write(event.getMessageBytes());
              stream.flush();
            } else {
              byte[] message = event.getMessageBytes();
              int eolIndex = Bytes.lastIndexOf(message, (byte) '\n');
              if (eolIndex >= 0) {
                clearProgressBar();
                terminal.flush();
                stream.write(event.getKind() == EventKind.STDOUT ? stdoutBuffer : stderrBuffer);
                stream.write(Arrays.copyOf(message, eolIndex + 1));
                byte[] restMessage = Arrays.copyOfRange(message, eolIndex + 1, message.length);
                if (event.getKind() == EventKind.STDOUT) {
                  stdoutBuffer = restMessage;
                } else {
                  stderrBuffer = restMessage;
                }
                stream.flush();
                if (showProgress && cursorControl) {
                  addProgressBar();
                }
                terminal.flush();
              } else {
                if (event.getKind() == EventKind.STDOUT) {
                  stdoutBuffer = Bytes.concat(stdoutBuffer, message);
                } else {
                  stderrBuffer = Bytes.concat(stderrBuffer, message);
                }
              }
            }
            break;
          case ERROR:
          case FAIL:
          case WARNING:
          case INFO:
          case SUBCOMMAND:
            if (showProgress && !buildComplete) {
              clearProgressBar();
            }
            outErr.getOutputStream().write(stdoutBuffer);
            outErr.getOutputStream().flush();
            stdoutBuffer = new byte[] {};
            outErr.getErrorStream().write(stderrBuffer);
            outErr.getErrorStream().flush();
            stderrBuffer = new byte[] {};
            crlf();
            setEventKindColor(event.getKind());
            terminal.writeString(event.getKind() + ": ");
            terminal.resetTerminal();
            if (event.getLocation() != null) {
              terminal.writeString(event.getLocation() + ": ");
            }
            if (event.getMessage() != null) {
              terminal.writeString(event.getMessage());
            }
            crlf();
            if (showProgress && !buildComplete) {
              addProgressBar();
            }
            terminal.flush();
            break;
          case PROGRESS:
            if (stateTracker.progressBarTimeDependent()) {
              refresh();
            }
            break;
          case START:
          case FINISH:
          case PASS:
          case TIMEOUT:
          case DEPCHECKER:
            break;
        }
      }
    } catch (IOException e) {
      LOG.warning("IO Error writing to output stream: " + e);
    }
  }

  private void setEventKindColor(EventKind kind) throws IOException {
    switch (kind) {
      case ERROR:
      case FAIL:
        terminal.textRed();
        terminal.textBold();
        break;
      case WARNING:
        terminal.textMagenta();
        break;
      case INFO:
        terminal.textGreen();
        break;
      case SUBCOMMAND:
        terminal.textBlue();
        break;
      default:
        terminal.resetTerminal();
    }
  }

  @Subscribe
  public void buildStarted(BuildStartingEvent event) {
    stateTracker.buildStarted(event);
    // As a new phase started, inform immediately.
    ignoreRefreshLimitOnce();
    refresh();
  }

  @Subscribe
  public void loadingStarted(LoadingPhaseStartedEvent event) {
    stateTracker.loadingStarted(event);
    // As a new phase started, inform immediately.
    ignoreRefreshLimitOnce();
    refresh();
    startUpdateThread();
  }

  @Subscribe
  public void loadingComplete(LoadingPhaseCompleteEvent event) {
    stateTracker.loadingComplete(event);
    refresh();
  }

  @Subscribe
  public void analysisComplete(AnalysisPhaseCompleteEvent event) {
    stateTracker.analysisComplete(event);
    refresh();
  }

  @Subscribe
  public void progressReceiverAvailable(ExecutionProgressReceiverAvailableEvent event) {
    stateTracker.progressReceiverAvailable(event);
    // As this is the first time we have a progress message, update immediately.
    ignoreRefreshLimitOnce();
    startUpdateThread();
  }

  @Subscribe
  public void buildComplete(BuildCompleteEvent event) {
    stateTracker.buildComplete(event);
    ignoreRefreshLimitOnce();
    refresh();
    buildComplete = true;
    stopUpdateThread();
  }

  @Subscribe
  public void noBuild(NoBuildEvent event) {
    buildComplete = true;
    stopUpdateThread();
  }

  @Subscribe
  public void actionStarted(ActionStartedEvent event) {
    stateTracker.actionStarted(event);
    refresh();
  }

  @Subscribe
  public void actionStatusMessage(ActionStatusMessage event) {
    stateTracker.actionStatusMessage(event);
    refresh();
  }

  @Subscribe
  public void actionCompletion(ActionCompletionEvent event) {
    stateTracker.actionCompletion(event);
    refreshSoon();
  }

  @Subscribe
  public void testFilteringComplete(TestFilteringCompleteEvent event) {
    stateTracker.testFilteringComplete(event);
    refresh();
  }

  @Subscribe
  public synchronized void testSummary(TestSummary summary) {
    stateTracker.testSummary(summary);
    if (summary.getStatus() != BlazeTestStatus.PASSED) {
      // For failed test, write the failure to the scroll-back buffer immediately
      try {
        clearProgressBar();
        setEventKindColor(EventKind.ERROR);
        terminal.writeString("FAIL: ");
        terminal.resetTerminal();
        terminal.writeString(summary.getTarget().getLabel().toString());
        terminal.writeString(" (Summary)");
        crlf();
        for (Path logPath : summary.getFailedLogs()) {
          terminal.writeString("      " + logPath.getPathString());
          crlf();
        }
        if (summary.getFailedLogs().size() > 0) {
          crlf();
        }
        if (showProgress && cursorControl) {
          addProgressBar();
        }
        terminal.flush();
      } catch (IOException e) {
        LOG.warning("IO Error writing to output stream: " + e);
      }
    } else {
      refresh();
    }
  }

  private void refresh() {
    if (showProgress) {
      progressBarNeedsRefresh = true;
      doRefresh();
    }
  }

  private void doRefresh() {
    long nowMillis = clock.currentTimeMillis();
    if (lastRefreshMillis + minimalDelayMillis < nowMillis) {
      synchronized (this) {
        try {
          if (showProgress && (progressBarNeedsRefresh || timeBasedRefresh())) {
            progressBarNeedsRefresh = false;
            lastRefreshMillis = nowMillis;
            clearProgressBar();
            addProgressBar();
            terminal.flush();
          }
        } catch (IOException e) {
          LOG.warning("IO Error writing to output stream: " + e);
        }
      }
      if (!stateTracker.progressBarTimeDependent() && mustRefreshAfterMillis < lastRefreshMillis) {
        stopUpdateThread();
      }
    } else {
      // We skipped an update due to rate limiting. If this however, turned
      // out to be the last update for a long while, we need to show it in a
      // timely manner, as it best describes the current state.
      startUpdateThread();
    }
  }

  private void refreshSoon() {
    // Schedule an update of the progress bar in the near future, unless there is already
    // a future update scheduled.
    long nowMillis = clock.currentTimeMillis();
    synchronized (this) {
      if (mustRefreshAfterMillis <= lastRefreshMillis) {
        mustRefreshAfterMillis = Math.max(nowMillis + minimalUpdateInterval, lastRefreshMillis + 1);
      }
    }
    startUpdateThread();
  }

  /**
   * Decide wheter the progress bar should be redrawn only for the reason
   * that time has passed.
   */
  private synchronized boolean timeBasedRefresh() {
    if (!stateTracker.progressBarTimeDependent()) {
      return false;
    }
    long nowMillis = clock.currentTimeMillis();
    long intervalMillis = cursorControl ? SHORT_REFRESH_MILLIS : LONG_REFRESH_MILLIS;
    if (lastRefreshMillis < mustRefreshAfterMillis
        && mustRefreshAfterMillis < nowMillis + minimalDelayMillis) {
      // Within the a smal interval from now, an update is scheduled anyway,
      // so don't do a time-based update of the progress bar now, to avoid
      // updates too close to each other.
      return false;
    }
    return lastRefreshMillis + intervalMillis < nowMillis;
  }

  private void ignoreRefreshLimitOnce() {
    // Set refresh time variables in a state such that the next progress bar
    // update will definitely be written out.
    lastRefreshMillis = clock.currentTimeMillis() - minimalDelayMillis - 1;
  }

  private void startUpdateThread() {
    Thread threadToStart = null;
    synchronized (this) {
      if (updateThread == null) {
        final ExperimentalEventHandler eventHandler = this;
        updateThread =
            new Thread(
                new Runnable() {
                  @Override
                  public void run() {
                    try {
                      while (true) {
                        Thread.sleep(minimalUpdateInterval);
                        if (lastRefreshMillis < mustRefreshAfterMillis
                            && mustRefreshAfterMillis < clock.currentTimeMillis()) {
                          progressBarNeedsRefresh = true;
                        }
                        eventHandler.doRefresh();
                      }
                    } catch (InterruptedException e) {
                      // Ignore
                    }
                  }
                });
        threadToStart = updateThread;
      }
      if (threadToStart != null) {
        threadToStart.start();
      }
    }
  }

  private void stopUpdateThread() {
    Thread threadToWaitFor = null;
    synchronized (this) {
      if (updateThread != null) {
        threadToWaitFor = updateThread;
        updateThread = null;
      }
    }
    if (threadToWaitFor != null) {
      threadToWaitFor.interrupt();
      try {
        threadToWaitFor.join();
      } catch (InterruptedException e) {
        // Ignore
      }
    }
  }

  public void resetTerminal() {
    try {
      terminal.resetTerminal();
    } catch (IOException e) {
      LOG.warning("IO Error writing to user terminal: " + e);
    }
  }

  private void clearProgressBar() throws IOException {
    if (!cursorControl) {
      return;
    }
    for (int i = 0; i < numLinesProgressBar; i++) {
      terminal.cr();
      terminal.cursorUp(1);
      terminal.clearLine();
    }
    numLinesProgressBar = 0;
  }

  private void crlf() throws IOException {
    terminal.cr();
    terminal.writeString("\n");
  }

  private void addProgressBar() throws IOException {
    LineCountingAnsiTerminalWriter countingTerminalWriter =
        new LineCountingAnsiTerminalWriter(terminal);
    AnsiTerminalWriter terminalWriter = countingTerminalWriter;
    if (cursorControl) {
      terminalWriter = new LineWrappingAnsiTerminalWriter(terminalWriter, terminalWidth - 1);
    }
    stateTracker.writeProgressBar(terminalWriter, /* shortVersion=*/ !cursorControl);
    terminalWriter.newline();
    numLinesProgressBar = countingTerminalWriter.getWrittenLines();
  }
}
