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
package com.google.devtools.build.lib.syntax;

import static com.google.common.truth.Truth.assertThat;
import static com.google.common.truth.Truth.assertWithMessage;
import static org.junit.Assert.fail;

import com.google.common.collect.ImmutableList;
import com.google.devtools.build.lib.cmdline.Label;
import com.google.devtools.build.lib.events.Location;
import com.google.devtools.build.lib.syntax.DictionaryLiteral.DictionaryEntryLiteral;
import com.google.devtools.build.lib.syntax.SkylarkImports.SkylarkImportSyntaxException;
import com.google.devtools.build.lib.syntax.util.EvaluationTestCase;
import com.google.devtools.build.lib.vfs.PathFragment;
import java.util.LinkedList;
import java.util.List;
import org.junit.Test;
import org.junit.runner.RunWith;
import org.junit.runners.JUnit4;

/**
 *  Tests of parser behaviour.
 */
@RunWith(JUnit4.class)
public class ParserTest extends EvaluationTestCase {

  private BuildFileAST parseFileWithComments(String... input) {
    return BuildFileAST.parseBuildString(getEventHandler(), input);
  }

  /** Parses build code (not Skylark) */
  @Override
  protected List<Statement> parseFile(String... input) {
    return parseFileWithComments(input).getStatements();
  }

  /** Parses Skylark code */
  private List<Statement> parseFileForSkylark(String... input) {
    BuildFileAST ast = BuildFileAST.parseSkylarkString(getEventHandler(), input);
    ast = ast.validate(env, getEventHandler());
    return ast.getStatements();
  }

  private static String getText(String text, ASTNode node) {
    return text.substring(node.getLocation().getStartOffset(),
                          node.getLocation().getEndOffset());
  }

  private void assertLocation(int start, int end, Location location)
      throws Exception {
    int actualStart = location.getStartOffset();
    int actualEnd = location.getEndOffset();

    if (actualStart != start || actualEnd != end) {
      fail("Expected location = [" + start + ", " + end + "), found ["
          + actualStart + ", " + actualEnd + ")");
    }
  }

  // helper func for testListLiterals:
  private static int getIntElem(DictionaryEntryLiteral entry, boolean key) {
    return ((IntegerLiteral) (key ? entry.getKey() : entry.getValue())).getValue();
  }

  // helper func for testListLiterals:
  private static DictionaryEntryLiteral getElem(DictionaryLiteral list, int index) {
    return list.getEntries().get(index);
  }

  // helper func for testListLiterals:
  private static int getIntElem(ListLiteral list, int index) {
    return ((IntegerLiteral) list.getElements().get(index)).getValue();
  }

  // helper func for testListLiterals:
  private static Expression getElem(ListLiteral list, int index) {
    return list.getElements().get(index);
  }

  // helper func for testing arguments:
  private static Expression getArg(FuncallExpression f, int index) {
    return f.getArguments().get(index).getValue();
  }

  @Test
  public void testPrecedence1() throws Exception {
    BinaryOperatorExpression e =
      (BinaryOperatorExpression) parseExpression("'%sx' % 'foo' + 'bar'");

    assertThat(e.getOperator()).isEqualTo(Operator.PLUS);
  }

  @Test
  public void testPrecedence2() throws Exception {
    BinaryOperatorExpression e =
      (BinaryOperatorExpression) parseExpression("('%sx' % 'foo') + 'bar'");
    assertThat(e.getOperator()).isEqualTo(Operator.PLUS);
  }

  @Test
  public void testPrecedence3() throws Exception {
    BinaryOperatorExpression e =
      (BinaryOperatorExpression) parseExpression("'%sx' % ('foo' + 'bar')");
    assertThat(e.getOperator()).isEqualTo(Operator.PERCENT);
  }

  @Test
  public void testPrecedence4() throws Exception {
    BinaryOperatorExpression e =
        (BinaryOperatorExpression) parseExpression("1 + - (2 - 3)");
    assertThat(e.getOperator()).isEqualTo(Operator.PLUS);
  }

  @Test
  public void testPrecedence5() throws Exception {
    BinaryOperatorExpression e =
        (BinaryOperatorExpression) parseExpression("2 * x | y + 1");
    assertThat(e.getOperator()).isEqualTo(Operator.PIPE);
  }

  @Test
  public void testNonAssociativeOperators() throws Exception {
    setFailFast(false);

    parseExpression("0 < 2 < 4");
    assertContainsError("Operator '<' is not associative with operator '<'");
    clearEvents();

    parseExpression("0 == 2 < 4");
    assertContainsError("Operator '==' is not associative with operator '<'");
    clearEvents();

    parseExpression("1 in [1, 2] == True");
    assertContainsError("Operator 'in' is not associative with operator '=='");
    clearEvents();

    parseExpression("1 >= 2 <= 3");
    assertContainsError("Operator '>=' is not associative with operator '<='");
    clearEvents();
  }

  @Test
  public void testNonAssociativeOperatorsWithParens() throws Exception {
    parseExpression("(0 < 2) < 4");
    parseExpression("(0 == 2) < 4");
    parseExpression("(1 in [1, 2]) == True");
    parseExpression("1 >= (2 <= 3)");
  }

  @Test
  public void testUnaryMinusExpr() throws Exception {
    UnaryOperatorExpression e = (UnaryOperatorExpression) parseExpression("-5");
    UnaryOperatorExpression e2 = (UnaryOperatorExpression) parseExpression("- 5");

    IntegerLiteral i = (IntegerLiteral) e.getOperand();
    assertThat(i.getValue()).isEqualTo(5);
    IntegerLiteral i2 = (IntegerLiteral) e2.getOperand();
    assertThat(i2.getValue()).isEqualTo(5);
    assertLocation(0, 2, e.getLocation());
    assertLocation(0, 3, e2.getLocation());
  }

  @Test
  public void testFuncallExpr() throws Exception {
    FuncallExpression e = (FuncallExpression) parseExpression("foo(1, 2, bar=wiz)");

    Identifier ident = e.getFunction();
    assertThat(ident.getName()).isEqualTo("foo");

    assertThat(e.getArguments()).hasSize(3);
    assertThat(e.getNumPositionalArguments()).isEqualTo(2);

    IntegerLiteral arg0 = (IntegerLiteral) e.getArguments().get(0).getValue();
    assertThat((int) arg0.getValue()).isEqualTo(1);

    IntegerLiteral arg1 = (IntegerLiteral) e.getArguments().get(1).getValue();
    assertThat((int) arg1.getValue()).isEqualTo(2);

    Argument.Passed arg2 = e.getArguments().get(2);
    assertThat(arg2.getName()).isEqualTo("bar");
    Identifier arg2val = (Identifier) arg2.getValue();
    assertThat(arg2val.getName()).isEqualTo("wiz");
  }

