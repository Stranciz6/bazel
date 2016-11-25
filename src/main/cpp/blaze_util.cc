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

#include "src/main/cpp/blaze_util.h"

#include <errno.h>
#include <fcntl.h>
#include <pwd.h>
#include <stdarg.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/file.h>
#include <sys/ioctl.h>
#include <sys/socket.h>
#include <sys/stat.h>
#include <sys/types.h>
#include <unistd.h>

#include <sstream>

#include "src/main/cpp/blaze_util_platform.h"
#include "src/main/cpp/util/errors.h"
#include "src/main/cpp/util/exit_code.h"
#include "src/main/cpp/util/file.h"
#include "src/main/cpp/util/file_platform.h"
#include "src/main/cpp/util/numbers.h"
#include "src/main/cpp/util/strings.h"
#include "src/main/cpp/util/port.h"

using blaze_util::die;
using blaze_util::pdie;

namespace blaze {

using std::string;
using std::vector;

const char kServerPidFile[] = "server.pid.txt";
const char kServerPidSymlink[] = "server.pid";

string GetUserName() {
  string user = GetEnv("USER");
  if (!user.empty()) {
    return user;
  }
  errno = 0;
  passwd *pwent = getpwuid(getuid());  // NOLINT (single-threaded)
  if (pwent == NULL || pwent->pw_name == NULL) {
    pdie(blaze_exit_code::LOCAL_ENVIRONMENTAL_ERROR,
         "$USER is not set, and unable to look up name of current user");
  }
  return pwent->pw_name;
}

string MakeAbsolute(const string &path) {
  // Check if path is already absolute.
  if (path.empty() || path[0] == '/' || (isalpha(path[0]) && path[1] == ':')) {
    return path;
  }

  string cwd = blaze_util::GetCwd();

  // Determine whether the cwd ends with "/" or not.
  string separator = cwd.back() == '/' ? "" : "/";
  return cwd + separator + path;
}

bool ReadFrom(const std::function<int(void *, int)> &read_func, string *content,
              int max_size) {
  content->clear();
  char buf[4096];
  // OPT:  This loop generates one spurious read on regular files.
  while (int r = read_func(
             buf, max_size > 0
                      ? std::min(max_size, static_cast<int>(sizeof buf))
                      : sizeof buf)) {
    if (r == -1) {
      if (errno == EINTR || errno == EAGAIN) continue;
      return false;
    }
    content->append(buf, r);
    if (max_size > 0) {
      if (max_size > r) {
        max_size -= r;
      } else {
        break;
      }
    }
  }
  return true;
}

bool ReadFile(const string &filename, string *content, int max_size) {
  int fd = open(filename.c_str(), O_RDONLY);
  if (fd == -1) return false;
  bool result =
      ReadFrom([fd](void *buf, int len) { return read(fd, buf, len); }, content,
               max_size);
  close(fd);
  return result;
}

bool WriteFile(const void* data, size_t size, const string &filename) {
  UnlinkPath(filename);  // We don't care about the success of this.
  int fd = open(filename.c_str(), O_CREAT|O_WRONLY|O_TRUNC, 0755);  // chmod +x
  if (fd == -1) {
    return false;
  }
  bool result = WriteTo(
      [fd](const void *buf, size_t bufsize) { return write(fd, buf, bufsize); },
      data, size);
  int saved_errno = errno;
  if (close(fd)) {
    return false;  // Can fail on NFS.
  }
  errno = saved_errno;  // Caller should see errno from write().
  return result;
}

bool WriteTo(const std::function<int(const void *, size_t)> &write_func,
             const void *data, size_t size) {
  int r = write_func(data, size);
  if (r == -1) {
    return false;
  }
  return static_cast<uint>(r) == size;
}

bool WriteFile(const std::string &content, const std::string &filename) {
  return WriteFile(content.c_str(), content.size(), filename);
}

bool UnlinkPath(const string &file_path) {
  return unlink(file_path.c_str()) == 0;
}

bool IsEmacsTerminal() {
  string emacs = GetEnv("EMACS");
  string inside_emacs = GetEnv("INSIDE_EMACS");
  // GNU Emacs <25.1 (and ~all non-GNU emacsen) set EMACS=t, but >=25.1 doesn't
  // do that and instead sets INSIDE_EMACS=<stuff> (where <stuff> can look like
  // e.g. "25.1.1,comint").  So we check both variables for maximum
  // compatibility.
  return emacs == "t" || !inside_emacs.empty();
}

// Returns true iff both stdout and stderr are connected to a
// terminal, and it can support color and cursor movement
// (this is computed heuristically based on the values of
// environment variables).
bool IsStandardTerminal() {
  string term = GetEnv("TERM");
  if (term.empty() || term == "dumb" || term == "emacs" ||
      term == "xterm-mono" || term == "symbolics" || term == "9term" ||
      IsEmacsTerminal()) {
    return false;
  }
  return isatty(STDOUT_FILENO) && isatty(STDERR_FILENO);
}

// Returns the number of columns of the terminal to which stdout is
// connected, or $COLUMNS (default 80) if there is no such terminal.
int GetTerminalColumns() {
  struct winsize ws;
  if (ioctl(STDOUT_FILENO, TIOCGWINSZ, &ws) != -1) {
    return ws.ws_col;
  }
  string columns_env = GetEnv("COLUMNS");
  if (!columns_env.empty()) {
    char* endptr;
    int columns = blaze_util::strto32(columns_env.c_str(), &endptr, 10);
    if (*endptr == '\0') {  // $COLUMNS is a valid number
      return columns;
    }
  }
  return 80;  // default if not a terminal.
}

const char* GetUnaryOption(const char *arg,
                           const char *next_arg,
                           const char *key) {
  const char *value = blaze_util::var_strprefix(arg, key);
  if (value == NULL) {
    return NULL;
  } else if (value[0] == '=') {
    return value + 1;
  } else if (value[0]) {
    return NULL;  // trailing garbage in key name
  }

  return next_arg;
}

bool GetNullaryOption(const char *arg, const char *key) {
  const char *value = blaze_util::var_strprefix(arg, key);
  if (value == NULL) {
    return false;
  } else if (value[0] == '=') {
    die(blaze_exit_code::BAD_ARGV,
        "In argument '%s': option '%s' does not take a value.", arg, key);
  } else if (value[0]) {
    return false;  // trailing garbage in key name
  }

  return true;
}

bool VerboseLogging() { return !GetEnv("VERBOSE_BLAZE_CLIENT").empty(); }

// Read the Jvm version from a file descriptor. The read fd
// should contains a similar output as the java -version output.
string ReadJvmVersion(const string& version_string) {
  // try to look out for 'version "'
  static const string version_pattern = "version \"";
  size_t found = version_string.find(version_pattern);
  if (found != string::npos) {
    found += version_pattern.size();
    // If we found "version \"", process until next '"'
    size_t end = version_string.find("\"", found);
    if (end == string::npos) {  // consider end of string as a '"'
      end = version_string.size();
    }
    return version_string.substr(found, end - found);
  }

  return "";
}

string GetJvmVersion(const string &java_exe) {
  vector<string> args;
  args.push_back("java");
  args.push_back("-version");

  string version_string = RunProgram(java_exe, args);
  return ReadJvmVersion(version_string);
}

bool CheckJavaVersionIsAtLeast(const string &jvm_version,
                               const string &version_spec) {
  vector<string> jvm_version_vect = blaze_util::Split(jvm_version, '.');
  int jvm_version_size = static_cast<int>(jvm_version_vect.size());
  vector<string> version_spec_vect = blaze_util::Split(version_spec, '.');
  int version_spec_size = static_cast<int>(version_spec_vect.size());
  int i;
  for (i = 0; i < jvm_version_size && i < version_spec_size; i++) {
    int jvm = blaze_util::strto32(jvm_version_vect[i].c_str(), NULL, 10);
    int spec = blaze_util::strto32(version_spec_vect[i].c_str(), NULL, 10);
    if (jvm > spec) {
      return true;
    } else if (jvm < spec) {
      return false;
    }
  }
  if (i < version_spec_size) {
    for (; i < version_spec_size; i++) {
      if (version_spec_vect[i] != "0") {
        return false;
      }
    }
  }
  return true;
}

bool IsArg(const string& arg) {
  return blaze_util::starts_with(arg, "-") && (arg != "--help")
      && (arg != "-help") && (arg != "-h");
}

}  // namespace blaze
