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

package com.google.devtools.build.lib.packages;

import com.google.common.annotations.VisibleForTesting;
import com.google.common.base.Joiner;
import com.google.common.base.Preconditions;
import com.google.common.collect.ImmutableList;
import com.google.common.collect.ImmutableMap;
import com.google.common.collect.Iterables;
import com.google.common.util.concurrent.ThreadFactoryBuilder;
import com.google.devtools.build.lib.cmdline.LabelSyntaxException;
import com.google.devtools.build.lib.cmdline.LabelValidator;
import com.google.devtools.build.lib.cmdline.PackageIdentifier;
import com.google.devtools.build.lib.events.Event;
import com.google.devtools.build.lib.events.EventHandler;
import com.google.devtools.build.lib.events.Location;
import com.google.devtools.build.lib.events.NullEventHandler;
import com.google.devtools.build.lib.events.StoredEventHandler;
import com.google.devtools.build.lib.packages.GlobCache.BadGlobException;
import com.google.devtools.build.lib.packages.License.DistributionType;
import com.google.devtools.build.lib.packages.Type.ConversionException;
import com.google.devtools.build.lib.syntax.AssignmentStatement;
import com.google.devtools.build.lib.syntax.BaseFunction;
import com.google.devtools.build.lib.syntax.BuildFileAST;
import com.google.devtools.build.lib.syntax.BuiltinFunction;
import com.google.devtools.build.lib.syntax.ClassObject;
import com.google.devtools.build.lib.syntax.Environment;
import com.google.devtools.build.lib.syntax.Environment.Extension;
import com.google.devtools.build.lib.syntax.Environment.NoSuchVariableException;
import com.google.devtools.build.lib.syntax.EvalException;
import com.google.devtools.build.lib.syntax.EvalUtils;
import com.google.devtools.build.lib.syntax.Expression;
import com.google.devtools.build.lib.syntax.FuncallExpression;
import com.google.devtools.build.lib.syntax.FunctionSignature;
import com.google.devtools.build.lib.syntax.GlobList;
import com.google.devtools.build.lib.syntax.Identifier;
import com.google.devtools.build.lib.syntax.Label;
import com.google.devtools.build.lib.syntax.Mutability;
import com.google.devtools.build.lib.syntax.ParserInputSource;
import com.google.devtools.build.lib.syntax.Runtime;
import com.google.devtools.build.lib.syntax.SkylarkSignature;
import com.google.devtools.build.lib.syntax.SkylarkSignature.Param;
import com.google.devtools.build.lib.syntax.SkylarkSignatureProcessor;
import com.google.devtools.build.lib.syntax.SkylarkSignatureProcessor.HackHackEitherList;
import com.google.devtools.build.lib.syntax.Statement;
import com.google.devtools.build.lib.util.Pair;
import com.google.devtools.build.lib.vfs.Path;
import com.google.devtools.build.lib.vfs.PathFragment;
import com.google.devtools.build.lib.vfs.UnixGlob;

import java.io.IOException;
import java.util.List;
import java.util.Map;
import java.util.Set;
import java.util.concurrent.LinkedBlockingQueue;
import java.util.concurrent.ThreadPoolExecutor;
import java.util.concurrent.TimeUnit;
import java.util.concurrent.atomic.AtomicReference;
import java.util.logging.Logger;

import javax.annotation.Nullable;

/**
 * The package factory is responsible for constructing Package instances
 * from a BUILD file's abstract syntax tree (AST).
 *
 * <p>A PackageFactory is a heavy-weight object; create them sparingly.
 * Typically only one is needed per client application.
 */
public final class PackageFactory {
  /**
   * An argument to the {@code package()} function.
   */
  public abstract static class PackageArgument<T> {
    private final String name;
    private final Type<T> type;

    protected PackageArgument(String name, Type<T> type) {
      this.name = name;
      this.type = type;
    }

    public String getName() {
      return name;
    }

    private void convertAndProcess(
        Package.LegacyBuilder pkgBuilder, Location location, Object value)
        throws EvalException, ConversionException {
      T typedValue = type.convert(value, "'package' argument", pkgBuilder.getBuildFileLabel());
      process(pkgBuilder, location, typedValue);
    }

    /**
     * Process an argument.
     *
     * @param pkgBuilder the package builder to be mutated
     * @param location the location of the {@code package} function for error reporting
     * @param value the value of the argument. Typically passed to {@link Type#convert}
     */
    protected abstract void process(
        Package.LegacyBuilder pkgBuilder, Location location, T value)
        throws EvalException;
  }

  /** Interface for evaluating globs during package loading. */
  public static interface Globber {
    /** An opaque token for fetching the result of a glob computation. */
    abstract static class Token {}

    /**
     * Asynchronously starts the given glob computation and returns a token for fetching the
     * result.
     */
    Token runAsync(List<String> includes, List<String> excludes, boolean excludeDirs)
        throws BadGlobException;

    /** Fetches the result of a previously started glob computation. */
    List<String> fetch(Token token) throws IOException, InterruptedException;

    /** Should be called when the globber is about to be discarded due to an interrupt. */
    void onInterrupt();

    /** Should be called when the globber is no longer needed. */
    void onCompletion();

    /** Returns all the glob computations requested before {@link #onCompletion} was called. */
    Set<Pair<String, Boolean>> getGlobPatterns();
  }

  /**
   * An extension to the global namespace of the BUILD language.
   */
  // TODO(bazel-team): this is largely unrelated to syntax.Environment.Extension,
  // and should probably be renamed PackageFactory.RuntimeExtension, since really,
  // we're extending the Runtime with more classes.
  public interface EnvironmentExtension {
    /**
     * Update the global environment with the identifiers this extension contributes.
     */
    void update(Environment environment, Label buildFileLabel);

    /**
     * Returns the extra functions needed to be added to the Skylark native module.
     */
    ImmutableList<BaseFunction> nativeModuleFunctions();

    Iterable<PackageArgument<?>> getPackageArguments();
  }

  private static class DefaultVisibility extends PackageArgument<List<Label>> {
    private DefaultVisibility() {
      super("default_visibility", Type.LABEL_LIST);
    }

    @Override
    protected void process(Package.LegacyBuilder pkgBuilder, Location location,
        List<Label> value) {
      pkgBuilder.setDefaultVisibility(getVisibility(value));
    }
  }

  private static class DefaultTestOnly extends PackageArgument<Boolean> {
    private DefaultTestOnly() {
      super("default_testonly", Type.BOOLEAN);
    }

    @Override
    protected void process(Package.LegacyBuilder pkgBuilder, Location location,
        Boolean value) {
      pkgBuilder.setDefaultTestonly(value);
    }
  }

  private static class DefaultDeprecation extends PackageArgument<String> {
    private DefaultDeprecation() {
      super("default_deprecation", Type.STRING);
    }