  @Test
  public void testMethCallExpr() throws Exception {
    FuncallExpression e =
      (FuncallExpression) parseExpression("foo.foo(1, 2, bar=wiz)");

    Identifier ident = e.getFunction();
    assertThat(ident.getName()).isEqualTo("foo");

    assertThat(e.getArguments()).hasSize(3);
    assertThat(e.getNumPositionalArguments()).isEqualTo(2);

    IntegerLiteral arg0 = (IntegerLiteral) e.getArguments().get(0).getValue();
    assertThat((int) arg0.getValue()).isEqualTo(1);

    IntegerLiteral arg1 = (IntegerLiteral) e.getArguments().get(1).getValue();
    assertThat((int) arg1.getValue()).isEqualTo(2);

    Argument.Passed arg2 = e.getArguments().get(2);
    assertThat(arg2.getName()).isEqualTo("bar");
    Identifier arg2val = (Identifier) arg2.getValue();
    assertThat(arg2val.getName()).isEqualTo("wiz");
  }

  @Test
  public void testChainedMethCallExpr() throws Exception {
    FuncallExpression e =
      (FuncallExpression) parseExpression("foo.replace().split(1)");

    Identifier ident = e.getFunction();
    assertThat(ident.getName()).isEqualTo("split");

    assertThat(e.getArguments()).hasSize(1);
    assertThat(e.getNumPositionalArguments()).isEqualTo(1);

    IntegerLiteral arg0 = (IntegerLiteral) e.getArguments().get(0).getValue();
    assertThat((int) arg0.getValue()).isEqualTo(1);
  }

  @Test
  public void testPropRefExpr() throws Exception {
    DotExpression e = (DotExpression) parseExpression("foo.foo");

    Identifier ident = e.getField();
    assertThat(ident.getName()).isEqualTo("foo");
  }

  @Test
  public void testStringMethExpr() throws Exception {
    FuncallExpression e = (FuncallExpression) parseExpression("'foo'.foo()");

    Identifier ident = e.getFunction();
    assertThat(ident.getName()).isEqualTo("foo");

    assertThat(e.getArguments()).isEmpty();
  }

  @Test
  public void testStringLiteralOptimizationValue() throws Exception {
    StringLiteral l = (StringLiteral) parseExpression("'abc' + 'def'");
    assertThat(l.value).isEqualTo("abcdef");
  }

  @Test
  public void testStringLiteralOptimizationToString() throws Exception {
    StringLiteral l = (StringLiteral) parseExpression("'abc' + 'def'");
    assertThat(l.toString()).isEqualTo("\"abcdef\"");
  }

  @Test
  public void testStringLiteralOptimizationLocation() throws Exception {
    StringLiteral l = (StringLiteral) parseExpression("'abc' + 'def'");
    assertThat(l.getLocation().getStartOffset()).isEqualTo(0);
    assertThat(l.getLocation().getEndOffset()).isEqualTo(13);
  }

  @Test
  public void testStringLiteralOptimizationDifferentQuote() throws Exception {
    StringLiteral l = (StringLiteral) parseExpression("'abc' + \"def\"");
    assertThat(l.getLocation().getStartOffset()).isEqualTo(0);
    assertThat(l.getLocation().getEndOffset()).isEqualTo(13);
  }

  @Test
  public void testIndex() throws Exception {
    IndexExpression e = (IndexExpression) parseExpression("a[i]");
    assertThat(e.getObject().toString()).isEqualTo("a");
    assertThat(e.getKey().toString()).isEqualTo("i");
    assertLocation(0, 4, e.getLocation());
  }

  @Test
  public void testSubstring() throws Exception {
    SliceExpression s = (SliceExpression) parseExpression("'FOO.CC'[:].lower()[1:]");
    assertThat(((IntegerLiteral) s.getStart()).value).isEqualTo(1);

    FuncallExpression e = (FuncallExpression) parseExpression(
        "'FOO.CC'.lower()[1:].startswith('oo')");
    assertThat(e.getFunction().getName()).isEqualTo("startswith");
    assertThat(e.getArguments()).hasSize(1);

    s = (SliceExpression) parseExpression("'FOO.CC'[1:][:2]");
    assertThat(((IntegerLiteral) s.getEnd()).value).isEqualTo(2);
  }

  @Test
  public void testSlice() throws Exception {
    evalSlice("'0123'[:]", Runtime.NONE, Runtime.NONE, 1);
    evalSlice("'0123'[1:]", 1, Runtime.NONE, 1);
    evalSlice("'0123'[:3]", Runtime.NONE, 3, 1);
    evalSlice("'0123'[::]", Runtime.NONE, Runtime.NONE, 1);
    evalSlice("'0123'[1::]", 1, Runtime.NONE, 1);
    evalSlice("'0123'[:3:]", Runtime.NONE, 3, 1);
    evalSlice("'0123'[::-1]", Runtime.NONE, Runtime.NONE, -1);
    evalSlice("'0123'[1:3:]", 1, 3, 1);
    evalSlice("'0123'[1::-1]", 1, Runtime.NONE, -1);
    evalSlice("'0123'[:3:-1]", Runtime.NONE, 3, -1);
    evalSlice("'0123'[1:3:-1]", 1, 3, -1);

    Expression slice = parseExpression("'0123'[1:3:-1]");
    assertLocation(0, 14, slice.getLocation());
  }

  private void evalSlice(String statement, Object... expectedArgs) {
    SliceExpression e = (SliceExpression) parseExpression(statement);

    // There is no way to evaluate the expression here, so we rely on string comparison.
    assertThat(e.getStart().toString()).isEqualTo(expectedArgs[0].toString());
    assertThat(e.getEnd().toString()).isEqualTo(expectedArgs[1].toString());
    assertThat(e.getStep().toString()).isEqualTo(expectedArgs[2].toString());
  }

  @Test
  public void testErrorRecovery() throws Exception {
    setFailFast(false);

    String expr = "f(1, [x for foo foo foo foo], 3)";
    FuncallExpression e = (FuncallExpression) parseExpression(expr);

    assertContainsError("syntax error at 'foo'");

    // Test that the actual parameters are: (1, $error$, 3):

    Identifier ident = e.getFunction();
    assertThat(ident.getName()).isEqualTo("f");

    assertThat(e.getArguments()).hasSize(3);
    assertThat(e.getNumPositionalArguments()).isEqualTo(3);

    IntegerLiteral arg0 = (IntegerLiteral) e.getArguments().get(0).getValue();
    assertThat((int) arg0.getValue()).isEqualTo(1);

    Argument.Passed arg1 = e.getArguments().get(1);
    Identifier arg1val = ((Identifier) arg1.getValue());
    assertThat(arg1val.getName()).isEqualTo("$error$");

    assertLocation(5, 29, arg1val.getLocation());
    assertThat(expr.substring(5, 28)).isEqualTo("[x for foo foo foo foo]");
    assertThat(arg1val.getLocation().getEndLineAndColumn().getColumn()).isEqualTo(30);

    IntegerLiteral arg2 = (IntegerLiteral) e.getArguments().get(2).getValue();
    assertThat((int) arg2.getValue()).isEqualTo(3);
  }

