#!/bin/bash
#
# Copyright 2015 The Bazel Authors. All rights reserved.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#    http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

source $(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/test-setup.sh \
  || { echo "test-setup.sh not found!" >&2; exit 1; }

function set_up() {
  LOCAL=$(pwd)
  REMOTE=$TEST_TMPDIR/remote

  # Set up empty remote repo.
  mkdir -p $REMOTE
  touch $REMOTE/WORKSPACE
  cat > $REMOTE/BUILD <<EOF
genrule(
    name = "get-input",
    outs = ["an-input"],
    srcs = ["input"],
    cmd = "cat \$< > \$@",
    visibility = ["//visibility:public"],
)
EOF

  # Set up local repo that uses $REMOTE as an external repo.
  cat > $LOCAL/WORKSPACE <<EOF
local_repository(
    name = "a",
    path = "$REMOTE",
)
EOF
  cat > $LOCAL/BUILD <<EOF
genrule(
    name = "b",
    srcs = ["@a//:get-input"],
    outs = ["b.out"],
    cmd = "cat \$< > \$@",
)
EOF
}

function test_build_file_changes_are_noticed() {
  cat > $REMOTE/BUILD <<EOF
SYNTAX ERROR
EOF
  bazel build //:b &> $TEST_log && fail "Build succeeded"
  expect_log "syntax error at 'ERROR'"

  cat > $REMOTE/BUILD <<EOF
genrule(
    name = "get-input",
    outs = ["a.out"],
    cmd = "echo 'I come from @a' > \$@",
    visibility = ["//visibility:public"],
)
EOF

  bazel build //:b &> $TEST_log || fail "Build failed"
  assert_contains "I come from @a" bazel-genfiles/b.out
}

function test_external_file_changes_are_noticed() {
  version="1.0"
  cat > $REMOTE/input <<EOF
$version
EOF
  bazel build //:b &> $TEST_log || fail "Build failed"
  assert_contains $version bazel-genfiles/b.out

  version="2.0"
  cat > $REMOTE/input <<EOF
$version
EOF
  bazel build //:b &> $TEST_log || fail "Build failed"
  assert_contains $version bazel-genfiles/b.out
}

function test_symlink_changes_are_noticed() {
  cat > $REMOTE/version1 <<EOF
1.0
EOF
  cat > $REMOTE/version2 <<EOF
2.0
EOF
  rm $REMOTE/input
  ln -s $REMOTE/version1 $REMOTE/input
  bazel build //:b &> $TEST_log || fail "Build failed"
  assert_contains 1.0 bazel-genfiles/b.out

  rm $REMOTE/input
  ln -s $REMOTE/version2 $REMOTE/input
  bazel build //:b &> $TEST_log || fail "Build failed"
  assert_contains 2.0 bazel-genfiles/b.out
}

function test_parent_symlink_change() {
  REMOTE1=$TEST_TMPDIR/remote1
  REMOTE2=$TEST_TMPDIR/remote2
  mkdir -p $REMOTE1 $REMOTE2
  cp -R $REMOTE/* $REMOTE1
  cp -R $REMOTE/* $REMOTE2
  cat > $REMOTE1/input <<EOF
1.0
EOF
  cat > $REMOTE2/input <<EOF
2.0
EOF
  rm -rf $REMOTE
  ln -s $REMOTE1 $REMOTE

  bazel build //:b &> $TEST_log || fail "Build failed"
  assert_contains 1.0 bazel-genfiles/b.out

  rm $REMOTE
  ln -s $REMOTE2 $REMOTE
  bazel build //:b &> $TEST_log || fail "Build failed"
  assert_contains 2.0 bazel-genfiles/b.out
}

run_suite "//external correctness tests"
