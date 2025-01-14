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
package com.google.devtools.common.options;

import com.google.devtools.common.options.OptionsParser.OptionUsageRestrictions;
import com.google.devtools.common.options.proto.OptionFilters.OptionEffectTag;
import com.google.devtools.common.options.proto.OptionFilters.OptionMetadataTag;
import java.lang.annotation.ElementType;
import java.lang.annotation.Retention;
import java.lang.annotation.RetentionPolicy;
import java.lang.annotation.Target;

/**
 * An interface for annotating fields in classes (derived from OptionsBase)
 * that are options.
 */
@Target(ElementType.FIELD)
@Retention(RetentionPolicy.RUNTIME)
public @interface Option {
  /**
   * The name of the option ("--name").
   */
  String name();

  /**
   * The single-character abbreviation of the option ("-abbrev").
   */
  char abbrev() default '\0';

  /**
   * A help string for the usage information.
   */
  String help() default "";

  /**
   * A short text string to describe the type of the expected value. E.g., <code>regex</code>. This
   * is ignored for boolean, tristate, boolean_or_enum, and void options.
   */
  String valueHelp() default "";

  /**
   * The default value for the option. This method should only be invoked directly by the parser
   * implementation. Any access to default values should go via the parser to allow for application
   * specific defaults.
   *
   * <p>There are two reasons this is a string. Firstly, it ensures that explicitly specifying this
   * option at its default value (as printed in the usage message) has the same behavior as not
   * specifying the option at all; this would be very hard to achieve if the default value was an
   * instance of type T, since we'd need to ensure that {@link #toString()} and {@link #converter}
   * were dual to each other. The second reason is more mundane but also more restrictive:
   * annotation values must be compile-time constants.
   *
   * <p>If an option's defaultValue() is the string "null", the option's converter will not be
   * invoked to interpret it; a null reference will be used instead. (It would be nice if
   * defaultValue could simply return null, but bizarrely, the Java Language Specification does not
   * consider null to be a compile-time constant.) This special interpretation of the string "null"
   * is only applicable when computing the default value; if specified on the command-line, this
   * string will have its usual literal meaning.
   *
   * <p>The default value for flags that set allowMultiple is always the empty list and its default
   * value is ignored.
   */
  String defaultValue();

  /**
   * This category field is deprecated. Bazel is in the process of migrating all options to use the
   * better defined enums in OptionDocumentationCategory and the tags in the option_filters.proto
   * file. It will still be used for the usage documentation until a sufficient proportion of
   * options are using the new system.
   *
   * <p>Please leave the old category field in existing options to minimize disruption to the Help
   * output during the transition period. All uses of this field will be removed when transition is
   * complete. This category field has no effect on the other fields below, having both set is not a
   * problem.
   */
  @Deprecated
  String category() default "misc";

  /**
   * Grouping categories used for usage documentation. See the enum's definition for details.
   *
   * <p>For undocumented flags that aren't listed anywhere, this is currently a no-op. Feel free to
   * set the value that it would have if it were documented, which might be helpful if a flag is
   * part of an experimental feature that might become documented in the future, or just leave it
   * unset as the default.
   *
   * <p>For hidden or internal options, use the category field only if it is helpful for yourself or
   * other Bazel developers.
   */
  OptionDocumentationCategory documentationCategory() default
      OptionDocumentationCategory.UNCATEGORIZED;

  /**
   * Tag about the intent or effect of this option. Unless this option is a no-op (and the reason
   * for this should be documented) all options should have some effect, so this needs to have at
   * least one value.
   *
   * <p>No option should list NO_OP_OR_UNKNOWN with other effects listed, but all other combinations
   * are allowed.
   */
  OptionEffectTag[] effectTags() default {OptionEffectTag.UNKNOWN};

  /**
   * Tag about the state of this option, such as if it gates an experimental feature, or is
   * deprecated.
   *
   * <p>If one or more of the OptionMetadataTag values apply, please include, but otherwise, this
   * list can be left blank.
   */
  OptionMetadataTag[] metadataTags() default {};

