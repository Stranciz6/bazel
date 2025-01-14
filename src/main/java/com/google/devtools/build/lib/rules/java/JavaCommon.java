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
package com.google.devtools.build.lib.rules.java;

import static com.google.common.collect.ImmutableList.toImmutableList;

import com.google.common.collect.ImmutableList;
import com.google.common.collect.ImmutableList.Builder;
import com.google.common.collect.ImmutableMap;
import com.google.common.collect.Iterables;
import com.google.common.collect.Streams;
import com.google.devtools.build.lib.actions.ActionAnalysisMetadata;
import com.google.devtools.build.lib.actions.Artifact;
import com.google.devtools.build.lib.analysis.AnalysisEnvironment;
import com.google.devtools.build.lib.analysis.AnalysisUtils;
import com.google.devtools.build.lib.analysis.OutputGroupProvider;
import com.google.devtools.build.lib.analysis.PrerequisiteArtifacts;
import com.google.devtools.build.lib.analysis.RuleConfiguredTarget.Mode;
import com.google.devtools.build.lib.analysis.RuleConfiguredTargetBuilder;
import com.google.devtools.build.lib.analysis.RuleContext;
import com.google.devtools.build.lib.analysis.Runfiles;
import com.google.devtools.build.lib.analysis.RunfilesProvider;
import com.google.devtools.build.lib.analysis.TransitiveInfoCollection;
import com.google.devtools.build.lib.analysis.TransitiveInfoProvider;
import com.google.devtools.build.lib.analysis.Util;
import com.google.devtools.build.lib.cmdline.Label;
import com.google.devtools.build.lib.collect.nestedset.NestedSet;
import com.google.devtools.build.lib.collect.nestedset.NestedSetBuilder;
import com.google.devtools.build.lib.collect.nestedset.Order;
import com.google.devtools.build.lib.packages.BuildType;
import com.google.devtools.build.lib.packages.ClassObjectConstructor;
import com.google.devtools.build.lib.packages.SkylarkClassObject;
import com.google.devtools.build.lib.packages.Target;
import com.google.devtools.build.lib.packages.TargetUtils;
import com.google.devtools.build.lib.rules.cpp.CppCompilationContext;
import com.google.devtools.build.lib.rules.cpp.LinkerInput;
import com.google.devtools.build.lib.rules.java.JavaCompilationArgs.ClasspathType;
import com.google.devtools.build.lib.rules.test.InstrumentedFilesCollector;
import com.google.devtools.build.lib.rules.test.InstrumentedFilesCollector.InstrumentationSpec;
import com.google.devtools.build.lib.rules.test.InstrumentedFilesCollector.LocalMetadataCollector;
import com.google.devtools.build.lib.rules.test.InstrumentedFilesProvider;
import com.google.devtools.build.lib.syntax.Type;
import com.google.devtools.build.lib.util.FileTypeSet;
import com.google.devtools.build.lib.util.Pair;
import com.google.devtools.build.lib.util.Preconditions;
import com.google.devtools.build.lib.vfs.FileSystemUtils;
import com.google.devtools.build.lib.vfs.PathFragment;
import java.util.ArrayList;
import java.util.Collection;
import java.util.HashSet;
import java.util.LinkedHashSet;
import java.util.List;
import java.util.Set;
import javax.annotation.Nullable;

/**
 * A helper class to create configured targets for Java rules.
 */
public class JavaCommon {
  public static final InstrumentationSpec JAVA_COLLECTION_SPEC = new InstrumentationSpec(
      FileTypeSet.of(JavaSemantics.JAVA_SOURCE))
      .withSourceAttributes("srcs")
      .withDependencyAttributes("deps", "data", "exports", "runtime_deps");

  /** Collects all metadata files generated by Java compilation actions. */
  private static final LocalMetadataCollector JAVA_METADATA_COLLECTOR =
      new LocalMetadataCollector() {
        @Override
        public void collectMetadataArtifacts(
            Iterable<Artifact> objectFiles,
            AnalysisEnvironment analysisEnvironment,
            NestedSetBuilder<Artifact> metadataFilesBuilder) {
          for (Artifact artifact : objectFiles) {
            ActionAnalysisMetadata action = analysisEnvironment.getLocalGeneratingAction(artifact);
            if (action instanceof JavaCompileAction) {
              addOutputs(metadataFilesBuilder, action, JavaSemantics.COVERAGE_METADATA);
            } else if (action != null && action.getMnemonic().equals("JavaResourceJar")) {
              // recurse on resource jar actions
              collectMetadataArtifacts(
                  action.getInputs(), analysisEnvironment, metadataFilesBuilder);
            }
          }
        }
      };

  private ClasspathConfiguredFragment classpathFragment = new ClasspathConfiguredFragment();
  private JavaCompilationArtifacts javaArtifacts = JavaCompilationArtifacts.EMPTY;
  private ImmutableList<String> javacOpts;

