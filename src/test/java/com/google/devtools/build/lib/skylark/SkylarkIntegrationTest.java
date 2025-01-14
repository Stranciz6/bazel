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
package com.google.devtools.build.lib.skylark;

import static com.google.common.truth.Truth.assertThat;
import static com.google.common.truth.Truth.assertWithMessage;
import static com.google.devtools.build.lib.analysis.OutputGroupProvider.INTERNAL_SUFFIX;
import static org.junit.Assert.fail;

import com.google.common.base.Joiner;
import com.google.common.collect.ImmutableMap;
import com.google.devtools.build.lib.actions.Artifact;
import com.google.devtools.build.lib.actions.util.ActionsTestUtil;
import com.google.devtools.build.lib.analysis.ConfiguredTarget;
import com.google.devtools.build.lib.analysis.FileConfiguredTarget;
import com.google.devtools.build.lib.analysis.FileProvider;
import com.google.devtools.build.lib.analysis.OutputGroupProvider;
import com.google.devtools.build.lib.analysis.RuleConfiguredTarget;
import com.google.devtools.build.lib.analysis.RunfilesProvider;
import com.google.devtools.build.lib.analysis.util.BuildViewTestCase;
import com.google.devtools.build.lib.cmdline.Label;
import com.google.devtools.build.lib.collect.nestedset.NestedSet;
import com.google.devtools.build.lib.packages.AttributeContainer;
import com.google.devtools.build.lib.packages.BuildFileContainsErrorsException;
import com.google.devtools.build.lib.packages.ClassObjectConstructor;
import com.google.devtools.build.lib.packages.SkylarkClassObject;
import com.google.devtools.build.lib.packages.SkylarkClassObjectConstructor;
import com.google.devtools.build.lib.rules.test.InstrumentedFilesProvider;
import com.google.devtools.build.lib.skyframe.PackageFunction;
import com.google.devtools.build.lib.skyframe.SkyFunctions;
import com.google.devtools.build.lib.skyframe.SkylarkImportLookupFunction;
import com.google.devtools.build.lib.syntax.Runtime;
import com.google.devtools.build.lib.syntax.SkylarkList;
import com.google.devtools.build.lib.syntax.SkylarkList.MutableList;
import com.google.devtools.build.lib.syntax.SkylarkNestedSet;
import com.google.devtools.build.lib.vfs.FileSystemUtils;
import com.google.devtools.build.skyframe.InMemoryMemoizingEvaluator;
import com.google.devtools.build.skyframe.SkyFunction;
import com.google.devtools.build.skyframe.SkyFunctionName;
import java.util.List;
import org.junit.Before;
import org.junit.Test;
import org.junit.runner.RunWith;
import org.junit.runners.JUnit4;

/**
 * Integration tests for Skylark.
 */
@RunWith(JUnit4.class)
public class SkylarkIntegrationTest extends BuildViewTestCase {
  protected boolean keepGoing() {
    return false;
  }

  @Test
  public void testRemoteLabelAsDefaultAttributeValue() throws Exception {
    scratch.file(
        "test/skylark/extension.bzl",
        "def _impl(ctx):",
        "  pass",
        "my_rule = rule(implementation = _impl,",
        "    attrs = { 'dep' : attr.label_list(default=[\"@r//:t\"]) })");

    // We are only interested in whether the label string in the default value can be converted
    // to a proper Label without an exception (see GitHub issue #1442).
    // Consequently, we expect getTarget() to fail later since the repository does not exist.
    checkError(
        "test/skylark",
        "the_rule",
        "no such package '@r//': The repository could not be resolved",
        "load('/test/skylark/extension', 'my_rule')",
        "",
        "my_rule(name='the_rule')");
  }

  @Test
  public void testSameMethodNames() throws Exception {
    // The alias feature of load() may hide the fact that two methods in the stack trace have the
    // same name. This is perfectly legal as long as these two methods are actually distinct.
    // Consequently, no "Recursion was detected" error must be thrown.
    scratch.file(
        "test/skylark/extension.bzl",
        "load('/test/skylark/other', other_impl = 'impl')",
        "def impl(ctx):",
        "  other_impl(ctx)",
        "empty = rule(implementation = impl)");
    scratch.file("test/skylark/other.bzl", "def impl(ctx):", "  print('This rule does nothing')");
    scratch.file(
        "test/skylark/BUILD",
        "load('/test/skylark/extension', 'empty')",
        "empty(name = 'test_target')");

    getConfiguredTarget("//test/skylark:test_target");
  }

  private AttributeContainer getContainerForTarget(String targetName) throws Exception {
    ConfiguredTarget target = getConfiguredTarget("//test/skylark:" + targetName);
    return target.getTarget().getAssociatedRule().getAttributeContainer();
  }

  @Test
  public void testMacroHasGeneratorAttributes() throws Exception {
    scratch.file(
        "test/skylark/extension.bzl",
        "def _impl(ctx):",
        "  print('This rule does nothing')",
        "",
        "empty = rule(implementation = _impl)",
        "no_macro = rule(implementation = _impl)",
        "",
        "def macro(name, visibility=None):",
        "  empty(name = name, visibility=visibility)",
        "def native_macro(name):",
        "  native.cc_library(name = name + '_suffix')");
    scratch.file(
        "test/skylark/BUILD",
        "load('/test/skylark/extension', macro_rule = 'macro', no_macro_rule = 'no_macro',",
        "  native_macro_rule = 'native_macro')",
        "macro_rule(name = 'macro_target')",
        "no_macro_rule(name = 'no_macro_target')",
        "native_macro_rule(name = 'native_macro_target')",
        "cc_binary(name = 'cc_target', deps = ['cc_dep'])",
        "cc_library(name = 'cc_dep')");

    AttributeContainer withMacro = getContainerForTarget("macro_target");
    assertThat(withMacro.getAttr("generator_name")).isEqualTo("macro_target");
    assertThat(withMacro.getAttr("generator_function")).isEqualTo("macro");
    assertThat(withMacro.getAttr("generator_location")).isEqualTo("test/skylark/BUILD:3");

    // Attributes are only set when the rule was created by a macro
    AttributeContainer noMacro = getContainerForTarget("no_macro_target");
    assertThat(noMacro.getAttr("generator_name")).isEqualTo("");
    assertThat(noMacro.getAttr("generator_function")).isEqualTo("");
    assertThat(noMacro.getAttr("generator_location")).isEqualTo("");

    AttributeContainer nativeMacro = getContainerForTarget("native_macro_target_suffix");
    assertThat(nativeMacro.getAttr("generator_name")).isEqualTo("native_macro_target");
    assertThat(nativeMacro.getAttr("generator_function")).isEqualTo("native_macro");
    assertThat(nativeMacro.getAttr("generator_location")).isEqualTo("test/skylark/BUILD:5");

    AttributeContainer ccTarget = getContainerForTarget("cc_target");
    assertThat(ccTarget.getAttr("generator_name")).isEqualTo("");
    assertThat(ccTarget.getAttr("generator_function")).isEqualTo("");
    assertThat(ccTarget.getAttr("generator_location")).isEqualTo("");
  }



