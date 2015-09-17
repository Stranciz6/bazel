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

package com.google.devtools.build.lib.syntax;

import com.google.common.annotations.VisibleForTesting;
import com.google.common.base.Joiner;
import com.google.common.base.Preconditions;
import com.google.common.collect.ImmutableList;
import com.google.common.collect.ImmutableMap;
import com.google.devtools.build.lib.cmdline.PackageIdentifier;
import com.google.devtools.build.lib.events.Event;
import com.google.devtools.build.lib.events.EventHandler;
import com.google.devtools.build.lib.events.EventKind;
import com.google.devtools.build.lib.events.Location;
import com.google.devtools.build.lib.packages.CachingPackageLocator;
import com.google.devtools.build.lib.syntax.Mutability.Freezable;
import com.google.devtools.build.lib.syntax.Mutability.MutabilityException;
import com.google.devtools.build.lib.util.Fingerprint;
import com.google.devtools.build.lib.util.Pair;
import com.google.devtools.build.lib.vfs.Path;
import com.google.devtools.build.lib.vfs.PathFragment;

import java.io.Serializable;
import java.util.HashMap;
import java.util.HashSet;
import java.util.List;
import java.util.Map;
import java.util.Set;
import java.util.TreeSet;

import javax.annotation.Nullable;

/**
 * An Environment is the main entry point to evaluating code in the BUILD language or Skylark.
 * It embodies all the state that is required to evaluate such code,
 * except for the current instruction pointer, which is an {@link ASTNode}
 * whose {@link Statement#exec exec} or {@link Expression#eval eval} method is invoked with
 * this Environment, in a straightforward direct-style AST-walking interpreter.
 * {@link Continuation}-s are explicitly represented, but only partly, with another part being
 * implicit in a series of try-catch statements, to maintain the direct style. One notable trick
 * is how a {@link UserDefinedFunction} implements returning values as the function catching a
 * {@link ReturnStatement.ReturnException} thrown by a {@link ReturnStatement} in the body.
 *
 * <p>Every Environment has a {@link Mutability} field, and must be used within a function that
 * creates and closes this {@link Mutability} with the try-with-resource pattern.
 * This {@link Mutability} is also used when initializing mutable objects within that Environment;
 * when closed at the end of the computation freezes the Environment and all those objects that
 * then become forever immutable. The pattern enforces the discipline that there should be no
 * dangling mutable Environment, or concurrency between interacting Environment-s.
 * It is also an error to try to mutate an Environment and its objects from another Environment,
 * before the {@link Mutability} is closed.
 *
 * <p>One creates an Environment using the {@link #builder} function, then
 * populates it with {@link #setup}, {@link #setupDynamic} and sometimes {@link #setupOverride},
 * before to evaluate code in it with {@link #eval}, or with {@link BuildFileAST#exec}
 * (where the AST was obtained by passing a {@link ValidationEnvironment} constructed from the
 * Environment to {@link BuildFileAST#parseBuildFile} or {@link BuildFileAST#parseSkylarkFile}).
 * When the computation is over, the frozen Environment can still be queried with {@link #lookup}.
 *
 * <p>Final fields of an Environment represent its dynamic state, i.e. state that remains the same
 * throughout a given evaluation context, and don't change with source code location,
 * while mutable fields embody its static state, that change with source code location.
 * The seeming paradox is that the words "dynamic" and "static" refer to the point of view
 * of the source code, and here we have a dual point of view.
 */
public final class Environment implements Freezable {