  @Test
  public void testDoesntGetStuck() throws Exception {
    setFailFast(false);

    // Make sure the parser does not get stuck when trying
    // to parse an expression containing a syntax error.
    // This usually results in OutOfMemoryError because the
    // parser keeps filling up the error log.
    // We need to make sure that we will always advance
    // in the token stream.
    parseExpression("f(1, ], 3)");
    parseExpression("f(1, ), 3)");
    parseExpression("[ ) for v in 3)");

    assertContainsError(""); // "" matches any, i.e., there were some events
  }

  @Test
  public void testSecondaryLocation() {
    String expr = "f(1 % 2)";
    FuncallExpression call = (FuncallExpression) parseExpression(expr);
    Argument.Passed arg = call.getArguments().get(0);
    assertThat(arg.getLocation().getEndOffset()).isLessThan(call.getLocation().getEndOffset());
  }

  @Test
  public void testPrimaryLocation() {
    String expr = "f(1 + 2)";
    FuncallExpression call = (FuncallExpression) parseExpression(expr);
    Argument.Passed arg = call.getArguments().get(0);
    assertThat(arg.getLocation().getEndOffset()).isLessThan(call.getLocation().getEndOffset());
  }

  @Test
  public void testAssignLocation() {
    List<Statement> statements = parseFile("a = b;c = d\n");
    Statement statement = statements.get(0);
    assertThat(statement.getLocation().getEndOffset()).isEqualTo(5);
  }

  @Test
  public void testAssignKeyword() {
    setFailFast(false);
    parseExpression("with = 4");
    assertContainsError("keyword 'with' not supported");
    assertContainsError("syntax error at 'with': expected expression");
  }

  @Test
  public void testBreak() {
    setFailFast(false);
    parseExpression("break");
    assertContainsError("syntax error at 'break': expected expression");
  }

  @Test
  public void testTry() {
    setFailFast(false);
    parseExpression("try: 1 + 1");
    assertContainsError("'try' not supported, all exceptions are fatal");
    assertContainsError("syntax error at 'try': expected expression");
  }

  @Test
  public void testDel() {
    setFailFast(false);
    parseExpression("del d['a']");
    assertContainsError("'del' not supported, use '.pop()' to delete");
  }

  @Test
  public void testTupleAssign() {
    List<Statement> statements = parseFile("list[0] = 5; dict['key'] = value\n");
    assertThat(statements).hasSize(2);
    assertThat(statements.get(0)).isInstanceOf(AssignmentStatement.class);
    assertThat(statements.get(1)).isInstanceOf(AssignmentStatement.class);
  }

  @Test
  public void testAssign() {
    List<Statement> statements = parseFile("a, b = 5\n");
    assertThat(statements).hasSize(1);
    assertThat(statements.get(0)).isInstanceOf(AssignmentStatement.class);
    AssignmentStatement assign = (AssignmentStatement) statements.get(0);
    assertThat(assign.getLValue().getExpression()).isInstanceOf(ListLiteral.class);
  }

  @Test
  public void testInvalidAssign() {
    setFailFast(false);
    parseExpression("1 + (b = c)");
    assertContainsError("syntax error");
    clearEvents();
  }

  @Test
  public void testAugmentedAssign() throws Exception {
    assertThat(parseFile("x += 1").toString()).isEqualTo("[x += 1\n]");
    assertThat(parseFile("x -= 1").toString()).isEqualTo("[x -= 1\n]");
    assertThat(parseFile("x *= 1").toString()).isEqualTo("[x *= 1\n]");
    assertThat(parseFile("x /= 1").toString()).isEqualTo("[x /= 1\n]");
    assertThat(parseFile("x %= 1").toString()).isEqualTo("[x %= 1\n]");
  }

  @Test
  public void testPrettyPrintFunctions() throws Exception {
    assertThat(parseFile("x[1:3]").toString()).isEqualTo("[x[1:3]\n]");
    assertThat(parseFile("x[1:3:1]").toString()).isEqualTo("[x[1:3]\n]");
    assertThat(parseFile("x[1:3:2]").toString()).isEqualTo("[x[1:3:2]\n]");
    assertThat(parseFile("x[1::2]").toString()).isEqualTo("[x[1::2]\n]");
    assertThat(parseFile("x[1:]").toString()).isEqualTo("[x[1:]\n]");
    assertThat(parseFile("str[42]").toString()).isEqualTo("[str[42]\n]");
    assertThat(parseFile("ctx.actions.declare_file('hello')").toString())
        .isEqualTo("[ctx.actions.declare_file(\"hello\")\n]");
    assertThat(parseFile("new_file(\"hello\")").toString()).isEqualTo("[new_file(\"hello\")\n]");
  }

  @Test
  public void testFuncallLocation() {
    List<Statement> statements = parseFile("a(b);c = d\n");
    Statement statement = statements.get(0);
    assertThat(statement.getLocation().getEndOffset()).isEqualTo(4);
  }

  @Test
  public void testListPositions() throws Exception {
    String expr = "[0,f(1),2]";
    ListLiteral list = (ListLiteral) parseExpression(expr);
    assertThat(getText(expr, list)).isEqualTo("[0,f(1),2]");
    assertThat(getText(expr, getElem(list, 0))).isEqualTo("0");
    assertThat(getText(expr, getElem(list, 1))).isEqualTo("f(1)");
    assertThat(getText(expr, getElem(list, 2))).isEqualTo("2");
  }

  @Test
  public void testDictPositions() throws Exception {
    String expr = "{1:2,2:f(1),3:4}";
    DictionaryLiteral list = (DictionaryLiteral) parseExpression(expr);
    assertThat(getText(expr, list)).isEqualTo("{1:2,2:f(1),3:4}");
    assertThat(getText(expr, getElem(list, 0))).isEqualTo("1:2");
    assertThat(getText(expr, getElem(list, 1))).isEqualTo("2:f(1)");
    assertThat(getText(expr, getElem(list, 2))).isEqualTo("3:4");
  }

  @Test
  public void testArgumentPositions() throws Exception {
    String stmt = "f(0,g(1,2),2)";
    FuncallExpression f = (FuncallExpression) parseExpression(stmt);
    assertThat(getText(stmt, f)).isEqualTo(stmt);
    assertThat(getText(stmt, getArg(f, 0))).isEqualTo("0");
    assertThat(getText(stmt, getArg(f, 1))).isEqualTo("g(1,2)");
    assertThat(getText(stmt, getArg(f, 2))).isEqualTo("2");
  }