  @Test
  public void testOutputGroups() throws Exception {
    scratch.file(
        "test/skylark/extension.bzl",
        "def _impl(ctx):",
        "  f = ctx.attr.dep.output_group('_hidden_top_level" + INTERNAL_SUFFIX + "')",
        "  return struct(result = f, ",
        "               output_groups = { 'my_group' : f })",
        "my_rule = rule(implementation = _impl,",
        "    attrs = { 'dep' : attr.label() })");
    scratch.file(
        "test/skylark/BUILD",
        "load('/test/skylark/extension',  'my_rule')",
        "cc_binary(name = 'lib', data = ['a.txt'])",
        "my_rule(name='my', dep = ':lib')");
    NestedSet<Artifact> hiddenTopLevelArtifacts =
        OutputGroupProvider.get(getConfiguredTarget("//test/skylark:lib"))
            .getOutputGroup(OutputGroupProvider.HIDDEN_TOP_LEVEL);
    ConfiguredTarget myTarget = getConfiguredTarget("//test/skylark:my");
    SkylarkNestedSet result = (SkylarkNestedSet) myTarget.get("result");
    assertThat(result.getSet(Artifact.class)).containsExactlyElementsIn(hiddenTopLevelArtifacts);
    assertThat(OutputGroupProvider.get(myTarget).getOutputGroup("my_group"))
        .containsExactlyElementsIn(hiddenTopLevelArtifacts);
  }

  @Test
  public void testOutputGroupsDeclaredProvider() throws Exception {
    scratch.file(
        "test/skylark/extension.bzl",
        "def _impl(ctx):",
        "  f = ctx.attr.dep[OutputGroupInfo]._hidden_top_level" + INTERNAL_SUFFIX,
        "  return struct(result = f, ",
        "                providers = [OutputGroupInfo(my_group = f)])",
        "my_rule = rule(implementation = _impl,",
        "    attrs = { 'dep' : attr.label() })");
    scratch.file(
        "test/skylark/BUILD",
        "load('/test/skylark/extension',  'my_rule')",
        "cc_binary(name = 'lib', data = ['a.txt'])",
        "my_rule(name='my', dep = ':lib')");
    NestedSet<Artifact> hiddenTopLevelArtifacts =
        OutputGroupProvider.get(getConfiguredTarget("//test/skylark:lib"))
            .getOutputGroup(OutputGroupProvider.HIDDEN_TOP_LEVEL);
    ConfiguredTarget myTarget = getConfiguredTarget("//test/skylark:my");
    SkylarkNestedSet result = (SkylarkNestedSet) myTarget.get("result");
    assertThat(result.getSet(Artifact.class)).containsExactlyElementsIn(hiddenTopLevelArtifacts);
    assertThat(OutputGroupProvider.get(myTarget).getOutputGroup("my_group"))
        .containsExactlyElementsIn(hiddenTopLevelArtifacts);
  }


  @Test
  public void testOutputGroupsAsDictionary() throws Exception {
    scratch.file(
        "test/skylark/extension.bzl",
        "def _impl(ctx):",
        "  f = ctx.attr.dep.output_groups['_hidden_top_level" + INTERNAL_SUFFIX + "']",
        "  has_key1 = '_hidden_top_level" + INTERNAL_SUFFIX + "' in ctx.attr.dep.output_groups",
        "  has_key2 = 'foobar' in ctx.attr.dep.output_groups",
        "  all_keys = [k for k in ctx.attr.dep.output_groups]",
        "  return struct(result = f, ",
        "                has_key1 = has_key1,",
        "                has_key2 = has_key2,",
        "                all_keys = all_keys,",
        "               output_groups = { 'my_group' : f })",
        "my_rule = rule(implementation = _impl,",
        "    attrs = { 'dep' : attr.label() })");
    scratch.file(
        "test/skylark/BUILD",
        "load('/test/skylark/extension',  'my_rule')",
        "cc_binary(name = 'lib', data = ['a.txt'])",
        "my_rule(name='my', dep = ':lib')");
    NestedSet<Artifact> hiddenTopLevelArtifacts =
        OutputGroupProvider.get(getConfiguredTarget("//test/skylark:lib"))
            .getOutputGroup(OutputGroupProvider.HIDDEN_TOP_LEVEL);
    ConfiguredTarget myTarget = getConfiguredTarget("//test/skylark:my");
    SkylarkNestedSet result = (SkylarkNestedSet) myTarget.get("result");
    assertThat(result.getSet(Artifact.class)).containsExactlyElementsIn(hiddenTopLevelArtifacts);
    assertThat(OutputGroupProvider.get(myTarget).getOutputGroup("my_group"))
        .containsExactlyElementsIn(hiddenTopLevelArtifacts);
    assertThat(myTarget.get("has_key1")).isEqualTo(Boolean.TRUE);
    assertThat(myTarget.get("has_key2")).isEqualTo(Boolean.FALSE);
    assertThat((SkylarkList) myTarget.get("all_keys"))
        .containsExactly(
            "_hidden_top_level" + INTERNAL_SUFFIX,
            "compilation_prerequisites" + INTERNAL_SUFFIX,
            "files_to_compile" + INTERNAL_SUFFIX,
            "temp_files" + INTERNAL_SUFFIX);
  }

  @Test
  public void testOutputGroupsAsDictionaryPipe() throws Exception {
    scratch.file(
        "test/skylark/extension.bzl",
        "def _impl(ctx):",
        "  f = ctx.attr.dep.output_groups['_hidden_top_level" + INTERNAL_SUFFIX + "']",
        "  g = ctx.attr.dep.output_groups['_hidden_top_level" + INTERNAL_SUFFIX + "'] | depset([])",
        "  return struct(result = g, ",
        "                output_groups = { 'my_group' : g })",
        "my_rule = rule(implementation = _impl,",
        "    attrs = { 'dep' : attr.label() })");
    scratch.file(
        "test/skylark/BUILD",
        "load('/test/skylark/extension',  'my_rule')",
        "cc_binary(name = 'lib', data = ['a.txt'])",
        "my_rule(name='my', dep = ':lib')");
    NestedSet<Artifact> hiddenTopLevelArtifacts =
        OutputGroupProvider.get(getConfiguredTarget("//test/skylark:lib"))
            .getOutputGroup(OutputGroupProvider.HIDDEN_TOP_LEVEL);
    ConfiguredTarget myTarget = getConfiguredTarget("//test/skylark:my");
    SkylarkNestedSet result = (SkylarkNestedSet) myTarget.get("result");
    assertThat(result.getSet(Artifact.class)).containsExactlyElementsIn(hiddenTopLevelArtifacts);
    assertThat(OutputGroupProvider.get(myTarget).getOutputGroup("my_group"))
        .containsExactlyElementsIn(hiddenTopLevelArtifacts);
  }

