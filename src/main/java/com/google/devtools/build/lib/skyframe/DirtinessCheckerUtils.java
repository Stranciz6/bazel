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
package com.google.devtools.build.lib.skyframe;

import static com.google.devtools.build.lib.skyframe.SkyFunctions.DIRECTORY_LISTING_STATE;
import static com.google.devtools.build.lib.skyframe.SkyFunctions.FILE_STATE;

import com.google.common.base.Preconditions;
import com.google.common.collect.ImmutableList;
import com.google.devtools.build.lib.util.io.TimestampGranularityMonitor;
import com.google.devtools.build.lib.vfs.Path;
import com.google.devtools.build.lib.vfs.RootedPath;
import com.google.devtools.build.skyframe.SkyKey;
import com.google.devtools.build.skyframe.SkyValue;

import java.io.IOException;
import java.util.Set;

import javax.annotation.Nullable;

/** Utilities for checking dirtiness of keys (mainly filesystem keys) in the graph. */
class DirtinessCheckerUtils {
  private DirtinessCheckerUtils() {}

  static class FileDirtinessChecker extends SkyValueDirtinessChecker {
    @Override
    public boolean applies(SkyKey skyKey) {
      return skyKey.functionName().equals(FILE_STATE);
    }

    @Override
    @Nullable
    public SkyValue createNewValue(SkyKey key, TimestampGranularityMonitor tsgm) {
      RootedPath rootedPath = (RootedPath) key.argument();
      try {
        return FileStateValue.create(rootedPath, tsgm);
      } catch (InconsistentFilesystemException | IOException e) {
        // TODO(bazel-team): An IOException indicates a failure to get a file digest or a symlink
        // target, not a missing file. Such a failure really shouldn't happen, so failing early
        // may be better here.
        return null;
      }
    }
  }

  static class DirectoryDirtinessChecker extends SkyValueDirtinessChecker {
    @Override
    public boolean applies(SkyKey skyKey) {
      return skyKey.functionName().equals(DIRECTORY_LISTING_STATE);
    }

    @Override
    @Nullable
    public SkyValue createNewValue(SkyKey key, TimestampGranularityMonitor tsgm) {
      RootedPath rootedPath = (RootedPath) key.argument();
      try {
        return DirectoryListingStateValue.create(rootedPath);
      } catch (IOException e) {
        return null;
      }
    }
  }

  static class BasicFilesystemDirtinessChecker extends SkyValueDirtinessChecker {
    private final FileDirtinessChecker fdc = new FileDirtinessChecker();
    private final DirectoryDirtinessChecker ddc = new DirectoryDirtinessChecker();
    private final UnionDirtinessChecker checker =
        new UnionDirtinessChecker(ImmutableList.of(fdc, ddc));

    @Override
    public boolean applies(SkyKey skyKey) {
      return fdc.applies(skyKey) || ddc.applies(skyKey);
    }

    @Override
    @Nullable
    public SkyValue createNewValue(SkyKey key, TimestampGranularityMonitor tsgm) {
      return checker.createNewValue(key, tsgm);
    }
  }

  static final class MissingDiffDirtinessChecker extends BasicFilesystemDirtinessChecker {
    private final Set<Path> missingDiffPaths;

    MissingDiffDirtinessChecker(final Set<Path> missingDiffPaths) {
      this.missingDiffPaths = missingDiffPaths;
    }

    @Override
    public boolean applies(SkyKey key) {
      return super.applies(key)
          && missingDiffPaths.contains(((RootedPath) key.argument()).getRoot());
    }
  }

  /** {@link SkyValueDirtinessChecker} that encompasses a union of other dirtiness checkers. */
  static final class UnionDirtinessChecker extends SkyValueDirtinessChecker {
    private final Iterable<SkyValueDirtinessChecker> dirtinessCheckers;

    UnionDirtinessChecker(Iterable<SkyValueDirtinessChecker> dirtinessCheckers) {
      this.dirtinessCheckers = dirtinessCheckers;
    }

    @Nullable
    private SkyValueDirtinessChecker getChecker(SkyKey key) {
      for (SkyValueDirtinessChecker dirtinessChecker : dirtinessCheckers) {
        if (dirtinessChecker.applies(key)) {
          return dirtinessChecker;
        }
      }
      return null;
    }

    @Override
    public boolean applies(SkyKey key) {
      return getChecker(key) != null;
    }

    @Override
    @Nullable
    public SkyValue createNewValue(SkyKey key, TimestampGranularityMonitor tsgm) {
      return Preconditions.checkNotNull(getChecker(key), key).createNewValue(key, tsgm);
    }

    @Override
    @Nullable
    public DirtyResult check(SkyKey key, @Nullable SkyValue oldValue,
        TimestampGranularityMonitor tsgm) {
      return Preconditions.checkNotNull(getChecker(key), key).check(key, oldValue, tsgm);
    }
  }
}
