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

package com.google.devtools.build.lib.packages;

import com.google.common.base.Predicate;
import com.google.common.base.Verify;
import com.google.common.collect.HashMultimap;
import com.google.common.collect.ImmutableSet;
import com.google.common.collect.Iterables;
import com.google.common.collect.Multimap;
import com.google.common.collect.Sets;
import com.google.devtools.build.lib.cmdline.Label;
import com.google.devtools.build.lib.collect.nestedset.NestedSet;
import com.google.devtools.build.lib.collect.nestedset.NestedSetBuilder;
import com.google.devtools.build.lib.collect.nestedset.Order;
import com.google.devtools.build.lib.concurrent.ThreadSafety.Immutable;
import com.google.devtools.build.lib.events.Event;
import com.google.devtools.build.lib.events.Location;

import java.util.ArrayList;
import java.util.Collections;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Set;

/**
 * Model for the "environment_group' rule: the piece of Bazel's rule constraint system that binds
 * thematically related environments together and determines which environments a rule supports
 * by default. See {@link com.google.devtools.build.lib.analysis.constraints.ConstraintSemantics}
 * for precise semantic details of how this information is used.
 *
 * <p>Note that "environment_group" is implemented as a loading-time function, not a rule. This is
 * to support proper discovery of defaults: Say rule A has no explicit constraints and depends
 * on rule B, which is explicitly constrained to environment ":bar". Since A declares nothing
 * explicitly, it's implicitly constrained to DEFAULTS (whatever that is). Therefore, the
 * dependency is only allowed if DEFAULTS doesn't include environments beyond ":bar". To figure
 * that out, we need to be able to look up the environment group for ":bar", which is what this
 * class provides.
 *
 * <p>If we implemented this as a rule, we'd have to provide that lookup via rule dependencies,
 * e.g. something like:
 *
 * <code>
 *   environment(
 *       name = 'bar',
 *       group = [':sample_environments'],
 *       is_default = 1
 *   )
 * </code>
 *
 * <p>But this won't work. This would let us find the environment group for ":bar", but the only way
 * to determine what other environments belong to the group is to have the group somehow reference
 * them. That would produce circular dependencies in the build graph, which is no good.
 */
@Immutable
public class EnvironmentGroup implements Target {
  private final Label label;
  private final Location location;
  private final Package containingPackage;
  private final Set<Label> environments;
  private final Set<Label> defaults;

  /**
   * Maps a member environment to the set of environments that directly fulfill it. Note that
   * we can't populate this map until all Target instances for member environments have been
   * initialized, which may occur after group instantiation (this makes the class mutable).
   */
  private final Map<Label, NestedSet<Label>> fulfillersMap = new HashMap<>();

  /**
   * Predicate that matches labels from a different package than the initialized package.
   */
  private static final class DifferentPackage implements Predicate<Label> {
    private final Package containingPackage;

    private DifferentPackage(Package containingPackage) {
      this.containingPackage = containingPackage;
    }

    @Override
    public boolean apply(Label environment) {
      return !environment.getPackageName().equals(containingPackage.getName());
    }
  }

  /**
   * Instantiates a new group without verifying the soundness of its contents. See the validation
   * methods below for appropriate checks.
   *
   * @param label the build label identifying this group
   * @param pkg the package this group belongs to
   * @param environments the set of environments that belong to this group
   * @param defaults the environments a rule implicitly supports unless otherwise specified
   * @param location location in the BUILD file of this group
   */
  EnvironmentGroup(Label label, Package pkg, final List<Label> environments, List<Label> defaults,
      Location location) {
    this.label = label;
    this.location = location;
    this.containingPackage = pkg;
    this.environments = ImmutableSet.copyOf(environments);
    this.defaults = ImmutableSet.copyOf(defaults);
  }

  /**
   * Checks that all environments declared by this group are in the same package as the group (so
   * we can perform an environment --> environment_group lookup and know the package is available)
   * and checks that all defaults are legitimate members of the group.
   *
   * <p>Does <b>not</b> check that the referenced environments exist (see
   * {@link #processMemberEnvironments}).
   *
   * @return a list of validation errors that occurred
   */
  List<Event> validateMembership() {
    List<Event> events = new ArrayList<>();

    // All environments should belong to the same package as this group.
    for (Label environment :
        Iterables.filter(environments, new DifferentPackage(containingPackage))) {
      events.add(Event.error(location,
          environment + " is not in the same package as group " + label));
    }

    // The defaults must be a subset of the member environments.
    for (Label unknownDefault : Sets.difference(defaults, environments)) {
      events.add(Event.error(location, "default " + unknownDefault + " is not a "
          + "declared environment for group " + getLabel()));
    }

    return events;
  }