  // Targets treated as deps in compilation time, runtime time and both
  private final ImmutableMap<ClasspathType, ImmutableList<TransitiveInfoCollection>>
      targetsTreatedAsDeps;

  private final ImmutableList<Artifact> sources;
  private ImmutableList<JavaPluginInfoProvider> activePlugins = ImmutableList.of();

  private final RuleContext ruleContext;
  private final JavaSemantics semantics;
  private JavaCompilationHelper javaCompilationHelper;

  public JavaCommon(RuleContext ruleContext, JavaSemantics semantics) {
    this(ruleContext, semantics,
        ruleContext.getPrerequisiteArtifacts("srcs", Mode.TARGET).list(),
        collectTargetsTreatedAsDeps(ruleContext, semantics, ClasspathType.COMPILE_ONLY),
        collectTargetsTreatedAsDeps(ruleContext, semantics, ClasspathType.RUNTIME_ONLY),
        collectTargetsTreatedAsDeps(ruleContext, semantics, ClasspathType.BOTH));
  }

  public JavaCommon(RuleContext ruleContext, JavaSemantics semantics,
      ImmutableList<Artifact> sources) {
    this(ruleContext, semantics,
        sources,
        collectTargetsTreatedAsDeps(ruleContext, semantics, ClasspathType.COMPILE_ONLY),
        collectTargetsTreatedAsDeps(ruleContext, semantics, ClasspathType.RUNTIME_ONLY),
        collectTargetsTreatedAsDeps(ruleContext, semantics, ClasspathType.BOTH));
  }

  public JavaCommon(RuleContext ruleContext,
      JavaSemantics semantics,
      ImmutableList<TransitiveInfoCollection> compileDeps,
      ImmutableList<TransitiveInfoCollection> runtimeDeps,
      ImmutableList<TransitiveInfoCollection> bothDeps) {
    this(ruleContext, semantics,
        ruleContext.getPrerequisiteArtifacts("srcs", Mode.TARGET).list(),
        compileDeps, runtimeDeps, bothDeps);
  }

  public JavaCommon(RuleContext ruleContext,
      JavaSemantics semantics,
      ImmutableList<Artifact> sources,
      ImmutableList<TransitiveInfoCollection> compileDeps,
      ImmutableList<TransitiveInfoCollection> runtimeDeps,
      ImmutableList<TransitiveInfoCollection> bothDeps) {
    this.ruleContext = ruleContext;
    this.semantics = semantics;
    this.sources = sources;
    this.targetsTreatedAsDeps = ImmutableMap.of(
        ClasspathType.COMPILE_ONLY, compileDeps,
        ClasspathType.RUNTIME_ONLY, runtimeDeps,
        ClasspathType.BOTH, bothDeps);
  }

  public JavaSemantics getJavaSemantics() {
    return semantics;
  }

  /**
   * Validates that the packages listed under "deps" all have the given constraint. If a package
   * does not have this attribute, an error is generated.
   */
  public static final void validateConstraint(RuleContext ruleContext,
      String constraint, Iterable<? extends TransitiveInfoCollection> targets) {
    for (JavaConstraintProvider constraintProvider :
        AnalysisUtils.getProviders(targets, JavaConstraintProvider.class)) {
      if (!constraintProvider.getJavaConstraints().contains(constraint)) {
        ruleContext.attributeError("deps",
            String.format("%s: does not have constraint '%s'",
                constraintProvider.getLabel(), constraint));
      }
    }
  }

  /**
   * Creates an action to aggregate all metadata artifacts into a single
   * &lt;target_name&gt;_instrumented.jar file.
   */
  public static void createInstrumentedJarAction(
      RuleContext ruleContext,
      JavaSemantics semantics,
      List<Artifact> metadataArtifacts,
      Artifact instrumentedJar,
      String mainClass)
      throws InterruptedException {
    // In Jacoco's setup, metadata artifacts are real jars.
    new DeployArchiveBuilder(semantics, ruleContext)
        .setOutputJar(instrumentedJar)
        // We need to save the original mainClass because we're going to run inside CoverageRunner
        .setJavaStartClass(mainClass)
        .setAttributes(new JavaTargetAttributes.Builder(semantics).build())
        .addRuntimeJars(ImmutableList.copyOf(metadataArtifacts))
        .setCompression(DeployArchiveBuilder.Compression.UNCOMPRESSED)
        .build();
  }

  public static ImmutableList<String> getConstraints(RuleContext ruleContext) {
    return ruleContext.getRule().isAttrDefined("constraints", Type.STRING_LIST)
        ? ImmutableList.copyOf(ruleContext.attributes().get("constraints", Type.STRING_LIST))
        : ImmutableList.<String>of();
  }

  public void setClassPathFragment(ClasspathConfiguredFragment classpathFragment) {
    this.classpathFragment = classpathFragment;
  }