    @Override
    protected void process(Package.LegacyBuilder pkgBuilder, Location location,
        String value) {
      pkgBuilder.setDefaultDeprecation(value);
    }
  }

  private static class Features extends PackageArgument<List<String>> {
    private Features() {
      super("features", Type.STRING_LIST);
    }

    @Override
    protected void process(Package.LegacyBuilder pkgBuilder, Location location,
        List<String> value) {
      pkgBuilder.addFeatures(value);
    }
  }

  private static class DefaultLicenses extends PackageArgument<License> {
    private DefaultLicenses() {
      super("licenses", Type.LICENSE);
    }

    @Override
    protected void process(Package.LegacyBuilder pkgBuilder, Location location,
        License value) {
      pkgBuilder.setDefaultLicense(value);
    }
  }

  private static class DefaultDistribs extends PackageArgument<Set<DistributionType>> {
    private DefaultDistribs() {
      super("distribs", Type.DISTRIBUTIONS);
    }

    @Override
    protected void process(Package.LegacyBuilder pkgBuilder, Location location,
        Set<DistributionType> value) {
      pkgBuilder.setDefaultDistribs(value);
    }
  }

  /**
   * Declares the package() attribute specifying the default value for
   * {@link RuleClass#COMPATIBLE_ENVIRONMENT_ATTR} when not explicitly specified.
   */
  private static class DefaultCompatibleWith extends PackageArgument<List<Label>> {
    private DefaultCompatibleWith() {
      super(Package.DEFAULT_COMPATIBLE_WITH_ATTRIBUTE, Type.LABEL_LIST);
    }

    @Override
    protected void process(Package.LegacyBuilder pkgBuilder, Location location,
        List<Label> value) {
      pkgBuilder.setDefaultCompatibleWith(value, Package.DEFAULT_COMPATIBLE_WITH_ATTRIBUTE,
          location);
    }
  }

  /**
   * Declares the package() attribute specifying the default value for
   * {@link RuleClass#RESTRICTED_ENVIRONMENT_ATTR} when not explicitly specified.
   */
  private static class DefaultRestrictedTo extends PackageArgument<List<Label>> {
    private DefaultRestrictedTo() {
      super(Package.DEFAULT_RESTRICTED_TO_ATTRIBUTE, Type.LABEL_LIST);
    }

    @Override
    protected void process(Package.LegacyBuilder pkgBuilder, Location location,
        List<Label> value) {
      pkgBuilder.setDefaultRestrictedTo(value, Package.DEFAULT_RESTRICTED_TO_ATTRIBUTE, location);
    }
  }

  public static final String PKG_CONTEXT = "$pkg_context";

  // Used outside of Bazel!
  /** {@link Globber} that uses the legacy GlobCache. */
  public static class LegacyGlobber implements Globber {

    private final GlobCache globCache;

    public LegacyGlobber(GlobCache globCache) {
      this.globCache = globCache;
    }

    private class Token extends Globber.Token {
      public final List<String> includes;
      public final List<String> excludes;
      public final boolean excludeDirs;

      public Token(List<String> includes, List<String> excludes, boolean excludeDirs) {
        this.includes = includes;
        this.excludes = excludes;
        this.excludeDirs = excludeDirs;
      }
    }

    @Override
    public Set<Pair<String, Boolean>> getGlobPatterns() {
      return globCache.getKeySet();
    }

    @Override
    public Token runAsync(List<String> includes, List<String> excludes, boolean excludeDirs)
        throws BadGlobException {
      for (String pattern : Iterables.concat(includes, excludes)) {
        globCache.getGlobAsync(pattern, excludeDirs);
      }
      return new Token(includes, excludes, excludeDirs);
    }

    @Override
    public List<String> fetch(Globber.Token token) throws IOException, InterruptedException {
      Token legacyToken = (Token) token;
      try {
        return globCache.glob(legacyToken.includes, legacyToken.excludes,
            legacyToken.excludeDirs);
      } catch (BadGlobException e) {
        throw new IllegalStateException(e);
      }
    }

    @Override
    public void onInterrupt() {
      globCache.cancelBackgroundTasks();
    }

    @Override
    public void onCompletion() {
      globCache.finishBackgroundTasks();
    }
  }

  private static final Logger LOG = Logger.getLogger(PackageFactory.class.getName());

  private final RuleFactory ruleFactory;
  private final RuleClassProvider ruleClassProvider;

  private AtomicReference<? extends UnixGlob.FilesystemCalls> syscalls;
  private Preprocessor.Factory preprocessorFactory = Preprocessor.Factory.NullFactory.INSTANCE;

  private final ThreadPoolExecutor threadPool;
  private Map<String, String> platformSetRegexps;

  private final ImmutableList<EnvironmentExtension> environmentExtensions;
  private final ImmutableMap<String, PackageArgument<?>> packageArguments;

  /**
   * Constructs a {@code PackageFactory} instance with the given rule factory.
   */
  @VisibleForTesting
  public PackageFactory(RuleClassProvider ruleClassProvider) {
    this(ruleClassProvider, null, ImmutableList.<EnvironmentExtension>of());
  }

  @VisibleForTesting
  public PackageFactory(RuleClassProvider ruleClassProvider,
      EnvironmentExtension environmentExtension) {
    this(ruleClassProvider, null, ImmutableList.of(environmentExtension));
  }

  @VisibleForTesting
  public PackageFactory(RuleClassProvider ruleClassProvider,
      Iterable<EnvironmentExtension> environmentExtensions) {
    this(ruleClassProvider, null, environmentExtensions);
  }

  /**
   * Constructs a {@code PackageFactory} instance with a specific glob path translator
   * and rule factory.
   */
  public PackageFactory(RuleClassProvider ruleClassProvider,
      Map<String, String> platformSetRegexps,
      Iterable<EnvironmentExtension> environmentExtensions) {
    this.platformSetRegexps = platformSetRegexps;
    this.ruleFactory = new RuleFactory(ruleClassProvider);
    this.ruleClassProvider = ruleClassProvider;
    threadPool = new ThreadPoolExecutor(100, 100, 15L, TimeUnit.SECONDS,
        new LinkedBlockingQueue<Runnable>(),
        new ThreadFactoryBuilder().setNameFormat("Legacy globber %d").build());
    // Do not consume threads when not in use.
    threadPool.allowCoreThreadTimeOut(true);
    this.environmentExtensions = ImmutableList.copyOf(environmentExtensions);
    this.packageArguments = createPackageArguments();
    this.nativeModule = newNativeModule();
  }

  /**
   * Sets the preprocessor used.
   */
  public void setPreprocessorFactory(Preprocessor.Factory preprocessorFactory) {
    this.preprocessorFactory = preprocessorFactory;
  }

