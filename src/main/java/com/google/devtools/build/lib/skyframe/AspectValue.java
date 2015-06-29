// Copyright 2014 Google Inc. All rights reserved.
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

import com.google.common.base.Objects;
import com.google.devtools.build.lib.actions.Action;
import com.google.devtools.build.lib.analysis.Aspect;
import com.google.devtools.build.lib.analysis.ConfiguredAspectFactory;
import com.google.devtools.build.lib.analysis.config.BuildConfiguration;
import com.google.devtools.build.lib.syntax.Label;
import com.google.devtools.build.skyframe.SkyFunctionName;
import com.google.devtools.build.skyframe.SkyKey;

/**
 * An aspect in the context of the Skyframe graph.
 */
public final class AspectValue extends ActionLookupValue {
  /**
   * The key of an action that is generated by an aspect.
   */
  public static final class AspectKey extends ActionLookupKey {
    private final Label label;
    private final BuildConfiguration configuration;
    // TODO(bazel-team): class objects are not really hashable or comparable for equality other than
    // by reference. We should identify the aspect here in a way that does not rely on comparison
    // by reference so that keys can be serialized and deserialized properly.
    private final Class<? extends ConfiguredAspectFactory> aspectFactory;

    private AspectKey(Label label, BuildConfiguration configuration,
        Class<? extends ConfiguredAspectFactory> aspectFactory) {
      this.label = label;
      this.configuration = configuration;
      this.aspectFactory = aspectFactory;
    }

    @Override
    public Label getLabel() {
      return label;
    }

    public BuildConfiguration getConfiguration() {
      return configuration;
    }

    public Class<? extends ConfiguredAspectFactory> getAspect() {
      return aspectFactory;
    }

    @Override
    SkyFunctionName getType() {
      return SkyFunctions.ASPECT;
    }

    @Override
    public int hashCode() {
      return Objects.hashCode(label, configuration, aspectFactory);
    }

    @Override
    public boolean equals(Object other) {
      if (this == other) {
        return true;
      }

      if (!(other instanceof AspectKey)) {
        return false;
      }

      AspectKey that = (AspectKey) other;
      return Objects.equal(label, that.label)
          && Objects.equal(configuration, that.configuration)
          && Objects.equal(aspectFactory, that.aspectFactory);
    }

    @Override
    public String toString() {
      return label + "#" + aspectFactory.getSimpleName() + " "
          + (configuration == null ? "null" : configuration.checksum());
    }
  }

  private final Aspect aspect;

  public AspectValue(Aspect aspect, Iterable<Action> actions) {
    super(actions);
    this.aspect = aspect;
  }

  public Aspect get() {
    return aspect;
  }

  public static SkyKey key(Label label, BuildConfiguration configuration,
      Class<? extends ConfiguredAspectFactory> aspectFactory) {
    return new SkyKey(SkyFunctions.ASPECT, new AspectKey(label, configuration, aspectFactory));
  }
}