  @Test
  public void testForBreakContinue() throws Exception {
    List<Statement> file = parseFileForSkylark(
        "def foo():",
        "  for i in [1, 2]:",
        "    break",
        "    continue",
        "    break");
    assertThat(file).hasSize(1);
    List<Statement> body = ((FunctionDefStatement) file.get(0)).getStatements();
    assertThat(body).hasSize(1);

    List<Statement> loop = ((ForStatement) body.get(0)).block();
    assertThat(loop).hasSize(3);

    assertThat(((FlowStatement) loop.get(0)).getKind()).isEqualTo(FlowStatement.Kind.BREAK);
    assertLocation(34, 39, loop.get(0).getLocation());

    assertThat(((FlowStatement) loop.get(1)).getKind()).isEqualTo(FlowStatement.Kind.CONTINUE);
    assertLocation(44, 52, loop.get(1).getLocation());

    assertThat(((FlowStatement) loop.get(2)).getKind()).isEqualTo(FlowStatement.Kind.BREAK);
    assertLocation(57, 62, loop.get(2).getLocation());
  }

  @Test
  public void testListLiterals1() throws Exception {
    ListLiteral list = (ListLiteral) parseExpression("[0,1,2]");
    assertThat(list.isTuple()).isFalse();
    assertThat(list.getElements()).hasSize(3);
    assertThat(list.isTuple()).isFalse();
    for (int i = 0; i < 3; ++i) {
      assertThat(getIntElem(list, i)).isEqualTo(i);
    }
  }

  @Test
  public void testTupleLiterals2() throws Exception {
    ListLiteral tuple = (ListLiteral) parseExpression("(0,1,2)");
    assertThat(tuple.isTuple()).isTrue();
    assertThat(tuple.getElements()).hasSize(3);
    assertThat(tuple.isTuple()).isTrue();
    for (int i = 0; i < 3; ++i) {
      assertThat(getIntElem(tuple, i)).isEqualTo(i);
    }
  }

  @Test
  public void testTupleWithoutParens() throws Exception {
    ListLiteral tuple = (ListLiteral) parseExpression("0, 1, 2");
    assertThat(tuple.isTuple()).isTrue();
    assertThat(tuple.getElements()).hasSize(3);
    assertThat(tuple.isTuple()).isTrue();
    for (int i = 0; i < 3; ++i) {
      assertThat(getIntElem(tuple, i)).isEqualTo(i);
    }
  }

  @Test
  public void testTupleWithTrailingComma() throws Exception {
    setFailFast(false);

    // Unlike Python, we require parens here.
    parseExpression("0, 1, 2, 3,");
    assertContainsError("Trailing comma");
    clearEvents();

    parseExpression("1 + 2,");
    assertContainsError("Trailing comma");
    clearEvents();

    ListLiteral tuple = (ListLiteral) parseExpression("(0, 1, 2, 3,)");
    assertThat(tuple.isTuple()).isTrue();
    assertThat(tuple.getElements()).hasSize(4);
    assertThat(tuple.isTuple()).isTrue();
    for (int i = 0; i < 4; ++i) {
      assertThat(getIntElem(tuple, i)).isEqualTo(i);
    }
  }

  @Test
  public void testTupleLiterals3() throws Exception {
    ListLiteral emptyTuple = (ListLiteral) parseExpression("()");
    assertThat(emptyTuple.isTuple()).isTrue();
    assertThat(emptyTuple.getElements()).isEmpty();
  }

  @Test
  public void testTupleLiterals4() throws Exception {
    ListLiteral singletonTuple = (ListLiteral) parseExpression("(42,)");
    assertThat(singletonTuple.isTuple()).isTrue();
    assertThat(singletonTuple.getElements()).hasSize(1);
    assertThat(getIntElem(singletonTuple, 0)).isEqualTo(42);
  }

  @Test
  public void testTupleLiterals5() throws Exception {
    IntegerLiteral intLit = (IntegerLiteral) parseExpression("(42)"); // not a tuple!
    assertThat((int) intLit.getValue()).isEqualTo(42);
  }

  @Test
  public void testListLiterals6() throws Exception {
    ListLiteral emptyList = (ListLiteral) parseExpression("[]");
    assertThat(emptyList.isTuple()).isFalse();
    assertThat(emptyList.getElements()).isEmpty();
  }

  @Test
  public void testListLiterals7() throws Exception {
    ListLiteral singletonList = (ListLiteral) parseExpression("[42,]");
    assertThat(singletonList.isTuple()).isFalse();
    assertThat(singletonList.getElements()).hasSize(1);
    assertThat(getIntElem(singletonList, 0)).isEqualTo(42);
  }

  @Test
  public void testListLiterals8() throws Exception {
    ListLiteral singletonList = (ListLiteral) parseExpression("[42]"); // a singleton
    assertThat(singletonList.isTuple()).isFalse();
    assertThat(singletonList.getElements()).hasSize(1);
    assertThat(getIntElem(singletonList, 0)).isEqualTo(42);
  }

  @Test
  public void testDictionaryLiterals() throws Exception {
    DictionaryLiteral dictionaryList =
      (DictionaryLiteral) parseExpression("{1:42}"); // a singleton dictionary
    assertThat(dictionaryList.getEntries()).hasSize(1);
    DictionaryEntryLiteral tuple = getElem(dictionaryList, 0);
    assertThat(getIntElem(tuple, true)).isEqualTo(1);
    assertThat(getIntElem(tuple, false)).isEqualTo(42);
  }

  @Test
  public void testDictionaryLiterals1() throws Exception {
    DictionaryLiteral dictionaryList =
      (DictionaryLiteral) parseExpression("{}"); // an empty dictionary
    assertThat(dictionaryList.getEntries()).isEmpty();
  }

  @Test
  public void testDictionaryLiterals2() throws Exception {
    DictionaryLiteral dictionaryList =
      (DictionaryLiteral) parseExpression("{1:42,}"); // a singleton dictionary
    assertThat(dictionaryList.getEntries()).hasSize(1);
    DictionaryEntryLiteral tuple = getElem(dictionaryList, 0);
    assertThat(getIntElem(tuple, true)).isEqualTo(1);
    assertThat(getIntElem(tuple, false)).isEqualTo(42);
  }

  @Test
  public void testDictionaryLiterals3() throws Exception {
    DictionaryLiteral dictionaryList = (DictionaryLiteral) parseExpression("{1:42,2:43,3:44}");
    assertThat(dictionaryList.getEntries()).hasSize(3);
    for (int i = 0; i < 3; i++) {
      DictionaryEntryLiteral tuple = getElem(dictionaryList, i);
      assertThat(getIntElem(tuple, true)).isEqualTo(i + 1);
      assertThat(getIntElem(tuple, false)).isEqualTo(i + 42);
    }
  }

  @Test
  public void testListLiterals9() throws Exception {
    ListLiteral singletonList =
      (ListLiteral) parseExpression("[ abi + opt_level + \'/include\' ]");
    assertThat(singletonList.isTuple()).isFalse();
    assertThat(singletonList.getElements()).hasSize(1);
  }