 /**
   * Sets the syscalls cache used in globbing.
   */
  public void setSyscalls(AtomicReference<? extends UnixGlob.FilesystemCalls> syscalls) {
    this.syscalls = Preconditions.checkNotNull(syscalls);
  }

  /**
   * Sets the max number of threads to use for globbing.
   */
  public void setGlobbingThreads(int globbingThreads) {
    threadPool.setCorePoolSize(globbingThreads);
    threadPool.setMaximumPoolSize(globbingThreads);
  }


  /**
   * Returns the immutable, unordered set of names of all the known rule
   * classes.
   */
  public Set<String> getRuleClassNames() {
    return ruleFactory.getRuleClassNames();
  }

  /**
   * Returns the {@link RuleClass} for the specified rule class name.
   */
  public RuleClass getRuleClass(String ruleClassName) {
    return ruleFactory.getRuleClass(ruleClassName);
  }

  /**
   * Returns the {@link RuleClassProvider} of this {@link PackageFactory}.
   */
  public RuleClassProvider getRuleClassProvider() {
    return ruleClassProvider;
  }

  /**
   * Creates the list of arguments for the 'package' function.
   */
  private ImmutableMap<String, PackageArgument<?>> createPackageArguments() {
    ImmutableList.Builder<PackageArgument<?>> arguments =
        ImmutableList.<PackageArgument<?>>builder()
           .add(new DefaultDeprecation())
           .add(new DefaultDistribs())
           .add(new DefaultLicenses())
           .add(new DefaultTestOnly())
           .add(new DefaultVisibility())
           .add(new Features())
           .add(new DefaultCompatibleWith())
           .add(new DefaultRestrictedTo());

    for (EnvironmentExtension extension : environmentExtensions) {
      arguments.addAll(extension.getPackageArguments());
    }

    ImmutableMap.Builder<String, PackageArgument<?>> packageArguments = ImmutableMap.builder();
    for (PackageArgument<?> argument : arguments.build()) {
      packageArguments.put(argument.getName(), argument);
    }
    return packageArguments.build();
  }

  /****************************************************************************
   * Environment function factories.
   */

  /**
   * Returns a function-value implementing "glob" in the specified package context.
   *
   * @param async if true, start globs in the background but don't block on their completion.
   *        Only use this for heuristic preloading.
   */
  @SkylarkSignature(name = "glob", objectType = Object.class, returnType = GlobList.class,
      doc = "Returns a list of files that match glob search pattern",
      mandatoryPositionals = {
        @Param(name = "include", type = HackHackEitherList.class, generic1 = String.class,
            doc = "a list of strings specifying patterns of files to include.")},
      optionalPositionals = {
        @Param(name = "exclude", type = HackHackEitherList.class, generic1 = String.class,
            defaultValue = "[]",
            doc = "a list of strings specifying patterns of files to exclude."),
        // TODO(bazel-team): migrate all existing code to use boolean instead?
        @Param(name = "exclude_directories", type = Integer.class, defaultValue = "1",
            doc = "a integer that if non-zero indicates directories should not be matched.")},
      documented = false, useAst = true, useEnvironment = true)
  private static final BuiltinFunction.Factory newGlobFunction =
      new BuiltinFunction.Factory("glob") {
        public BuiltinFunction create(final PackageContext originalContext, final boolean async) {
          return new BuiltinFunction("glob", this) {
            public GlobList<String> invoke(
                Object include, Object exclude, Integer excludeDirectories,
                FuncallExpression ast, Environment env)
                throws EvalException, ConversionException, InterruptedException {
              return callGlob(
                  originalContext, async, include, exclude, excludeDirectories != 0, ast, env);
            }
          };
        }
      };

  static GlobList<String> callGlob(@Nullable PackageContext originalContext,
      boolean async, Object include, Object exclude, boolean excludeDirs,
      FuncallExpression ast, Environment env)
      throws EvalException, ConversionException, InterruptedException {
    // Skylark build extensions need to get the PackageContext from the Environment;
    // async glob functions cannot do the same because the Environment is not thread safe.
    PackageContext context;
    if (originalContext == null) {
      Preconditions.checkArgument(!async);
      context = getContext(env, ast);
    } else {
      context = originalContext;
    }

    List<String> includes = Type.STRING_LIST.convert(include, "'glob' argument");
    List<String> excludes = Type.STRING_LIST.convert(exclude, "'glob' argument");

    if (async) {
      try {
        context.globber.runAsync(includes, excludes, excludeDirs);
      } catch (GlobCache.BadGlobException e) {
        // Ignore: errors will appear during the actual evaluation of the package.
      }
      return GlobList.captureResults(includes, excludes, ImmutableList.<String>of());
    } else {
      return handleGlob(includes, excludes, excludeDirs, context, ast);
    }
  }

  /**
   * Adds a glob to the package, reporting any errors it finds.
   *
   * @param includes the list of includes which must be non-null
   * @param excludes the list of excludes which must be non-null
   * @param context the package context
   * @param ast the AST
   * @return the list of matches
   * @throws EvalException if globbing failed
   */
  private static GlobList<String> handleGlob(List<String> includes, List<String> excludes,
      boolean excludeDirs, PackageContext context, FuncallExpression ast)
        throws EvalException, InterruptedException {
    try {
      Globber.Token globToken = context.globber.runAsync(includes, excludes, excludeDirs);
      List<String> matches = context.globber.fetch(globToken);
      return GlobList.captureResults(includes, excludes, matches);
    } catch (IOException expected) {
      context.eventHandler.handle(Event.error(ast.getLocation(),
              "error globbing [" + Joiner.on(", ").join(includes) + "]: " + expected.getMessage()));
      context.pkgBuilder.setContainsErrors();
      return GlobList.captureResults(includes, excludes, ImmutableList.<String>of());
    } catch (GlobCache.BadGlobException e) {
      throw new EvalException(ast.getLocation(), e.getMessage());
    }
  }