  /**
   * Options have multiple uses, some flags, some not. For user-visible flags, they are
   * "documented," but otherwise, there are 3 types of undocumented options.
   *
   * <ul>
   *   <li>{@code UNDOCUMENTED}: undocumented but user-usable flags. These options are useful for
   *       (some subset of) users, but not meant to be publicly advertised. For example,
   *       experimental options which are only meant to be used by specific testers or team members.
   *       These options will not be listed in the usage info displayed for the {@code --help}
   *       option. They are otherwise normal - {@link
   *       OptionsParser.UnparsedOptionValueDescription#isHidden()} returns {@code false} for them,
   *       and they can be parsed normally from the command line or RC files.
   *   <li>{@code HIDDEN}: flags which users should not pass or know about, but which are used by
   *       the program (e.g., communication between a command-line client and a backend server).
   *       Like {@code "undocumented"} options, these options will not be listed in the usage info
   *       displayed for the {@code --help} option. However, in addition to this, calling {@link
   *       OptionsParser.UnparsedOptionValueDescription#isHidden()} on these options will return
   *       {@code true} - for example, this can be checked to strip out such secret options when
   *       logging or otherwise reporting the command line to the user. This category does not
   *       affect the option in any other way; it can still be parsed normally from the command line
   *       or an RC file.
   *   <li>{@code INTERNAL}: these are not flags, but options which are purely for internal use
   *       within the JVM, and should never be shown to the user, nor be parsed by the options
   *       parser. Like {@code "hidden"} options, these options will not be listed in the usage info
   *       displayed for the --help option, and are considered hidden by {@link
   *       OptionsParser.UnparsedOptionValueDescription#isHidden()}. Unlike those, this type of
   *       option cannot be parsed by any call to {@link OptionsParser#parse} - it will be treated
   *       as if it was not defined.
   * </ul>
   */
  OptionUsageRestrictions optionUsageRestrictions() default OptionUsageRestrictions.DOCUMENTED;

  /**
   * The converter that we'll use to convert the string representation of this option's value into
   * an object or a simple type. The default is to use the builtin converters ({@link
   * Converters#DEFAULT_CONVERTERS}). Custom converters must implement the {@link Converter}
   * interface.
   */
  @SuppressWarnings({"unchecked", "rawtypes"})
  // Can't figure out how to coerce Converter.class into Class<? extends Converter<?>>
  Class<? extends Converter> converter() default Converter.class;

  /**
   * A flag indicating whether the option type should be allowed to occur multiple times in a single
   * option list.
   *
   * <p>If the command can occur multiple times, then the attribute value <em>must</em> be a list
   * type {@code List<T>}, and the result type of the converter for this option must either match
   * the parameter {@code T} or {@code List<T>}. In the latter case the individual lists are
   * concatenated to form the full options value.
   *
   * <p>The {@link #defaultValue()} field of the annotation is ignored for repeatable flags and the
   * default value will be the empty list.
   */
  boolean allowMultiple() default false;

  /**
   * If the option is actually an abbreviation for other options, this field will contain the
   * strings to expand this option into. The original option is dropped and the replacement used in
   * its stead. It is recommended that such an option be of type {@link Void}.
   *
   * <p>An expanded option overrides previously specified options of the same name, even if it is
   * explicitly specified. This is the original behavior and can be surprising if the user is not
   * aware of it, which has led to several requests to change this behavior. This was discussed in
   * the blaze team and it was decided that it is not a strong enough case to change the behavior.
   */
  String[] expansion() default {};

  /**
   * A mechanism for specifying an expansion that is a function of the parser's {@link
   * IsolatedOptionsData}. This can be used to create an option that expands to different strings
   * depending on what other options the parser knows about.
   *
   * <p>If provided (i.e. not {@link ExpansionFunction}{@code .class}), the {@code expansion} field
   * must not be set. The mechanism of expansion is as if the {@code expansion} field were set to
   * whatever the return value of this function is.
   */
  Class<? extends ExpansionFunction> expansionFunction() default ExpansionFunction.class;

  /**
   * If the option requires that additional options be implicitly appended, this field will contain
   * the additional options. Implicit dependencies are parsed at the end of each {@link
   * OptionsParser#parse} invocation, and override options specified in the same call. However, they
   * can be overridden by options specified in a later call or by options with a higher priority.
   *
   * @see OptionPriority
   */
  String[] implicitRequirements() default {};

  /**
   * If this field is a non-empty string, the option is deprecated, and a deprecation warning is
   * added to the list of warnings when such an option is used.
   */
  String deprecationWarning() default "";

  /**
   * The old name for this option. If an option has a name "foo" and an old name "bar", --foo=baz
   * and --bar=baz will be equivalent. If the old name is used, a warning will be printed indicating
   * that the old name is deprecated and the new name should be used.
   */
  String oldName() default "";

  /**
   * Indicates that this option is a wrapper for other options, and will be unwrapped when parsed.
   * For example, if foo is a wrapper option, then "--foo=--bar=baz" will be parsed as the flag
   * "--bar=baz" (rather than --foo taking the value "--bar=baz"). A wrapper option should have the
   * type {@link Void} (if it is something other than Void, the parser will not assign a value to
   * it). The {@link Option#implicitRequirements()}, {@link Option#expansion()}, {@link
   * Option#converter()} attributes will not be processed. Wrapper options are implicitly repeatable
   * (i.e., as though {@link Option#allowMultiple()} is true regardless of its value in the
   * annotation).
   *
   * <p>Wrapper options are provided only for transitioning flags which appear as values to other
   * flags, to top-level flags. Wrapper options should not be used in Invocation Policy, as
   * expansion flags to other flags, or as implicit requirements to other flags. Use the inner flags
   * instead.
   */
  boolean wrapperOption() default false;
}