  @Test
  public void testOutputGroupsWithList() throws Exception {
    scratch.file(
        "test/skylark/extension.bzl",
        "def _impl(ctx):",
        "  f = ctx.attr.dep.output_group('_hidden_top_level" + INTERNAL_SUFFIX + "')",
        "  g = list(f)",
        "  return struct(result = f, ",
        "               output_groups = { 'my_group' : g, 'my_empty_group' : [] })",
        "my_rule = rule(implementation = _impl,",
        "    attrs = { 'dep' : attr.label() })");
    scratch.file(
        "test/skylark/BUILD",
        "load('/test/skylark/extension',  'my_rule')",
        "cc_binary(name = 'lib', data = ['a.txt'])",
        "my_rule(name='my', dep = ':lib')");
    NestedSet<Artifact> hiddenTopLevelArtifacts =
        OutputGroupProvider.get(getConfiguredTarget("//test/skylark:lib"))
            .getOutputGroup(OutputGroupProvider.HIDDEN_TOP_LEVEL);
    ConfiguredTarget myTarget = getConfiguredTarget("//test/skylark:my");
    SkylarkNestedSet result =
        (SkylarkNestedSet) myTarget.get("result");
    assertThat(result.getSet(Artifact.class)).containsExactlyElementsIn(hiddenTopLevelArtifacts);
    assertThat(OutputGroupProvider.get(myTarget).getOutputGroup("my_group"))
        .containsExactlyElementsIn(hiddenTopLevelArtifacts);
    assertThat(OutputGroupProvider.get(myTarget).getOutputGroup("my_empty_group"))
        .isEmpty();
  }

  @Test
  public void testOutputGroupsDeclaredProviderWithList() throws Exception {
    scratch.file(
        "test/skylark/extension.bzl",
        "def _impl(ctx):",
        "  f = ctx.attr.dep[OutputGroupInfo]._hidden_top_level" + INTERNAL_SUFFIX,
        "  g = list(f)",
        "  return struct(result = f, ",
        "                providers = [OutputGroupInfo(my_group = g, my_empty_group = [])])",
        "my_rule = rule(implementation = _impl,",
        "    attrs = { 'dep' : attr.label() })");
    scratch.file(
        "test/skylark/BUILD",
        "load('/test/skylark/extension',  'my_rule')",
        "cc_binary(name = 'lib', data = ['a.txt'])",
        "my_rule(name='my', dep = ':lib')");
    NestedSet<Artifact> hiddenTopLevelArtifacts =
        OutputGroupProvider.get(getConfiguredTarget("//test/skylark:lib"))
            .getOutputGroup(OutputGroupProvider.HIDDEN_TOP_LEVEL);
    ConfiguredTarget myTarget = getConfiguredTarget("//test/skylark:my");
    SkylarkNestedSet result =
        (SkylarkNestedSet) myTarget.get("result");
    assertThat(result.getSet(Artifact.class)).containsExactlyElementsIn(hiddenTopLevelArtifacts);
    assertThat(OutputGroupProvider.get(myTarget).getOutputGroup("my_group"))
        .containsExactlyElementsIn(hiddenTopLevelArtifacts);
    assertThat(OutputGroupProvider.get(myTarget).getOutputGroup("my_empty_group"))
        .isEmpty();
  }

  @Test
  public void testStackTraceErrorInFunction() throws Exception {
    runStackTraceTest(
        "str",
        "\t\tstr.index(1)"
            + System.lineSeparator()
            + "method string.index(sub: string, start: int, end: int or NoneType) is not "
            + "applicable for arguments (int, int, NoneType): 'sub' is 'int', "
            + "but should be 'string'");
  }

  @Test
  public void testStackTraceMissingMethod() throws Exception {
    runStackTraceTest(
        "None",
        "\t\tNone.index(1)" + System.lineSeparator() + "type 'NoneType' has no method index(int)");
  }

  protected void runStackTraceTest(String object, String errorMessage) throws Exception {
    reporter.removeHandler(failFastHandler);
    String expectedTrace =
        Joiner.on(System.lineSeparator())
            .join(
                "Traceback (most recent call last):",
                "\tFile \"/workspace/test/skylark/BUILD\", line 3",
                "\t\tcustom_rule(name = 'cr')",
                "\tFile \"/workspace/test/skylark/extension.bzl\", line 5, in custom_rule_impl",
                "\t\tfoo()",
                "\tFile \"/workspace/test/skylark/extension.bzl\", line 8, in foo",
                "\t\tbar(2, 4)",
                "\tFile \"/workspace/test/skylark/extension.bzl\", line 10, in bar",
                "\t\tfirst(x, y, z)",
                "\tFile \"/workspace/test/skylark/functions.bzl\", line 2, in first",
                "\t\tsecond(a, b)",
                "\tFile \"/workspace/test/skylark/functions.bzl\", line 5, in second",
                "\t\tthird(\"legal\")",
                "\tFile \"/workspace/test/skylark/functions.bzl\", line 7, in third",
                errorMessage);
    scratch.file(
        "test/skylark/extension.bzl",
        "load('/test/skylark/functions', 'first')",
        "def custom_rule_impl(ctx):",
        "  attr1 = ctx.files.attr1",
        "  ftb = depset(attr1)",
        "  foo()",
        "  return struct(provider_key = ftb)",
        "def foo():",
        "  bar(2,4)",
        "def bar(x,y,z=1):",
        "  first(x,y, z)",
        "custom_rule = rule(implementation = custom_rule_impl,",
        "  attrs = {'attr1': attr.label_list(mandatory=True, allow_files=True)})");
    scratch.file(
        "test/skylark/functions.bzl",
        "def first(a, b, c):",
        "  second(a, b)",
        "  third(b)",
        "def second(a, b):",
        "  third('legal')",
        "def third(str):",
        "  " + object + ".index(1)");
    scratch.file(
        "test/skylark/BUILD",
        "load('/test/skylark/extension', 'custom_rule')",
        "",
        "custom_rule(name = 'cr', attr1 = [':a.txt'])");

    getConfiguredTarget("//test/skylark:cr");
    assertContainsEvent(expectedTrace);
  }

  @Test
  public void testFilesToBuild() throws Exception {
    scratch.file(
        "test/skylark/extension.bzl",
        "def custom_rule_impl(ctx):",
        "  attr1 = ctx.files.attr1",
        "  ftb = depset(attr1)",
        "  return struct(runfiles = ctx.runfiles(), files = ftb)",
        "",
        "custom_rule = rule(implementation = custom_rule_impl,",
        "  attrs = {'attr1': attr.label_list(mandatory=True, allow_files=True)})");

    scratch.file(
        "test/skylark/BUILD",
        "load('/test/skylark/extension', 'custom_rule')",
        "",
        "custom_rule(name = 'cr', attr1 = [':a.txt'])");

    ConfiguredTarget target = getConfiguredTarget("//test/skylark:cr");

    assertThat(target.getLabel().toString()).isEqualTo("//test/skylark:cr");
    assertThat(
        ActionsTestUtil.baseArtifactNames(
            target.getProvider(FileProvider.class).getFilesToBuild()))
        .containsExactly("a.txt");
  }

  @Test
  public void testRunfiles() throws Exception {
    scratch.file(
        "test/skylark/extension.bzl",
        "def custom_rule_impl(ctx):",
        "  attr1 = ctx.files.attr1",
        "  rf = ctx.runfiles(files = attr1)",
        "  return struct(runfiles = rf)",
        "",
        "custom_rule = rule(implementation = custom_rule_impl,",
        "  attrs = {'attr1': attr.label_list(mandatory=True, allow_files=True)})");

    scratch.file(
        "test/skylark/BUILD",
        "load('/test/skylark/extension', 'custom_rule')",
        "",
        "custom_rule(name = 'cr', attr1 = [':a.txt'])");

    ConfiguredTarget target = getConfiguredTarget("//test/skylark:cr");

    assertThat(target.getLabel().toString()).isEqualTo("//test/skylark:cr");
    assertThat(
        ActionsTestUtil.baseArtifactNames(
            target.getProvider(RunfilesProvider.class).getDefaultRunfiles().getAllArtifacts()))
        .containsExactly("a.txt");
    assertThat(
        ActionsTestUtil.baseArtifactNames(
            target.getProvider(RunfilesProvider.class).getDataRunfiles().getAllArtifacts()))
        .containsExactly("a.txt");
  }

