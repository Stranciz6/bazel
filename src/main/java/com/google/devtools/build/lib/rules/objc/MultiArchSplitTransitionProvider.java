// Copyright 2016 The Bazel Authors. All rights reserved.
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

package com.google.devtools.build.lib.rules.objc;

import static com.google.devtools.build.lib.syntax.Type.STRING;

import com.google.common.annotations.VisibleForTesting;
import com.google.common.base.Optional;
import com.google.common.base.Strings;
import com.google.common.collect.ImmutableList;
import com.google.common.collect.ImmutableSet;
import com.google.devtools.build.lib.analysis.RuleContext;
import com.google.devtools.build.lib.analysis.config.BuildConfiguration.Options;
import com.google.devtools.build.lib.analysis.config.BuildOptions;
import com.google.devtools.build.lib.packages.Attribute.SplitTransition;
import com.google.devtools.build.lib.packages.Attribute.SplitTransitionProvider;
import com.google.devtools.build.lib.packages.NonconfigurableAttributeMapper;
import com.google.devtools.build.lib.packages.Rule;
import com.google.devtools.build.lib.packages.RuleClass.ConfiguredTargetFactory.RuleErrorException;
import com.google.devtools.build.lib.rules.apple.AppleCommandLineOptions;
import com.google.devtools.build.lib.rules.apple.AppleConfiguration;
import com.google.devtools.build.lib.rules.apple.AppleConfiguration.ConfigurationDistinguisher;
import com.google.devtools.build.lib.rules.apple.DottedVersion;
import com.google.devtools.build.lib.rules.apple.Platform;
import com.google.devtools.build.lib.rules.apple.Platform.PlatformType;
import com.google.devtools.build.lib.rules.objc.ObjcRuleClasses.PlatformRule;
import java.util.List;

/**
 * {@link SplitTransitionProvider} implementation for multi-architecture apple rules which can
 * accept different apple platform types (such as ios or watchos).
 */
public class MultiArchSplitTransitionProvider implements SplitTransitionProvider {

  @VisibleForTesting
  static final String UNSUPPORTED_PLATFORM_TYPE_ERROR_FORMAT =
      "Unsupported platform type \"%s\"";
  
  @VisibleForTesting
  static final String INVALID_VERSION_STRING_ERROR_FORMAT =
      "Invalid version string \"%s\". Version must be of the form 'x.y' without alphabetic "
          + "characters, such as '4.3'.";

  private static final ImmutableSet<PlatformType> SUPPORTED_PLATFORM_TYPES =
      ImmutableSet.of(
          PlatformType.IOS, PlatformType.WATCHOS, PlatformType.TVOS, PlatformType.MACOS);

  /**
   * Returns the apple platform type in the current rule context.
   *
   * @throws RuleErrorException if the platform type attribute in the current rulecontext is
   *     an invalid value
   */
  public static PlatformType getPlatformType(RuleContext ruleContext) throws RuleErrorException {
    String attributeValue =
        ruleContext.attributes().get(PlatformRule.PLATFORM_TYPE_ATTR_NAME, STRING);
    try {
      return getPlatformType(attributeValue);
    } catch (IllegalArgumentException exception) {
      throw ruleContext.throwWithAttributeError(
          PlatformRule.PLATFORM_TYPE_ATTR_NAME,
          String.format(UNSUPPORTED_PLATFORM_TYPE_ERROR_FORMAT, attributeValue));
    }
  }

