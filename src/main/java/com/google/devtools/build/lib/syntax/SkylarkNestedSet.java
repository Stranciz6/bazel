// Copyright 2014 The Bazel Authors. All rights reserved.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
package com.google.devtools.build.lib.syntax;

import com.google.common.collect.ImmutableList;
import com.google.devtools.build.lib.collect.nestedset.NestedSet;
import com.google.devtools.build.lib.collect.nestedset.NestedSetBuilder;
import com.google.devtools.build.lib.collect.nestedset.Order;
import com.google.devtools.build.lib.concurrent.ThreadSafety.Immutable;
import com.google.devtools.build.lib.events.Location;
import com.google.devtools.build.lib.skylarkinterface.SkylarkCallable;
import com.google.devtools.build.lib.skylarkinterface.SkylarkModule;
import com.google.devtools.build.lib.skylarkinterface.SkylarkModuleCategory;
import com.google.devtools.build.lib.skylarkinterface.SkylarkValue;
import com.google.devtools.build.lib.syntax.SkylarkList.MutableList;
import com.google.devtools.build.lib.util.Preconditions;
import java.util.ArrayList;
import java.util.Collection;
import java.util.List;
import javax.annotation.Nullable;

/**
 * A generic, type-safe {@link NestedSet} wrapper for Skylark.
 *
 * <p>The content type of a {@code SkylarkNestedSet} is the intersection of the {@link SkylarkType}
 * of each of its elements. It is an error if this intersection is {@link SkylarkType#BOTTOM}. An
 * empty set has a content type of {@link SkylarkType#TOP}.
 *
 * <p>It is also an error if this type has a non-bottom intersection with {@link SkylarkType#DICT}
 * or {@link SkylarkType#LIST}, unless the set is empty.
 * TODO(bazel-team): Decide whether this restriction is still useful.
 */
@SkylarkModule(
    name = "depset",
    category = SkylarkModuleCategory.BUILTIN,
    // TODO(bazel-team): Move this documentation to a dedicated page and link to it from here.
    doc =
        "A language built-in type that supports efficiently accumulating data from transitive "
        + "dependencies. Note that depsets are not hash sets: they don't support fast membership "
        + "tests, but on the contrary they support fast union. Depsets are designed to be used as "
        + "a collection of items (such as file names) generated by Bazel targets. "
        + "Depsets can be created using the <a href=\"globals.html#depset\">depset</a> function, "
        + "and they support the <code>|</code> operator to extend the depset with more elements or "
        + "to nest other depsets inside of it. Examples:<br>"

        + "<pre class=language-python>s = depset([1, 2])\n"
        + "s = s | [3]              # s == {1, 2, 3}\n"
        + "s = s | depset([4, 5])   # s == {1, 2, 3, {4, 5}}\n"
        + "other = depset([\"a\", \"b\", \"c\"], order=\"postorder\")</pre>"

        + "Note that in these examples <code>{..}</code> is not a valid literal to create depsets. "
        + "Depsets have a fixed generic type, so <code>depset([1]) + [\"a\"]</code> or "
        + "<code>depset([1]) + depset([\"a\"])</code> results in an error.<br>"
        + "Elements in a depset can neither be mutable nor be of type <code>list</code>, "
        + "<code>struct</code> or <code>dict</code>.<br>"
        + "When aggregating data from providers, depsets can take significantly less memory than "
        + "other types as they support nesting, that is, their subsets are shared in memory.<br>"
        + "Every depset has an <code>order</code> parameter which determines the iteration order. "
        + "There are four possible values:"

        + "<ul><li><code>postorder</code> (formerly <code>compile</code>): Defines a left-to-right "
        + "post-ordering where child elements come after those of nested depsets (parent-last). "
        + "For example, <code>{1, 2, 3, {4, 5}}</code> leads to <code>4 5 1 2 3</code>. "
        + "Left-to-right order is preserved for both the child elements and the references to "
        + "nested depsets.</li>"

        + "<li><code>default</code> (formerly <code>stable</code>): Same behavior as "
        + "<code>postorder</code>.</li>"

        + "<li><code>topological</code> (formerly <code>link</code>): Defines a variation of "
        + "left-to-right pre-ordering, i.e. <code>{1, 2, 3, {4, 5}}</code> leads to "
        + "<code>1 2 3 4 5</code>. This ordering enforces that elements of the depset always come "
        + "before elements of nested depsets (parent-first), which may lead to situations where "
        + "left-to-right order cannot be preserved (<a href=\"https://github.com/bazelbuild/bazel/blob/master/src/main/java/com/google/devtools/build/lib/collect/nestedset/LinkOrderExpander.java#L56\">Example</a>)."
        + "</li>"

        + "<li><code>preorder</code> (formerly <code>naive_link</code>): Defines \"naive\" "
        + "left-to-right pre-ordering (parent-first), i.e. <code>{1, 2, 3, {4, 5}}</code> leads to "
        + "<code>1 2 3 4 5</code>. Unlike <code>topological</code> ordering, it will sacrifice the "
        + "parent-first property in order to uphold left-to-right order in cases where both "
        + "properties cannot be guaranteed (<a href=\"https://github.com/bazelbuild/bazel/blob/master/src/main/java/com/google/devtools/build/lib/collect/nestedset/NaiveLinkOrderExpander.java#L26\">Example</a>)."
        + "</li></ul>"

        + "Except for <code>default</code>, the above values are incompatible with each other. "
        + "Consequently, two depsets can only be merged via the <code>+</code> operator or via "
        + "<code>union()</code> if either both depsets have the same <code>order</code> or one of "
        + "the depsets has <code>stable</code> order. In the latter case the iteration order will "
        + "be determined by the outer depset, thus ignoring the <code>order</code> parameter of "
        + "nested depsets."
)
@Immutable
public final class SkylarkNestedSet implements SkylarkValue, SkylarkQueryable {

