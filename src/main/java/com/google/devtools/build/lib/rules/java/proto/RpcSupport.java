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

package com.google.devtools.build.lib.rules.java.proto;

import com.google.devtools.build.lib.actions.Artifact;
import com.google.devtools.build.lib.analysis.RuleContext;
import com.google.devtools.build.lib.packages.AspectDefinition;
import com.google.devtools.build.lib.packages.AspectParameters;
import com.google.devtools.build.lib.rules.java.JavaLibraryHelper;
import com.google.devtools.build.lib.rules.proto.ProtoCompileActionBuilder;

/**
 * Used by java_proto_library to support Google-specific features.
 */
public interface RpcSupport {
  void mutateProtoCompileAction(
      RuleContext ruleContext, Artifact sourceJar, ProtoCompileActionBuilder actionBuilder);

  void mutateJavaCompileAction(RuleContext ruleContext, JavaLibraryHelper helper);

  void mutateAspectDefinition(AspectDefinition.Builder def, AspectParameters aspectParameters);

  /** Returns false if the attributes of the rule are invalid */
  boolean checkAttributes(RuleContext ruleContext, AspectParameters aspectParameters);
}