  /**
   * Validates that minimum OS was set to a valid value on the current rule.
    
   * @throws RuleErrorException if the platform type attribute in the current rulecontext is
   *     an invalid value
   */
  public static void validateMinimumOs(RuleContext ruleContext) throws RuleErrorException {
    String attributeValue = ruleContext.attributes().get(PlatformRule.MINIMUM_OS_VERSION, STRING);
    // TODO(b/37096178): This should be a mandatory attribute.
    if (!Strings.isNullOrEmpty(attributeValue)) {
      try {
        DottedVersion minimumOsVersion = DottedVersion.fromString(attributeValue);
        if (minimumOsVersion.hasAlphabeticCharacters() || minimumOsVersion.numComponents() > 2) {
          throw ruleContext.throwWithAttributeError(
              PlatformRule.MINIMUM_OS_VERSION,
              String.format(INVALID_VERSION_STRING_ERROR_FORMAT, attributeValue));
        }
      } catch (IllegalArgumentException exception) {
        throw ruleContext.throwWithAttributeError(
            PlatformRule.MINIMUM_OS_VERSION,
            String.format(INVALID_VERSION_STRING_ERROR_FORMAT, attributeValue));
      }
    }
  }

  /**
   * Returns the apple platform type for the given platform type string (corresponding directly
   * with platform type attribute value).
   * 
   * @throws IllegalArgumentException if the given platform type string is not a valid type
   */
  public static PlatformType getPlatformType(String platformTypeString) {
    PlatformType platformType = PlatformType.fromString(platformTypeString);

    if (!SUPPORTED_PLATFORM_TYPES.contains(platformType)) {
      throw new IllegalArgumentException(
          String.format(UNSUPPORTED_PLATFORM_TYPE_ERROR_FORMAT, platformTypeString));
    } else {
      return platformType;
    }
  }

  @Override
  public SplitTransition<?> apply(Rule fromRule) {
    NonconfigurableAttributeMapper attrMapper = NonconfigurableAttributeMapper.of(fromRule);
    String platformTypeString = attrMapper.get(PlatformRule.PLATFORM_TYPE_ATTR_NAME, STRING);
    String minimumOsVersionString = attrMapper.get(PlatformRule.MINIMUM_OS_VERSION, STRING);
    PlatformType platformType;
    Optional<DottedVersion> minimumOsVersion;
    try {
      platformType = getPlatformType(platformTypeString);
      // TODO(b/37096178): This should be a mandatory attribute.
      if (Strings.isNullOrEmpty(minimumOsVersionString)) {
        minimumOsVersion = Optional.absent();
      } else {
        minimumOsVersion = Optional.of(DottedVersion.fromString(minimumOsVersionString));
      }
    } catch (IllegalArgumentException exception) {
      // There's no opportunity to propagate exception information up cleanly at the transition
      // provider level. This should later be registered as a rule error during the initialization
      // of the rule.
      platformType = PlatformType.IOS;
      minimumOsVersion = Optional.absent();
    }

    return new AppleBinaryTransition(platformType, minimumOsVersion);
  }

  /**
   * Transition that results in one configured target per architecture specified in the
   * platform-specific cpu flag for a particular platform type (for example, --watchos_cpus
   * for watchos platform type).
   */
  protected static class AppleBinaryTransition implements SplitTransition<BuildOptions> {

    private final PlatformType platformType;
    // TODO(b/37096178): This should be a mandatory attribute.
    private final Optional<DottedVersion> minimumOsVersion;

    public AppleBinaryTransition(PlatformType platformType,
        Optional<DottedVersion> minimumOsVersion) {
      this.platformType = platformType;
      this.minimumOsVersion = minimumOsVersion;
    }