  /**
   * A Frame is a Map of bindings, plus a {@link Mutability} and a parent Frame
   * from which to inherit bindings.
   *
   * <p>A Frame contains bindings mapping variable name to variable value in a given scope.
   * It may also inherit bindings from a parent Frame corresponding to a parent scope,
   * which in turn may inherit bindings from its own parent, etc., transitively.
   * Bindings may shadow bindings from the parent. In Skylark, you may only mutate
   * bindings from the current Frame, which always got its {@link Mutability} with the
   * current {@link Environment}; but future extensions may make it more like Python
   * and allow mutation of bindings in outer Frame-s (or then again may not).
   *
   * <p>A Frame inherits the {@link Mutability} from the {@link Environment} in which it was
   * originally created. When that {@link Environment} is finalized and its {@link Mutability}
   * is closed, it becomes immutable, including the Frame, which can be shared in other
   * {@link Environment}-s. Indeed, a {@link UserDefinedFunction} will close over the global
   * Frame of its definition {@link Environment}, which will thus be reused (immutably)
   * in all any {@link Environment} in which this function is called, so it's important to
   * preserve the {@link Mutability} to make sure no Frame is modified after it's been finalized.
   */
  public static final class Frame implements Freezable {

    private final Mutability mutability;
    final Frame parent;
    final Map<String, Object> bindings = new HashMap<>();

    Frame(Mutability mutability, Frame parent) {
      this.mutability = mutability;
      this.parent = parent;
    }

    @Override
    public final Mutability mutability() {
      return mutability;
    }

    /**
     * Gets a binding from the current frame or if not found its parent.
     * @param varname the name of the variable to be bound
     * @return the value bound to variable
     */
    public Object get(String varname) {
      if (bindings.containsKey(varname)) {
        return bindings.get(varname);
      }
      if (parent != null) {
        return parent.get(varname);
      }
      return null;
    }

    /**
     * Modifies a binding in the current Frame.
     * Does not try to modify an inherited binding.
     * This will shadow any inherited binding, which may be an error
     * that you want to guard against before calling this function.
     * @param env the Environment attempting the mutation
     * @param varname the name of the variable to be bound
     * @param value the value to bind to the variable
     */
    public void put(Environment env, String varname, Object value)
        throws MutabilityException {
      Mutability.checkMutable(this, env);
      bindings.put(varname, value);
    }

    /**
     * Adds the variable names of this Frame and its transitive parents to the given set.
     * This provides a O(n) way of extracting the list of all variables visible in an Environment.
     * @param vars the set of visible variables in the Environment, being computed.
     */
    public void addVariableNamesTo(Set<String> vars) {
      vars.addAll(bindings.keySet());
      if (parent != null) {
        parent.addVariableNamesTo(vars);
      }
    }

    public Set<String> getDirectVariableNames() {
      return bindings.keySet();
    }

    @Override
    public String toString() {
      String prefix = "Frame";
      StringBuilder sb = new StringBuilder();
      for (Frame f = this; f != null; f = f.parent) {
        Printer.formatTo(sb, "%s%s%r",
            ImmutableList.<Object>of(prefix, f.mutability(), f.bindings));
        prefix = "=>";
      }
      return sb.toString();
    }
  }

  /**
   * A Continuation contains data saved during a function call and restored when the function exits.
   */
  private static final class Continuation {
    /** The {@link BaseFunction} being evaluated that will return into this Continuation. */
    BaseFunction function;

    /** The {@link FuncallExpression} to which this Continuation will return. */
    FuncallExpression caller;

    /** The next Continuation after this Continuation. */
    @Nullable Continuation continuation;

    /** The lexical Frame of the caller. */
    Frame lexicalFrame;

    /** The global Frame of the caller. */
    Frame globalFrame;

    /** The set of known global variables of the caller. */
    @Nullable Set<String> knownGlobalVariables;

    /** Whether the caller is in Skylark mode. */
    boolean isSkylark;

    Continuation(
        Continuation continuation,
        BaseFunction function,
        FuncallExpression caller,
        Frame lexicalFrame,
        Frame globalFrame,
        Set<String> knownGlobalVariables,
        boolean isSkylark) {
      this.continuation = continuation;
      this.function = function;
      this.caller = caller;
      this.lexicalFrame = lexicalFrame;
      this.globalFrame = globalFrame;
      this.isSkylark = isSkylark;
    }
  }

