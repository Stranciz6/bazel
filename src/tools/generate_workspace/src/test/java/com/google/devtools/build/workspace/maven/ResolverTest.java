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

package com.google.devtools.build.workspace.maven;

import static com.google.common.truth.Truth.assertThat;

import com.google.devtools.build.lib.events.StoredEventHandler;
import org.junit.Test;
import org.junit.runner.RunWith;
import org.junit.runners.JUnit4;
import org.mockito.Mockito;

import java.io.ByteArrayOutputStream;
import java.io.PrintStream;
import java.nio.charset.Charset;

/**
 * Tests for {@link Resolver}.
 */
@RunWith(JUnit4.class)
public class ResolverTest {
  @Test
  public void testGetSha1Url() throws Exception {
    assertThat(Resolver.getSha1Url("http://example.com/foo.pom", "jar"))
        .isEqualTo("http://example.com/foo.jar.sha1");
    assertThat(Resolver.getSha1Url("http://example.com/foo.pom", "aar"))
        .isEqualTo("http://example.com/foo.aar.sha1");
  }

  @Test
  public void testGetSha1UrlOnlyAtEOL() throws Exception {
    assertThat(Resolver.getSha1Url("http://example.pom/foo.pom", "jar"))
        .isEqualTo("http://example.pom/foo.jar.sha1");
  }

  @Test
  public void testArtifactResolution() throws Exception {
    StoredEventHandler handler = new StoredEventHandler();
    DefaultModelResolver modelResolver = Mockito.mock(DefaultModelResolver.class);
    Resolver resolver = new Resolver(handler, modelResolver);
    resolver.resolveArtifact("x:y:1.2.3");

    ByteArrayOutputStream baos = new ByteArrayOutputStream();
    PrintStream ps = new PrintStream(baos);
    resolver.writeWorkspace(ps);
    String content = baos.toString(String.valueOf(Charset.defaultCharset()));
    assertThat(content).contains("maven_jar(\n"
        + "    name = \"x_y\",\n"
        + "    artifact = \"x:y:1.2.3\",\n"
        + ")"
    );
    assertThat(handler.hasErrors()).isFalse();
  }
}
