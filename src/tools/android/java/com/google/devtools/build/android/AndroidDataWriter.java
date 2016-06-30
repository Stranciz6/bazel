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
package com.google.devtools.build.android;

import com.google.common.annotations.VisibleForTesting;
import com.google.common.base.Joiner;
import com.google.common.base.Preconditions;
import com.google.common.collect.ArrayListMultimap;
import com.google.common.collect.Multimap;
import com.google.common.collect.Ordering;
import com.google.common.util.concurrent.ListenableFuture;
import com.google.common.util.concurrent.ListeningExecutorService;
import com.google.common.util.concurrent.MoreExecutors;

import com.android.SdkConstants;
import com.android.annotations.NonNull;
import com.android.ide.common.internal.LoggedErrorException;
import com.android.ide.common.internal.PngCruncher;
import com.android.ide.common.res2.MergingException;

import java.io.BufferedWriter;
import java.io.File;
import java.io.IOException;
import java.io.Writer;
import java.nio.charset.StandardCharsets;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.StandardCopyOption;
import java.nio.file.StandardOpenOption;
import java.util.ArrayDeque;
import java.util.ArrayList;
import java.util.Deque;
import java.util.HashMap;
import java.util.HashSet;
import java.util.Iterator;
import java.util.List;
import java.util.Map;
import java.util.Map.Entry;
import java.util.Set;
import java.util.TreeMap;
import java.util.concurrent.Callable;
import java.util.concurrent.ExecutorService;

import javax.annotation.Nullable;
import javax.xml.namespace.QName;

/** Writer for UnwrittenMergedAndroidData. */
public class AndroidDataWriter implements AndroidDataWritingVisitor {

  private static final class CrunchTask implements Callable<Boolean> {
    private final Path destinationPath;
    private final Path source;
    private final PngCruncher cruncher;

    private CrunchTask(PngCruncher cruncher, Path destinationPath, Path source) {
      this.cruncher = cruncher;
      this.destinationPath = destinationPath;
      this.source = source;
    }

    @Override
    public Boolean call() throws Exception {
      try {
        Files.createDirectories(destinationPath.getParent());
        cruncher.crunchPng(source.toFile(), destinationPath.toFile());
      } catch (InterruptedException | LoggedErrorException e) {
        throw new MergingException(e);
      }
      return Boolean.TRUE;
    }
  }

  private static final class WriteValuesXmlTask implements Callable<Boolean> {

    private final Path valuesPath;
    private final Map<FullyQualifiedName, Iterable<String>> valueFragments;

    WriteValuesXmlTask(Path valuesPath, Map<FullyQualifiedName, Iterable<String>> valueFragments) {
      this.valuesPath = valuesPath;
      this.valueFragments = valueFragments;
    }

    @Override
    public Boolean call() throws Exception {
      // TODO(corysmith): replace the xml writing with a real xml writing library.
      Files.createDirectories(valuesPath.getParent());
      try (BufferedWriter writer =
          Files.newBufferedWriter(
              valuesPath,
              StandardCharsets.UTF_8,
              StandardOpenOption.CREATE_NEW,
              StandardOpenOption.WRITE)) {
        writer.write(START_RESOURCES);
        for (FullyQualifiedName key :
            Ordering.natural().immutableSortedCopy(valueFragments.keySet())) {
          for (String line : valueFragments.get(key)) {
            writer.write(line);
            writer.write(LINE_END);
          }
        }
        writer.write(END_RESOURCES);
      }
      return Boolean.TRUE;
    }
  }

  private static final class CopyTask implements Callable<Boolean> {

    private final Path sourcePath;

    private final Path destinationPath;

    private CopyTask(Path sourcePath, Path destinationPath) {
      this.sourcePath = sourcePath;
      this.destinationPath = destinationPath;
    }

    @Override
    public Boolean call() throws Exception {
      Files.createDirectories(destinationPath.getParent());
      Files.copy(sourcePath, destinationPath, StandardCopyOption.REPLACE_EXISTING);
      return Boolean.TRUE;
    }
  }