  public void setJavaCompilationArtifacts(JavaCompilationArtifacts javaArtifacts) {
    this.javaArtifacts = javaArtifacts;
  }

  public JavaCompilationArtifacts getJavaCompilationArtifacts() {
    return javaArtifacts;
  }

  public NestedSet<Artifact> getProcessorClasspathJars() {
    NestedSetBuilder<Artifact> builder = NestedSetBuilder.naiveLinkOrder();
    for (JavaPluginInfoProvider plugin : activePlugins) {
      builder.addTransitive(plugin.getProcessorClasspath());
    }
    return builder.build();
  }

  public ImmutableList<String> getProcessorClassNames() {
    Set<String> processorNames = new LinkedHashSet<>();
    for (JavaPluginInfoProvider plugin : activePlugins) {
      processorNames.addAll(plugin.getProcessorClasses());
    }
    return ImmutableList.copyOf(processorNames);
  }

  /**
   * Creates the java.library.path from a list of the native libraries.
   * Concatenates the parent directories of the shared libraries into a Java
   * search path. Each relative path entry is prepended with "${JAVA_RUNFILES}/"
   * so it can be resolved at runtime.
   *
   * @param sharedLibraries a collection of native libraries to create the java
   *        library path from
   * @return a String containing the ":" separated java library path
   */
  public static String javaLibraryPath(
      Collection<Artifact> sharedLibraries, String runfilePrefix) {
    StringBuilder buffer = new StringBuilder();
    Set<PathFragment> entries = new HashSet<>();
    for (Artifact sharedLibrary : sharedLibraries) {
      PathFragment entry = sharedLibrary.getRootRelativePath().getParentDirectory();
      if (entries.add(entry)) {
        if (buffer.length() > 0) {
          buffer.append(':');
        }
        buffer.append("${JAVA_RUNFILES}/" + runfilePrefix + "/");
        buffer.append(entry.getPathString());
      }
    }
    return buffer.toString();
  }

  /**
   * Collects Java compilation arguments for this target.
   *
   * @param recursive Whether to scan dependencies recursively.
   * @param isNeverLink Whether the target has the 'neverlink' attr.
   * @param srcLessDepsExport If srcs is omitted, deps are exported
   * (deprecated behaviour for android_library only)
   */
  public JavaCompilationArgs collectJavaCompilationArgs(boolean recursive, boolean isNeverLink,
      boolean srcLessDepsExport) {
    ClasspathType type = isNeverLink ? ClasspathType.COMPILE_ONLY : ClasspathType.BOTH;
    JavaCompilationArgs.Builder builder = JavaCompilationArgs.builder()
        .merge(getJavaCompilationArtifacts(), isNeverLink)
        .addTransitiveTargets(getExports(ruleContext), recursive, type);
    // TODO(bazel-team): remove srcs-less behaviour after android_library users are refactored
    if (recursive || srcLessDepsExport) {
      builder
          .addTransitiveTargets(targetsTreatedAsDeps(ClasspathType.COMPILE_ONLY), recursive, type)
          .addTransitiveTargets(getRuntimeDeps(ruleContext), recursive, ClasspathType.RUNTIME_ONLY);
    }
    return builder.build();
  }

  /**
   * Collects Java dependency artifacts for this target.
   *
   * @param outDeps output (compile-time) dependency artifact of this target
   */
  public NestedSet<Artifact> collectCompileTimeDependencyArtifacts(@Nullable Artifact outDeps) {
    NestedSetBuilder<Artifact> builder = NestedSetBuilder.stableOrder();
    if (outDeps != null) {
      builder.add(outDeps);
    }

    for (JavaCompilationArgsProvider provider : JavaProvider.getProvidersFromListOfTargets(
        JavaCompilationArgsProvider.class, getExports(ruleContext))) {
      builder.addTransitive(provider.getCompileTimeJavaDependencyArtifacts());
    }

    return builder.build();
  }

  public static List<TransitiveInfoCollection> getExports(RuleContext ruleContext) {
    // We need to check here because there are classes inheriting from this class that implement
    // rules that don't have this attribute.
    if (ruleContext.attributes().has("exports", BuildType.LABEL_LIST)) {
      // Do not remove <SplitTransition<?>, BuildConfiguration>:
      // workaround for Java 7 type inference.
      return ImmutableList.<TransitiveInfoCollection>copyOf(
          ruleContext.getPrerequisites("exports", Mode.TARGET));
    } else {
      return ImmutableList.of();
    }
  }