  @Test
  public void testAccessRunfiles() throws Exception {
    scratch.file(
        "test/skylark/extension.bzl",
        "def custom_rule_impl(ctx):",
        "  runfiles = ctx.attr.x.default_runfiles.files",
        "  return struct(files = runfiles)",
        "",
        "custom_rule = rule(implementation = custom_rule_impl,",
        "  attrs = {'x': attr.label(allow_files=True)})");

    scratch.file(
        "test/skylark/BUILD",
        "load('/test/skylark/extension', 'custom_rule')",
        "",
        "cc_library(name = 'lib', data = ['a.txt'])",
        "custom_rule(name = 'cr1', x = ':lib')",
        "custom_rule(name = 'cr2', x = 'b.txt')");

    scratch.file("test/skylark/a.txt");
    scratch.file("test/skylark/b.txt");

    ConfiguredTarget target = getConfiguredTarget("//test/skylark:cr1");
    List<String> baseArtifactNames =
        ActionsTestUtil.baseArtifactNames(target.getProvider(FileProvider.class).getFilesToBuild());
    assertThat(baseArtifactNames).containsExactly("a.txt");

    target = getConfiguredTarget("//test/skylark:cr2");
    baseArtifactNames =
        ActionsTestUtil.baseArtifactNames(target.getProvider(FileProvider.class).getFilesToBuild());
    assertThat(baseArtifactNames).isEmpty();
  }

  @Test
  public void testStatefulRunfiles() throws Exception {
    scratch.file(
        "test/skylark/extension.bzl",
        "def custom_rule_impl(ctx):",
        "  attr1 = ctx.files.attr1",
        "  rf1 = ctx.runfiles(files = attr1)",
        "  rf2 = ctx.runfiles()",
        "  return struct(data_runfiles = rf1, default_runfiles = rf2)",
        "",
        "custom_rule = rule(implementation = custom_rule_impl,",
        "  attrs = {'attr1': attr.label_list(mandatory = True, allow_files=True)})");

    scratch.file(
        "test/skylark/BUILD",
        "load('/test/skylark/extension', 'custom_rule')",
        "",
        "custom_rule(name = 'cr', attr1 = [':a.txt'])");

    ConfiguredTarget target = getConfiguredTarget("//test/skylark:cr");

    assertThat(target.getLabel().toString()).isEqualTo("//test/skylark:cr");
    assertThat(target.getProvider(RunfilesProvider.class).getDefaultRunfiles().isEmpty()).isTrue();
    assertThat(
        ActionsTestUtil.baseArtifactNames(
            target.getProvider(RunfilesProvider.class).getDataRunfiles().getAllArtifacts()))
        .containsExactly("a.txt");
  }

  @Test
  public void testExecutableGetsInRunfilesAndFilesToBuild() throws Exception {
    scratch.file(
        "test/skylark/extension.bzl",
        "def custom_rule_impl(ctx):",
        "  ctx.actions.write(output = ctx.outputs.executable, content = 'echo hello')",
        "  rf = ctx.runfiles(ctx.files.data)",
        "  return struct(runfiles = rf)",
        "",
        "custom_rule = rule(implementation = custom_rule_impl, executable = True,",
        "  attrs = {'data': attr.label_list(cfg='data', allow_files=True)})");

    scratch.file(
        "test/skylark/BUILD",
        "load('/test/skylark/extension', 'custom_rule')",
        "",
        "custom_rule(name = 'cr', data = [':a.txt'])");

    ConfiguredTarget target = getConfiguredTarget("//test/skylark:cr");

    assertThat(target.getLabel().toString()).isEqualTo("//test/skylark:cr");
    assertThat(
        ActionsTestUtil.baseArtifactNames(
            target.getProvider(RunfilesProvider.class).getDefaultRunfiles().getAllArtifacts()))
        .containsExactly("a.txt", "cr")
        .inOrder();
    assertThat(
        ActionsTestUtil.baseArtifactNames(
            target.getProvider(FileProvider.class).getFilesToBuild()))
        .containsExactly("cr");
  }

  @Test
  public void testCannotSpecifyRunfilesWithDataOrDefaultRunfiles() throws Exception {
    scratch.file(
        "test/skylark/extension.bzl",
        "def custom_rule_impl(ctx):",
        "  rf = ctx.runfiles()",
        "  return struct(runfiles = rf, default_runfiles = rf)",
        "",
        "custom_rule = rule(implementation = custom_rule_impl)");

    checkError(
        "test/skylark",
        "cr",
        "Cannot specify the provider 'runfiles' together with "
            + "'data_runfiles' or 'default_runfiles'",
        "load('/test/skylark/extension', 'custom_rule')",
        "",
        "custom_rule(name = 'cr')");
  }

  @Test
  public void testInstrumentedFilesProviderWithCodeCoverageDiabled() throws Exception {
    scratch.file(
        "test/skylark/extension.bzl",
        "def custom_rule_impl(ctx):",
        "  return struct(instrumented_files=struct(",
        "      extensions = ['txt'],",
        "      source_attributes = ['attr1'],",
        "      dependency_attributes = ['attr2']))",
        "",
        "custom_rule = rule(implementation = custom_rule_impl,",
        "  attrs = {",
        "      'attr1': attr.label_list(mandatory = True, allow_files=True),",
        "      'attr2': attr.label_list(mandatory = True)})");

    scratch.file(
        "test/skylark/BUILD",
        "load('/test/skylark/extension', 'custom_rule')",
        "",
        "java_library(name='jl', srcs = [':A.java'])",
        "custom_rule(name = 'cr', attr1 = [':a.txt', ':a.random'], attr2 = [':jl'])");

    useConfiguration("--nocollect_code_coverage");

    ConfiguredTarget target = getConfiguredTarget("//test/skylark:cr");

    assertThat(target.getLabel().toString()).isEqualTo("//test/skylark:cr");
    InstrumentedFilesProvider provider = target.getProvider(InstrumentedFilesProvider.class);
    assertWithMessage("InstrumentedFilesProvider should be set.").that(provider).isNotNull();
    assertThat(ActionsTestUtil.baseArtifactNames(provider.getInstrumentedFiles())).isEmpty();
  }