  // TODO(bazel-team): Fix this scary failure of serializability.
  // skyframe.SkylarkImportLookupFunction processes a .bzl and returns an Extension,
  // for use by whoever imports the .bzl file. Skyframe may subsequently serialize the results.
  // And it will fail to process these bindings, because they are inherited from a non-serializable
  // class (in previous versions of the code the serializable SkylarkEnvironment was inheriting
  // from the non-serializable Environment and being returned by said Function).
  // If we try to merge this otherwise redundant superclass into Extension, though,
  // skyframe experiences a massive failure to serialize things, and it's unclear how far
  // reaching the need to make things Serializable goes, though clearly we'll need to make
  // a whole lot of things Serializable, and for efficiency, we'll want to implement sharing
  // of imported values rather than a code explosion.
  private static class BaseExtension {
    final ImmutableMap<String, Object> bindings;
    BaseExtension(Environment env) {
      this.bindings = ImmutableMap.copyOf(env.globalFrame.bindings);
    }

    // Hack to allow serialization.
    BaseExtension() {
      this.bindings = ImmutableMap.of();
    }
  }

  /**
   * An Extension to be imported with load() into a BUILD or .bzl file.
   */
  public static final class Extension extends BaseExtension implements Serializable {

    private final String transitiveContentHashCode;

    /**
     * Constructs an Extension by extracting the new global definitions from an Environment.
     * Also caches a hash code for the transitive content of the file and its dependencies.
     * @param env the Environment from which to extract an Extension.
     */
    public Extension(Environment env) {
      super(env);
      this.transitiveContentHashCode = env.getTransitiveContentHashCode();
    }

    // Hack to allow serialization.
    private Extension() {
      super();
      this.transitiveContentHashCode = null;
    }

    @VisibleForTesting // This is only used in one test.
    public String getTransitiveContentHashCode() {
      return transitiveContentHashCode;
    }

    /** get the value bound to a variable in this Extension */
    public Object get(String varname) {
      return bindings.get(varname);
    }

    /** does this Extension contain a binding for the named variable? */
    public boolean containsKey(String varname) {
      return bindings.containsKey(varname);
    }
  }

  /**
   * Static Frame for lexical variables that are always looked up in the current Environment
   * or for the definition Environment of the function currently being evaluated.
   */
  private Frame lexicalFrame;

  /**
   * Static Frame for global variables; either the current lexical Frame if evaluation is currently
   * happening at the global scope of a BUILD file, or the global Frame at the time of function
   * definition if evaluation is currently happening in the body of a function. Thus functions can
   * close over other functions defined in the same file.
   */
  private Frame globalFrame;

  /**
   * Dynamic Frame for variables that are always looked up in the runtime Environment,
   * and never in the lexical or "global" Environment as it was at the time of function definition.
   * For instance, PACKAGE_NAME.
   */
  private final Frame dynamicFrame;

  /**
   * An EventHandler for errors and warnings. This is not used in the BUILD language,
   * however it might be used in Skylark code called from the BUILD language, so shouldn't be null.
   */
  private final EventHandler eventHandler;

  /**
   * For each imported extensions, a global Skylark frame from which to load() individual bindings.
   */
  private final Map<PathFragment, Extension> importedExtensions;

  /**
   * Is this Environment being executed in Skylark context?
   */
  private boolean isSkylark;

  /**
   * Is this Environment being executed during the loading phase?
   * Many builtin functions are only enabled during the loading phase, and check this flag.
   */
  private final boolean isLoadingPhase;

  /**
   * When in a lexical (Skylark) Frame, this set contains the variable names that are global,
   * as determined not by global declarations (not currently supported),
   * but by previous lookups that ended being global or dynamic.
   * This is necessary because if in a function definition something
   * reads a global variable after which a local variable with the same name is assigned an
   * Exception needs to be thrown.
   */
  @Nullable private Set<String> knownGlobalVariables;

  /**
   * When in a lexical (Skylark) frame, this lists the names of the functions in the call stack.
   * We currently use it to artificially disable recursion.
   */
  @Nullable private Continuation continuation;

  /**
   * Enters a scope by saving state to a new Continuation
   * @param function the function whose scope to enter
   * @param caller the source AST node for the caller
   * @param globals the global Frame that this function closes over from its definition Environment
   */
  void enterScope(BaseFunction function, FuncallExpression caller, Frame globals) {
    continuation = new Continuation(
        continuation, function, caller, lexicalFrame, globalFrame, knownGlobalVariables, isSkylark);
    lexicalFrame = new Frame(mutability(), null);
    globalFrame = globals;
    knownGlobalVariables = new HashSet<String>();
    isSkylark = true;
  }

