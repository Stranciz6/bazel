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

import com.google.common.base.Preconditions;
import com.google.devtools.build.lib.analysis.config.BuildConfiguration;
import com.google.devtools.build.lib.analysis.config.BuildOptions;
import com.google.devtools.build.lib.concurrent.ThreadSafety.ThreadSafe;
import com.google.devtools.build.skyframe.SkyKey;
import com.google.devtools.build.skyframe.SkyValue;

import java.io.Serializable;
import java.util.Objects;
import java.util.Set;

/**
 * A Skyframe value representing a {@link BuildConfiguration}.
 */
// TODO(bazel-team): mark this immutable when BuildConfiguration is immutable.
// @Immutable
@ThreadSafe
public class BuildConfigurationValue implements SkyValue {

  private final BuildConfiguration configuration;

  BuildConfigurationValue(BuildConfiguration configuration) {
    this.configuration = configuration;
  }

  public BuildConfiguration getConfiguration() {
    return configuration;
  }

  /**
   * Returns the key for a requested configuration.
   *
   * @param fragments the fragments the configuration should contain
   * @param buildOptions the build options the fragments should be built from
   */
  @ThreadSafe
  public static SkyKey key(Set<Class<? extends BuildConfiguration.Fragment>> fragments,
      BuildOptions buildOptions) {
    return new SkyKey(SkyFunctions.BUILD_CONFIGURATION,
        new Key(fragments, buildOptions, true));
  }

  /**
   * Returns the key for a requested action-disabled configuration (actions generated by rules
   * under the configuration are ignored).
   *
   * @param fragments the fragments the configuration should contain
   * @param buildOptions the build options the fragments should be built from
   */
  @ThreadSafe
  public static SkyKey disabledActionsKey(
      Set<Class<? extends BuildConfiguration.Fragment>> fragments,
      BuildOptions buildOptions) {
    return new SkyKey(SkyFunctions.BUILD_CONFIGURATION,
        new Key(fragments, buildOptions, false));
  }

  static final class Key implements Serializable {
    private final Set<Class<? extends BuildConfiguration.Fragment>> fragments;
    private final BuildOptions buildOptions;
    private final boolean enableActions;

    Key(Set<Class<? extends BuildConfiguration.Fragment>> fragments,
        BuildOptions buildOptions, boolean enableActions) {
      this.fragments = fragments;
      this.buildOptions = Preconditions.checkNotNull(buildOptions);
      this.enableActions = enableActions;
    }

    Set<Class<? extends BuildConfiguration.Fragment>> getFragments() {
      return fragments;
    }

    BuildOptions getBuildOptions() {
      return buildOptions;
    }

    boolean actionsEnabled() {
      return enableActions;
    }

    @Override
    public boolean equals(Object o) {
      if (!(o instanceof Key)) {
        return false;
      }
      Key otherConfig = (Key) o;
      return Objects.equals(fragments, otherConfig.fragments)
          && Objects.equals(buildOptions, otherConfig.buildOptions)
          && otherConfig.actionsEnabled() == enableActions;
    }

    @Override
    public int hashCode() {
      return Objects.hash(fragments, buildOptions, enableActions);
    }
  }
}