  /**
   * Returns a function value implementing the "mocksubinclude" function,
   * emitted by the PythonPreprocessor.  We annotate the
   * package with additional dependencies.  (A 'real' subinclude will never be
   * seen by the parser, because the presence of "subinclude" triggers
   * preprocessing.)
   */
  @SkylarkSignature(name = "mocksubinclude", returnType = Runtime.NoneType.class,
      doc = "implement the mocksubinclude function emitted by the PythonPreprocessor",
      mandatoryPositionals = {
        @Param(name = "label", type = Object.class,
            doc = "a label designator."),
        @Param(name = "path", type = String.class,
            doc = "a path.")},
      documented = false, useLocation = true)
  private static final BuiltinFunction.Factory newMockSubincludeFunction =
      new BuiltinFunction.Factory("mocksubinclude") {
        public BuiltinFunction create(final PackageContext context) {
          return new BuiltinFunction("mocksubinclude", this) {
            public Runtime.NoneType invoke(Object labelO, String pathString,
                Location loc) throws ConversionException {
              Label label = Type.LABEL.convert(labelO, "'mocksubinclude' argument",
                  context.pkgBuilder.getBuildFileLabel());
              Path path = pathString.isEmpty()
                  ? null : context.pkgBuilder.getFilename().getRelative(pathString);
              // A subinclude within a package counts as a file declaration.
              if (label.getPackageIdentifier().equals(context.pkgBuilder.getPackageIdentifier())) {
                if (loc == null) {
                  loc = Location.fromFile(context.pkgBuilder.getFilename());
                }
                context.pkgBuilder.createInputFileMaybe(label, loc);
              }

              context.pkgBuilder.addSubinclude(label, path);
              return Runtime.NONE;
            }
          };
        }
      };

  /**
   * Returns a function value implementing "environment_group" in the specified package context.
   * Syntax is as follows:
   *
   * <pre>{@code
   *   environment_group(
   *       name = "sample_group",
   *       environments = [":env1", ":env2", ...],
   *       defaults = [":env1", ...]
   *   )
   * }</pre>
   *
   * <p>Where ":env1", "env2", ... are all environment rules declared in the same package. All
   * parameters are mandatory.
   */
  @SkylarkSignature(name = "environment_group", returnType = Runtime.NoneType.class,
      doc = "Defines a cc_library, by wrapping around the usual library "
      + "and also defining a headers target.",
      mandatoryNamedOnly = {
        @Param(name = "name", type = String.class,
            doc = "The name of the rule."),
        // Both parameter below are lists of label designators
        @Param(name = "environments", type = HackHackEitherList.class, generic1 = Object.class,
            doc = "A list of Labels for the environments to be grouped, from the same package."),
        @Param(name = "defaults", type = HackHackEitherList.class, generic1 = Object.class,
            doc = "A list of Labels.")}, // TODO(bazel-team): document what that is
      documented = false, useLocation = true)
  private static final BuiltinFunction.Factory newEnvironmentGroupFunction =
      new BuiltinFunction.Factory("environment_group") {
        public BuiltinFunction create(final PackageContext context) {
          return new BuiltinFunction("environment_group", this) {
            public Runtime.NoneType invoke(String name, Object environmentsO, Object defaultsO,
                Location loc) throws EvalException, ConversionException {
              List<Label> environments = Type.LABEL_LIST.convert(environmentsO,
                  "'environment_group argument'", context.pkgBuilder.getBuildFileLabel());
              List<Label> defaults = Type.LABEL_LIST.convert(defaultsO,
                  "'environment_group argument'", context.pkgBuilder.getBuildFileLabel());

              try {
                context.pkgBuilder.addEnvironmentGroup(
                    name, environments, defaults, context.eventHandler, loc);
                return Runtime.NONE;
              } catch (LabelSyntaxException e) {
                throw new EvalException(loc,
                    "environment group has invalid name: " + name + ": " + e.getMessage());
              } catch (Package.NameConflictException e) {
                throw new EvalException(loc, e.getMessage());
              }
            }
          };
        }
      };

  /**
   * Returns a function-value implementing "exports_files" in the specified
   * package context.
   */
  @SkylarkSignature(name = "exports_files", returnType = Runtime.NoneType.class,
      doc = "Declare a set of files as exported",
      mandatoryPositionals = {
        @Param(name = "srcs", type = HackHackEitherList.class, generic1 = String.class,
            doc = "A list of strings, the names of the files to export.")},
      optionalPositionals = {
        // TODO(blaze-team): make it possible to express a list of label designators,
        // i.e. a java List or Skylark list of Label or String.
        @Param(name = "visibility", type = HackHackEitherList.class, noneable = true,
            defaultValue = "None",
            doc = "A list of Labels specifying the visibility of the exported files "
            + "(defaults to public)"),
        @Param(name = "licenses", type = HackHackEitherList.class, generic1 = String.class,
            noneable = true, defaultValue = "None",
            doc = "A list of strings specifying the licenses used in the exported code.")},
      documented = false, useAst = true, useEnvironment = true)
  private static final BuiltinFunction.Factory newExportsFilesFunction =
      new BuiltinFunction.Factory("exports_files") {
        public BuiltinFunction create () {
          return new BuiltinFunction("exports_files", this) {
            public Runtime.NoneType invoke(Object srcs, Object visibility, Object licenses,
                FuncallExpression ast, Environment env)
                throws EvalException, ConversionException {
              return callExportsFiles(srcs, visibility, licenses, ast, env);
            }
          };
        }
      };

  static Runtime.NoneType callExportsFiles(Object srcs, Object visibilityO, Object licensesO,
      FuncallExpression ast, Environment env) throws EvalException, ConversionException {
    Package.LegacyBuilder pkgBuilder = getContext(env, ast).pkgBuilder;
    List<String> files = Type.STRING_LIST.convert(srcs, "'exports_files' operand");

    RuleVisibility visibility = EvalUtils.isNullOrNone(visibilityO)
        ? ConstantRuleVisibility.PUBLIC
        : getVisibility(Type.LABEL_LIST.convert(
              visibilityO,
              "'exports_files' operand",
              pkgBuilder.getBuildFileLabel()));
    // TODO(bazel-team): is licenses plural or singular?
    License license = Type.LICENSE.convertOptional(licensesO, "'exports_files' operand");

    for (String file : files) {
      String errorMessage = LabelValidator.validateTargetName(file);
      if (errorMessage != null) {
        throw new EvalException(ast.getLocation(), errorMessage);
      }
      try {
        InputFile inputFile = pkgBuilder.createInputFile(file, ast.getLocation());
        if (inputFile.isVisibilitySpecified()
            && inputFile.getVisibility() != visibility) {
          throw new EvalException(ast.getLocation(),
              String.format("visibility for exported file '%s' declared twice",
                  inputFile.getName()));
        }
        if (license != null && inputFile.isLicenseSpecified()) {
          throw new EvalException(ast.getLocation(),
              String.format("licenses for exported file '%s' declared twice",
                  inputFile.getName()));
        }
        if (license == null && pkgBuilder.getDefaultLicense() == License.NO_LICENSE
            && pkgBuilder.getBuildFileLabel().toString().startsWith("//third_party/")) {
          throw new EvalException(ast.getLocation(),
              "third-party file '" + inputFile.getName() + "' lacks a license declaration "
              + "with one of the following types: notice, reciprocal, permissive, "
              + "restricted, unencumbered, by_exception_only");
        }

        pkgBuilder.setVisibilityAndLicense(inputFile, visibility, license);
      } catch (Package.Builder.GeneratedLabelConflict e) {
        throw new EvalException(ast.getLocation(), e.getMessage());
      }
    }
    return Runtime.NONE;
  }