  /**
   * Exits a scope by restoring state from the current continuation
   */
  void exitScope() {
    Preconditions.checkNotNull(continuation);
    lexicalFrame = continuation.lexicalFrame;
    globalFrame = continuation.globalFrame;
    knownGlobalVariables = continuation.knownGlobalVariables;
    isSkylark = continuation.isSkylark;
    continuation = continuation.continuation;
  }

  /**
   * When evaluating code from a file, this contains a hash of the file.
   */
  @Nullable private String fileContentHashCode;

  /**
   * Is this Environment being evaluated during the loading phase?
   * This is fixed during Environment setup, and enables various functions
   * that are not available during the analysis phase.
   * @return true if this Environment corresponds to code during the loading phase.
   */
  private boolean isLoadingPhase() {
    return isLoadingPhase;
  }

  /**
   * Checks that the current Environment is in the loading phase.
   * @param symbol name of the function being only authorized thus.
   */
  public void checkLoadingPhase(String symbol, Location loc) throws EvalException {
    if (!isLoadingPhase()) {
      throw new EvalException(loc, symbol + "() can only be called during the loading phase");
    }
  }

  /**
   * Is this a global Environment?
   * @return true if the current code is being executed at the top-level,
   * as opposed to inside the body of a function.
   */
  boolean isGlobal() {
    return lexicalFrame == null;
  }

  /**
   * Is the current code Skylark?
   * @return true if Skylark was enabled when this code was read.
   */
  // TODO(bazel-team): Delete this function.
  // This function is currently used in various functions that change their behavior with respect to
  // lists depending on the Skylark-ness of the code; lists should be unified between the two modes.
  boolean isSkylark() {
    return isSkylark;
  }

  /**
   * Is the caller of the current function executing Skylark code?
   * @return true if this is skylark was enabled when this code was read.
   */
  // TODO(bazel-team): Delete this function.
  // This function is currently used by MethodLibrary to modify behavior of lists
  // depending on the Skylark-ness of the code; lists should be unified between the two modes.
  boolean isCallerSkylark() {
    return continuation.isSkylark;
  }

  @Override
  public Mutability mutability() {
    // the mutability of the environment is that of its dynamic frame.
    return dynamicFrame.mutability();
  }

  /**
   * @return the current Frame, in which variable side-effects happen.
   */
  private Frame currentFrame() {
    return isGlobal() ? globalFrame : lexicalFrame;
  }

  /**
   * @return the global variables for the Environment (not including dynamic bindings).
   */
  public Frame getGlobals() {
    return globalFrame;
  }

  /**
   * Returns an EventHandler for errors and warnings.
   * The BUILD language doesn't use it directly, but can call Skylark code that does use it.
   * @return an EventHandler
   */
  public EventHandler getEventHandler() {
    return eventHandler;
  }

  /**
   * @return the current stack trace as a list of functions.
   */
  public ImmutableList<BaseFunction> getStackTrace() {
    ImmutableList.Builder<BaseFunction> builder = new ImmutableList.Builder<>();
    for (Continuation k = continuation; k != null; k = k.continuation) {
      builder.add(k.function);
    }
    return builder.build().reverse();
  }


  /**
   * Returns the FuncallExpression and the BaseFunction for the top-level call being evaluated.
   */
  public Pair<FuncallExpression, BaseFunction> getTopCall() {
    Continuation continuation = this.continuation;
    if (continuation == null) {
      return null;
    }
    while (continuation.continuation != null) {
      continuation = continuation.continuation;
    }
    return new Pair<>(continuation.caller, continuation.function);
  }