  @Test
  public void testInstrumentedFilesProviderWithCodeCoverageEnabled() throws Exception {
    scratch.file(
        "test/skylark/extension.bzl",
        "def custom_rule_impl(ctx):",
        "  return struct(instrumented_files=struct(",
        "      extensions = ['txt'],",
        "      source_attributes = ['attr1'],",
        "      dependency_attributes = ['attr2']))",
        "",
        "custom_rule = rule(implementation = custom_rule_impl,",
        "  attrs = {",
        "      'attr1': attr.label_list(mandatory = True, allow_files=True),",
        "      'attr2': attr.label_list(mandatory = True)})");

    scratch.file(
        "test/skylark/BUILD",
        "load('/test/skylark/extension', 'custom_rule')",
        "",
        "java_library(name='jl', srcs = [':A.java'])",
        "custom_rule(name = 'cr', attr1 = [':a.txt', ':a.random'], attr2 = [':jl'])");

    useConfiguration("--collect_code_coverage");

    ConfiguredTarget target = getConfiguredTarget("//test/skylark:cr");

    assertThat(target.getLabel().toString()).isEqualTo("//test/skylark:cr");
    InstrumentedFilesProvider provider = target.getProvider(InstrumentedFilesProvider.class);
    assertWithMessage("InstrumentedFilesProvider should be set.").that(provider).isNotNull();
    assertThat(ActionsTestUtil.baseArtifactNames(provider.getInstrumentedFiles()))
        .containsExactly("a.txt", "A.java");
  }

  @Test
  public void testTransitiveInfoProviders() throws Exception {
    scratch.file(
        "test/skylark/extension.bzl",
        "def custom_rule_impl(ctx):",
        "  attr1 = ctx.files.attr1",
        "  ftb = depset(attr1)",
        "  return struct(provider_key = ftb)",
        "",
        "custom_rule = rule(implementation = custom_rule_impl,",
        "  attrs = {'attr1': attr.label_list(mandatory=True, allow_files=True)})");

    scratch.file(
        "test/skylark/BUILD",
        "load('/test/skylark/extension', 'custom_rule')",
        "",
        "custom_rule(name = 'cr', attr1 = [':a.txt'])");

    RuleConfiguredTarget target = (RuleConfiguredTarget) getConfiguredTarget("//test/skylark:cr");

    assertThat(
        ActionsTestUtil.baseArtifactNames(
            ((SkylarkNestedSet) target.get("provider_key")).getSet(Artifact.class)))
        .containsExactly("a.txt");
  }

  @Test
  public void testMandatoryProviderMissing() throws Exception {
    scratch.file("test/skylark/BUILD");
    scratch.file(
        "test/skylark/extension.bzl",
        "def rule_impl(ctx):",
        "  return struct()",
        "",
        "dependent_rule = rule(implementation = rule_impl)",
        "",
        "main_rule = rule(implementation = rule_impl,",
        "    attrs = {'dependencies': attr.label_list(providers = ['some_provider'],",
        "        allow_files=True)})");

    checkError(
        "test",
        "b",
        "in dependencies attribute of main_rule rule //test:b: "
            + "'//test:a' does not have mandatory provider 'some_provider'",
        "load('/test/skylark/extension', 'dependent_rule')",
        "load('/test/skylark/extension', 'main_rule')",
        "",
        "dependent_rule(name = 'a')",
        "main_rule(name = 'b', dependencies = [':a'])");
  }

  @Test
  public void testSpecialMandatoryProviderMissing() throws Exception {
    // Test that rules satisfy `providers = [...]` condition if a special provider that always
    // exists for all rules is requested. Also check external rules.

    FileSystemUtils.appendIsoLatin1(scratch.resolve("WORKSPACE"),
        "bind(name = 'bar', actual = '//test/ext:bar')");
    scratch.file(
        "test/ext/BUILD",
        "load('//test/skylark:extension.bzl', 'foobar')",
        "",
        "foobar(name = 'bar', visibility = ['//visibility:public'],)");
    scratch.file(
        "test/skylark/extension.bzl",
        "def rule_impl(ctx):",
        "  pass",
        "",
        "foobar = rule(implementation = rule_impl)",
        "main_rule = rule(implementation = rule_impl, attrs = {",
        "    'deps': attr.label_list(providers = [",
        "        'files', 'data_runfiles', 'default_runfiles',",
        "        'files_to_run', 'label', 'output_groups',",
        "    ])",
        "})");
    scratch.file(
        "test/skylark/BUILD",
        "load(':extension.bzl', 'foobar', 'main_rule')",
        "",
        "foobar(name = 'foo')",
        "main_rule(name = 'main', deps = [':foo', '//external:bar'])");

    invalidatePackages();
    getConfiguredTarget("//test/skylark:main");
  }

  @Test
  public void testActions() throws Exception {
    scratch.file(
        "test/skylark/extension.bzl",
        "def custom_rule_impl(ctx):",
        "  attr1 = ctx.files.attr1",
        "  output = ctx.outputs.o",
        "  ctx.action(",
        "    inputs = attr1,",
        "    outputs = [output],",
        "    command = 'echo')",
        "",
        "custom_rule = rule(implementation = custom_rule_impl,",
        "  attrs = {'attr1': attr.label_list(mandatory=True, allow_files=True)},",
        "  outputs = {'o': 'o.txt'})");

    scratch.file(
        "test/skylark/BUILD",
        "load('/test/skylark/extension', 'custom_rule')",
        "",
        "custom_rule(name = 'cr', attr1 = [':a.txt'])");

    getConfiguredTarget("//test/skylark:cr");

    FileConfiguredTarget target = getFileConfiguredTarget("//test/skylark:o.txt");
    assertThat(
        ActionsTestUtil.baseArtifactNames(
            getGeneratingAction(target.getArtifact()).getInputs()))
        .containsExactly("a.txt");
  }

  @Test
  public void testRuleClassImplicitOutputFunction() throws Exception {
    scratch.file(
        "test/skylark/extension.bzl",
        "def custom_rule_impl(ctx):",
        "  files = [ctx.outputs.o]",
        "  ctx.action(",
        "    outputs = files,",
        "    command = 'echo')",
        "  ftb = depset(files)",
        "  return struct(runfiles = ctx.runfiles(), files = ftb)",
        "",
        "def output_func(name, public_attr, _private_attr):",
        "  if _private_attr != None: return {}",
        "  return {'o': name + '-' + public_attr + '.txt'}",
        "",
        "custom_rule = rule(implementation = custom_rule_impl,",
        "  attrs = {'public_attr': attr.string(),",
        "           '_private_attr': attr.label()},",
        "  outputs = output_func)");

    scratch.file(
        "test/skylark/BUILD",
        "load('/test/skylark/extension', 'custom_rule')",
        "",
        "custom_rule(name = 'cr', public_attr = 'bar')");

    ConfiguredTarget target = getConfiguredTarget("//test/skylark:cr");

    assertThat(
            ActionsTestUtil.baseArtifactNames(
                target.getProvider(FileProvider.class).getFilesToBuild()))
        .containsExactly("cr-bar.txt");
  }