  /**
   * Sanity checks the given runtime dependencies, and emits errors if there is a problem.
   * Also called by {@link #initCommon()} for the current target's runtime dependencies.
   */
  public static void checkRuntimeDeps(
      RuleContext ruleContext, List<TransitiveInfoCollection> runtimeDepInfo) {
    for (TransitiveInfoCollection c : runtimeDepInfo) {
      JavaNeverlinkInfoProvider neverLinkedness =
          c.getProvider(JavaNeverlinkInfoProvider.class);
      if (neverLinkedness == null) {
        continue;
      }
      boolean reportError = !ruleContext.getConfiguration().getAllowRuntimeDepsOnNeverLink();
      if (neverLinkedness.isNeverlink()) {
        String msg = String.format("neverlink dep %s not allowed in runtime deps", c.getLabel());
        if (reportError) {
          ruleContext.attributeError("runtime_deps", msg);
        } else {
          ruleContext.attributeWarning("runtime_deps", msg);
        }
      }
    }
  }

  /**
   * Returns transitive Java native libraries.
   *
   * @see JavaNativeLibraryProvider
   */
  protected NestedSet<LinkerInput> collectTransitiveJavaNativeLibraries() {
    NativeLibraryNestedSetBuilder builder = new NativeLibraryNestedSetBuilder();
    builder.addJavaTargets(targetsTreatedAsDeps(ClasspathType.BOTH));

    if (ruleContext.getRule().isAttrDefined("data", BuildType.LABEL_LIST)) {
      builder.addJavaTargets(ruleContext.getPrerequisites("data", Mode.DATA));
    }
    return builder.build();
  }

  /**
   * Collects transitive source jars for the current rule.
   *
   * @param targetSrcJars The source jar artifacts corresponding to the output of the current rule.
   * @return A nested set containing all of the source jar artifacts on which the current rule
   *         transitively depends.
   */
  public NestedSet<Artifact> collectTransitiveSourceJars(Artifact... targetSrcJars) {
    return collectTransitiveSourceJars(ImmutableList.copyOf(targetSrcJars));
  }

  /**
   * Collects transitive source jars for the current rule.
   *
   * @param targetSrcJars The source jar artifacts corresponding to the output of the current rule.
   * @return A nested set containing all of the source jar artifacts on which the current rule
   *         transitively depends.
   */
  public NestedSet<Artifact> collectTransitiveSourceJars(Iterable<Artifact> targetSrcJars) {
    NestedSetBuilder<Artifact> builder = NestedSetBuilder.<Artifact>stableOrder()
        .addAll(targetSrcJars);

    for (JavaSourceJarsProvider sourceJarsProvider : JavaProvider.getProvidersFromListOfTargets(
        JavaSourceJarsProvider.class, getDependencies())) {
      builder.addTransitive(sourceJarsProvider.getTransitiveSourceJars());
    }

    return builder.build();
  }

  /**
   * Collects transitive gen jars for the current rule.
   */
  private JavaGenJarsProvider collectTransitiveGenJars(
          boolean usesAnnotationProcessing,
          @Nullable Artifact genClassJar,
          @Nullable Artifact genSourceJar) {
    NestedSetBuilder<Artifact> classJarsBuilder = NestedSetBuilder.stableOrder();
    NestedSetBuilder<Artifact> sourceJarsBuilder = NestedSetBuilder.stableOrder();

    if (genClassJar != null) {
      classJarsBuilder.add(genClassJar);
    }
    if (genSourceJar != null) {
      sourceJarsBuilder.add(genSourceJar);
    }
    for (JavaGenJarsProvider dep : getDependencies(JavaGenJarsProvider.class)) {
      classJarsBuilder.addTransitive(dep.getTransitiveGenClassJars());
      sourceJarsBuilder.addTransitive(dep.getTransitiveGenSourceJars());
    }
    return new JavaGenJarsProvider(
        usesAnnotationProcessing,
        genClassJar,
        genSourceJar,
        getProcessorClasspathJars(),
        getProcessorClassNames(),
        classJarsBuilder.build(),
        sourceJarsBuilder.build()
    );
  }

 /**
   * Collects transitive C++ dependencies.
   */
  protected CppCompilationContext collectTransitiveCppDeps() {
    CppCompilationContext.Builder builder = new CppCompilationContext.Builder(ruleContext);
    for (TransitiveInfoCollection dep : targetsTreatedAsDeps(ClasspathType.BOTH)) {
      CppCompilationContext context = dep.getProvider(CppCompilationContext.class);
      if (context != null) {
        builder.mergeDependentContext(context);
      }
    }
    return builder.build();
  }

  /**
   * Collects labels of targets and artifacts reached transitively via the "exports" attribute.
   */
  protected JavaExportsProvider collectTransitiveExports() {
    NestedSetBuilder<Label> builder = NestedSetBuilder.stableOrder();
    List<TransitiveInfoCollection> currentRuleExports = getExports(ruleContext);

    builder.addAll(Iterables.transform(currentRuleExports, TransitiveInfoCollection::getLabel));

    for (TransitiveInfoCollection dep : currentRuleExports) {
      JavaExportsProvider exportsProvider = dep.getProvider(JavaExportsProvider.class);

      if (exportsProvider != null) {
        builder.addTransitive(exportsProvider.getTransitiveExports());
      }
    }

    return new JavaExportsProvider(builder.build());
  }