  private final SkylarkType contentType;
  private final NestedSet<?> set;
  @Nullable
  private final List<Object> items;
  @Nullable
  private final List<NestedSet> transitiveItems;

  public SkylarkNestedSet(Order order, Object item, Location loc) throws EvalException {
    this(order, SkylarkType.TOP, item, loc, null);
  }

  public SkylarkNestedSet(SkylarkNestedSet left, Object right, Location loc) throws EvalException {
    this(left.set.getOrder(), left.contentType, right, loc, left);
  }

  // This is safe because of the type checking
  @SuppressWarnings("unchecked")
  private SkylarkNestedSet(Order order, SkylarkType contentType, Object item, Location loc,
      @Nullable SkylarkNestedSet left) throws EvalException {

    ArrayList<Object> items = new ArrayList<>();
    ArrayList<NestedSet> transitiveItems = new ArrayList<>();
    if (left != null) {
      if (left.items == null) { // SkylarkSet created from native NestedSet
        transitiveItems.add(left.set);
      } else { // Preserving the left-to-right addition order.
        items.addAll(left.items);
        transitiveItems.addAll(left.transitiveItems);
      }
    }
    // Adding the item
    if (item instanceof SkylarkNestedSet) {
      SkylarkNestedSet nestedSet = (SkylarkNestedSet) item;
      if (!nestedSet.isEmpty()) {
        contentType = getTypeAfterInsert(contentType, nestedSet.contentType, loc);
        transitiveItems.add(nestedSet.set);
      }
    } else if (item instanceof SkylarkList) {
      // TODO(bazel-team): we should check ImmutableList here but it screws up genrule at line 43
      for (Object object : (SkylarkList) item) {
        contentType = getTypeAfterInsert(contentType, SkylarkType.of(object.getClass()), loc);
        checkImmutable(object, loc);
        items.add(object);
      }
    } else {
      throw new EvalException(
          loc,
          String.format(
              "cannot union value of type '%s' to a depset", EvalUtils.getDataTypeName(item)));
    }
    this.contentType = Preconditions.checkNotNull(contentType, "type cannot be null");

    // Initializing the real nested set
    NestedSetBuilder<Object> builder = new NestedSetBuilder<>(order);
    builder.addAll(items);
    try {
      for (NestedSet<?> nestedSet : transitiveItems) {
        builder.addTransitive(nestedSet);
      }
    } catch (IllegalStateException e) {
      throw new EvalException(loc, e.getMessage());
    }
    this.set = builder.build();
    this.items = ImmutableList.copyOf(items);
    this.transitiveItems = ImmutableList.copyOf(transitiveItems);
  }

  /**
   * Returns a type safe SkylarkNestedSet. Use this instead of the constructor if possible.
   */
  public static <T> SkylarkNestedSet of(SkylarkType contentType, NestedSet<T> set) {
    return new SkylarkNestedSet(contentType, set);
  }

  /**
   * Returns a type safe SkylarkNestedSet. Use this instead of the constructor if possible.
   */
  public static <T> SkylarkNestedSet of(Class<T> contentType, NestedSet<T> set) {
    return of(SkylarkType.of(contentType), set);
  }

  /**
   * A not type safe constructor for SkylarkNestedSet. It's discouraged to use it unless type
   * generic safety is guaranteed from the caller side.
   */
  SkylarkNestedSet(SkylarkType contentType, NestedSet<?> set) {
    // This is here for the sake of FuncallExpression.
    this.contentType = Preconditions.checkNotNull(contentType, "type cannot be null");
    this.set = Preconditions.checkNotNull(set, "set cannot be null");
    this.items = null;
    this.transitiveItems = null;
  }

