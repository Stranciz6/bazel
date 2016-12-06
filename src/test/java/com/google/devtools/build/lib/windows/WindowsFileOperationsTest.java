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

package com.google.devtools.build.lib.windows;

import static com.google.common.truth.Truth.assertThat;
import static org.junit.Assert.fail;

import com.google.common.collect.ImmutableMap;
import com.google.devtools.build.lib.testutil.TestSpec;
import com.google.devtools.build.lib.util.OS;
import com.google.devtools.build.lib.vfs.WindowsFileSystem;
import com.google.devtools.build.lib.windows.util.WindowsTestUtil;
import java.io.File;
import java.io.IOException;
import java.nio.file.Files;
import java.util.Arrays;
import java.util.HashMap;
import java.util.Map;
import org.junit.After;
import org.junit.Before;
import org.junit.Test;
import org.junit.runner.RunWith;
import org.junit.runners.JUnit4;

/** Unit tests for {@link WindowsFileOperations}. */
@RunWith(JUnit4.class)
@TestSpec(localOnly = true, supportedOs = OS.WINDOWS)
public class WindowsFileOperationsTest {

  private String scratchRoot;
  private WindowsTestUtil testUtil;

  @Before
  public void loadJni() throws Exception {
    WindowsTestUtil.loadJni();
    scratchRoot = new File(System.getenv("TEST_TMPDIR")).getAbsolutePath() + "/x";
    testUtil = new WindowsTestUtil(scratchRoot);
    cleanupScratchDir();
  }

  @After
  public void cleanupScratchDir() throws Exception {
    testUtil.deleteAllUnder("");
  }

  @Test
  public void testMockJunctionCreation() throws Exception {
    String root = testUtil.scratchDir("dir").getParent().toString();
    testUtil.scratchFile("dir/file.txt", "hello");
    testUtil.createJunctions(ImmutableMap.of("junc", "dir"));
    String[] children = new File(root + "/junc").list();
    assertThat(children).isNotNull();
    assertThat(children).hasLength(1);
    assertThat(Arrays.asList(children)).containsExactly("file.txt");
  }

