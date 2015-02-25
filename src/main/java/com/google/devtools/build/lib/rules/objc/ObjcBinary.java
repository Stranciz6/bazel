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

package com.google.devtools.build.lib.rules.objc;

import static com.google.devtools.build.lib.rules.objc.ObjcProvider.IMPORTED_LIBRARY;
import static com.google.devtools.build.lib.rules.objc.ObjcProvider.LIBRARY;
import static com.google.devtools.build.lib.rules.objc.XcodeProductType.APPLICATION;

import com.google.common.annotations.VisibleForTesting;
import com.google.common.base.Optional;
import com.google.common.collect.ImmutableList;
import com.google.common.collect.Iterables;
import com.google.devtools.build.lib.actions.Artifact;
import com.google.devtools.build.lib.analysis.ConfiguredTarget;
import com.google.devtools.build.lib.analysis.RuleConfiguredTarget.Mode;
import com.google.devtools.build.lib.analysis.RuleContext;
import com.google.devtools.build.lib.collect.nestedset.NestedSetBuilder;
import com.google.devtools.build.lib.rules.RuleConfiguredTargetFactory;
import com.google.devtools.build.lib.rules.objc.ApplicationSupport.LinkedBinary;
import com.google.devtools.build.lib.rules.objc.ObjcActionsBuilder.ExtraLinkArgs;
import com.google.devtools.build.lib.rules.objc.ObjcActionsBuilder.ExtraLinkInputs;
import com.google.devtools.build.lib.rules.objc.ObjcCommon.CompilationAttributes;
import com.google.devtools.build.lib.rules.objc.ObjcCommon.ResourceAttributes;

/**
 * Implementation for the "objc_binary" rule.
 */
public class ObjcBinary implements RuleConfiguredTargetFactory {

  @VisibleForTesting
  static final String REQUIRES_AT_LEAST_ONE_LIBRARY_OR_SOURCE_FILE =
      "At least one library dependency or source file is required.";

  @Override
  public ConfiguredTarget create(RuleContext ruleContext) throws InterruptedException {
    ObjcCommon common = common(ruleContext);
    OptionsProvider optionsProvider = optionsProvider(ruleContext);

    ObjcProvider objcProvider = common.getObjcProvider();
    if (!hasLibraryOrSources(objcProvider)) {
      ruleContext.ruleError(REQUIRES_AT_LEAST_ONE_LIBRARY_OR_SOURCE_FILE);
      return null;
    }

    XcodeProvider.Builder xcodeProviderBuilder = new XcodeProvider.Builder();
    NestedSetBuilder<Artifact> filesToBuild = NestedSetBuilder.stableOrder();

    new CompilationSupport(ruleContext)
        .registerJ2ObjcCompileAndArchiveActions(optionsProvider, common.getObjcProvider())
        .registerCompileAndArchiveActions(common, optionsProvider)
        .addXcodeSettings(xcodeProviderBuilder, common, optionsProvider)
        .registerLinkActions(common.getObjcProvider(), new ExtraLinkArgs(), new ExtraLinkInputs())
        .validateAttributes();

    // TODO(bazel-team): Remove once all bundle users are migrated to ios_application.
    ApplicationSupport applicationSupport = new ApplicationSupport(
        ruleContext, common.getObjcProvider(), optionsProvider, LinkedBinary.LOCAL_AND_DEPENDENCIES)
        .registerActions()
        .addXcodeSettings(xcodeProviderBuilder)
        .addFilesToBuild(filesToBuild)
        .validateAttributes();

    new ResourceSupport(ruleContext)
        .registerActions(common.getStoryboards())
        .validateAttributes()
        .addXcodeSettings(xcodeProviderBuilder);

    XcodeSupport xcodeSupport = new XcodeSupport(ruleContext)
        // TODO(bazel-team): Use LIBRARY_STATIC as parameter instead of APPLICATION once objc_binary
        // no longer creates an application bundle
        .addXcodeSettings(xcodeProviderBuilder, common.getObjcProvider(), APPLICATION)
        .addDependencies(xcodeProviderBuilder)
        .addFilesToBuild(filesToBuild);
    XcodeProvider xcodeProvider = xcodeProviderBuilder.build();
    xcodeSupport.registerActions(xcodeProvider);

    // TODO(bazel-team): Stop exporting an XcTestAppProvider once objc_binary no longer creates an
    // application bundle.
    return common.configuredTarget(
        filesToBuild.build(),
        Optional.of(xcodeProvider),
        Optional.<ObjcProvider>absent(),
        Optional.of(applicationSupport.xcTestAppProvider()),
        Optional.<J2ObjcSrcsProvider>absent());
  }

  private OptionsProvider optionsProvider(RuleContext ruleContext) {
    return new OptionsProvider.Builder()
        .addCopts(ruleContext.getTokenizedStringListAttr("copts"))
        .addInfoplists(ruleContext.getPrerequisiteArtifacts("infoplist", Mode.TARGET).list())
        .addTransitive(Optional.fromNullable(
            ruleContext.getPrerequisite("options", Mode.TARGET, OptionsProvider.class)))
        .build();
  }

  private boolean hasLibraryOrSources(ObjcProvider objcProvider) {
    return !Iterables.isEmpty(objcProvider.get(LIBRARY)) // Includes sources from this target.
        || !Iterables.isEmpty(objcProvider.get(IMPORTED_LIBRARY));
  }

  private ObjcCommon common(RuleContext ruleContext) {
    IntermediateArtifacts intermediateArtifacts =
        ObjcRuleClasses.intermediateArtifacts(ruleContext);
    CompilationArtifacts compilationArtifacts =
        CompilationSupport.compilationArtifacts(ruleContext);

    return new ObjcCommon.Builder(ruleContext)
        .setCompilationAttributes(new CompilationAttributes(ruleContext))
        .setResourceAttributes(new ResourceAttributes(ruleContext))
        .setCompilationArtifacts(compilationArtifacts)
        .addDepObjcProviders(ruleContext.getPrerequisites("deps", Mode.TARGET, ObjcProvider.class))
        .addDepObjcProviders(
            ruleContext.getPrerequisites("bundles", Mode.TARGET, ObjcProvider.class))
        .addNonPropagatedDepObjcProviders(
            ruleContext.getPrerequisites("non_propagated_deps", Mode.TARGET, ObjcProvider.class))
        .setIntermediateArtifacts(intermediateArtifacts)
        .setAlwayslink(false)
        .addExtraImportLibraries(j2ObjcLibraries(ruleContext))
        .setLinkedBinary(intermediateArtifacts.singleArchitectureBinary())
        .build();
  }

  private Iterable<Artifact> j2ObjcLibraries(RuleContext ruleContext) {
    J2ObjcSrcsProvider j2ObjcSrcsProvider = ObjcRuleClasses.j2ObjcSrcsProvider(ruleContext);
    ImmutableList.Builder<Artifact> j2objcLibraries = ImmutableList.builder();

    // TODO(bazel-team): Refactor the code to stop flattening the nested set here.
    for (J2ObjcSource j2ObjcSource : j2ObjcSrcsProvider.getSrcs()) {
      j2objcLibraries.add(
          ObjcRuleClasses.j2objcIntermediateArtifacts(ruleContext, j2ObjcSource).archive());
    }

    return j2objcLibraries.build();
  }
}
