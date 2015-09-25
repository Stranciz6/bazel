// Copyright 2014 The Bazel Authors. All rights reserved.
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
import com.google.common.collect.ImmutableList;
import com.google.common.collect.ImmutableSet;
import com.google.devtools.build.lib.cmdline.Label;
import com.google.devtools.build.lib.concurrent.ThreadSafety.Immutable;
import com.google.devtools.build.lib.concurrent.ThreadSafety.ThreadSafe;
import com.google.devtools.build.lib.packages.NoSuchTargetException;
import com.google.devtools.build.lib.packages.Rule;
import com.google.devtools.build.lib.packages.Target;
import com.google.devtools.build.lib.util.StringCanonicalizer;
import com.google.devtools.build.skyframe.SkyKey;
import com.google.devtools.build.skyframe.SkyValue;

import java.util.Collection;
import java.util.Objects;
import java.util.Set;

import javax.annotation.Nullable;

/**
 * A <i>transitive</i> target reference that, when built in skyframe, loads the entire
 * transitive closure of a target. Contains no information about the targets traversed.
 */
@Immutable
@ThreadSafe
public class TransitiveTraversalValue implements SkyValue {

  @Nullable
  private final NoSuchTargetException errorLoadingTarget;
  @Nullable
  private final ImmutableSet<String> providers;

  private TransitiveTraversalValue(@Nullable Iterable<String> providers,
      @Nullable NoSuchTargetException errorLoadingTarget) {
    this.errorLoadingTarget = errorLoadingTarget;
    this.providers = (providers == null) ? null : canonicalSet(providers);
  }

  public static TransitiveTraversalValue unsuccessfulTransitiveTraversal(
      NoSuchTargetException errorLoadingTarget) {
    return new TransitiveTraversalValue(null, Preconditions.checkNotNull(errorLoadingTarget));
  }

  public static TransitiveTraversalValue forTarget(Target target) {
    if (target instanceof Rule) {
      Rule rule = (Rule) target;
      return new TransitiveTraversalValue(
          toStringSet(rule.getRuleClassObject().getAdvertisedProviders()), null);
    }
    return new TransitiveTraversalValue(ImmutableList.<String>of(), null);
  }

  public static TransitiveTraversalValue withProviders(Collection<String> vals) {
    return new TransitiveTraversalValue(ImmutableSet.copyOf(vals), null);
  }

  private static ImmutableSet<String> canonicalSet(Iterable<String> strIterable) {
    ImmutableSet.Builder<String> builder = new ImmutableSet.Builder<>();
    for (String str : strIterable) {
      builder.add(StringCanonicalizer.intern(str));
    }
    return builder.build();
  }

  private static ImmutableSet<String> toStringSet(Iterable<Class<?>> providers) {
    ImmutableSet.Builder<String> pBuilder = new ImmutableSet.Builder<>();
    if (providers != null) {
      for (Class<?> clazz : providers) {
        pBuilder.add(StringCanonicalizer.intern(clazz.getName()));
      }
    }
    return pBuilder.build();
  }

  public Set<String> getProviders() {
    return providers;
  }

  /** Returns the error, if any, from loading the target. */
  @Nullable
  public NoSuchTargetException getErrorLoadingTarget() {
    return errorLoadingTarget;
  }

  @Override
  public boolean equals(Object o) {
    if (this == o) {
      return true;
    }
    if (!(o instanceof TransitiveTraversalValue)) {
      return false;
    }
    TransitiveTraversalValue that = (TransitiveTraversalValue) o;
    return Objects.equals(this.errorLoadingTarget, that.errorLoadingTarget)
        && Objects.equals(this.providers, that.providers);
  }

  @Override
  public int hashCode() {
    return 31 * Objects.hashCode(errorLoadingTarget) + Objects.hashCode(providers);
  }

  @ThreadSafe
  public static SkyKey key(Label label) {
    return new SkyKey(SkyFunctions.TRANSITIVE_TRAVERSAL, label);
  }
}