    @Override
    public final List<BuildOptions> split(BuildOptions buildOptions) {
      List<String> cpus;
      DottedVersion actualMinimumOsVersion;
      ConfigurationDistinguisher configurationDistinguisher;
      switch (platformType) {
        case IOS:
          cpus = buildOptions.get(AppleCommandLineOptions.class).iosMultiCpus;
          if (cpus.isEmpty()) {
            cpus =
                ImmutableList.of(
                    AppleConfiguration.iosCpuFromCpu(buildOptions.get(Options.class).cpu));
          }
          configurationDistinguisher = ConfigurationDistinguisher.APPLEBIN_IOS;
          actualMinimumOsVersion =
              minimumOsVersion.isPresent()
                  ? minimumOsVersion.get()
                  : buildOptions.get(AppleCommandLineOptions.class).iosMinimumOs;
          break;
        case WATCHOS:
          cpus = buildOptions.get(AppleCommandLineOptions.class).watchosCpus;
          if (cpus.isEmpty()) {
            cpus = ImmutableList.of(AppleCommandLineOptions.DEFAULT_WATCHOS_CPU);
          }
          configurationDistinguisher = ConfigurationDistinguisher.APPLEBIN_WATCHOS;
          actualMinimumOsVersion = minimumOsVersion.isPresent() ? minimumOsVersion.get()
              : buildOptions.get(AppleCommandLineOptions.class).watchosMinimumOs;
          break;
        case TVOS:
          cpus = buildOptions.get(AppleCommandLineOptions.class).tvosCpus;
          if (cpus.isEmpty()) {
            cpus = ImmutableList.of(AppleCommandLineOptions.DEFAULT_TVOS_CPU);
          }
          configurationDistinguisher = ConfigurationDistinguisher.APPLEBIN_TVOS;
          actualMinimumOsVersion = minimumOsVersion.isPresent() ? minimumOsVersion.get()
              : buildOptions.get(AppleCommandLineOptions.class).tvosMinimumOs;
          break;
        case MACOS:
          cpus = buildOptions.get(AppleCommandLineOptions.class).macosCpus;
          if (cpus.isEmpty()) {
            cpus = ImmutableList.of(AppleCommandLineOptions.DEFAULT_MACOS_CPU);
          }
          configurationDistinguisher = ConfigurationDistinguisher.APPLEBIN_MACOS;
          actualMinimumOsVersion = minimumOsVersion.isPresent() ? minimumOsVersion.get()
              : buildOptions.get(AppleCommandLineOptions.class).macosMinimumOs;
          break;
        default:
          throw new IllegalArgumentException("Unsupported platform type " + platformType);
      }

      ImmutableList.Builder<BuildOptions> splitBuildOptions = ImmutableList.builder();
      for (String cpu : cpus) {
        BuildOptions splitOptions = buildOptions.clone();

        AppleCommandLineOptions appleCommandLineOptions =
            splitOptions.get(AppleCommandLineOptions.class);

        appleCommandLineOptions.applePlatformType = platformType;
        appleCommandLineOptions.appleSplitCpu = cpu;
        // If the new configuration does not use the apple crosstool, then it needs ios_cpu to be
        // to decide architecture.
        // TODO(b/29355778, b/28403953): Use a crosstool for any apple rule. Deprecate ios_cpu.
        appleCommandLineOptions.iosCpu = cpu;
  
        if (splitOptions.get(ObjcCommandLineOptions.class).enableCcDeps) {
          // Only set the (CC-compilation) CPU for dependencies if explicitly required by the user.
          // This helps users of the iOS rules who do not depend on CC rules as these CPU values
          // require additional flags to work (e.g. a custom crosstool) which now only need to be
          // set if this feature is explicitly requested.
          String platformCpu = Platform.cpuStringForTarget(platformType, cpu);
          AppleCrosstoolTransition.setAppleCrosstoolTransitionConfiguration(buildOptions,
              splitOptions, platformCpu);
        }
        switch (platformType) {
          case IOS:
            appleCommandLineOptions.iosMinimumOs = actualMinimumOsVersion;
            break;
          case WATCHOS:
            appleCommandLineOptions.watchosMinimumOs = actualMinimumOsVersion;
            break;
          case TVOS:
            appleCommandLineOptions.tvosMinimumOs = actualMinimumOsVersion;
            break;
          case MACOS:
            appleCommandLineOptions.macosMinimumOs = actualMinimumOsVersion;
            break;
        }

        appleCommandLineOptions.configurationDistinguisher = configurationDistinguisher;
        splitBuildOptions.add(splitOptions);
      }
      return splitBuildOptions.build();
    }

    @Override
    public boolean defaultsToSelf() {
      return true;
    }
  }
}