  public final void initializeJavacOpts() {
    Preconditions.checkState(javacOpts == null);
    javacOpts = computeJavacOpts(semantics.getExtraJavacOpts(ruleContext));
  }

  /**
   * For backwards compatibility, this method allows multiple calls to set the Javac opts. Do not
   * use this.
   */
  @Deprecated
  public final void initializeJavacOpts(Iterable<String> extraJavacOpts) {
    javacOpts = computeJavacOpts(extraJavacOpts);
  }

  private ImmutableList<String> computeJavacOpts(Iterable<String> extraJavacOpts) {
    return Streams.concat(
            JavaToolchainProvider.fromRuleContext(ruleContext).getJavacOptions().stream(),
            Streams.stream(extraJavacOpts),
            ruleContext.getTokenizedStringListAttr("javacopts").stream())
        .collect(toImmutableList());
  }

  /**
   * Returns the string that the stub should use to determine the JVM
   * @param launcher if non-null, the cc_binary used to launch the Java Virtual Machine
   */
  public static String getJavaBinSubstitution(
      RuleContext ruleContext, @Nullable Artifact launcher) {
    Preconditions.checkState(ruleContext.getConfiguration().hasFragment(Jvm.class));
    PathFragment javaExecutable;

    if (launcher != null) {
      javaExecutable = launcher.getRootRelativePath();
    } else {
      javaExecutable = ruleContext.getFragment(Jvm.class).getRunfilesJavaExecutable();
    }

    if (!javaExecutable.isAbsolute()) {
      javaExecutable =
          PathFragment.create(PathFragment.create(ruleContext.getWorkspaceName()), javaExecutable);
    }
    javaExecutable = javaExecutable.normalize();

    if (ruleContext.getConfiguration().runfilesEnabled()) {
      String prefix = "";
      if (!javaExecutable.isAbsolute()) {
        prefix = "${JAVA_RUNFILES}/";
      }
      return "JAVABIN=${JAVABIN:-" + prefix + javaExecutable.getPathString() + "}";
    } else {
      return "JAVABIN=${JAVABIN:-$(rlocation " + javaExecutable.getPathString() + ")}";
    }
  }

  /**
   * Heuristically determines the name of the primary Java class for this
   * executable, based on the rule name and the "srcs" list.
   *
   * <p>(This is expected to be the class containing the "main" method for a
   * java_binary, or a JUnit Test class for a java_test.)
   *
   * @param sourceFiles the source files for this rule
   * @return a fully qualified Java class name, or null if none could be
   *   determined.
   */
  public static String determinePrimaryClass(
      RuleContext ruleContext, ImmutableList<Artifact> sourceFiles) {
    return determinePrimaryClass(ruleContext.getTarget(), sourceFiles);
  }

  private static String determinePrimaryClass(Target target, ImmutableList<Artifact> sourceFiles) {
    if (!sourceFiles.isEmpty()) {
      String mainSource = target.getName() + ".java";
      for (Artifact sourceFile : sourceFiles) {
        PathFragment path = sourceFile.getRootRelativePath();
        if (path.getBaseName().equals(mainSource)) {
          return JavaUtil.getJavaFullClassname(FileSystemUtils.removeExtension(path));
        }
      }
    }
    // Last resort: Use the name and package name of the target.
    // TODO(bazel-team): this should be fixed to use a source file from the dependencies to
    // determine the package of the Java class.
    return JavaUtil.getJavaFullClassname(Util.getWorkspaceRelativePath(target));
  }

  /**
   * Gets the value of the "jvm_flags" attribute combining it with the default
   * options and expanding any make variables and $(location) tags.
   */
  public static List<String> getJvmFlags(RuleContext ruleContext) {
    List<String> jvmFlags = new ArrayList<>();
    jvmFlags.addAll(ruleContext.getFragment(JavaConfiguration.class).getDefaultJvmFlags());
    jvmFlags.addAll(ruleContext.getExpandedStringListAttr("jvm_flags", RuleContext.Tokenize.NO));
    return jvmFlags;
  }

  private static List<TransitiveInfoCollection> getRuntimeDeps(RuleContext ruleContext) {
    // We need to check here because there are classes inheriting from this class that implement
    // rules that don't have this attribute.
    if (ruleContext.attributes().has("runtime_deps", BuildType.LABEL_LIST)) {
      // Do not remove <TransitiveInfoCollection>: workaround for Java 7 type inference.
      return ImmutableList.<TransitiveInfoCollection>copyOf(
          ruleContext.getPrerequisites("runtime_deps", Mode.TARGET));
    } else {
      return ImmutableList.of();
    }
  }