  /**
   * Constructs an Environment.
   * This is the main, most basic constructor.
   * @param globalFrame a frame for the global Environment
   * @param dynamicFrame a frame for the dynamic Environment
   * @param eventHandler an EventHandler for warnings, errors, etc
   * @param importedExtensions Extension-s from which to import bindings with load()
   * @param isSkylark true if in Skylark context
   * @param fileContentHashCode a hash for the source file being evaluated, if any
   * @param isLoadingPhase true if in loading phase
   */
  private Environment(
      Frame globalFrame,
      Frame dynamicFrame,
      EventHandler eventHandler,
      Map<PathFragment, Extension> importedExtensions,
      boolean isSkylark,
      @Nullable String fileContentHashCode,
      boolean isLoadingPhase) {
    this.globalFrame = Preconditions.checkNotNull(globalFrame);
    this.dynamicFrame = Preconditions.checkNotNull(dynamicFrame);
    Preconditions.checkArgument(globalFrame.mutability().isMutable());
    Preconditions.checkArgument(dynamicFrame.mutability().isMutable());
    this.eventHandler = eventHandler;
    this.importedExtensions = importedExtensions;
    this.isSkylark = isSkylark;
    this.fileContentHashCode = fileContentHashCode;
    this.isLoadingPhase = isLoadingPhase;
  }

  /**
   * A Builder class for Environment
   */
  public static class Builder {
    private final Mutability mutability;
    private boolean isSkylark = false;
    private boolean isLoadingPhase = false;
    @Nullable private Frame parent;
    @Nullable private EventHandler eventHandler;
    @Nullable private Map<PathFragment, Extension> importedExtensions;
    @Nullable private String fileContentHashCode;

    Builder(Mutability mutability) {
      this.mutability = mutability;
    }

    /** Enables Skylark for code read in this Environment. */
    public Builder setSkylark() {
      Preconditions.checkState(!isSkylark);
      isSkylark = true;
      return this;
    }

    /** Enables loading phase only functions in this Environment. */
    public Builder setLoadingPhase() {
      Preconditions.checkState(!isLoadingPhase);
      isLoadingPhase = true;
      return this;
    }

    /** Inherits global bindings from the given parent Frame. */
    public Builder setGlobals(Frame parent) {
      Preconditions.checkState(this.parent == null);
      this.parent = parent;
      return this;
    }

    /** Sets an EventHandler for errors and warnings. */
    public Builder setEventHandler(EventHandler eventHandler) {
      Preconditions.checkState(this.eventHandler == null);
      this.eventHandler = eventHandler;
      return this;
    }

    /** Declares imported extensions for load() statements. */
    public Builder setImportedExtensions (Map<PathFragment, Extension> importedExtensions) {
      Preconditions.checkState(this.importedExtensions == null);
      this.importedExtensions = importedExtensions;
      return this;
    }

    /** Declares content hash for the source file for this Environment. */
    public Builder setFileContentHashCode(String fileContentHashCode) {
      this.fileContentHashCode = fileContentHashCode;
      return this;
    }

    /** Builds the Environment. */
    public Environment build() {
      Preconditions.checkArgument(mutability.isMutable());
      if (parent != null) {
        Preconditions.checkArgument(!parent.mutability().isMutable());
      }
      Frame globalFrame = new Frame(mutability, parent);
      Frame dynamicFrame = new Frame(mutability, null);
      if (importedExtensions == null) {
        importedExtensions = ImmutableMap.of();
      }
      Environment env = new Environment(
          globalFrame,
          dynamicFrame,
          eventHandler,
          importedExtensions,
          isSkylark,
          fileContentHashCode,
          isLoadingPhase);
      return env;
    }
  }

  public static Builder builder(Mutability mutability) {
    return new Builder(mutability);
  }

