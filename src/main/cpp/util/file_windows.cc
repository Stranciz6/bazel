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
#include "src/main/cpp/util/file_platform.h"

#include <windows.h>

#include "src/main/cpp/util/errors.h"

namespace blaze_util {

using std::string;

string Which(const string &executable) {
  pdie(255, "blaze_util::Which is not implemented on Windows");
  return "";
}

bool PathExists(const string& path) {
  // TODO(bazel-team): implement this.
  pdie(255, "blaze_util::PathExists is not implemented on Windows");
  return false;
}

string MakeCanonical(const char *path) {
  // TODO(bazel-team): implement this.
  pdie(255, "blaze_util::MakeCanonical is not implemented on Windows");
  return "";
}

bool CanAccess(const string& path, bool read, bool write, bool exec) {
  // TODO(bazel-team): implement this.
  pdie(255, "blaze_util::CanAccess is not implemented on Windows");
  return false;
}

bool IsDirectory(const string& path) {
  // TODO(bazel-team): implement this.
  pdie(255, "blaze_util::IsDirectory is not implemented on Windows");
  return false;
}

void SyncFile(const string& path) {
  // No-op on Windows native; unsupported by Cygwin.
}

time_t GetMtimeMillisec(const string& path) {
  // TODO(bazel-team): implement this.
  pdie(255, "blaze_util::GetMtimeMillisec is not implemented on Windows");
  return -1;
}

bool SetMtimeMillisec(const string& path, time_t mtime) {
  // TODO(bazel-team): implement this.
  pdie(255, "blaze_util::SetMtimeMillisec is not implemented on Windows");
  return false;
}

string GetCwd() {
  // TODO(bazel-team): implement this.
  pdie(255, "blaze_util::GetCwd is not implemented on Windows");
  return "";
}

bool ChangeDirectory(const string& path) {
  // TODO(bazel-team): implement this.
  pdie(255, "blaze_util::ChangeDirectory is not implemented on Windows");
  return false;
}

void ForEachDirectoryEntry(const string &path,
                           DirectoryEntryConsumer *consume) {
  // TODO(bazel-team): implement this.
  pdie(255, "blaze_util::ForEachDirectoryEntry is not implemented on Windows");
}

}  // namespace blaze_util