  public JavaTargetAttributes.Builder initCommon() {
    return initCommon(ImmutableList.<Artifact>of(), semantics.getExtraJavacOpts(ruleContext));
  }

  /**
   * Initialize the common actions and build various collections of artifacts
   * for the initializationHook() methods of the subclasses.
   *
   * <p>Note that not all subclasses call this method.
   *
   * @return the processed attributes
   */
  public JavaTargetAttributes.Builder initCommon(
      Collection<Artifact> extraSrcs, Iterable<String> extraJavacOpts) {
    Preconditions.checkState(javacOpts == null);
    javacOpts = computeJavacOpts(extraJavacOpts);
    activePlugins = collectPlugins();

    JavaTargetAttributes.Builder javaTargetAttributes = new JavaTargetAttributes.Builder(semantics);
    javaCompilationHelper = new JavaCompilationHelper(
        ruleContext, semantics, javacOpts, javaTargetAttributes);

    processSrcs(javaTargetAttributes);
    javaTargetAttributes.addSourceArtifacts(sources);
    javaTargetAttributes.addSourceArtifacts(extraSrcs);
    processRuntimeDeps(javaTargetAttributes);

    semantics.commonDependencyProcessing(ruleContext, javaTargetAttributes,
        targetsTreatedAsDeps(ClasspathType.COMPILE_ONLY));

    semantics.checkProtoDeps(ruleContext, targetsTreatedAsDeps(ClasspathType.BOTH));

    if (disallowDepsWithoutSrcs(ruleContext.getRule().getRuleClass())
        && ruleContext.attributes().get("srcs", BuildType.LABEL_LIST).isEmpty()
        && ruleContext.getRule().isAttributeValueExplicitlySpecified("deps")) {
      ruleContext.attributeError("deps", "deps not allowed without srcs; move to runtime_deps?");
    }

    for (Artifact resource : semantics.collectResources(ruleContext)) {
      javaTargetAttributes.addResource(
          JavaHelper.getJavaResourcePath(semantics, ruleContext, resource), resource);
    }

    if (ruleContext.attributes().has("resource_jars", BuildType.LABEL_LIST)) {
      javaTargetAttributes.addResourceJars(PrerequisiteArtifacts.nestedSet(
          ruleContext, "resource_jars", Mode.TARGET));
    }

    addPlugins(javaTargetAttributes);

    javaTargetAttributes.setRuleKind(ruleContext.getRule().getRuleClass());
    javaTargetAttributes.setTargetLabel(ruleContext.getLabel());

    return javaTargetAttributes;
  }

  private boolean disallowDepsWithoutSrcs(String ruleClass) {
    return ruleClass.equals("java_library")
        || ruleClass.equals("java_binary")
        || ruleClass.equals("java_test");
  }

  public ImmutableList<? extends TransitiveInfoCollection> targetsTreatedAsDeps(
      ClasspathType type) {
    return targetsTreatedAsDeps.get(type);
  }

  /**
   * Returns the default dependencies for the given classpath context.
   */
  public static ImmutableList<TransitiveInfoCollection> defaultDeps(RuleContext ruleContext,
      JavaSemantics semantics, ClasspathType type) {
    return collectTargetsTreatedAsDeps(ruleContext, semantics, type);
  }

  private static ImmutableList<TransitiveInfoCollection> collectTargetsTreatedAsDeps(
      RuleContext ruleContext, JavaSemantics semantics, ClasspathType type) {
    ImmutableList.Builder<TransitiveInfoCollection> builder = new Builder<>();

    if (!type.equals(ClasspathType.COMPILE_ONLY)) {
      builder.addAll(getRuntimeDeps(ruleContext));
      builder.addAll(getExports(ruleContext));
    }
    builder.addAll(ruleContext.getPrerequisites("deps", Mode.TARGET));

    semantics.collectTargetsTreatedAsDeps(ruleContext, builder, type);

    // Implicitly add dependency on java launcher cc_binary when --java_launcher= is enabled,
    // or when launcher attribute is specified in a build rule.
    TransitiveInfoCollection launcher = JavaHelper.launcherForTarget(semantics, ruleContext);
    if (launcher != null) {
      builder.add(launcher);
    }

    return builder.build();
  }

  public void addTransitiveInfoProviders(
      RuleConfiguredTargetBuilder builder,
      NestedSet<Artifact> filesToBuild,
      @Nullable Artifact classJar) {
    addTransitiveInfoProviders(builder, filesToBuild, classJar, JAVA_COLLECTION_SPEC);
  }