  /**
   * Sets a binding for a special dynamic variable in this Environment.
   * This is not for end-users, and will throw an AssertionError in case of conflict.
   * @param varname the name of the dynamic variable to be bound
   * @param value a value to bind to the variable
   * @return this Environment, in fluid style
   */
  public Environment setupDynamic(String varname, Object value) {
    if (dynamicFrame.get(varname) != null) {
      throw new AssertionError(
          String.format("Trying to bind dynamic variable '%s' but it is already bound",
              varname));
    }
    if (lexicalFrame != null && lexicalFrame.get(varname) != null) {
      throw new AssertionError(
          String.format("Trying to bind dynamic variable '%s' but it is already bound lexically",
              varname));
    }
    if (globalFrame.get(varname) != null) {
      throw new AssertionError(
          String.format("Trying to bind dynamic variable '%s' but it is already bound globally",
              varname));
    }
    try {
      dynamicFrame.put(this, varname, value);
    } catch (MutabilityException e) {
      // End users don't have access to setupDynamic, and it is an implementation error
      // if we encounter a mutability exception.
      throw new AssertionError(
          Printer.format(
              "Trying to bind dynamic variable '%s' in frozen environment %r", varname, this),
          e);
    }
    return this;
  }


  /**
   * Modifies a binding in the current Frame of this Environment, as would an
   * {@link AssignmentStatement}. Does not try to modify an inherited binding.
   * This will shadow any inherited binding, which may be an error
   * that you want to guard against before calling this function.
   * @param varname the name of the variable to be bound
   * @param value the value to bind to the variable
   * @return this Environment, in fluid style
   */
  public Environment update(String varname, Object value) throws EvalException {
    Preconditions.checkNotNull(value, "update(value == null)");
    // prevents clashes between static and dynamic variables.
    if (dynamicFrame.get(varname) != null) {
      throw new EvalException(
          null, String.format("Trying to update special read-only global variable '%s'", varname));
    }
    if (isKnownGlobalVariable(varname)) {
      throw new EvalException(
          null, String.format("Trying to update read-only global variable '%s'", varname));
    }
    try {
      currentFrame().put(this, varname, Preconditions.checkNotNull(value));
    } catch (MutabilityException e) {
      // Note that since at this time we don't accept the global keyword, and don't have closures,
      // end users should never be able to mutate a frozen Environment, and a MutabilityException
      // is therefore a failed assertion for Bazel. However, it is possible to shadow a binding
      // imported from a parent Environment by updating the current Environment, which will not
      // trigger a MutabilityException.
      throw new AssertionError(
          Printer.format("Can't update %s to %r in frozen environment", varname, value),
          e);
    }
    return this;
  }

  private boolean hasVariable(String varname) {
    try {
      lookup(varname);
      return true;
    } catch (NoSuchVariableException e) {
      return false;
    }
  }

  /**
   * Initializes a binding in this Environment. It is an error if the variable is already bound.
   * This is not for end-users, and will throw an AssertionError in case of conflict.
   * @param varname the name of the variable to be bound
   * @param value the value to bind to the variable
   * @return this Environment, in fluid style
   */
  public Environment setup(String varname, Object value) {
    if (hasVariable(varname)) {
      throw new AssertionError(String.format("variable '%s' already bound", varname));
    }
    return setupOverride(varname, value);
  }

  /**
   * Initializes a binding in this environment. Overrides any previous binding.
   * This is not for end-users, and will throw an AssertionError in case of conflict.
   * @param varname the name of the variable to be bound
   * @param value the value to bind to the variable
   * @return this Environment, in fluid style
   */
  public Environment setupOverride(String varname, Object value) {
    try {
      return update(varname, value);
    } catch (EvalException ee) {
      throw new AssertionError(ee);
    }
  }

  /**
   * @return the value from the environment whose name is "varname".
   * @throws NoSuchVariableException if the variable is not defined in the Environment.
   */
  public Object lookup(String varname) throws NoSuchVariableException {
    // Which Frame to lookup first doesn't matter because update prevents clashes.
    if (lexicalFrame != null) {
      Object lexicalValue = lexicalFrame.get(varname);
      if (lexicalValue != null) {
        return lexicalValue;
      }
    }
    Object globalValue = globalFrame.get(varname);
    Object dynamicValue = dynamicFrame.get(varname);
    if (globalValue == null && dynamicValue == null) {
      throw new NoSuchVariableException(varname);
    }
    if (knownGlobalVariables != null) {
      knownGlobalVariables.add(varname);
    }
    if (globalValue != null) {
      return globalValue;
    }
    return dynamicValue;
  }