  /**
   * Returns a function-value implementing "licenses" in the specified package
   * context.
   * TODO(bazel-team): Remove in favor of package.licenses.
   */
  @SkylarkSignature(name = "licenses", returnType = Runtime.NoneType.class,
      doc = "Declare the license(s) for the code in the current package.",
      mandatoryPositionals = {
        @Param(name = "license_strings", type = HackHackEitherList.class, generic1 = String.class,
            doc = "A list of strings, the names of the licenses used.")},
      documented = false, useLocation = true)
  private static final BuiltinFunction.Factory newLicensesFunction =
      new BuiltinFunction.Factory("licenses") {
        public BuiltinFunction create(final PackageContext context) {
          return new BuiltinFunction("licenses", this) {
            public Runtime.NoneType invoke(Object licensesO, Location loc) {
              try {
                License license = Type.LICENSE.convert(licensesO, "'licenses' operand");
                context.pkgBuilder.setDefaultLicense(license);
              } catch (ConversionException e) {
                context.eventHandler.handle(Event.error(loc, e.getMessage()));
                context.pkgBuilder.setContainsErrors();
              }
              return Runtime.NONE;
            }
          };
        }
      };

  /**
   * Returns a function-value implementing "distribs" in the specified package
   * context.
   */
  // TODO(bazel-team): Remove in favor of package.distribs.
  // TODO(bazel-team): Remove all these new*Function-s and/or have static functions
  // that consult the context dynamically via getContext(env, ast) since we have that,
  // and share the functions with the native package... which requires unifying the List types.
  @SkylarkSignature(name = "distribs", returnType = Runtime.NoneType.class,
      doc = "Declare the distribution(s) for the code in the current package.",
      mandatoryPositionals = {
        @Param(name = "distribution_strings", type = Object.class,
            doc = "The distributions.")},
      documented = false, useLocation = true)
  private static final BuiltinFunction.Factory newDistribsFunction =
      new BuiltinFunction.Factory("distribs") {
        public BuiltinFunction create(final PackageContext context) {
          return new BuiltinFunction("distribs", this) {
            public Runtime.NoneType invoke(Object object, Location loc) {
              try {
                Set<DistributionType> distribs = Type.DISTRIBUTIONS.convert(object,
                    "'distribs' operand");
                context.pkgBuilder.setDefaultDistribs(distribs);
              } catch (ConversionException e) {
                context.eventHandler.handle(Event.error(loc, e.getMessage()));
                context.pkgBuilder.setContainsErrors();
              }
              return Runtime.NONE;
            }
          };
        }
      };

  @SkylarkSignature(name = "package_group", returnType = Runtime.NoneType.class,
      doc = "Declare a set of files as exported",
      mandatoryNamedOnly = {
        @Param(name = "name", type = String.class,
            doc = "The name of the rule.")},
      optionalNamedOnly = {
        @Param(name = "packages", type = HackHackEitherList.class, generic1 = String.class,
            defaultValue = "[]",
            doc = "A list of Strings specifying the packages grouped."),
        // java list or list of label designators: Label or String
        @Param(name = "includes", type = HackHackEitherList.class, generic1 = Object.class,
            defaultValue = "[]",
            doc = "A list of Label specifiers for the files to include.")},
      documented = false, useAst = true, useEnvironment = true)
  private static final BuiltinFunction.Factory newPackageGroupFunction =
      new BuiltinFunction.Factory("package_group") {
        public BuiltinFunction create() {
          return new BuiltinFunction("package_group", this) {
            public Runtime.NoneType invoke(String name, Object packages, Object includes,
                FuncallExpression ast, Environment env) throws EvalException, ConversionException {
              return callPackageFunction(name, packages, includes, ast, env);
            }
          };
        }
      };

  static Runtime.NoneType callPackageFunction(String name, Object packagesO, Object includesO,
      FuncallExpression ast, Environment env) throws EvalException, ConversionException {
    PackageContext context = getContext(env, ast);

    List<String> packages = Type.STRING_LIST.convert(
        packagesO, "'package_group.packages argument'");
    List<Label> includes = Type.LABEL_LIST.convert(includesO,
        "'package_group.includes argument'", context.pkgBuilder.getBuildFileLabel());

    try {
      context.pkgBuilder.addPackageGroup(name, packages, includes, context.eventHandler,
          ast.getLocation());
      return Runtime.NONE;
    } catch (LabelSyntaxException e) {
      throw new EvalException(ast.getLocation(),
          "package group has invalid name: " + name + ": " + e.getMessage());
    } catch (Package.NameConflictException e) {
      throw new EvalException(ast.getLocation(), e.getMessage());
    }
  }

  public static RuleVisibility getVisibility(List<Label> original) {
    RuleVisibility result;

    result = ConstantRuleVisibility.tryParse(original);
    if (result != null) {
      return result;
    }

    result = PackageGroupsRuleVisibility.tryParse(original);
    return result;
  }

  /**
   * Returns a function-value implementing "package" in the specified package
   * context.
   */
  private static BaseFunction newPackageFunction(
      final ImmutableMap<String, PackageArgument<?>> packageArguments) {
    // Flatten the map of argument name of PackageArgument specifier in two co-indexed arrays:
    // one for the argument names, to create a FunctionSignature when we create the function,
    // one of the PackageArgument specifiers, over which to iterate at every function invocation
    // at the same time that we iterate over the function arguments.
    final int numArgs = packageArguments.size();
    final String[] argumentNames = new String[numArgs];
    final PackageArgument<?>[] argumentSpecifiers = new PackageArgument<?>[numArgs];
    int i = 0;
    for (Map.Entry<String, PackageArgument<?>> entry : packageArguments.entrySet()) {
      argumentNames[i] = entry.getKey();
      argumentSpecifiers[i++] = entry.getValue();
    }

    return new BaseFunction("package", FunctionSignature.namedOnly(0, argumentNames)) {
      @Override
      public Object call(Object[] arguments, FuncallExpression ast, Environment env)
          throws EvalException, ConversionException {

        Package.LegacyBuilder pkgBuilder = getContext(env, ast).pkgBuilder;

        // Validate parameter list
        if (pkgBuilder.isPackageFunctionUsed()) {
          throw new EvalException(ast.getLocation(),
              "'package' can only be used once per BUILD file");
        }
        pkgBuilder.setPackageFunctionUsed();

        // Parse params
        boolean foundParameter = false;

        for (int i = 0; i < numArgs; i++) {
          Object value = arguments[i];
          if (value != null) {
            foundParameter = true;
            argumentSpecifiers[i].convertAndProcess(pkgBuilder, ast.getLocation(), value);
          }
        }

        if (!foundParameter) {
          throw new EvalException(ast.getLocation(),
              "at least one argument must be given to the 'package' function");
        }

        return Runtime.NONE;
      }
    };
  }

