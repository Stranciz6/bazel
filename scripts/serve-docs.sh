#!/bin/bash
# Copyright 2016 The Bazel Authors. All rights reserved.
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

set -eu

readonly PORT=${1-12345}

readonly WORKING_DIR=$(mktemp -d)

function check {
  which $1 > /dev/null || (echo "$1 not installed. Please install $1."; exit 1)
}

function build_and_serve {
  bazel build //site:jekyll-tree.tar
  rm -rf $WORKING_DIR/*
  tar -xf bazel-genfiles/site/jekyll-tree.tar -C $WORKING_DIR

  pkill -9 jekyll || true
  jekyll serve --detach --quiet --port $PORT --source $WORKING_DIR
}

function main {
  check jekyll

  old_version="Jekyll 0.11.2"
  if expr match "$(jekyll --version)" "$old_version"; then
    # The ancient version that apt-get has.
    echo "ERROR: Running with an old version of Jekyll, update " \
      "to 2.5.3 with \`sudo gem install jekyll -v 2.5.3\`"
    exit 1
  fi

  build_and_serve

  echo "Type q to quit, r to rebuild docs and restart jekyll"
  while true; do

    read -n 1 -s user_input
    if [ "$user_input" == "q" ]; then
      echo "Quitting"
      exit 0
    elif [ "$user_input" == "r" ]; then
      echo "Rebuilding docs and restarting jekyll"
      build_and_serve
      echo "Rebuilt docs and restarted jekyll"
    fi
  done
}

function cleanup {
  rm -rf $WORKING_DIR
  pkill -9 jekyll
}
trap cleanup EXIT

main