  public static final char[] START_RESOURCES =
      ("<?xml version=\"1.0\" encoding='utf-8' standalone='no'?>\n"
              + "<resources xmlns:xliff=\""
              + XmlResourceValues.XLIFF_NAMESPACE
              + "\">")
          .toCharArray();
  public static final char[] END_RESOURCES = "</resources>".toCharArray();
  private static final char[] LINE_END = "\n".toCharArray();
  private static final PngCruncher NOOP_CRUNCHER =
      new PngCruncher() {
        @Override
        public void crunchPng(@NonNull File source, @NonNull File destination)
            throws InterruptedException, LoggedErrorException, IOException {
          Files.createDirectories(destination.toPath().getParent());
          Files.copy(source.toPath(), destination.toPath());
        }
      };

  private final Path destination;
  private final Map<String, Map<FullyQualifiedName, Iterable<String>>> valueFragments =
      new HashMap<>();

  private final Map<String, ResourceValuesDefinitions> valueTags = new HashMap<>();
  private final Path resourceDirectory;
  private final Path assetDirectory;
  private final PngCruncher cruncher;
  private final List<ListenableFuture<Boolean>> writeTasks = new ArrayList<>();
  private final ListeningExecutorService executorService;

  private AndroidDataWriter(
      Path destination,
      Path resourceDirectory,
      Path assetsDirectory,
      PngCruncher cruncher,
      ListeningExecutorService executorService) {
    this.destination = destination;
    this.resourceDirectory = resourceDirectory;
    this.assetDirectory = assetsDirectory;
    this.cruncher = cruncher;
    this.executorService = executorService;
  }

  /**
   * Creates a new, naive writer for testing.
   *
   * This writer has "assets" and a "res" directory from the destination directory, as well as a
   * noop png cruncher and a {@link ExecutorService} of 1 thread.
   *
   * @param destination The base directory to derive all paths.
   * @return A new {@link AndroidDataWriter}.
   */
  @VisibleForTesting
  static AndroidDataWriter createWithDefaults(Path destination) {
    return createWith(
        destination,
        destination.resolve("res"),
        destination.resolve("assets"),
        NOOP_CRUNCHER,
        MoreExecutors.newDirectExecutorService());
  }

  /**
   * Creates a new writer.
   *
   * @param manifestDirectory The base directory for the AndroidManifest.
   * @param resourceDirectory The directory to copy resources into.
   * @param assetsDirectory The directory to copy assets into.
   * @param cruncher The cruncher for png files. If the cruncher is null, it will be replaced with a
   *    noop cruncher.
   * @param executorService An execution service for multi-threaded writing.
   * @return A new {@link AndroidDataWriter}.
   */
  public static AndroidDataWriter createWith(
      Path manifestDirectory,
      Path resourceDirectory,
      Path assetsDirectory,
      @Nullable PngCruncher cruncher,
      ListeningExecutorService executorService) {
    return new AndroidDataWriter(
        manifestDirectory,
        resourceDirectory,
        assetsDirectory,
        cruncher == null ? NOOP_CRUNCHER : cruncher,
        executorService);
  }

  @Override
  public Path copyManifest(Path sourceManifest) throws IOException {
    // aapt won't read any manifest that is not named AndroidManifest.xml,
    // so we hard code it here.
    Path destinationManifest = destination.resolve("AndroidManifest.xml");
    copy(sourceManifest, destinationManifest);
    return destinationManifest;
  }

  public Path assetDirectory() {
    return assetDirectory;
  }

  public Path resourceDirectory() {
    return resourceDirectory;
  }

  @Override
  public void copyAsset(Path source, String relativeDestinationPath) throws IOException {
    copy(source, assetDirectory.resolve(relativeDestinationPath));
  }

  @Override
  public void copyResource(final Path source, final String relativeDestinationPath)
      throws IOException, MergingException {
    final Path destinationPath = resourceDirectory.resolve(relativeDestinationPath);
    if (!source.getParent().getFileName().toString().startsWith(SdkConstants.FD_RES_RAW)
        && source.getFileName().toString().endsWith(SdkConstants.DOT_PNG)) {
      writeTasks.add(executorService.submit(new CrunchTask(cruncher, destinationPath, source)));
    } else {
      copy(source, destinationPath);
    }
  }

  private void copy(final Path sourcePath, final Path destinationPath) {
    writeTasks.add(executorService.submit(new CopyTask(sourcePath, destinationPath)));
  }