  // Helper function for createRuleFunction.
  private static void addRule(RuleFactory ruleFactory,
                              String ruleClassName,
                              PackageContext context,
                              Map<String, Object> kwargs,
                              FuncallExpression ast,
                              Environment env)
      throws RuleFactory.InvalidRuleException, Package.NameConflictException, InterruptedException {
    RuleClass ruleClass = getBuiltInRuleClass(ruleClassName, ruleFactory);
    RuleFactory.createAndAddRule(context, ruleClass, kwargs, ast, env);
  }

  private static RuleClass getBuiltInRuleClass(String ruleClassName, RuleFactory ruleFactory) {
    if (ruleFactory.getRuleClassNames().contains(ruleClassName)) {
      return ruleFactory.getRuleClass(ruleClassName);
    }
    throw new IllegalArgumentException("no such rule class: "  + ruleClassName);
  }

  /**
   * Get the PackageContext by looking up in the environment.
   */
  public static PackageContext getContext(Environment env, FuncallExpression ast)
      throws EvalException {
    try {
      return (PackageContext) env.lookup(PKG_CONTEXT);
    } catch (NoSuchVariableException e) {
      // if PKG_CONTEXT is missing, we're not called from a BUILD file. This happens if someone
      // uses native.some_func() in the wrong place.
      throw new EvalException(ast.getLocation(),
          "The native module cannot be accessed from here. "
          + "Wrap the function in a macro and call it from a BUILD file");
    }
  }

  /**
   * Returns a function-value implementing the build rule "ruleClass" (e.g. cc_library) in the
   * specified package context.
   */
  private static BuiltinFunction newRuleFunction(
      final RuleFactory ruleFactory, final String ruleClass) {
    return new BuiltinFunction(ruleClass, FunctionSignature.KWARGS, BuiltinFunction.USE_AST_ENV) {
      @SuppressWarnings({"unchecked", "unused"})
      public Runtime.NoneType invoke(Map<String, Object> kwargs,
          FuncallExpression ast, Environment env)
          throws EvalException, InterruptedException {
        env.checkLoadingPhase(ruleClass, ast.getLocation());
        try {
          addRule(ruleFactory, ruleClass, getContext(env, ast), kwargs, ast, env);
        } catch (RuleFactory.InvalidRuleException | Package.NameConflictException e) {
          throw new EvalException(ast.getLocation(), e.getMessage());
        }
        return Runtime.NONE;
      }
    };
  }

  /****************************************************************************
   * Package creation.
   */

  /**
   * Loads, scans parses and evaluates the build file at "buildFile", and
   * creates and returns a Package builder instance capable of building a package identified by
   * "packageId".
   *
   * <p>This method returns a builder to allow the caller to do additional work, if necessary.
   *
   * <p>This method assumes "packageId" is a valid package name according to the
   * {@link LabelValidator#validatePackageName} heuristic.
   *
   * <p>See {@link #evaluateBuildFile} for information on AST retention.
   *
   * <p>Executes {@code globber.onCompletion()} on completion and executes
   * {@code globber.onInterrupt()} on an {@link InterruptedException}.
   */
  // Used outside of bazel!
  public Package.LegacyBuilder createPackageFromPreprocessingResult(
      Package externalPkg,
      PackageIdentifier packageId,
      Path buildFile,
      Preprocessor.Result preprocessingResult,
      Iterable<Event> preprocessingEvents,
      List<Statement> preludeStatements,
      Map<PathFragment, Extension> imports,
      ImmutableList<Label> skylarkFileDependencies,
      CachingPackageLocator locator,
      RuleVisibility defaultVisibility,
      Globber globber) throws InterruptedException {
    StoredEventHandler localReporter = new StoredEventHandler();
    // Run the lexer and parser with a local reporter, so that errors from other threads do not
    // show up below. Merge the local and global reporters afterwards.
    // Logged messages are used as a testability hook tracing the parsing progress
    LOG.fine("Starting to parse " + packageId);
    BuildFileAST buildFileAST = BuildFileAST.parseBuildFile(
        preprocessingResult.result, preludeStatements, localReporter, false);
    LOG.fine("Finished parsing of " + packageId);

    MakeEnvironment.Builder makeEnv = new MakeEnvironment.Builder();
    if (platformSetRegexps != null) {
      makeEnv.setPlatformSetRegexps(platformSetRegexps);
    }
    try {
      // At this point the package is guaranteed to exist.  It may have parse or
      // evaluation errors, resulting in a diminished number of rules.
      prefetchGlobs(packageId, buildFileAST, preprocessingResult.preprocessed,
          buildFile, globber, defaultVisibility, makeEnv);
      return evaluateBuildFile(
          externalPkg,
          packageId,
          buildFileAST,
          buildFile,
          globber,
          Iterables.concat(preprocessingEvents, localReporter.getEvents()),
          defaultVisibility,
          preprocessingResult.containsErrors,
          makeEnv,
          imports,
          skylarkFileDependencies);
    } catch (InterruptedException e) {
      globber.onInterrupt();
      throw e;
    } finally {
      globber.onCompletion();
    }
  }

  /**
   * Same as {@link #createPackage}, but does the required validation of "packageName" first,
   * throwing a {@link NoSuchPackageException} if the name is invalid.
   */
  @VisibleForTesting
  public Package createPackageForTesting(PackageIdentifier packageId,
      Path buildFile, CachingPackageLocator locator, EventHandler eventHandler)
          throws NoSuchPackageException, InterruptedException {
    String error = LabelValidator.validatePackageName(
        packageId.getPackageFragment().getPathString());
    if (error != null) {
      throw new BuildFileNotFoundException(
          packageId, "illegal package name: '" + packageId + "' (" + error + ")");
    }
    ParserInputSource inputSource = maybeGetParserInputSource(buildFile, eventHandler);
    if (inputSource == null) {
      throw new BuildFileContainsErrorsException(packageId, "IOException occured");
    }

    Globber globber = createLegacyGlobber(buildFile.getParentDirectory(), packageId, locator);
    Preprocessor.Result preprocessingResult;
    try {
      preprocessingResult = preprocess(packageId, inputSource, globber);
    } catch (IOException e) {
      eventHandler.handle(
          Event.error(Location.fromFile(buildFile), "preprocessing failed: " + e.getMessage()));
      throw new BuildFileContainsErrorsException(packageId, "preprocessing failed", e);
    }
    ExternalPackage externalPkg =
        new ExternalPackage.Builder(
            buildFile.getRelative("WORKSPACE"), ruleClassProvider.getRunfilesPrefix()).build();

    Package result =
        createPackageFromPreprocessingResult(
                externalPkg,
                packageId,
                buildFile,
                preprocessingResult,
                /*preprocessingEvents=*/preprocessingResult.events,
                /*preludeStatements=*/ImmutableList.<Statement>of(),
                /*imports=*/ImmutableMap.<PathFragment, Extension>of(),
                /*skylarkFileDependencies=*/ImmutableList.<Label>of(),
                locator,
                /*defaultVisibility=*/ConstantRuleVisibility.PUBLIC,
                globber)
            .build();
    Event.replayEventsOn(eventHandler, result.getEvents());
    return result;
  }