  /**
   * Like {@link #lookup(String)}, but instead of throwing an exception in the case
   * where <code>varname</code> is not defined, <code>defaultValue</code> is returned instead.
   */
  public Object lookup(String varname, Object defaultValue) {
    Preconditions.checkState(!isSkylark);
    try {
      return lookup(varname);
    } catch (NoSuchVariableException e) {
      return defaultValue;
    }
  }

  /**
   * @return true if varname is a known global variable,
   * because it has been read in the context of the current function.
   */
  boolean isKnownGlobalVariable(String varname) {
    return knownGlobalVariables != null && knownGlobalVariables.contains(varname);
  }

  public void handleEvent(Event event) {
    eventHandler.handle(event);
  }

  /**
   * @return the (immutable) set of names of all variables defined in this
   * Environment. Exposed for testing.
   */
  @VisibleForTesting
  public Set<String> getVariableNames() {
    Set<String> vars = new HashSet<>();
    if (lexicalFrame != null) {
      lexicalFrame.addVariableNamesTo(vars);
    }
    globalFrame.addVariableNamesTo(vars);
    dynamicFrame.addVariableNamesTo(vars);
    return vars;
  }

  @Override
  public int hashCode() {
    throw new UnsupportedOperationException(); // avoid nondeterminism
  }

  @Override
  public boolean equals(Object that) {
    throw new UnsupportedOperationException();
  }

  @Override
  public String toString() {
    StringBuilder out = new StringBuilder();
    out.append("Environment(lexicalFrame=");
    out.append(lexicalFrame);
    out.append(", globalFrame=");
    out.append(globalFrame);
    out.append(", dynamicFrame=");
    out.append(dynamicFrame);
    out.append(", eventHandler.getClass()=");
    out.append(eventHandler.getClass());
    out.append(", importedExtensions=");
    out.append(importedExtensions);
    out.append(", isSkylark=");
    out.append(isSkylark);
    out.append(", fileContentHashCode=");
    out.append(fileContentHashCode);
    out.append(", isLoadingPhase=");
    out.append(isLoadingPhase);
    out.append(")");
    return out.toString();
  }

  /**
   * An Exception thrown when an attempt is made to lookup a non-existent
   * variable in the Environment.
   */
  public static class NoSuchVariableException extends Exception {
    NoSuchVariableException(String variable) {
      super("no such variable: " + variable);
    }
  }

  /**
   * An Exception thrown when an attempt is made to import a symbol from a file
   * that was not properly loaded.
   */
  public static class LoadFailedException extends Exception {
    LoadFailedException(PathFragment extension) {
      super(String.format("file '%s' was not correctly loaded. "
              + "Make sure the 'load' statement appears in the global scope in your file",
              extension));
    }
  }

  public void importSymbol(PathFragment extension, Identifier symbol, String nameInLoadedFile)
      throws NoSuchVariableException, LoadFailedException {
    Preconditions.checkState(isGlobal()); // loading is only allowed at global scope.

    if (!importedExtensions.containsKey(extension)) {
      throw new LoadFailedException(extension);
    }

    Extension ext = importedExtensions.get(extension);

    // TODO(bazel-team): Throw a LoadFailedException instead, with an appropriate message.
    // Throwing a NoSuchVariableException is backward compatible, but backward.
    if (!ext.containsKey(nameInLoadedFile)) {
      throw new NoSuchVariableException(nameInLoadedFile);
    }

    Object value = ext.get(nameInLoadedFile);
    // TODO(bazel-team): Unify data structures between Skylark and BUILD,
    // and stop doing the conversions below:
    if (!isSkylark) {
      value = SkylarkType.convertFromSkylark(value);
    }

    try {
      update(symbol.getName(), value);
    } catch (EvalException e) {
      throw new LoadFailedException(extension);
    }
  }