  /**
   * Finalizes all operations and flushes the buffers.
   */
  @Override
  public void flush() throws IOException {
    for (Entry<String, Map<FullyQualifiedName, Iterable<String>>> entry :
        valueFragments.entrySet()) {
      writeTasks.add(
          executorService.submit(
              new WriteValuesXmlTask(
                  resourceDirectory().resolve(entry.getKey()), entry.getValue())));
    }
    
    for (Entry<String, ResourceValuesDefinitions> entry : valueTags.entrySet()) {
      writeTasks.add(
          executorService.submit(
              entry.getValue().createWritingTask(resourceDirectory().resolve(entry.getKey()))));
    }

    FailedFutureAggregator.forIOExceptionsWithMessage("Failures during writing.")
        .aggregateAndMaybeThrow(writeTasks);

    writeTasks.clear();
    valueFragments.clear();
  }

  @Override
  public void writeToValuesXml(FullyQualifiedName key, Iterable<String> xmlFragment) {
    String valuesPathString = key.valuesPath();
    if (!valueFragments.containsKey(valuesPathString)) {
      valueFragments.put(
          valuesPathString, new TreeMap<FullyQualifiedName, Iterable<String>>(Ordering.natural()));
    }
    valueFragments.get(valuesPathString).put(key, xmlFragment);
  }

  @Override
  public ValueResourceDefinitionMetadata define(FullyQualifiedName fqn) {
    String valuesPath = fqn.valuesPath();
    if (!valueTags.containsKey(valuesPath)) {
      valueTags.put(valuesPath, new ResourceValuesDefinitions());
    }
    return valueTags.get(valuesPath).resource(fqn);
  }

  /**
   * A container for the {@linkplain Segment}s of a values.xml file.
   */
  private static class ResourceValuesDefinitions {
    final Multimap<FullyQualifiedName, Segment> segments = ArrayListMultimap.create();
    final Set<FullyQualifiedName> adopted = new HashSet<>();

    private ValueResourceDefinitionMetadata resource(final FullyQualifiedName fqn) {
      return new StringValueResourceDefinitionMetadata(segments, adopted, fqn);
    }

    /** Generates a {@link Callable} that will write the {@link Segment} to the provided path. */
    public Callable<Boolean> createWritingTask(final Path valuesPath) {
      return new Callable<Boolean>() {
        @Override
        public Boolean call() throws Exception {
          Files.createDirectories(valuesPath.getParent());
          try (BufferedWriter writer =
              Files.newBufferedWriter(
                  valuesPath,
                  StandardCharsets.UTF_8,
                  StandardOpenOption.CREATE_NEW,
                  StandardOpenOption.WRITE)) {
            writer.write(START_RESOURCES);
            writer.write(LINE_END);
            Path previousSource = null;
            for (FullyQualifiedName key :
                Ordering.natural().immutableSortedCopy(segments.keySet())) {
              if (!adopted.contains(key)) {
                for (Segment segment : segments.get(key)) {
                  previousSource = segment.write(previousSource, writer);
                }
              }
            }
            writer.write(END_RESOURCES);
          }
          return Boolean.TRUE;
        }
      };
    }
  }

  /** Utility function to provide xml namespaced name if a prefix is defined. */
  private static String maybePrefixName(@Nullable String prefix, String name) {
    if (prefix == null) {
      return name;
    }
    return prefix + ":" + name;
  }

  /** Intermediate class that associates a {@link Path} source with an xml definition. */
  private static class StringValueResourceDefinitionMetadata
      implements ValueResourceDefinitionMetadata {

    private final Multimap<FullyQualifiedName, Segment> segments;
    private final Set<FullyQualifiedName> adopted;
    private final FullyQualifiedName segmentsKey;

    public StringValueResourceDefinitionMetadata(
        Multimap<FullyQualifiedName, Segment> segments,
        Set<FullyQualifiedName> adopted,
        FullyQualifiedName fqn) {
      this.segments = segments;
      this.adopted = adopted;
      this.segmentsKey = fqn;
    }

    @Override
    public ValuesResourceDefinition derivedFrom(final Path source) {
      final SegmentMapper mapper = SegmentMapper.create(segments, adopted, segmentsKey, source);
      return new StringValuesResourceDefinition(mapper);
    }
  }

  /** Intermediate class that builds a string attribute for a {@link StartTag} */
  private static final class StringAttribute implements Attribute {

    private final String name;
    private final StringStartTag owner;
    private final boolean optional;