  public void addTransitiveInfoProviders(
      RuleConfiguredTargetBuilder builder,
      NestedSet<Artifact> filesToBuild,
      @Nullable Artifact classJar,
      InstrumentationSpec instrumentationSpec) {

    JavaCompilationInfoProvider compilationInfoProvider = createCompilationInfoProvider();
    JavaExportsProvider exportsProvider = collectTransitiveExports();

    builder
        .add(
            InstrumentedFilesProvider.class,
            getInstrumentationFilesProvider(ruleContext, filesToBuild, instrumentationSpec))
        .add(JavaExportsProvider.class, exportsProvider)
        .addOutputGroup(OutputGroupProvider.FILES_TO_COMPILE, getFilesToCompile(classJar))
        .add(JavaCompilationInfoProvider.class, compilationInfoProvider);
  }

  private static InstrumentedFilesProvider getInstrumentationFilesProvider(RuleContext ruleContext,
      NestedSet<Artifact> filesToBuild, InstrumentationSpec instrumentationSpec) {
    return InstrumentedFilesCollector.collect(
        ruleContext,
        instrumentationSpec,
        JAVA_METADATA_COLLECTOR,
        filesToBuild,
        NestedSetBuilder.<Artifact>emptySet(Order.STABLE_ORDER),
        NestedSetBuilder.<Pair<String, String>>emptySet(Order.STABLE_ORDER),
        /*withBaselineCoverage*/!TargetUtils.isTestRule(ruleContext.getTarget()));
  }

  public void addGenJarsProvider(
      RuleConfiguredTargetBuilder builder,
      @Nullable Artifact genClassJar,
      @Nullable Artifact genSourceJar) {
    JavaGenJarsProvider genJarsProvider = collectTransitiveGenJars(
        javaCompilationHelper.usesAnnotationProcessing(),
        genClassJar, genSourceJar);

    NestedSetBuilder<Artifact> genJarsBuilder = NestedSetBuilder.stableOrder();
    genJarsBuilder.addTransitive(genJarsProvider.getTransitiveGenClassJars());
    genJarsBuilder.addTransitive(genJarsProvider.getTransitiveGenSourceJars());

    builder
        .add(JavaGenJarsProvider.class, genJarsProvider)
        .addOutputGroup(JavaSemantics.GENERATED_JARS_OUTPUT_GROUP, genJarsBuilder.build());
  }

  /**
   * Processes the sources of this target, adding them as messages or proper
   * sources.
   */
  private void processSrcs(JavaTargetAttributes.Builder attributes) {
    for (MessageBundleProvider srcItem : ruleContext.getPrerequisites(
        "srcs", Mode.TARGET, MessageBundleProvider.class)) {
      attributes.addMessages(srcItem.getMessages());
    }
  }

  /**
   * Processes the transitive runtime_deps of this target.
   */
  private void processRuntimeDeps(JavaTargetAttributes.Builder attributes) {
    List<TransitiveInfoCollection> runtimeDepInfo = getRuntimeDeps(ruleContext);
    checkRuntimeDeps(ruleContext, runtimeDepInfo);
    JavaCompilationArgs args = JavaCompilationArgs.builder()
        .addTransitiveTargets(runtimeDepInfo, true, ClasspathType.RUNTIME_ONLY)
        .build();
    attributes.addRuntimeClassPathEntries(args.getRuntimeJars());
    attributes.addInstrumentationMetadataEntries(args.getInstrumentationMetadata());
  }

  /**
   * Adds information about the annotation processors that should be run for this java target to
   * the target attributes.
   */
  private void addPlugins(JavaTargetAttributes.Builder attributes) {
    for (JavaPluginInfoProvider plugin : activePlugins) {
      for (String name : plugin.getProcessorClasses()) {
        attributes.addProcessorName(name);
      }
      // Now get the plugin-libraries runtime classpath.
      attributes.addProcessorPath(plugin.getProcessorClasspath());

      // Add api-generating plugins
      for (String name : plugin.getApiGeneratingProcessorClasses()) {
        attributes.addApiGeneratingProcessorName(name);
      }
      attributes.addApiGeneratingProcessorPath(plugin.getApiGeneratingProcessorClasspath());
    }
  }

  private ImmutableList<JavaPluginInfoProvider> collectPlugins() {
    List<JavaPluginInfoProvider> result = new ArrayList<>();
    Iterables.addAll(result,
        getPluginInfoProvidersForAttribute(ruleContext, ":java_plugins", Mode.HOST));
    Iterables.addAll(result, getPluginInfoProvidersForAttribute(ruleContext, "plugins", Mode.HOST));
    Iterables.addAll(result, getPluginInfoProvidersForAttribute(ruleContext, "deps", Mode.TARGET));
    return ImmutableList.copyOf(result);
  }

  private static Iterable<JavaPluginInfoProvider> getPluginInfoProvidersForAttribute(
      RuleContext ruleContext, String attribute, Mode mode) {
    if (ruleContext.attributes().has(attribute, BuildType.LABEL_LIST)) {
      return ruleContext.getPrerequisites(attribute, mode, JavaPluginInfoProvider.class);
    }
    return ImmutableList.of();
  }

