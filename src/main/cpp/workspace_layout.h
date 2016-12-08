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

#ifndef BAZEL_SRC_MAIN_CPP_WORKSPACE_LAYOUT_H_
#define BAZEL_SRC_MAIN_CPP_WORKSPACE_LAYOUT_H_

#include <string>
#include <vector>

namespace blaze {

// Provides methods to compute paths related to the workspace.
class WorkspaceLayout {
 public:
  virtual ~WorkspaceLayout() = default;

  // Returns the directory to use for storing outputs.
  virtual std::string GetOutputRoot() const;

  // Given the working directory, returns the nearest enclosing directory with a
  // WORKSPACE file in it.  If there is no such enclosing directory, returns "".
  //
  // E.g., if there was a WORKSPACE file in foo/bar/build_root:
  // GetWorkspace('foo/bar') --> ''
  // GetWorkspace('foo/bar/build_root') --> 'foo/bar/build_root'
  // GetWorkspace('foo/bar/build_root/biz') --> 'foo/bar/build_root'
  //
  // The returned path is relative or absolute depending on whether cwd was
  // relative or absolute.
  virtual std::string GetWorkspace(const std::string& cwd) const;

  // Returns if workspace is a valid build workspace.
  virtual bool InWorkspace(const std::string& workspace) const;

  // Returns the basename for the rc file.
  virtual std::string RcBasename() const;

  // Returns the candidate pathnames for the RC files.
  virtual void FindCandidateBlazercPaths(
      const std::string& workspace,
      const std::string& cwd,
      const std::string& path_to_binary,
      const std::vector<std::string>& startup_args,
      std::vector<std::string>* result) const;

  // Returns the candidate pathnames for the RC file in the workspace,
  // the first readable one of which will be chosen.
  // It is ok if no usable candidate exists.
  virtual void WorkspaceRcFileSearchPath(std::vector<std::string>* candidates)
      const;

  // Turn a %workspace%-relative import into its true name in the filesystem.
  // path_fragment is modified in place.
  // Unlike WorkspaceRcFileSearchPath, it is an error if no import file exists.
  virtual bool WorkspaceRelativizeRcFilePath(const std::string& workspace,
                                             std::string* path_fragment) const;

  static constexpr const char WorkspacePrefix[] = "%workspace%/";
  static const int WorkspacePrefixLength = sizeof WorkspacePrefix - 1;
};

}  // namespace blaze

#endif  // BAZEL_SRC_MAIN_CPP_WORKSPACE_LAYOUT_H_