    public StringAttribute(StringStartTag owner, String name, boolean optional) {
      this.owner = owner;
      this.name = name;
      this.optional = optional;
    }

    @Override
    public StartTag setTo(FullyQualifiedName fqn) {
      return setTo(fqn.name());
    }

    @Override
    public StartTag setTo(String value) {
      if (!optional || value != null) {
        owner.attributes.add(" " + name + "=\"" + value + "\"");
      }
      return owner;
    }

    @Override
    public ValueJoiner setFrom(final Iterable<String> values) {
      return new ValueJoiner() {
        @Override
        public StartTag joinedBy(String separator) {
          Iterator<String> valuesIterator = values.iterator();
          if (!optional || valuesIterator.hasNext()) {
            setTo(Joiner.on(separator).join(valuesIterator));
          }
          return owner;
        }
      };
    }
  }

  /** Intermediate class that collects information for writing an xml start tag string. */
  private static final class StringStartTag implements StartTag {
    private final StringValuesResourceDefinition writer;
    private final String tagName;
    private final List<String> attributes = new ArrayList<>();

    public StringStartTag(StringValuesResourceDefinition writer, String tagName) {
      this.writer = writer;
      this.tagName = tagName;
    }

    @Override
    public Attribute attribute(String prefix, String name) {
      return createAttribute(prefix, name, false);
    }

    @Override
    public StringValuesResourceDefinition closeTag() {
      // Make sure we close this later.
      writer.tagStack.push(tagName);
      writer.mapper.add("<" + tagName + Joiner.on("").join(attributes) + ">");
      return writer;
    }

    @Override
    public Attribute attribute(String name) {
      return attribute(null, name);
    }

    private Attribute createAttribute(String prefix, String name, boolean optional) {
      return new StringAttribute(this, maybePrefixName(prefix, name), optional);
    }

    @Override
    public Optional optional() {
      return new Optional() {
        @Override
        public Attribute attribute(String prefix, String name) {
          return createAttribute(prefix, name, true);
        }

        @Override
        public Attribute attribute(String name) {
          return createAttribute(null, name, true);
        }
      };
    }

    @Override
    public ValuesResourceDefinition closeUnaryTag() {
      writer.mapper.add("\n<" + tagName + Joiner.on("").join(attributes) + "/>");
      return writer;
    }

    @Override
    public StartTag named(FullyQualifiedName key) {
      return named(key.name());
    }

    @Override
    public StartTag named(String name) {
      return createAttribute(null, "name", false).setTo(name);
    }

    @Override
    public StartTag addAttributesFrom(Iterable<Entry<String, String>> entries) {
      StartTag tag = this;
      for (Entry<String, String> entry : entries) {
        tag = tag.attribute(entry.getKey()).setTo(entry.getValue());
      }
      return tag;
    }
  }

  /** Intermediate class that provides methods to generate string xml definitions. */
  static class StringValuesResourceDefinition implements ValuesResourceDefinition {
    private final SegmentMapper mapper;
    private final Deque<String> tagStack = new ArrayDeque<>();

    public StringValuesResourceDefinition(SegmentMapper mapper) {
      this.mapper = mapper;
    }

    @Override
    public StartTag startTag(String prefix, String localName) {
      final String tagName = maybePrefixName(prefix, localName);
      return new StringStartTag(this, tagName);
    }

    @Override
    public StartTag startTag(String localName) {
      return startTag(null, localName);
    }

    @Override
    public StartTag startTag(QName name) {
      return startTag(name.getPrefix().isEmpty() ? null : name.getPrefix(), name.getLocalPart());
    }

    @Override
    public ValuesResourceDefinition adopt(FullyQualifiedName fqn) {
      mapper.adopt(fqn);
      return this;
    }

    @Override
    public ValuesResourceDefinition addCharactersOf(String characters) {
      mapper.add(characters);
      return this;
    }

    @Override
    public ValuesResourceDefinition endTag() {
      Preconditions.checkArgument(!tagStack.isEmpty(),
          "Unable to endTag, as no tag has been started.");
      mapper.add("</" + tagStack.pop() + ">");
      return this;
    }

    @Override
    public void save() {
      Preconditions.checkArgument(tagStack.isEmpty(), "Unfinished tags %s", tagStack);
      mapper.add("\n"); // Safe to add a line break to separate from other definitions.
      mapper.finish();
    }