  public static JavaPluginInfoProvider getTransitivePlugins(RuleContext ruleContext) {
    return JavaPluginInfoProvider.merge(Iterables.concat(
        getPluginInfoProvidersForAttribute(ruleContext, "exported_plugins", Mode.HOST),
        getPluginInfoProvidersForAttribute(ruleContext, "exports", Mode.TARGET)));
  }

  public static Runfiles getRunfiles(
      RuleContext ruleContext, JavaSemantics semantics, JavaCompilationArtifacts javaArtifacts,
      boolean neverLink) {
    // The "neverlink" attribute is transitive, so we don't add any
    // runfiles from this target or its dependencies.
    if (neverLink) {
      return Runfiles.EMPTY;
    }
    Runfiles.Builder runfilesBuilder = new Runfiles.Builder(
        ruleContext.getWorkspaceName(), ruleContext.getConfiguration().legacyExternalRunfiles())
        .addArtifacts(javaArtifacts.getRuntimeJars());
    runfilesBuilder.addRunfiles(ruleContext, RunfilesProvider.DEFAULT_RUNFILES);
    runfilesBuilder.add(ruleContext, JavaRunfilesProvider.TO_RUNFILES);

    List<TransitiveInfoCollection> depsForRunfiles = new ArrayList<>();
    if (ruleContext.getRule().isAttrDefined("runtime_deps", BuildType.LABEL_LIST)) {
      depsForRunfiles.addAll(ruleContext.getPrerequisites("runtime_deps", Mode.TARGET));
    }
    if (ruleContext.getRule().isAttrDefined("exports", BuildType.LABEL_LIST)) {
      depsForRunfiles.addAll(ruleContext.getPrerequisites("exports", Mode.TARGET));
    }

    runfilesBuilder.addTargets(depsForRunfiles, RunfilesProvider.DEFAULT_RUNFILES);
    runfilesBuilder.addTargets(depsForRunfiles, JavaRunfilesProvider.TO_RUNFILES);

    TransitiveInfoCollection launcher = JavaHelper.launcherForTarget(semantics, ruleContext);
    if (launcher != null) {
      runfilesBuilder.addTarget(launcher, RunfilesProvider.DATA_RUNFILES);
    }

    semantics.addRunfilesForLibrary(ruleContext, runfilesBuilder);
    return runfilesBuilder.build();
  }

  /**
   * Gets all the deps.
   */
  public final Iterable<? extends TransitiveInfoCollection> getDependencies() {
    return targetsTreatedAsDeps(ClasspathType.BOTH);
  }

  /**
   * Gets all the deps that implement a particular provider.
   */
  public final <P extends TransitiveInfoProvider> Iterable<P> getDependencies(
      Class<P> provider) {
    return AnalysisUtils.getProviders(getDependencies(), provider);
  }

  /**
   * Gets all the deps that implement a particular provider.
   */
  public final <P extends SkylarkClassObject> Iterable<P> getDependencies(
      ClassObjectConstructor.Key provider, Class<P> resultClass) {
    return AnalysisUtils.getProviders(getDependencies(), provider, resultClass);
  }


  /**
   * Returns true if and only if this target has the neverlink attribute set to
   * 1, or false if the neverlink attribute does not exist (for example, on
   * *_binary targets)
   *
   * @return the value of the neverlink attribute.
   */
  public static final boolean isNeverLink(RuleContext ruleContext) {
    return ruleContext.getRule().isAttrDefined("neverlink", Type.BOOLEAN)
        && ruleContext.attributes().get("neverlink", Type.BOOLEAN);
  }

  private static NestedSet<Artifact> getFilesToCompile(Artifact classJar) {
    if (classJar == null) {
      // Some subclasses don't produce jars
      return NestedSetBuilder.emptySet(Order.STABLE_ORDER);
    }
    return NestedSetBuilder.create(Order.STABLE_ORDER, classJar);
  }

  public ImmutableList<Artifact> getSrcsArtifacts() {
    return sources;
  }

  public ImmutableList<String> getJavacOpts() {
    return javacOpts;
  }

  public ImmutableList<Artifact> getBootClasspath() {
    return classpathFragment.getBootClasspath();
  }

  public NestedSet<Artifact> getRuntimeClasspath() {
    return classpathFragment.getRuntimeClasspath();
  }

  public NestedSet<Artifact> getCompileTimeClasspath() {
    return classpathFragment.getCompileTimeClasspath();
  }

  public RuleContext getRuleContext() {
    return ruleContext;
  }

  private JavaCompilationInfoProvider createCompilationInfoProvider() {
    return new JavaCompilationInfoProvider.Builder()
        .setJavacOpts(javacOpts)
        .setBootClasspath(getBootClasspath())
        .setCompilationClasspath(getCompileTimeClasspath())
        .setRuntimeClasspath(getRuntimeClasspath())
        .build();
  }
}