  @Test
  public void testRuleClassImplicitOutputFunctionDependingOnComputedAttribute() throws Exception {
    scratch.file(
        "test/skylark/extension.bzl",
        "def custom_rule_impl(ctx):",
        "  files = [ctx.outputs.o]",
        "  ctx.action(",
        "    outputs = files,",
        "    command = 'echo')",
        "  ftb = depset(files)",
        "  return struct(runfiles = ctx.runfiles(), files = ftb)",
        "",
        "def attr_func(public_attr):",
        "  return public_attr",
        "",
        "def output_func(_private_attr):",
        "  return {'o': _private_attr.name + '.txt'}",
        "",
        "custom_rule = rule(implementation = custom_rule_impl,",
        "  attrs = {'public_attr': attr.label(),",
        "           '_private_attr': attr.label(default = attr_func)},",
        "  outputs = output_func)",
        "",
        "def empty_rule_impl(ctx):",
        "  pass",
        "",
        "empty_rule = rule(implementation = empty_rule_impl)");

    scratch.file(
        "test/skylark/BUILD",
        "load('/test/skylark/extension', 'custom_rule', 'empty_rule')",
        "",
        "empty_rule(name = 'foo')",
        "custom_rule(name = 'cr', public_attr = '//test/skylark:foo')");

    ConfiguredTarget target = getConfiguredTarget("//test/skylark:cr");

    assertThat(
        ActionsTestUtil.baseArtifactNames(
            target.getProvider(FileProvider.class).getFilesToBuild()))
        .containsExactly("foo.txt");
  }

  @Test
  public void testRuleClassImplicitOutputs() throws Exception {
    scratch.file(
        "test/skylark/extension.bzl",
        "def custom_rule_impl(ctx):",
        "  files = [ctx.outputs.lbl, ctx.outputs.list, ctx.outputs.str]",
        "  print('==!=!=!=')",
        "  print(files)",
        "  ctx.action(",
        "    outputs = files,",
        "    command = 'echo')",
        "  return struct(files = depset(files))",
        "",
        "custom_rule = rule(implementation = custom_rule_impl,",
        "  attrs = {",
        "    'attr1': attr.label(allow_files=True),",
        "    'attr2': attr.label_list(allow_files=True),",
        "    'attr3': attr.string(),",
        "  },",
        "  outputs = {",
        "    'lbl': '%{attr1}.a',",
        "    'list': '%{attr2}.b',",
        "    'str': '%{attr3}.c',",
        "})");

    scratch.file(
        "test/skylark/BUILD",
        "load('/test/skylark/extension', 'custom_rule')",
        "",
        "custom_rule(",
        "  name='cr',",
        "  attr1='f1.txt',",
        "  attr2=['f2.txt'],",
        "  attr3='f3.txt',",
        ")");

    scratch.file("test/skylark/f1.txt");
    scratch.file("test/skylark/f2.txt");
    scratch.file("test/skylark/f3.txt");

    ConfiguredTarget target = getConfiguredTarget("//test/skylark:cr");
    assertThat(
        ActionsTestUtil.baseArtifactNames(
            target.getProvider(FileProvider.class).getFilesToBuild()))
        .containsExactly("f1.a", "f2.b", "f3.txt.c");
  }

  @Test
  public void testRuleClassImplicitOutputFunctionAndDefaultValue() throws Exception {
    scratch.file(
        "test/skylark/extension.bzl",
        "def custom_rule_impl(ctx):",
        "  ctx.action(",
        "    outputs = [ctx.outputs.o],",
        "    command = 'echo')",
        "  return struct(runfiles = ctx.runfiles())",
        "",
        "def output_func(attr1):",
        "  return {'o': attr1 + '.txt'}",
        "",
        "custom_rule = rule(implementation = custom_rule_impl,",
        "  attrs = {'attr1': attr.string(default='bar')},",
        "  outputs = output_func)");

    scratch.file(
        "test/skylark/BUILD",
        "load('/test/skylark/extension', 'custom_rule')",
        "",
        "custom_rule(name = 'cr', attr1 = None)");

    ConfiguredTarget target = getConfiguredTarget("//test/skylark:cr");

    assertThat(
        ActionsTestUtil.baseArtifactNames(
            target.getProvider(FileProvider.class).getFilesToBuild()))
        .containsExactly("bar.txt");
  }

  @Test
  public void testRuleClassNonMandatoryEmptyOutputs() throws Exception {
    scratch.file(
        "test/skylark/extension.bzl",
        "def custom_rule_impl(ctx):",
        "  return struct(",
        "      o1=ctx.outputs.o1,",
        "      o2=ctx.outputs.o2)",
        "",
        "custom_rule = rule(implementation = custom_rule_impl,",
        "  attrs = {'o1': attr.output(), 'o2': attr.output_list()})");

    scratch.file(
        "test/skylark/BUILD",
        "load('/test/skylark/extension', 'custom_rule')",
        "",
        "custom_rule(name = 'cr')");

    ConfiguredTarget target = getConfiguredTarget("//test/skylark:cr");
    assertThat(target.get("o1")).isEqualTo(Runtime.NONE);
    assertThat(target.get("o2")).isEqualTo(MutableList.EMPTY);
  }

  @Test
  public void testRuleClassImplicitAndExplicitOutputNamesCollide() throws Exception {
    scratch.file(
        "test/skylark/extension.bzl",
        "def custom_rule_impl(ctx):",
        "  return struct()",
        "",
        "custom_rule = rule(implementation = custom_rule_impl,",
        "  attrs = {'o': attr.output_list()},",
        "  outputs = {'o': '%{name}.txt'})");

    checkError(
        "test/skylark",
        "cr",
        "Multiple outputs with the same key: o",
        "load('/test/skylark/extension', 'custom_rule')",
        "",
        "custom_rule(name = 'cr', o = [':bar.txt'])");
  }

  @Test
  public void testRuleClassDefaultFilesToBuild() throws Exception {
    scratch.file(
        "test/skylark/extension.bzl",
        "def custom_rule_impl(ctx):",
        "  files = [ctx.outputs.o]",
        "  ctx.action(",
        "    outputs = files,",
        "    command = 'echo')",
        "  ftb = depset(files)",
        "  for i in ctx.outputs.out:",
        "    ctx.actions.write(output=i, content='hi there')",
        "",
        "def output_func(attr1):",
        "  return {'o': attr1 + '.txt'}",
        "",
        "custom_rule = rule(implementation = custom_rule_impl,",
        "  attrs = {",
        "    'attr1': attr.string(),",
        "    'out': attr.output_list()",
        "  },",
        "  outputs = output_func)");

    scratch.file(
        "test/skylark/BUILD",
        "load('/test/skylark/extension', 'custom_rule')",
        "",
        "custom_rule(name = 'cr', attr1 = 'bar', out=['other'])");

    ConfiguredTarget target = getConfiguredTarget("//test/skylark:cr");

    assertThat(
        ActionsTestUtil.baseArtifactNames(
            target.getProvider(FileProvider.class).getFilesToBuild()))
        .containsExactly("bar.txt", "other")
        .inOrder();
  }

  @Test
  public void rulesReturningDeclaredProviders() throws Exception {
    scratch.file(
        "test/extension.bzl",
        "my_provider = provider()",
        "def _impl(ctx):",
        "   return [my_provider(x = 1)]",
        "my_rule = rule(_impl)"
    );
    scratch.file(
        "test/BUILD",
        "load(':extension.bzl', 'my_rule')",
        "my_rule(name = 'r')"
    );

    ConfiguredTarget configuredTarget = getConfiguredTarget("//test:r");
    ClassObjectConstructor.Key key = new SkylarkClassObjectConstructor.SkylarkKey(
        Label.create(configuredTarget.getLabel().getPackageIdentifier(), "extension.bzl"),
        "my_provider");
    SkylarkClassObject declaredProvider = configuredTarget.get(key);
    assertThat(declaredProvider).isNotNull();
    assertThat(declaredProvider.getConstructor().getKey()).isEqualTo(key);
    assertThat(declaredProvider.getValue("x")).isEqualTo(1);
  }