  /**
   * A not type safe constructor for SkylarkNestedSet, specifying type as a Java class.
   * It's discouraged to use it unless type generic safety is guaranteed from the caller side.
   */
  public SkylarkNestedSet(Class<?> contentType, NestedSet<?> set) {
    this(SkylarkType.of(contentType), set);
  }

  private static final SkylarkType DICT_LIST_UNION =
      SkylarkType.Union.of(SkylarkType.DICT, SkylarkType.LIST);

  /**
   * Throws EvalException if a type overlaps with DICT or LIST.
   */
  private static void checkTypeNotDictOrList(SkylarkType type, Location loc)
      throws EvalException {
    if (SkylarkType.intersection(DICT_LIST_UNION, type) != SkylarkType.BOTTOM) {
      throw new EvalException(
          loc, String.format("depsets cannot contain items of type '%s'", type));
    }
  }

  /**
   * Returns the intersection of two types, and throws EvalException if the intersection is bottom.
   */
  private static SkylarkType commonNonemptyType(
      SkylarkType depsetType, SkylarkType itemType, Location loc) throws EvalException {
    SkylarkType resultType = SkylarkType.intersection(depsetType, itemType);
    if (resultType == SkylarkType.BOTTOM) {
      throw new EvalException(
          loc,
          String.format(
              "cannot add an item of type '%s' to a depset of '%s'", itemType, depsetType));
    }
    return resultType;
  }

  /**
   * Checks that an item type is allowed in a given set type, and returns the type of a new depset
   * with that item inserted.
   */
  private static SkylarkType getTypeAfterInsert(
      SkylarkType depsetType, SkylarkType itemType, Location loc) throws EvalException {
    checkTypeNotDictOrList(itemType, loc);
    return commonNonemptyType(depsetType, itemType, loc);
  }

  /**
   * Throws EvalException if a given value is mutable.
   */
  private static void checkImmutable(Object o, Location loc) throws EvalException {
    if (!EvalUtils.isImmutable(o)) {
      throw new EvalException(loc, "depsets cannot contain mutable items");
    }
  }

  private void checkHasContentType(Class<?> type) {
    // Empty sets should be SkylarkType.TOP anyway.
    if (!set.isEmpty()) {
      Preconditions.checkArgument(
          contentType.canBeCastTo(type),
          "Expected a depset of '%s' but got a depset of '%s'",
          EvalUtils.getDataTypeNameFromClass(type), contentType);
    }
  }

  /**
   * Returns the embedded {@link NestedSet}, while asserting that its elements all have the given
   * type.
   *
   * <p>If you do not specifically need the {@code NestedSet} and you are going to flatten it
   * anyway, prefer {@link #toCollection} to make your intent clear.
   *
   * @param type a {@link Class} representing the expected type of the contents
   * @return the {@code NestedSet}, with the appropriate generic type
   * @throws IllegalArgumentException if the type does not accurately describe all elements
   */
  // The precondition ensures generic type safety.
  @SuppressWarnings("unchecked")
  public <T> NestedSet<T> getSet(Class<T> type) {
    checkHasContentType(type);
    return (NestedSet<T>) set;
  }

  /**
   * Returns the contents of the set as a {@link Collection}.
   */
  public Collection<Object> toCollection() {
    // Do not remove <Object>: workaround for Java 7 type inference.
    return ImmutableList.<Object>copyOf(set.toCollection());
  }

  /**
   * Returns the contents of the set as a {@link Collection}, asserting that the set type is
   * compatible with {@code T}.
   *
   * @param type a {@link Class} representing the expected type of the contents
   * @throws IllegalArgumentException if the type does not accurately describe all elements
   */
  // The precondition ensures generic type safety.
  @SuppressWarnings("unchecked")
  public <T> Collection<T> toCollection(Class<T> type) {
    checkHasContentType(type);
    return (Collection<T>) toCollection();
  }

  @SkylarkCallable(
      name = "to_list",
      doc = "Returns a frozen list of the elements, without duplicates, in the depset's traversal "
          + "order.")
  public MutableList<Object> skylarkToList() {
    return new MutableList<Object>(set, null);
  }

  public boolean isEmpty() {
    return set.isEmpty();
  }

  public SkylarkType getContentType() {
    return contentType;
  }

  @Override
  public String toString() {
    return Printer.repr(this);
  }

  public Order getOrder() {
    return set.getOrder();
  }

  @Override
  public boolean isImmutable() {
    return true;
  }

  @Override
  public void write(Appendable buffer, char quotationMark) {
    Printer.append(buffer, "set(");
    Printer.printList(buffer, set, "[", ", ", "]", null, quotationMark);
    Order order = getOrder();
    if (order != Order.STABLE_ORDER) {
      Printer.append(buffer, ", order = \"" + order.getSkylarkName() + "\"");
    }
    Printer.append(buffer, ")");
  }

  @Override
  public final boolean containsKey(Object key, Location loc) throws EvalException {
    return (set.toSet().contains(key));
  }
}