  /**
   * Returns a hash code calculated from the hash code of this Environment and the
   * transitive closure of other Environments it loads.
   */
  public String getTransitiveContentHashCode() {
    // Calculate a new hash from the hash of the loaded Extension-s.
    Fingerprint fingerprint = new Fingerprint();
    fingerprint.addString(Preconditions.checkNotNull(fileContentHashCode));
    TreeSet<PathFragment> paths = new TreeSet<>(importedExtensions.keySet());
    for (PathFragment path : paths) {
      fingerprint.addString(importedExtensions.get(path).getTransitiveContentHashCode());
    }
    return fingerprint.hexDigestAndReset();
  }


  /** A read-only Environment.Frame with global constants in it only */
  public static final Frame CONSTANTS_ONLY = createConstantsGlobals();

  /** A read-only Environment.Frame with initial globals for the BUILD language */
  public static final Frame BUILD = createBuildGlobals();

  /** A read-only Environment.Frame with initial globals for Skylark */
  public static final Frame SKYLARK = createSkylarkGlobals();

  private static Environment.Frame createConstantsGlobals() {
    try (Mutability mutability = Mutability.create("CONSTANTS")) {
      Environment env = Environment.builder(mutability).build();
      Runtime.setupConstants(env);
      return env.getGlobals();
    }
  }

  private static Environment.Frame createBuildGlobals() {
    try (Mutability mutability = Mutability.create("BUILD")) {
      Environment env = Environment.builder(mutability).build();
      Runtime.setupConstants(env);
      Runtime.setupMethodEnvironment(env, MethodLibrary.buildGlobalFunctions);
      return env.getGlobals();
    }
  }

  private static Environment.Frame createSkylarkGlobals() {
    try (Mutability mutability = Mutability.create("SKYLARK")) {
      Environment env = Environment.builder(mutability).setSkylark().build();
      Runtime.setupConstants(env);
      Runtime.setupMethodEnvironment(env, MethodLibrary.skylarkGlobalFunctions);
      return env.getGlobals();
    }
  }


  /**
   * The fail fast handler, which throws a AssertionError whenever an error or warning occurs.
   */
  public static final EventHandler FAIL_FAST_HANDLER = new EventHandler() {
      @Override
      public void handle(Event event) {
        Preconditions.checkArgument(
            !EventKind.ERRORS_AND_WARNINGS.contains(event.getKind()), event);
      }
    };

  /** Mock package locator class */
  private static final class EmptyPackageLocator implements CachingPackageLocator {
    @Override
    public Path getBuildFileForPackage(PackageIdentifier packageName) {
      return null;
    }
  }

  /** A mock package locator */
  @VisibleForTesting
  static final CachingPackageLocator EMPTY_PACKAGE_LOCATOR = new EmptyPackageLocator();

  /**
   * Creates a Lexer without a supporting file.
   * @param input a list of lines of code
   */
  @VisibleForTesting
  Lexer createLexer(String... input) {
    return new Lexer(ParserInputSource.create(Joiner.on("\n").join(input), null),
        eventHandler);
  }

  /**
   * Parses some String input without a supporting file, returning statements and comments.
   * @param input a list of lines of code
   */
  @VisibleForTesting
  Parser.ParseResult parseFileWithComments(String... input) {
    return isSkylark
        ? Parser.parseFileForSkylark(
            createLexer(input),
            eventHandler,
            EMPTY_PACKAGE_LOCATOR,
            new ValidationEnvironment(this))
        : Parser.parseFile(
              createLexer(input),
              eventHandler,
              EMPTY_PACKAGE_LOCATOR,
              /*parsePython=*/false);
  }

  /**
   * Parses some String input without a supporting file, returning statements only.
   * @param input a list of lines of code
   */
  @VisibleForTesting
  List<Statement> parseFile(String... input) {
    return parseFileWithComments(input).statements;
  }

  /**
   * Evaluates code some String input without a supporting file.
   * @param input a list of lines of code to evaluate
   * @return the value of the last statement if it's an Expression or else null
   */
  @Nullable public Object eval(String... input) throws EvalException, InterruptedException {
    Object last = null;
    for (Statement statement : parseFile(input)) {
      if (statement instanceof ExpressionStatement) {
        last = ((ExpressionStatement) statement).getExpression().eval(this);
      } else {
        statement.exec(this);
        last = null;
      }
    }
    return last;
  }
}