  @Test
  public void rulesReturningDeclaredProvidersCompatMode() throws Exception {
    scratch.file(
        "test/extension.bzl",
        "my_provider = provider()",
        "def _impl(ctx):",
        "   return struct(providers = [my_provider(x = 1)])",
        "my_rule = rule(_impl)"
    );
    scratch.file(
        "test/BUILD",
        "load(':extension.bzl', 'my_rule')",
        "my_rule(name = 'r')"
    );

    ConfiguredTarget configuredTarget  = getConfiguredTarget("//test:r");
    ClassObjectConstructor.Key key = new SkylarkClassObjectConstructor.SkylarkKey(
        Label.create(configuredTarget.getLabel().getPackageIdentifier(), "extension.bzl"),
        "my_provider");
    SkylarkClassObject declaredProvider = configuredTarget.get(key);
    assertThat(declaredProvider).isNotNull();
    assertThat(declaredProvider.getConstructor().getKey()).isEqualTo(key);
    assertThat(declaredProvider.getValue("x")).isEqualTo(1);
  }

  @Test
  public void testRecursionDetection() throws Exception {
    reporter.removeHandler(failFastHandler);
    scratch.file(
        "test/skylark/extension.bzl",
        "def _impl(ctx):",
        "  _impl(ctx)",
        "empty = rule(implementation = _impl)");
    scratch.file(
        "test/skylark/BUILD",
        "load('/test/skylark/extension', 'empty')",
        "empty(name = 'test_target')");

    getConfiguredTarget("//test/skylark:test_target");
    assertContainsEvent("Recursion was detected when calling '_impl' from '_impl'");
  }

  @Test
  public void testBadCallbackFunction() throws Exception {
    scratch.file(
        "test/skylark/extension.bzl", "def impl(): return 0", "", "custom_rule = rule(impl)");

    checkError(
        "test/skylark",
        "cr",
        "impl() does not accept positional arguments",
        "load('/test/skylark/extension', 'custom_rule')",
        "",
        "custom_rule(name = 'cr')");
  }

  @Test
  public void testRuleClassImplicitOutputFunctionBadAttr() throws Exception {
    scratch.file(
        "test/skylark/extension.bzl",
        "def custom_rule_impl(ctx):",
        "  return None",
        "",
        "def output_func(bad_attr):",
        "  return {'a': bad_attr}",
        "",
        "custom_rule = rule(implementation = custom_rule_impl,",
        "  attrs = {'attr1': attr.string()},",
        "  outputs = output_func)");

    checkError(
        "test/skylark",
        "cr",
        "Attribute 'bad_attr' either doesn't exist or uses a select()",
        "load('/test/skylark/extension', 'custom_rule')",
        "",
        "custom_rule(name = 'cr', attr1 = 'bar')");
  }

  @Test
  public void testHelperFunctionInRuleImplementation() throws Exception {
    scratch.file(
        "test/skylark/extension.bzl",
        "def helper_func(attr1):",
        "  return depset(attr1)",
        "",
        "def custom_rule_impl(ctx):",
        "  attr1 = ctx.files.attr1",
        "  ftb = helper_func(attr1)",
        "  return struct(runfiles = ctx.runfiles(), files = ftb)",
        "",
        "custom_rule = rule(implementation = custom_rule_impl,",
        "  attrs = {'attr1': attr.label_list(mandatory=True, allow_files=True)})");

    scratch.file(
        "test/skylark/BUILD",
        "load('/test/skylark/extension', 'custom_rule')",
        "",
        "custom_rule(name = 'cr', attr1 = [':a.txt'])");

    ConfiguredTarget target = getConfiguredTarget("//test/skylark:cr");

    assertThat(target.getLabel().toString()).isEqualTo("//test/skylark:cr");
    assertThat(
        ActionsTestUtil.baseArtifactNames(
            target.getProvider(FileProvider.class).getFilesToBuild()))
        .containsExactly("a.txt");
  }

  @Test
  public void testMultipleImportsOfSameRule() throws Exception {
    scratch.file("test/skylark/BUILD");
    scratch.file(
        "test/skylark/extension.bzl",
        "def custom_rule_impl(ctx):",
        "  return None",
        "",
        "custom_rule = rule(implementation = custom_rule_impl,",
        "     attrs = {'dep': attr.label_list(allow_files=True)})");

    scratch.file(
        "test/skylark1/BUILD",
        "load('/test/skylark/extension', 'custom_rule')",
        "custom_rule(name = 'cr1')");

    scratch.file(
        "test/skylark2/BUILD",
        "load('/test/skylark/extension', 'custom_rule')",
        "custom_rule(name = 'cr2', dep = ['//test/skylark1:cr1'])");

    getConfiguredTarget("//test/skylark2:cr2");
  }

  @Test
  public void testFunctionGeneratingRules() throws Exception {
    scratch.file(
        "test/skylark/extension.bzl",
        "def impl(ctx): return None",
        "def gen(): return rule(impl)",
        "r = gen()",
        "s = gen()");

    scratch.file(
        "test/skylark/BUILD", "load('extension', 'r', 's')", "r(name = 'r')", "s(name = 's')");

    getConfiguredTarget("//test/skylark:r");
    getConfiguredTarget("//test/skylark:s");
  }

  @Test
  public void testImportInSkylark() throws Exception {
    scratch.file("test/skylark/implementation.bzl", "def custom_rule_impl(ctx):", "  return None");

    scratch.file(
        "test/skylark/extension.bzl",
        "load('/test/skylark/implementation', 'custom_rule_impl')",
        "",
        "custom_rule = rule(implementation = custom_rule_impl,",
        "     attrs = {'dep': attr.label_list(allow_files=True)})");

    scratch.file(
        "test/skylark/BUILD",
        "load('/test/skylark/extension', 'custom_rule')",
        "custom_rule(name = 'cr')");

    getConfiguredTarget("//test/skylark:cr");
  }

  @Test
  public void testRuleAliasing() throws Exception {
    scratch.file(
        "test/skylark/implementation.bzl",
        "def impl(ctx): return struct()",
        "custom_rule = rule(implementation = impl)");

    scratch.file(
        "test/skylark/ext.bzl",
        "load('/test/skylark/implementation', 'custom_rule')",
        "def impl(ctx): return struct()",
        "custom_rule1 = rule(implementation = impl)",
        "custom_rule2 = custom_rule1",
        "custom_rule3 = custom_rule");

    scratch.file(
        "test/skylark/BUILD",
        "load('/test/skylark/ext', 'custom_rule1', 'custom_rule2', 'custom_rule3')",
        "custom_rule4 = custom_rule3",
        "custom_rule1(name = 'cr1')",
        "custom_rule2(name = 'cr2')",
        "custom_rule3(name = 'cr3')",
        "custom_rule4(name = 'cr4')");

    getConfiguredTarget("//test/skylark:cr1");
    getConfiguredTarget("//test/skylark:cr2");
    getConfiguredTarget("//test/skylark:cr3");
    getConfiguredTarget("//test/skylark:cr4");
  }