  @Test
  public void testListComprehensionSyntax() throws Exception {
    setFailFast(false);

    parseExpression("[x for");
    assertContainsError("syntax error at 'newline'");
    clearEvents();

    parseExpression("[x for x");
    assertContainsError("syntax error at 'newline'");
    clearEvents();

    parseExpression("[x for x in");
    assertContainsError("syntax error at 'newline'");
    clearEvents();

    parseExpression("[x for x in []");
    assertContainsError("syntax error at 'newline'");
    clearEvents();

    parseExpression("[x for x for y in ['a']]");
    assertContainsError("syntax error at 'for'");
    clearEvents();

    parseExpression("[x for x for y in 1, 2]");
    assertContainsError("syntax error at 'for'");
    clearEvents();
  }

  @Test
  public void testListComprehensionEmptyList() throws Exception {
    List<ListComprehension.Clause> clauses = ((ListComprehension) parseExpression(
        "['foo/%s.java' % x for x in []]")).getClauses();
    assertThat(clauses).hasSize(1);
    assertThat(clauses.get(0).getExpression().toString()).isEqualTo("[]");
    assertThat(clauses.get(0).getLValue().getExpression().toString()).isEqualTo("x");
  }

  @Test
  public void testListComprehension() throws Exception {
    List<ListComprehension.Clause> clauses = ((ListComprehension) parseExpression(
        "['foo/%s.java' % x for x in ['bar', 'wiz', 'quux']]")).getClauses();
    assertThat(clauses).hasSize(1);
    assertThat(clauses.get(0).getLValue().getExpression().toString()).isEqualTo("x");
    assertThat(clauses.get(0).getExpression()).isInstanceOf(ListLiteral.class);
  }

  @Test
  public void testForForListComprehension() throws Exception {
    List<ListComprehension.Clause> clauses = ((ListComprehension) parseExpression(
        "['%s/%s.java' % (x, y) for x in ['foo', 'bar'] for y in list]")).getClauses();
    assertThat(clauses).hasSize(2);
    assertThat(clauses.get(0).getLValue().getExpression().toString()).isEqualTo("x");
    assertThat(clauses.get(0).getExpression()).isInstanceOf(ListLiteral.class);
    assertThat(clauses.get(1).getLValue().getExpression().toString()).isEqualTo("y");
    assertThat(clauses.get(1).getExpression()).isInstanceOf(Identifier.class);
  }

  @Test
  public void testParserRecovery() throws Exception {
    setFailFast(false);
    List<Statement> statements = parseFileForSkylark(
        "def foo():",
        "  a = 2 for 4",  // parse error
        "  b = [3, 4]",
        "",
        "d = 4 ada",  // parse error
        "",
        "def bar():",
        "  a = [3, 4]",
        "  b = 2 + + 5",  // parse error
        "");

    assertThat(getEventCollector()).hasSize(3);
    assertContainsError("syntax error at 'for': expected newline");
    assertContainsError("syntax error at 'ada': expected newline");
    assertContainsError("syntax error at '+': expected expression");
    assertThat(statements).hasSize(3);
  }

  @Test
  public void testParserContainsErrorsIfSyntaxException() throws Exception {
    setFailFast(false);
    parseExpression("'foo' %%");
    assertContainsError("syntax error at '%'");
  }

  @Test
  public void testParserDoesNotContainErrorsIfSuccess() throws Exception {
    parseExpression("'foo'");
  }

  @Test
  public void testParserContainsErrors() throws Exception {
    setFailFast(false);
    parseFile("+");
    assertContainsError("syntax error at '+'");
  }

  @Test
  public void testSemicolonAndNewline() throws Exception {
    List<Statement> stmts = parseFile(
        "foo='bar'; foo(bar)",
        "",
        "foo='bar'; foo(bar)");
    assertThat(stmts).hasSize(4);
  }

  @Test
  public void testSemicolonAndNewline2() throws Exception {
    setFailFast(false);
    List<Statement> stmts = parseFile(
        "foo='foo' error(bar)",
        "",
        "");
    assertContainsError("syntax error at 'error'");
    assertThat(stmts).hasSize(1);
  }

  @Test
  public void testExprAsStatement() throws Exception {
    List<Statement> stmts = parseFile(
        "li = []",
        "li.append('a.c')",
        "\"\"\" string comment \"\"\"",
        "foo(bar)");
    assertThat(stmts).hasSize(4);
  }

  @Test
  public void testParseBuildFileWithSingeRule() throws Exception {
    List<Statement> stmts = parseFile(
        "genrule(name = 'foo',",
        "   srcs = ['input.csv'],",
        "   outs = [ 'result.txt',",
        "           'result.log'],",
        "   cmd = 'touch result.txt result.log')",
        "");
    assertThat(stmts).hasSize(1);
  }

  @Test
  public void testParseBuildFileWithMultipleRules() throws Exception {
    List<Statement> stmts = parseFile(
        "genrule(name = 'foo',",
        "   srcs = ['input.csv'],",
        "   outs = [ 'result.txt',",
        "           'result.log'],",
        "   cmd = 'touch result.txt result.log')",
        "",
        "genrule(name = 'bar',",
        "   srcs = ['input.csv'],",
        "   outs = [ 'graph.svg'],",
        "   cmd = 'touch graph.svg')");
    assertThat(stmts).hasSize(2);
  }

  @Test
  public void testParseBuildFileWithComments() throws Exception {
    BuildFileAST result = parseFileWithComments(
      "# Test BUILD file",
      "# with multi-line comment",
      "",
      "genrule(name = 'foo',",
      "   srcs = ['input.csv'],",
      "   outs = [ 'result.txt',",
      "           'result.log'],",
      "   cmd = 'touch result.txt result.log')");
    assertThat(result.getStatements()).hasSize(1);
    assertThat(result.getComments()).hasSize(2);
  }

  @Test
  public void testParseBuildFileWithManyComments() throws Exception {
    BuildFileAST result = parseFileWithComments(
        "# 1",
        "# 2",
        "",
        "# 4 ",
        "# 5",
        "#", // 6 - find empty comment for syntax highlighting
        "# 7 ",
        "# 8",
        "genrule(name = 'foo',",
        "   srcs = ['input.csv'],",
        "   # 11",
        "   outs = [ 'result.txt',",
        "           'result.log'], # 13",
        "   cmd = 'touch result.txt result.log')",
        "# 15");
    assertThat(result.getStatements()).hasSize(1); // Single genrule
    StringBuilder commentLines = new StringBuilder();
    for (Comment comment : result.getComments()) {
      // Comments start and end on the same line
      assertWithMessage(
              comment.getLocation().getStartLineAndColumn().getLine()
                  + " ends on "
                  + comment.getLocation().getEndLineAndColumn().getLine())
          .that(comment.getLocation().getEndLineAndColumn().getLine())
          .isEqualTo(comment.getLocation().getStartLineAndColumn().getLine());
      commentLines.append('(');
      commentLines.append(comment.getLocation().getStartLineAndColumn().getLine());
      commentLines.append(',');
      commentLines.append(comment.getLocation().getStartLineAndColumn().getColumn());
      commentLines.append(") ");
    }
    assertWithMessage("Found: " + commentLines)
        .that(result.getComments().size()).isEqualTo(10); // One per '#'
  }