  @Test
  public void testIsJunction() throws Exception {
    final Map<String, String> junctions = new HashMap<>();
    junctions.put("shrtpath/a", "shrttrgt");
    junctions.put("shrtpath/b", "longtargetpath");
    junctions.put("shrtpath/c", "longta~1");
    junctions.put("longlinkpath/a", "shrttrgt");
    junctions.put("longlinkpath/b", "longtargetpath");
    junctions.put("longlinkpath/c", "longta~1");
    junctions.put("abbrev~1/a", "shrttrgt");
    junctions.put("abbrev~1/b", "longtargetpath");
    junctions.put("abbrev~1/c", "longta~1");

    String root = testUtil.scratchDir("shrtpath").getParent().toAbsolutePath().toString();
    testUtil.scratchDir("longlinkpath");
    testUtil.scratchDir("abbreviated");
    testUtil.scratchDir("control/a");
    testUtil.scratchDir("control/b");
    testUtil.scratchDir("control/c");

    testUtil.scratchFile("shrttrgt/file1.txt", "hello");
    testUtil.scratchFile("longtargetpath/file2.txt", "hello");

    testUtil.createJunctions(junctions);

    assertThat(WindowsFileOperations.isJunction(root + "/shrtpath/a")).isTrue();
    assertThat(WindowsFileOperations.isJunction(root + "/shrtpath/b")).isTrue();
    assertThat(WindowsFileOperations.isJunction(root + "/shrtpath/c")).isTrue();
    assertThat(WindowsFileOperations.isJunction(root + "/longlinkpath/a")).isTrue();
    assertThat(WindowsFileOperations.isJunction(root + "/longlinkpath/b")).isTrue();
    assertThat(WindowsFileOperations.isJunction(root + "/longlinkpath/c")).isTrue();
    assertThat(WindowsFileOperations.isJunction(root + "/longli~1/a")).isTrue();
    assertThat(WindowsFileOperations.isJunction(root + "/longli~1/b")).isTrue();
    assertThat(WindowsFileOperations.isJunction(root + "/longli~1/c")).isTrue();
    assertThat(WindowsFileOperations.isJunction(root + "/abbreviated/a")).isTrue();
    assertThat(WindowsFileOperations.isJunction(root + "/abbreviated/b")).isTrue();
    assertThat(WindowsFileOperations.isJunction(root + "/abbreviated/c")).isTrue();
    assertThat(WindowsFileOperations.isJunction(root + "/abbrev~1/a")).isTrue();
    assertThat(WindowsFileOperations.isJunction(root + "/abbrev~1/b")).isTrue();
    assertThat(WindowsFileOperations.isJunction(root + "/abbrev~1/c")).isTrue();
    assertThat(WindowsFileOperations.isJunction(root + "/control/a")).isFalse();
    assertThat(WindowsFileOperations.isJunction(root + "/control/b")).isFalse();
    assertThat(WindowsFileOperations.isJunction(root + "/control/c")).isFalse();
    assertThat(WindowsFileOperations.isJunction(root + "/shrttrgt/file1.txt")).isFalse();
    assertThat(WindowsFileOperations.isJunction(root + "/longtargetpath/file2.txt")).isFalse();
    assertThat(WindowsFileOperations.isJunction(root + "/longta~1/file2.txt")).isFalse();
    try {
      WindowsFileOperations.isJunction(root + "/non-existent");
      fail("expected to throw");
    } catch (IOException e) {
      assertThat(e.getMessage()).contains("GetFileAttributes");
    }
    assertThat(Arrays.asList(new File(root + "/shrtpath/a").list())).containsExactly("file1.txt");
    assertThat(Arrays.asList(new File(root + "/shrtpath/b").list())).containsExactly("file2.txt");
    assertThat(Arrays.asList(new File(root + "/shrtpath/c").list())).containsExactly("file2.txt");
    assertThat(Arrays.asList(new File(root + "/longlinkpath/a").list()))
        .containsExactly("file1.txt");
    assertThat(Arrays.asList(new File(root + "/longlinkpath/b").list()))
        .containsExactly("file2.txt");
    assertThat(Arrays.asList(new File(root + "/longlinkpath/c").list()))
        .containsExactly("file2.txt");
    assertThat(Arrays.asList(new File(root + "/abbreviated/a").list()))
        .containsExactly("file1.txt");
    assertThat(Arrays.asList(new File(root + "/abbreviated/b").list()))
        .containsExactly("file2.txt");
    assertThat(Arrays.asList(new File(root + "/abbreviated/c").list()))
        .containsExactly("file2.txt");
  }

  @Test
  public void testIsJunctionIsTrueForDanglingJunction() throws Exception {
    java.nio.file.Path helloPath = testUtil.scratchFile("target\\hello.txt", "hello");
    testUtil.createJunctions(ImmutableMap.of("link", "target"));

    File linkPath = new File(helloPath.getParent().getParent().toFile(), "link");
    assertThat(Arrays.asList(linkPath.list())).containsExactly("hello.txt");
    assertThat(WindowsFileOperations.isJunction(linkPath.getAbsolutePath())).isTrue();

    assertThat(helloPath.toFile().delete()).isTrue();
    assertThat(helloPath.getParent().toFile().delete()).isTrue();
    assertThat(helloPath.getParent().toFile().exists()).isFalse();
    assertThat(Arrays.asList(linkPath.getParentFile().list())).containsExactly("link");

    assertThat(WindowsFileOperations.isJunction(linkPath.getAbsolutePath())).isTrue();
    assertThat(
            Files.exists(
                linkPath.toPath(), WindowsFileSystem.symlinkOpts(/* followSymlinks */ false)))
        .isTrue();
    assertThat(
            Files.exists(
                linkPath.toPath(), WindowsFileSystem.symlinkOpts(/* followSymlinks */ true)))
        .isFalse();
  }
}