  @Test
  public void testRecursiveImport() throws Exception {
    scratch.file("test/skylark/ext2.bzl", "load('/test/skylark/ext1', 'symbol2')");

    scratch.file("test/skylark/ext1.bzl", "load('/test/skylark/ext2', 'symbol1')");

    scratch.file(
        "test/skylark/BUILD",
        "load('/test/skylark/ext1', 'custom_rule')",
        "genrule(name = 'rule')");

    reporter.removeHandler(failFastHandler);
    try {
      getTarget("//test/skylark:rule");
      fail();
    } catch (BuildFileContainsErrorsException e) {
      // This is expected
    }
    assertContainsEvent(
        "cycle detected in extension files: \n"
            + "    test/skylark/BUILD\n"
            + ".-> //test/skylark:ext1.bzl\n"
            + "|   //test/skylark:ext2.bzl\n"
            + "`-- //test/skylark:ext1.bzl");
  }

  @Test
  public void testRecursiveImport2() throws Exception {
    scratch.file("test/skylark/ext1.bzl", "load('//test/skylark:ext2.bzl', 'symbol2')");
    scratch.file("test/skylark/ext2.bzl", "load('//test/skylark:ext3.bzl', 'symbol3')");
    scratch.file("test/skylark/ext3.bzl", "load('//test/skylark:ext4.bzl', 'symbol4')");
    scratch.file("test/skylark/ext4.bzl", "load('//test/skylark:ext2.bzl', 'symbol2')");

    scratch.file(
        "test/skylark/BUILD",
        "load('//test/skylark:ext1.bzl', 'custom_rule')",
        "genrule(name = 'rule')");

    reporter.removeHandler(failFastHandler);
    try {
      getTarget("//test/skylark:rule");
      fail();
    } catch (BuildFileContainsErrorsException e) {
      // This is expected
    }
    assertContainsEvent(
        "cycle detected in extension files: \n"
            + "    //test/skylark:ext1.bzl\n"
            + ".-> //test/skylark:ext2.bzl\n"
            + "|   //test/skylark:ext3.bzl\n"
            + "|   //test/skylark:ext4.bzl\n"
            + "`-- //test/skylark:ext2.bzl");
  }

  @Test
  public void testSymbolPropagateThroughImports() throws Exception {
    scratch.file("test/skylark/implementation.bzl", "def custom_rule_impl(ctx):", "  return None");

    scratch.file(
        "test/skylark/extension2.bzl", "load('/test/skylark/implementation', 'custom_rule_impl')");

    scratch.file(
        "test/skylark/extension1.bzl",
        "load('/test/skylark/extension2', 'custom_rule_impl')",
        "",
        "custom_rule = rule(implementation = custom_rule_impl,",
        "     attrs = {'dep': attr.label_list()})");

    scratch.file(
        "test/skylark/BUILD",
        "load('/test/skylark/extension1', 'custom_rule')",
        "custom_rule(name = 'cr')");

    getConfiguredTarget("//test/skylark:cr");
  }

  @Test
  public void testLoadSymbolTypo() throws Exception {
    scratch.file("test/skylark/ext1.bzl", "myvariable = 2");

    scratch.file("test/skylark/BUILD", "load('//test/skylark:ext1.bzl', 'myvariables')");

    reporter.removeHandler(failFastHandler);
    getConfiguredTarget("//test/skylark:test_target");
    assertContainsEvent(
        "file '//test/skylark:ext1.bzl' does not contain symbol 'myvariables' "
            + "(did you mean 'myvariable'?)");
  }

  @Test
  public void testLoadSucceedsDespiteSyntaxError() throws Exception {
    reporter.removeHandler(failFastHandler);
    scratch.file(
        "test/skylark/macro.bzl",
        "x = 5");

    scratch.file("test/skylark/BUILD",
        "load('//test/skylark:macro.bzl', 'x')",
        "if 0: pass", // syntax error
        "print(1 / (5 - x)"); // division by 0

    // Make sure that evaluation continues and load() succeeds, despite a syntax
    // error in the file.
    // We can get the division by 0 only if x was correctly loaded.
    getConfiguredTarget("//test/skylark:a");
    assertContainsEvent("syntax error at 'if'");
    assertContainsEvent("integer division by zero");
  }

  /**
   * Skylark integration test that forces inlining.
   */
  @RunWith(JUnit4.class)
  public static class SkylarkIntegrationTestsWithInlineCalls extends SkylarkIntegrationTest {

    @Before
    public final void initializeLookupFunctions() throws Exception {
      ImmutableMap<SkyFunctionName, ? extends SkyFunction> skyFunctions =
          ((InMemoryMemoizingEvaluator) getSkyframeExecutor().getEvaluatorForTesting())
              .getSkyFunctionsForTesting();
      SkylarkImportLookupFunction skylarkImportLookupFunction =
          new SkylarkImportLookupFunction(this.getRuleClassProvider(), this.getPackageFactory());
      ((PackageFunction) skyFunctions.get(SkyFunctions.PACKAGE))
          .setSkylarkImportLookupFunctionForInliningForTesting(skylarkImportLookupFunction);
    }

    @Override
    @Test
    public void testRecursiveImport() throws Exception {
      scratch.file("test/skylark/ext2.bzl", "load('/test/skylark/ext1', 'symbol2')");

      scratch.file("test/skylark/ext1.bzl", "load('/test/skylark/ext2', 'symbol1')");

      scratch.file(
          "test/skylark/BUILD",
          "load('/test/skylark/ext1', 'custom_rule')",
          "genrule(name = 'rule')");

      reporter.removeHandler(failFastHandler);
      try {
        getTarget("//test/skylark:rule");
        fail();
      } catch (BuildFileContainsErrorsException e) {
        // The reason that this is an exception and not reported to the event handler is that the
        // error is reported by the parent sky function, which we don't have here.
        assertThat(e).hasMessageThat().contains("Skylark import cycle");
        assertThat(e).hasMessageThat().contains("test/skylark:ext1.bzl");
        assertThat(e).hasMessageThat().contains("test/skylark:ext2.bzl");
      }
    }

    @Override
    @Test
    public void testRecursiveImport2() throws Exception {
      scratch.file("test/skylark/ext1.bzl", "load('//test/skylark:ext2.bzl', 'symbol2')");
      scratch.file("test/skylark/ext2.bzl", "load('//test/skylark:ext3.bzl', 'symbol3')");
      scratch.file("test/skylark/ext3.bzl", "load('//test/skylark:ext4.bzl', 'symbol4')");
      scratch.file("test/skylark/ext4.bzl", "load('//test/skylark:ext2.bzl', 'symbol2')");

      scratch.file(
          "test/skylark/BUILD",
          "load('//test/skylark:ext1.bzl', 'custom_rule')",
          "genrule(name = 'rule')");

      reporter.removeHandler(failFastHandler);
      try {
        getTarget("//test/skylark:rule");
        fail();
      } catch (BuildFileContainsErrorsException e) {
        // The reason that this is an exception and not reported to the event handler is that the
        // error is reported by the parent sky function, which we don't have here.
        assertThat(e).hasMessageThat().contains("Skylark import cycle");
        assertThat(e).hasMessageThat().contains("//test/skylark:ext2.bzl");
        assertThat(e).hasMessageThat().contains("//test/skylark:ext3.bzl");
        assertThat(e).hasMessageThat().contains("//test/skylark:ext4.bzl");
      }
    }

  }
}