  @Test
  public void testMissingComma() throws Exception {
    setFailFast(false);
    // Regression test.
    // Note: missing comma after name='foo'
    parseFile("genrule(name = 'foo'\n"
              + "      srcs = ['in'])");
    assertContainsError("syntax error at 'srcs'");
  }

  @Test
  public void testDoubleSemicolon() throws Exception {
    setFailFast(false);
    // Regression test.
    parseFile("x = 1; ; x = 2;");
    assertContainsError("syntax error at ';'");
  }

  @Test
  public void testFunctionDefinitionErrorRecovery() throws Exception {
    // Parser skips over entire function definitions, and reports a meaningful
    // error.
    setFailFast(false);
    List<Statement> stmts = parseFile(
        "x = 1;\n"
        + "def foo(x, y, **z):\n"
        + "  # a comment\n"
        + "  x = 2\n"
        + "  foo(bar)\n"
        + "  return z\n"
        + "x = 3");
    assertThat(stmts).hasSize(2);
  }

  @Test
  public void testDefSingleLine() throws Exception {
    List<Statement> statements = parseFileForSkylark(
        "def foo(): x = 1; y = 2\n");
    FunctionDefStatement stmt = (FunctionDefStatement) statements.get(0);
    assertThat(stmt.getStatements()).hasSize(2);
  }

  @Test
  public void testPass() throws Exception {
    List<Statement> statements = parseFileForSkylark("pass\n");
    assertThat(statements).isEmpty();
  }

  @Test
  public void testForPass() throws Exception {
    List<Statement> statements = parseFileForSkylark(
        "def foo():",
        "  pass\n");

    assertThat(statements).hasSize(1);
    FunctionDefStatement stmt = (FunctionDefStatement) statements.get(0);
    assertThat(stmt.getStatements()).isEmpty();
  }

  @Test
  public void testSkipIfBlockFail() throws Exception {
    // Do not parse 'if' blocks, when parsePython is not set
    setFailFast(false);
    List<Statement> stmts = parseFile(
        "x = 1;",
        "if x == 1:",
        "  x = 2",
        "x = 3;\n");
    assertThat(stmts).hasSize(2);
    assertContainsError("This is not supported in BUILD files");
  }

  @Test
  public void testForLoopMultipleVariables() throws Exception {
    List<Statement> stmts1 = parseFile("[ i for i, j, k in [(1, 2, 3)] ]\n");
    assertThat(stmts1).hasSize(1);

    List<Statement> stmts2 = parseFile("[ i for i, j in [(1, 2, 3)] ]\n");
    assertThat(stmts2).hasSize(1);

    List<Statement> stmts3 = parseFile("[ i for (i, j, k) in [(1, 2, 3)] ]\n");
    assertThat(stmts3).hasSize(1);
  }

  @Test
  public void testReturnNone() throws Exception {
    List<Statement> defNone = parseFileForSkylark("def foo():", "  return None\n");
    assertThat(defNone).hasSize(1);

    List<Statement> bodyNone = ((FunctionDefStatement) defNone.get(0)).getStatements();
    assertThat(bodyNone).hasSize(1);

    ReturnStatement returnNone = (ReturnStatement) bodyNone.get(0);
    assertThat(((Identifier) returnNone.getReturnExpression()).getName()).isEqualTo("None");

    int i = 0;
    for (String end : new String[]{";", "\n"}) {
      List<Statement> defNoExpr = parseFileForSkylark("def bar" + i + "():", "  return" + end);
      i++;
      assertThat(defNoExpr).hasSize(1);

      List<Statement> bodyNoExpr = ((FunctionDefStatement) defNoExpr.get(0)).getStatements();
      assertThat(bodyNoExpr).hasSize(1);

      ReturnStatement returnNoExpr = (ReturnStatement) bodyNoExpr.get(0);
      Identifier none = (Identifier) returnNoExpr.getReturnExpression();
      assertThat(none.getName()).isEqualTo("None");
      assertLocation(
          returnNoExpr.getLocation().getStartOffset(),
          returnNoExpr.getLocation().getEndOffset(),
          none.getLocation());
    }
  }

  @Test
  public void testForLoopBadSyntax() throws Exception {
    setFailFast(false);
    parseFile("[1 for (a, b, c in var]\n");
    assertContainsError("syntax error");
  }

  @Test
  public void testForLoopBadSyntax2() throws Exception {
    setFailFast(false);
    parseFile("[1 for in var]\n");
    assertContainsError("syntax error");
  }

  @Test
  public void testFunCallBadSyntax() throws Exception {
    setFailFast(false);
    parseFile("f(1,\n");
    assertContainsError("syntax error");
  }

  @Test
  public void testFunCallBadSyntax2() throws Exception {
    setFailFast(false);
    parseFile("f(1, 5, ,)\n");
    assertContainsError("syntax error");
  }

  @Test
  public void testValidAbsoluteImportPath() throws SkylarkImportSyntaxException {
    String importString = "/some/skylark/file";
    List<Statement> statements =
        parseFileForSkylark("load('" + importString + "', 'fun_test')\n");
    LoadStatement stmt = (LoadStatement) statements.get(0);
    SkylarkImport imp = SkylarkImports.create(stmt.getImport().getValue());

    assertThat(imp.getImportString()).named("getImportString()").isEqualTo("/some/skylark/file");
    assertThat(imp.hasAbsolutePath()).named("hasAbsolutePath()").isTrue();
    assertThat(imp.getAbsolutePath()).named("getAbsolutePath()")
        .isEqualTo(PathFragment.create("/some/skylark/file.bzl"));

    int startOffset = stmt.getImport().getLocation().getStartOffset();
    int endOffset = stmt.getImport().getLocation().getEndOffset();
    assertThat(startOffset).named("getStartOffset()").isEqualTo(5);
    assertThat(endOffset).named("getEndOffset()")
        .isEqualTo(startOffset + importString.length() + 2);
  }

  private void validNonAbsoluteImportTest(String importString, String containingFileLabelString,
      String expectedLabelString) throws SkylarkImportSyntaxException {
    List<Statement> statements =
        parseFileForSkylark("load('" + importString + "', 'fun_test')\n");
    LoadStatement stmt = (LoadStatement) statements.get(0);
    SkylarkImport imp = SkylarkImports.create(stmt.getImport().getValue());

    assertThat(imp.getImportString()).named("getImportString()").isEqualTo(importString);
    assertThat(imp.hasAbsolutePath()).named("hasAbsolutePath()").isFalse();

    Label containingFileLabel = Label.parseAbsoluteUnchecked(containingFileLabelString);
    assertThat(imp.getLabel(containingFileLabel)).named("containingFileLabel()")
        .isEqualTo(Label.parseAbsoluteUnchecked(expectedLabelString));

    int startOffset = stmt.getImport().getLocation().getStartOffset();
    int endOffset = stmt.getImport().getLocation().getEndOffset();
    assertThat(startOffset).named("getStartOffset()").isEqualTo(5);
    assertThat(endOffset).named("getEndOffset()")
        .isEqualTo(startOffset + importString.length() + 2);
  }

