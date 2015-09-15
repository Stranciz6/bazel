// Copyright 2015 Google Inc. All rights reserved.
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
package com.google.devtools.build.lib.sandbox;

import com.google.common.base.Preconditions;
import com.google.common.collect.ImmutableList;
import com.google.common.eventbus.Subscribe;
import com.google.devtools.build.lib.actions.ActionContextConsumer;
import com.google.devtools.build.lib.actions.ActionContextProvider;
import com.google.devtools.build.lib.buildtool.BuildRequest;
import com.google.devtools.build.lib.buildtool.buildevent.BuildStartingEvent;
import com.google.devtools.build.lib.events.Event;
import com.google.devtools.build.lib.runtime.BlazeModule;
import com.google.devtools.build.lib.runtime.BlazeRuntime;
import com.google.devtools.build.lib.runtime.Command;
import com.google.devtools.build.lib.runtime.CommandEnvironment;
import com.google.devtools.build.lib.util.OS;
import com.google.devtools.common.options.OptionsBase;

import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;
import java.util.concurrent.TimeUnit;

/**
 * This module provides the Sandbox spawn strategy.
 */
public class SandboxModule extends BlazeModule {
  private final ExecutorService backgroundWorkers = Executors.newCachedThreadPool();
  private BuildRequest buildRequest;
  private CommandEnvironment env;
  private BlazeRuntime runtime;
  private Boolean sandboxingSupported = null;

  public static final String SANDBOX_NOT_SUPPORTED_MESSAGE =
      "Sandboxed execution is not supported on your system and thus hermeticity of actions cannot "
          + "be guaranteed. See http://bazel.io/docs/bazel-user-manual.html#sandboxing for more "
          + "information. You can turn off this warning via --ignore_unsupported_sandboxing";

  @Override
  public Iterable<ActionContextProvider> getActionContextProviders() {
    Preconditions.checkNotNull(buildRequest);
    Preconditions.checkNotNull(env);

    // Cache
    if (sandboxingSupported == null) {
      sandboxingSupported = NamespaceSandboxRunner.isSupported(runtime);
    }

    if (sandboxingSupported) {
      return ImmutableList.<ActionContextProvider>of(
          new SandboxActionContextProvider(runtime, buildRequest, backgroundWorkers));
    }

    // For now, sandboxing is only supported on Linux and there's not much point in showing a scary
    // warning to the user if they can't do anything about it.
    if (!buildRequest.getOptions(SandboxOptions.class).ignoreUnsupportedSandboxing
        && OS.getCurrent() == OS.LINUX) {
      env.getReporter().handle(Event.warn(SANDBOX_NOT_SUPPORTED_MESSAGE));
    }

    return ImmutableList.of();
  }

  @Override
  public Iterable<ActionContextConsumer> getActionContextConsumers() {
    Preconditions.checkNotNull(env);

    if (sandboxingSupported == null) {
      sandboxingSupported = NamespaceSandboxRunner.isSupported(runtime);
    }

    if (sandboxingSupported) {
      return ImmutableList.<ActionContextConsumer>of(new SandboxActionContextConsumer());
    }

    return ImmutableList.of();
  }

  @Override
  public Iterable<Class<? extends OptionsBase>> getCommandOptions(Command command) {
    return command.builds()
        ? ImmutableList.<Class<? extends OptionsBase>>of(SandboxOptions.class)
        : ImmutableList.<Class<? extends OptionsBase>>of();
  }

  @Override
  public void beforeCommand(Command command, CommandEnvironment env) {
    this.env = env;
    this.runtime = env.getRuntime();
    env.getEventBus().register(this);
  }

  @Subscribe
  public void buildStarting(BuildStartingEvent event) {
    buildRequest = event.getRequest();
  }

  /**
   * Shut down the background worker pool in the canonical way.
   *
   * <p>See https://docs.oracle.com/javase/8/docs/api/java/util/concurrent/ExecutorService.html
   */
  @Override
  public void blazeShutdown() {
    // Disable new tasks from being submitted
    backgroundWorkers.shutdown();

    try {
      // Wait a while for existing tasks to terminate
      if (!backgroundWorkers.awaitTermination(5, TimeUnit.SECONDS)) {
        backgroundWorkers.shutdownNow(); // Cancel currently executing tasks

        // Wait a while for tasks to respond to being cancelled and force-kill them if necessary
        // after the timeout.
        backgroundWorkers.awaitTermination(5, TimeUnit.SECONDS);
      }
    } catch (InterruptedException ie) {
      // (Re-)Cancel if current thread also interrupted
      backgroundWorkers.shutdownNow();

      // Preserve interrupt status
      Thread.currentThread().interrupt();
    }
  }
}