    @Override
    public StartTag startItemTag() {
      return startTag("item");
    }
  }

  /** Maps {@link Segment}s to a {@link Multimap} via a {@link FullyQualifiedName} key. */
  private static class SegmentMapper {
    private List<String> currentLines = new ArrayList<>();

    private final Multimap<FullyQualifiedName, Segment> segmentStore;
    final FullyQualifiedName segmentKey;

    private final Set<FullyQualifiedName> adopted;

    private SegmentMapper(
        Set<FullyQualifiedName> adopted,
        Multimap<FullyQualifiedName, Segment> segmentStore,
        FullyQualifiedName segmentKey) {
      this.adopted = adopted;
      this.segmentStore = segmentStore;
      this.segmentKey = segmentKey;
    }

    static SegmentMapper create(
        Multimap<FullyQualifiedName, Segment> segmentStore,
        Set<FullyQualifiedName> adopted,
        FullyQualifiedName segmentKey,
        Path source) {
      Preconditions.checkNotNull(source);
      segmentStore.put(segmentKey, new SourceSegment(source));
      return new SegmentMapper(adopted, segmentStore, segmentKey);
    }

    /** Adds a string to the current {@link StringsSegment}. */
    SegmentMapper add(String line) {
      currentLines.add(line);
      return this;
    }

    /** Closes current {@link StringsSegment} and adds a {@link ReferenceSegment} to the store. */
    SegmentMapper adopt(FullyQualifiedName adoptedKey) {
      segmentStore.put(segmentKey, new StringsSegment(currentLines));
      adopted.add(adoptedKey);
      segmentStore.put(segmentKey, new ReferenceSegment(adoptedKey, segmentStore));
      currentLines = new ArrayList<>();
      return this;
    }

    /** Ends the mapping for the current key. */
    void finish() {
      segmentStore.put(segmentKey, new StringsSegment(currentLines));
    }
  }

  /** Base interface for writing information to a {@link Writer}. */
  private static interface Segment {
    /**
     * Writes the segment contents to a Writer
     *
     * @param previousSource The source Path of the last Segment to be written. This can be used to
     *     omit source annotations from the Writer is the last source matches the current one.
     * @param writer The writer of the segments.
     * @return The source Path of this segment for the next segment.
     * @throws IOException thrown by the writer.
     */
    Path write(Path previousSource, @Nullable Writer writer) throws IOException;
  }

  /** Represents a reference to another list of {@link Segment}s from the {@link Multimap}. */
  private static class ReferenceSegment implements Segment {
    private final FullyQualifiedName fqn;
    private final Multimap<FullyQualifiedName, Segment> segmentsByName;

    public ReferenceSegment(
        FullyQualifiedName fqn, Multimap<FullyQualifiedName, Segment> segmentsByName) {
      this.fqn = fqn;
      this.segmentsByName = segmentsByName;
    }

    @Override
    public Path write(Path previousSource, Writer writer) throws IOException {
      Path source = previousSource;
      Preconditions.checkArgument(segmentsByName.containsKey(fqn), "%s has no segment in %s",
          fqn.toPrettyString(), segmentsByName.keySet());
      for (Segment s : segmentsByName.get(fqn)) {
        // not recording the source
        source = s.write(source, writer);
      }
      return source;
    }
  }

  /** A simple container for a list of strings to be written. */
  private static class StringsSegment implements Segment {
    private final List<String> lines;

    public StringsSegment(List<String> lines) {
      this.lines = lines;
    }

    @Override
    public Path write(Path previousSource, Writer writer) throws IOException {
      for (String line : lines) {
        writer.write(line);
      }
      return previousSource;
    }
  }

  /** Represents a resource source annotation to be written as xml. */
  private static class SourceSegment implements Segment {

    private final Path source;

    SourceSegment(Path source) {
      this.source = source;
    }

    @Override
    public Path write(Path previousSource, Writer writer) throws IOException {
      // If sources are equal don't write a new source annotation.
      if (source.equals(previousSource)) {
        return previousSource;
      }
      writer.write(String.format("<!-- %s -->", source));
      writer.write(LINE_END);
      writer.write("<eat-comment/>");
      writer.write(LINE_END);
      return source;
    }
  }
}