  private void invalidImportTest(String importString, String expectedMsg) {
    setFailFast(false);
    parseFileForSkylark("load('" + importString + "', 'fun_test')\n");
    assertContainsError(expectedMsg);
  }

  @Test
  public void testValidRelativeImportPathInPackageDir() throws Exception {
    validNonAbsoluteImportTest("file", /*containing*/ "//some/skylark:BUILD",
        /*expected*/ "//some/skylark:file.bzl");
  }

  @Test
  public void testValidRelativeImportPathInPackageSubdir() throws Exception {
    validNonAbsoluteImportTest("file", /*containing*/ "//some/path/to:skylark/parent.bzl",
        /*expected*/ "//some/path/to:skylark/file.bzl");
  }

  @Test
  public void testInvalidRelativePathBzlExtImplicit() throws Exception {
    invalidImportTest("file.bzl", SkylarkImports.INVALID_PATH_SYNTAX);
  }

  @Test
  public void testInvalidRelativePathNoSubdirs() throws Exception {
    invalidImportTest("path/to/file", SkylarkImports.INVALID_PATH_SYNTAX);
  }

  @Test
  public void testInvalidRelativePathInvalidFilename() throws Exception {
    invalidImportTest("\tfile", SkylarkImports.INVALID_FILENAME_PREFIX);
  }

  private void validAbsoluteImportLabelTest(String importString)
      throws SkylarkImportSyntaxException {
    validNonAbsoluteImportTest(importString, /*irrelevant*/ "//another/path:BUILD",
        /*expected*/ importString);
  }

  @Test
  public void testValidAbsoluteImportLabel() throws Exception {
    validAbsoluteImportLabelTest("//some/skylark:file.bzl");
  }

  @Test
  public void testValidAbsoluteImportLabelWithRepo() throws Exception {
    validAbsoluteImportLabelTest("@my_repo//some/skylark:file.bzl");
  }

  @Test
  public void testInvalidAbsoluteImportLabel() throws Exception {
    invalidImportTest("//some/skylark/:file.bzl", SkylarkImports.INVALID_LABEL_PREFIX);
  }

  @Test
  public void testInvalidAbsoluteImportLabelWithRepo() throws Exception {
    invalidImportTest("@my_repo//some/skylark/:file.bzl",
        SkylarkImports.INVALID_LABEL_PREFIX);
  }

  @Test
  public void testInvalidAbsoluteImportLabelMissingBzlExt() throws Exception {
    invalidImportTest("//some/skylark:file", SkylarkImports.MUST_HAVE_BZL_EXT_MSG);
  }

  @Test
  public void testInvalidAbsoluteImportReferencesExternalPkg() throws Exception {
    invalidImportTest("//external:file.bzl", SkylarkImports.EXTERNAL_PKG_NOT_ALLOWED_MSG);
  }

  @Test
  public void testValidRelativeImportSimpleLabelInPackageDir() throws Exception {
    validNonAbsoluteImportTest(":file.bzl", /*containing*/ "//some/skylark:BUILD",
        /*expected*/ "//some/skylark:file.bzl");
  }

  @Test
  public void testValidRelativeImportSimpleLabelInPackageSubdir() throws Exception {
    validNonAbsoluteImportTest(":file.bzl", /*containing*/ "//some/path/to:skylark/parent.bzl",
        /*expected*/ "//some/path/to:file.bzl");
  }

  @Test
  public void testValidRelativeImportComplexLabelInPackageDir() throws Exception {
    validNonAbsoluteImportTest(":subdir/containing/file.bzl", /*containing*/ "//some/skylark:BUILD",
        /*expected*/ "//some/skylark:subdir/containing/file.bzl");
  }

  @Test
  public void testValidRelativeImportComplexLabelInPackageSubdir() throws Exception {
    validNonAbsoluteImportTest(":subdir/containing/file.bzl",
        /*containing*/ "//some/path/to:skylark/parent.bzl",
        /*expected*/ "//some/path/to:subdir/containing/file.bzl");
  }

  @Test
  public void testInvalidRelativeImportLabelMissingBzlExt() throws Exception {
    invalidImportTest(":file", SkylarkImports.MUST_HAVE_BZL_EXT_MSG);
  }

  @Test
  public void testInvalidRelativeImportLabelSyntax() throws Exception {
    invalidImportTest("::file.bzl", SkylarkImports.INVALID_TARGET_PREFIX);
  }

 @Test
  public void testLoadNoSymbol() throws Exception {
    setFailFast(false);
    parseFileForSkylark("load('/foo/bar/file')\n");
    assertContainsError("syntax error");
  }

  @Test
  public void testLoadOneSymbol() throws Exception {
    List<Statement> statements = parseFileForSkylark(
        "load('/foo/bar/file', 'fun_test')\n");
    LoadStatement stmt = (LoadStatement) statements.get(0);
    assertThat(stmt.getImport().getValue()).isEqualTo("/foo/bar/file");
    assertThat(stmt.getSymbols()).hasSize(1);
    Identifier sym = stmt.getSymbols().get(0);
    int startOffset = sym.getLocation().getStartOffset();
    int endOffset = sym.getLocation().getEndOffset();
    assertThat(startOffset).named("getStartOffset()").isEqualTo(22);
    assertThat(endOffset).named("getEndOffset()").isEqualTo(startOffset + 10);
  }

  @Test
  public void testLoadOneSymbolWithTrailingComma() throws Exception {
    List<Statement> statements = parseFileForSkylark(
        "load('/foo/bar/file', 'fun_test',)\n");
    LoadStatement stmt = (LoadStatement) statements.get(0);
    assertThat(stmt.getImport().getValue()).isEqualTo("/foo/bar/file");
    assertThat(stmt.getSymbols()).hasSize(1);
  }

  @Test
  public void testLoadMultipleSymbols() throws Exception {
    List<Statement> statements = parseFileForSkylark(
        "load('file', 'foo', 'bar')\n");
    LoadStatement stmt = (LoadStatement) statements.get(0);
    assertThat(stmt.getImport().getValue()).isEqualTo("file");
    assertThat(stmt.getSymbols()).hasSize(2);
  }

  @Test
  public void testLoadSyntaxError() throws Exception {
    setFailFast(false);
    parseFileForSkylark("load(non_quoted, 'a')\n");
    assertContainsError("syntax error");
  }

  @Test
  public void testLoadSyntaxError2() throws Exception {
    setFailFast(false);
    parseFileForSkylark("load('non_quoted', a)\n");
    assertContainsError("syntax error");
  }

  @Test
  public void testLoadNotAtTopLevel() throws Exception {
    setFailFast(false);
    parseFileForSkylark("if 1: load(8)\n");
    assertContainsError("name 'load' is not defined");
  }