  /**
   * Checks that the group's declared environments are legitimate same-package environment
   * rules and prepares the "fulfills" relationships between these environments to support
   * {@link #getFulfillers}.
   *
   * @param pkgTargets mapping from label name to target instance for this group's package
   * @return a list of validation errors that occurred
   */
  List<Event> processMemberEnvironments(Map<String, Target> pkgTargets) {
    List<Event> events = new ArrayList<>();
    // Maps an environment to the environments that directly fulfill it.
    Multimap<Label, Label> directFulfillers = HashMultimap.create();

    for (Label envName : environments) {
      Target env = pkgTargets.get(envName.getName());
      if (isValidEnvironment(env, envName, "", events)) {
        AttributeMap attr = NonconfigurableAttributeMapper.of((Rule) env);
        for (Label fulfilledEnv : attr.get("fulfills", BuildType.LABEL_LIST)) {
          if (isValidEnvironment(pkgTargets.get(fulfilledEnv.getName()), fulfilledEnv,
              "in \"fulfills\" attribute of " + envName + ": ", events)) {
            directFulfillers.put(fulfilledEnv, envName);
          }
        }
      }
    }

    // Now that we know which environments directly fulfill each other, compute which environments
    // transitively fulfill each other. We could alternatively compute this on-demand, but since
    // we don't expect these chains to be very large we opt toward computing them once at package
    // load time.
    Verify.verify(fulfillersMap.isEmpty());
    for (Label envName : environments) {
      setTransitiveFulfillers(envName, directFulfillers, fulfillersMap);
    }

    return events;
  }

  /**
   * Given an environment and set of environments that directly fulfill it, computes a nested
   * set of environments that <i>transitively</i> fulfill it, places it into transitiveFulfillers,
   * and returns that set.
   */
  private static NestedSet<Label> setTransitiveFulfillers(Label env,
      Multimap<Label, Label> directFulfillers, Map<Label, NestedSet<Label>> transitiveFulfillers) {
    if (transitiveFulfillers.containsKey(env)) {
      return transitiveFulfillers.get(env);
    } else if (!directFulfillers.containsKey(env)) {
      // Nobody fulfills this environment.
      NestedSet<Label> emptySet = NestedSetBuilder.emptySet(Order.STABLE_ORDER);
      transitiveFulfillers.put(env, emptySet);
      return emptySet;
    } else {
      NestedSetBuilder<Label> set = NestedSetBuilder.stableOrder();
      for (Label fulfillingEnv : directFulfillers.get(env)) {
        set.add(fulfillingEnv);
        set.addTransitive(
            setTransitiveFulfillers(fulfillingEnv, directFulfillers, transitiveFulfillers));
      }
      NestedSet<Label> builtSet = set.build();
      transitiveFulfillers.put(env, builtSet);
      return builtSet;
    }
  }

  private boolean isValidEnvironment(Target env, Label envName, String prefix, List<Event> events) {
    if (env == null) {
      events.add(Event.error(location, prefix + "environment " + envName + " does not exist"));
      return false;
    } else if (!env.getTargetKind().equals("environment rule")) {
      events.add(Event.error(location, prefix + env.getLabel() + " is not a valid environment"));
      return false;
    } else if (!environments.contains(env.getLabel())) {
      events.add(Event.error(location, prefix + env.getLabel() + " is not a member of this group"));
      return false;
    }
    return true;
  }

  /**
   * Returns the environments that belong to this group.
   */
  public Set<Label> getEnvironments() {
    return environments;
  }

  /**
   * Returns the environments a rule supports by default, i.e. if it has no explicit references to
   * environments in this group.
   */
  public Set<Label> getDefaults() {
    return defaults;
  }

  /**
   * Determines whether or not an environment is a default. Returns false if the environment
   * doesn't belong to this group.
   */
  public boolean isDefault(Label environment) {
    return defaults.contains(environment);
  }

  /**
   * Returns the set of environments that transitively fulfill the specified environment.
   * The environment must be a valid member of this group.
   *
   * <p>>For example, if the input is <code>":foo"</code> and <code>":bar"</code> fulfills
   * <code>":foo"</code> and <code>":baz"</code> fulfills <code>":bar"</code>, this returns
   * <code>[":foo", ":bar", ":baz"]</code>.
   *
   * <p>If no environments fulfill the input, returns an empty set.
   */
  public Iterable<Label> getFulfillers(Label environment) {
    return Verify.verifyNotNull(fulfillersMap.get(environment));
  }

  @Override
  public Label getLabel() {
    return label;
  }

  @Override
  public String getName() {
    return label.getName();
  }

  @Override
  public Package getPackage() {
    return containingPackage;
  }

  @Override
  public String getTargetKind() {
    return targetKind();
  }

  @Override
  public Rule getAssociatedRule() {
    return null;
  }

  @Override
  public License getLicense() {
    return License.NO_LICENSE;
  }

  @Override
  public Location getLocation() {
    return location;
  }

  @Override
  public String toString() {
   return targetKind() + " " + getLabel();
  }

  @Override
  public Set<License.DistributionType> getDistributions() {
    return Collections.emptySet();
  }

  @Override
  public RuleVisibility getVisibility() {
    return ConstantRuleVisibility.PRIVATE; // No rule should be referencing an environment_group.
  }

  public static String targetKind() {
    return "environment group";
  }
}