  /** Preprocesses the given BUILD file. */
  public Preprocessor.Result preprocess(
      PackageIdentifier packageId, Path buildFile, CachingPackageLocator locator)
      throws InterruptedException, IOException {
    ParserInputSource inputSource;
    inputSource = ParserInputSource.create(buildFile);
    Globber globber = createLegacyGlobber(buildFile.getParentDirectory(), packageId, locator);
    try {
      return preprocess(packageId, inputSource, globber);
    } finally {
      globber.onCompletion();
    }
  }

  /**
   * Preprocesses the given BUILD file, executing {@code globber.onInterrupt()} on an
   * {@link InterruptedException}.
   */
  public Preprocessor.Result preprocess(
      PackageIdentifier packageId, ParserInputSource inputSource, Globber globber)
      throws InterruptedException, IOException {
    Preprocessor preprocessor = preprocessorFactory.getPreprocessor();
    if (preprocessor == null) {
      return Preprocessor.Result.noPreprocessing(inputSource);
    }
    try {
      return preprocessor.preprocess(
          inputSource,
          packageId.toString(),
          globber,
          Environment.BUILD,
          ruleFactory.getRuleClassNames());
    } catch (InterruptedException e) {
      globber.onInterrupt();
      throw e;
    }
  }

  public LegacyGlobber createLegacyGlobber(Path packageDirectory, PackageIdentifier packageId,
      CachingPackageLocator locator) {
    return new LegacyGlobber(new GlobCache(packageDirectory, packageId, locator, syscalls,
        threadPool));
  }

  @Nullable
  private ParserInputSource maybeGetParserInputSource(Path buildFile, EventHandler eventHandler) {
    try {
      return ParserInputSource.create(buildFile);
    } catch (IOException e) {
      eventHandler.handle(Event.error(Location.fromFile(buildFile), e.getMessage()));
      return null;
    }
  }

  /**
   * This tuple holds the current package builder, current lexer, etc, for the
   * duration of the evaluation of one BUILD file. (We use a PackageContext
   * object in preference to storing these values in mutable fields of the
   * PackageFactory.)
   *
   * <p>PLEASE NOTE: references to PackageContext objects are held by many
   * BaseFunction closures, but should become unreachable once the Environment is
   * discarded at the end of evaluation.  Please be aware of your memory
   * footprint when making changes here!
   */
  public static class PackageContext {

    final Package.LegacyBuilder pkgBuilder;
    final Globber globber;
    final EventHandler eventHandler;

    @VisibleForTesting
    public PackageContext(Package.LegacyBuilder pkgBuilder, Globber globber,
        EventHandler eventHandler) {
      this.pkgBuilder = pkgBuilder;
      this.eventHandler = eventHandler;
      this.globber = globber;
    }

    /**
     * Returns the Label of this Package.
     */
    public Label getLabel() {
      return pkgBuilder.getBuildFileLabel();
    }

    /**
     * Returns the MakeEnvironment Builder of this Package.
     */
    public MakeEnvironment.Builder getMakeEnvironment() {
      return pkgBuilder.getMakeEnvironment();
    }
  }

  private final ClassObject nativeModule;

  /** @return the Skylark struct to bind to "native" */
  public ClassObject getNativeModule() {
    return nativeModule;
  }

  /**
   * Returns a native module with the functions created using the {@link RuleClassProvider}
   * of this {@link PackageFactory}.
   */
  private ClassObject newNativeModule() {
    ImmutableMap.Builder<String, Object> builder = new ImmutableMap.Builder<>();
    for (String nativeFunction : Runtime.getFunctionNames(SkylarkNativeModule.class)) {
      builder.put(nativeFunction, Runtime.getFunction(SkylarkNativeModule.class, nativeFunction));
    }
    for (String ruleClass : ruleFactory.getRuleClassNames()) {
      builder.put(ruleClass, newRuleFunction(ruleFactory, ruleClass));
    }
    builder.put("package", newPackageFunction(packageArguments));
    for (EnvironmentExtension extension : environmentExtensions) {
      for (BaseFunction function : extension.nativeModuleFunctions()) {
        builder.put(function.getName(), function);
      }
    }
    return new ClassObject.SkylarkClassObject(builder.build(), "no native function or rule '%s'");
  }

  private void buildPkgEnv(Environment pkgEnv, PackageContext context, RuleFactory ruleFactory) {
    // TODO(bazel-team): remove the naked functions that are redundant with the nativeModule,
    // or if not possible, at least make them straight copies from the native module variant.
    // or better, use a common Environment.Frame for these common bindings
    // (that shares a backing ImmutableMap for the bindings?)
    pkgEnv
        .setup("native", nativeModule)
        .setup("distribs", newDistribsFunction.apply(context))
        .setup("glob", newGlobFunction.apply(context, /*async=*/false))
        .setup("mocksubinclude", newMockSubincludeFunction.apply(context))
        .setup("licenses", newLicensesFunction.apply(context))
        .setup("exports_files", newExportsFilesFunction.apply())
        .setup("package_group", newPackageGroupFunction.apply())
        .setup("package", newPackageFunction(packageArguments))
        .setup("environment_group", newEnvironmentGroupFunction.apply(context));

    for (String ruleClass : ruleFactory.getRuleClassNames()) {
      BaseFunction ruleFunction = newRuleFunction(ruleFactory, ruleClass);
      pkgEnv.setup(ruleClass, ruleFunction);
    }

    for (EnvironmentExtension extension : environmentExtensions) {
      extension.update(pkgEnv, context.pkgBuilder.getBuildFileLabel());
    }
  }