  @Test
  public void testLoadAlias() throws Exception {
    List<Statement> statements = parseFileForSkylark(
        "load('/foo/bar/file', my_alias = 'lawl')\n");
    LoadStatement stmt = (LoadStatement) statements.get(0);
    ImmutableList<Identifier> actualSymbols = stmt.getSymbols();

    assertThat(actualSymbols).hasSize(1);
    Identifier sym = actualSymbols.get(0);
    assertThat(sym.getName()).isEqualTo("my_alias");
    int startOffset = sym.getLocation().getStartOffset();
    int endOffset = sym.getLocation().getEndOffset();
    assertThat(startOffset).named("getStartOffset()").isEqualTo(22);
    assertThat(endOffset).named("getEndOffset()").isEqualTo(startOffset + 8);
  }

  @Test
  public void testLoadAliasMultiple() throws Exception {
    runLoadAliasTestForSymbols(
        "my_alias = 'lawl', 'lol', next_alias = 'rofl'", "my_alias", "lol", "next_alias");
  }

  private void runLoadAliasTestForSymbols(String loadSymbolString, String... expectedSymbols) {
    List<Statement> statements =
        parseFileForSkylark(String.format("load('/foo/bar/file', %s)\n", loadSymbolString));
    LoadStatement stmt = (LoadStatement) statements.get(0);
    ImmutableList<Identifier> actualSymbols = stmt.getSymbols();

    assertThat(actualSymbols).hasSize(expectedSymbols.length);

    List<String> actualSymbolNames = new LinkedList<>();

    for (Identifier identifier : actualSymbols) {
      actualSymbolNames.add(identifier.getName());
    }

    assertThat(actualSymbolNames).containsExactly((Object[]) expectedSymbols);
  }

  @Test
  public void testLoadAliasSyntaxError() throws Exception {
    setFailFast(false);
    parseFileForSkylark("load('/foo', test1 = )\n");
    assertContainsError("syntax error at ')': expected string");

    parseFileForSkylark("load('/foo', test2 = 1)\n");
    assertContainsError("syntax error at '1': expected string");

    parseFileForSkylark("load('/foo', test3 = old)\n");
    assertContainsError("syntax error at 'old': expected string");
  }

  @Test
  public void testParseErrorNotComparison() throws Exception {
    setFailFast(false);
    parseFile("2 < not 3");
    assertContainsError("syntax error at 'not'");
  }

  @Test
  public void testNotWithArithmeticOperatorsBadSyntax() throws Exception {
    setFailFast(false);
    parseFile("0 + not 0");
    assertContainsError("syntax error at 'not'");
  }

  @Test
  public void testKwargsForbidden() throws Exception {
    setFailFast(false);
    parseFile("func(**dict)");
    assertContainsError("**kwargs arguments are not allowed in BUILD files");
  }

  @Test
  public void testArgsForbidden() throws Exception {
    setFailFast(false);
    parseFile("func(*array)");
    assertContainsError("*args arguments are not allowed in BUILD files");
  }

  @Test
  public void testOptionalArgBeforeMandatoryArgInFuncDef() throws Exception {
    setFailFast(false);
    parseFileForSkylark("def func(a, b = 'a', c):\n  return 0\n");
    assertContainsError(
        "a mandatory positional parameter must not follow an optional parameter");
  }

  @Test
  public void testKwargBeforePositionalArg() throws Exception {
    setFailFast(false);
    parseFileForSkylark(
        "def func(a, b): return a + b",
        "func(**{'b': 1}, 'a')");
    assertContainsError("unexpected tokens after kwarg");
  }

  @Test
  public void testDuplicateKwarg() throws Exception {
    setFailFast(false);
    parseFileForSkylark(
        "def func(a, b): return a + b",
        "func(**{'b': 1}, **{'a': 2})");
    assertContainsError("unexpected tokens after kwarg");
  }

  @Test
  public void testUnnamedStar() throws Exception {
    setFailFast(false);
    List<Statement> statements = parseFileForSkylark(
        "def func(a, b1=2, b2=3, *, c1, d=4, c2): return a + b1 + b2 + c1 + c2 + d\n");
    assertThat(statements).hasSize(1);
    assertThat(statements.get(0)).isInstanceOf(FunctionDefStatement.class);
    FunctionDefStatement stmt = (FunctionDefStatement) statements.get(0);
    FunctionSignature sig = stmt.getSignature().getSignature();
    // Note the reordering of optional named-only at the end.
    assertThat(sig.getNames()).isEqualTo(ImmutableList.<String>of(
        "a", "b1", "b2", "c1", "c2", "d"));
    FunctionSignature.Shape shape = sig.getShape();
    assertThat(shape.getMandatoryPositionals()).isEqualTo(1);
    assertThat(shape.getOptionalPositionals()).isEqualTo(2);
    assertThat(shape.getMandatoryNamedOnly()).isEqualTo(2);
    assertThat(shape.getOptionalNamedOnly()).isEqualTo(1);
  }

  @Test
  public void testTopLevelForFails() throws Exception {
    setFailFast(false);
    parseFileForSkylark("for i in []: 0\n");
    assertContainsError(
        "for loops are not allowed on top-level. Put it into a function");
  }

  @Test
  public void testNestedFunctionFails() throws Exception {
    setFailFast(false);
    parseFileForSkylark(
          "def func(a):",
          "  def bar(): return 0",
          "  return bar()",
          "");
    assertContainsError(
        "nested functions are not allowed. Move the function to top-level");
  }

  @Test
  public void testElseWithoutIf() throws Exception {
    setFailFast(false);
    parseFileForSkylark(
        "def func(a):",
        // no if
        "  else: return a");
    assertContainsError("syntax error at 'else': not allowed here.");
  }

  @Test
  public void testForElse() throws Exception {
    setFailFast(false);
    parseFileForSkylark(
        "def func(a):",
        "  for i in range(a):",
        "    print(i)",
        "  else: return a");
    assertContainsError("syntax error at 'else': not allowed here.");
  }

  @Test
  public void testTryStatementInBuild() throws Exception {
    setFailFast(false);
    parseFile("try: pass");
    assertContainsError("syntax error at 'try': Try statements are not supported.");
  }

  @Test
  public void testTryStatementInSkylark() throws Exception {
    setFailFast(false);
    parseFileForSkylark("try: pass");
    assertContainsError("syntax error at 'try': Try statements are not supported.");
  }

  @Test
  public void testClassDefinitionInBuild() throws Exception {
    setFailFast(false);
    parseFile("class test(object): pass");
    assertContainsError("syntax error at 'class': Class definitions are not supported.");
  }

  @Test
  public void testClassDefinitionInSkylark() throws Exception {
    setFailFast(false);
    parseFileForSkylark("class test(object): pass");
    assertContainsError("syntax error at 'class': Class definitions are not supported.");
  }

  @Test
  public void testDefInBuild() throws Exception {
    setFailFast(false);
    parseFile("def func(): pass");
    assertContainsError("syntax error at 'def': This is not supported in BUILD files. "
        + "Move the block to a .bzl file and load it");
  }
}