  /**
   * Constructs a Package instance, evaluates the BUILD-file AST inside the
   * build environment, and populates the package with Rule instances as it
   * goes.  As with most programming languages, evaluation stops when an
   * exception is encountered: no further rules after the point of failure will
   * be constructed.  We assume that rules constructed before the point of
   * failure are valid; this assumption is not entirely correct, since a
   * "vardef" after a rule declaration can affect the behavior of that rule.
   *
   * <p>Rule attribute checking is performed during evaluation. Each attribute
   * must conform to the type specified for that <i>(rule class, attribute
   * name)</i> pair.  Errors reported at this stage include: missing value for
   * mandatory attribute, value of wrong type.  Such error cause Rule
   * construction to be aborted, so the resulting package will have missing
   * members.
   *
   * @see PackageFactory#PackageFactory
   */
  @VisibleForTesting // used by PackageFactoryApparatus
  public Package.LegacyBuilder evaluateBuildFile(
      Package externalPkg,
      PackageIdentifier packageId,
      BuildFileAST buildFileAST,
      Path buildFilePath,
      Globber globber,
      Iterable<Event> pastEvents,
      RuleVisibility defaultVisibility,
      boolean containsError,
      MakeEnvironment.Builder pkgMakeEnv,
      Map<PathFragment, Extension> imports,
      ImmutableList<Label> skylarkFileDependencies)
      throws InterruptedException {
    Package.LegacyBuilder pkgBuilder = new Package.LegacyBuilder(
        packageId, ruleClassProvider.getRunfilesPrefix());
    StoredEventHandler eventHandler = new StoredEventHandler();

    try (Mutability mutability = Mutability.create("package %s", packageId)) {
      Environment pkgEnv = Environment.builder(mutability)
          .setGlobals(Environment.BUILD)
          .setEventHandler(eventHandler)
          .setImportedExtensions(imports)
          .setLoadingPhase()
          .build();

      pkgBuilder.setGlobber(globber)
          .setFilename(buildFilePath)
          .setMakeEnv(pkgMakeEnv)
          .setDefaultVisibility(defaultVisibility)
          // "defaultVisibility" comes from the command line. Let's give the BUILD file a chance to
          // set default_visibility once, be reseting the PackageBuilder.defaultVisibilitySet flag.
          .setDefaultVisibilitySet(false)
          .setSkylarkFileDependencies(skylarkFileDependencies)
          .setWorkspaceName(externalPkg.getWorkspaceName());

      Event.replayEventsOn(eventHandler, pastEvents);

      // Stuff that closes over the package context:
      PackageContext context = new PackageContext(pkgBuilder, globber, eventHandler);
      buildPkgEnv(pkgEnv, context, ruleFactory);
      pkgEnv.setupDynamic(PKG_CONTEXT, context);
      pkgEnv.setupDynamic(Runtime.PKG_NAME, packageId.toString());

      if (containsError) {
        pkgBuilder.setContainsErrors();
      }

      if (!validatePackageIdentifier(packageId, buildFileAST.getLocation(), eventHandler)) {
        pkgBuilder.setContainsErrors();
      }

      if (!validateAssignmentStatements(pkgEnv, buildFileAST, eventHandler)) {
        pkgBuilder.setContainsErrors();
      }

      if (buildFileAST.containsErrors()) {
        pkgBuilder.setContainsErrors();
      }

      // TODO(bazel-team): (2009) the invariant "if errors are reported, mark the package
      // as containing errors" is strewn all over this class.  Refactor to use an
      // event sensor--and see if we can simplify the calling code in
      // createPackage().
      if (!buildFileAST.exec(pkgEnv, eventHandler)) {
        pkgBuilder.setContainsErrors();
      }
    }

    pkgBuilder.addEvents(eventHandler.getEvents());
    return pkgBuilder;
  }

  /**
   * Visit all targets and expand the globs in parallel.
   */
  private void prefetchGlobs(PackageIdentifier packageId, BuildFileAST buildFileAST,
      boolean wasPreprocessed, Path buildFilePath, Globber globber,
      RuleVisibility defaultVisibility, MakeEnvironment.Builder pkgMakeEnv)
      throws InterruptedException {
    if (wasPreprocessed) {
      // No point in prefetching globs here: preprocessing implies eager evaluation
      // of all globs.
      return;
    }
    try (Mutability mutability = Mutability.create("prefetchGlobs for %s", packageId)) {
      Environment pkgEnv = Environment.builder(mutability)
          .setGlobals(Environment.BUILD)
          .setEventHandler(NullEventHandler.INSTANCE)
          .setLoadingPhase()
          .build();

      Package.LegacyBuilder pkgBuilder = new Package.LegacyBuilder(packageId,
          ruleClassProvider.getRunfilesPrefix());

      pkgBuilder.setFilename(buildFilePath)
          .setMakeEnv(pkgMakeEnv)
          .setDefaultVisibility(defaultVisibility)
          // "defaultVisibility" comes from the command line. Let's give the BUILD file a chance to
          // set default_visibility once, be reseting the PackageBuilder.defaultVisibilitySet flag.
          .setDefaultVisibilitySet(false);

      // Stuff that closes over the package context:
      PackageContext context = new PackageContext(pkgBuilder, globber, NullEventHandler.INSTANCE);
      buildPkgEnv(pkgEnv, context, ruleFactory);
      try {
        pkgEnv.update("glob", newGlobFunction.apply(context, /*async=*/true));
        // The Fileset function is heavyweight in that it can run glob(). Avoid this during the
        // preloading phase.
        pkgEnv.update("FilesetEntry", Runtime.NONE);
      } catch (EvalException e) {
        throw new AssertionError(e);
      }
      buildFileAST.exec(pkgEnv, NullEventHandler.INSTANCE);
    }
  }


  /**
   * Tests a build AST to ensure that it contains no assignment statements that
   * redefine built-in build rules.
   *
   * @param pkgEnv a package environment initialized with all of the built-in
   *        build rules
   * @param ast the build file AST to be tested
   * @param eventHandler a eventHandler where any errors should be logged
   * @return true if the build file contains no redefinitions of built-in
   *         functions
   */
  // TODO(bazel-team): Remove this check. It should be moved to LValue.assign
  private static boolean validateAssignmentStatements(
      Environment pkgEnv, BuildFileAST ast, EventHandler eventHandler) {
    for (Statement stmt : ast.getStatements()) {
      if (stmt instanceof AssignmentStatement) {
        Expression lvalue = ((AssignmentStatement) stmt).getLValue().getExpression();
        if (!(lvalue instanceof Identifier)) {
          continue;
        }
        String target = ((Identifier) lvalue).getName();
        if (pkgEnv.lookup(target, null) != null) {
          eventHandler.handle(Event.error(stmt.getLocation(), "Reassignment of builtin build "
              + "function '" + target + "' not permitted"));
          return false;
        }
      }
    }
    return true;
  }

  // Reports an error and returns false iff package identifier was illegal.
  private static boolean validatePackageIdentifier(PackageIdentifier packageId, Location location,
      EventHandler eventHandler) {
    String error = LabelValidator.validatePackageName(packageId.getPackageFragment().toString());
    if (error != null) {
      eventHandler.handle(Event.error(location, error));
      return false; // Invalid package name 'foo'
    }
    return true;
  }

  static {
    SkylarkSignatureProcessor.configureSkylarkFunctions(PackageFactory.class);
  }
}
