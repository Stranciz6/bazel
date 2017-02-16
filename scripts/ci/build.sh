#!/bin/bash

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

set -eu

# Main deploy functions for the continous build system
# Just source this file and use the various method:
#   bazel_build build bazel and run all its test
#   bazel_release use the artifact generated by bazel_build and push
#     them to github for a release and to GCS for a release candidate.
#     Also prepare an email for announcing the release.

# Load common.sh
SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
source $(dirname ${SCRIPT_DIR})/release/common.sh

: ${GIT_REPOSITORY_URL:=https://github.com/bazelbuild/bazel}

: ${GCS_BASE_URL:=https://storage.googleapis.com}
: ${GCS_BUCKET:=bucket-o-bazel}
: ${GCS_APT_BUCKET:=bazel-apt}

: ${EMAIL_TEMPLATE_RC:=${SCRIPT_DIR}/rc_email.txt}
: ${EMAIL_TEMPLATE_RELEASE:=${SCRIPT_DIR}/release_email.txt}

: ${RELEASE_CANDIDATE_URL:="${GCS_BASE_URL}/${GCS_BUCKET}/%release_name%/rc%rc%/index.html"}
: ${RELEASE_URL="${GIT_REPOSITORY_URL}/releases/tag/%release_name%"}

: ${BOOTSTRAP_BAZEL:=bazel}

PLATFORM="$(uname -s | tr 'A-Z' 'a-z')"
if [[ ${PLATFORM} == "darwin" ]] || [[ ${PLATFORM} == "freebsd" ]] ; then
  function checksum() {
    (cd "$(dirname "$1")" && shasum -a 256 "$(basename "$1")")
  }
else
  function checksum() {
    (cd "$(dirname "$1")" && sha256sum "$(basename "$1")")
  }
fi

# Returns the full release name in the form NAME(rcRC)?
function get_full_release_name() {
  local rc=$(get_release_candidate)
  local name=$(get_release_name)
  if [ -n "${rc}" ]; then
    echo "${name}rc${rc}"
  else
    echo "${name}"
  fi
}

function setup_android_repositories() {
  if [ ! -f WORKSPACE.bak ] && [ -n "${ANDROID_SDK_PATH-}" ]; then
    cp WORKSPACE WORKSPACE.bak
    trap '[ -f WORKSPACE.bak ] && rm WORKSPACE && mv WORKSPACE.bak WORKSPACE' \
      EXIT
    # Make sure that WORKSPACE ends with a newline, otherwise we'll end up with
    # a syntax error.
    echo >>WORKSPACE
    cat >>WORKSPACE <<EOF
android_sdk_repository(
    name = "androidsdk",
    path = "${ANDROID_SDK_PATH}",
    build_tools_version = "${ANDROID_SDK_BUILD_TOOLS_VERSION:-22.0.1}",
    api_level = ${ANDROID_SDK_API_LEVEL:-21},
)

bind(
    name = "android_sdk_for_testing",
    actual = "@androidsdk//:files",
)
EOF
    if [ -n "${ANDROID_NDK_PATH-}" ]; then
      cat >>WORKSPACE <<EOF
android_ndk_repository(
    name = "androidndk",
    path = "${ANDROID_NDK_PATH}",
    api_level = ${ANDROID_NDK_API_LEVEL:-21},
)

bind(
    name = "android_ndk_for_testing",
    actual = "@androidndk//:files",
)
EOF
    fi
  fi
}

# Main entry point for building bazel.
# It sets the embed label to the release name if any, calls the whole
# test suite, compile the various packages, then copy the artifacts
# to the folder in $1
function bazel_build() {
  local release_label="$(get_full_release_name)"
  local embed_label_opts=

  if [ -n "${release_label}" ]; then
    export EMBED_LABEL="${release_label}"
  fi

  if [[ "${JAVA_VERSION-}" =~ ^(1\.)?7$ ]]; then
    JAVA_VERSION=1.7
    release_label="${release_label}-jdk7"
  else
    JAVA_VERSION=1.8
  fi

  # Build the packages
  local ARGS=
  if [[ $PLATFORM == "darwin" ]] && \
      xcodebuild -showsdks 2> /dev/null | grep -q '\-sdk iphonesimulator'; then
    ARGS="--define IPHONE_SDK=1"
  fi
  local OPTIONAL_TARGETS="//site:jekyll-tree //scripts/packages //src/tools/benchmark/webapp:site"
  if [[ $PLATFORM =~ "freebsd" ]] ; then
      OPTIONAL_TARGETS=
  fi
  ${BOOTSTRAP_BAZEL} --bazelrc=${BAZELRC:-/dev/null} --nomaster_bazelrc build \
      --embed_label=${release_label} --stamp \
      --workspace_status_command=scripts/ci/build_status_command.sh \
      --define JAVA_VERSION=${JAVA_VERSION} \
      ${ARGS} \
      //src:bazel \
      ${OPTIONAL_TARGETS} || exit $?

  if [ -n "${1-}" ]; then
    # Copy the results to the output directory
    mkdir -p $1/packages
    cp bazel-bin/src/bazel $1/bazel
    cp bazel-bin/scripts/packages/install.sh $1/bazel-${release_label}-installer.sh
    if [ "$PLATFORM" = "linux" ]; then
      cp bazel-bin/scripts/packages/debian/bazel-debian.deb $1/bazel_${release_label}.deb
      cp -f bazel-genfiles/scripts/packages/debian/bazel.dsc $1/bazel.dsc
      cp -f bazel-genfiles/scripts/packages/debian/bazel.tar.gz $1/bazel.tar.gz
      cp bazel-genfiles/bazel-distfile.zip $1/bazel-${release_label}-dist.zip
    fi
    cp bazel-genfiles/site/jekyll-tree.tar $1/www.bazel.build.tar
    cp bazel-bin/src/tools/benchmark/webapp/site.tar $1/perf.bazel.build.tar.nobuild
    cp bazel-genfiles/scripts/packages/README.md $1/README.md
  fi
}

# Generate a string from a template and a list of substitutions.
# The first parameter is the template name and each subsequent parameter
# is taken as a couple: first is the string the substitute and the second
# is the result of the substitution.
function generate_from_template() {
  local value="$1"
  shift
  while (( $# >= 2 )); do
    value="${value//$1/$2}"
    shift 2
  done
  echo "${value}"
}

# Generate the email for the release.
# The first line of the output will be the recipient, the second line
# the mail subjects and the subsequent lines the mail, its content.
# If no planed release, then this function output will be empty.
function generate_email() {
  local release_name=$(get_release_name)
  local rc=$(get_release_candidate)
  local args=(
      "%release_name%" "${release_name}"
      "%rc%" "${rc}"
      "%relnotes%" "# $(get_full_release_notes)"
  )
  if [ -n "${rc}" ]; then
    args+=(
        "%url%"
        "$(generate_from_template "${RELEASE_CANDIDATE_URL}" "${args[@]}")"
    )
    generate_from_template "$(cat ${EMAIL_TEMPLATE_RC})" "${args[@]}"
  elif [ -n "${release_name}" ]; then
    args+=(
        "%url%"
        "$(generate_from_template "${RELEASE_URL}" "${args[@]}")"
    )
    generate_from_template "$(cat ${EMAIL_TEMPLATE_RELEASE})" "${args[@]}"
  fi
}

# Deploy a github release using a third party tool:
#   https://github.com/c4milo/github-release
# This methods expects the following arguments:
#   $1..$n files generated by package_build (should not contains the README file)
# Please set GITHUB_TOKEN to talk to the Github API and GITHUB_RELEASE
# for the path to the https://github.com/c4milo/github-release tool.
# This method is also affected by GIT_REPOSITORY_URL which should be the
# URL to the github repository (defaulted to https://github.com/bazelbuild/bazel).
function release_to_github() {
  local url="${GIT_REPOSITORY_URL}"
  local release_name=$(get_release_name)
  local rc=$(get_release_candidate)
  local release_tool="${GITHUB_RELEASE:-$(which github-release 2>/dev/null || true)}"
  local gpl_warning="

_Notice_: Bazel installers contain binaries licensed under the GPLv2 with
Classpath exception. Those installers should always be redistributed along with
the source code.

_Security_: All our binaries are signed with our
[public key](https://bazel.build/bazel-release.pub.gpg) 48457EE0.
"

  if [ ! -x "${release_tool}" ]; then
    echo "Please set GITHUB_RELEASE to the path to the github-release binary." >&2
    echo "This probably means you haven't installed https://github.com/c4milo/github-release " >&2
    echo "on this machine." >&2
    return 1
  fi
  local github_repo="$(echo "$url" | sed -E 's|https?://github.com/([^/]*/[^/]*).*$|\1|')"
  if [ -n "${release_name}" ] && [ -z "${rc}" ]; then
    mkdir -p "${tmpdir}/to-github"
    cp "${@}" "${tmpdir}/to-github"
    "${GITHUB_RELEASE}" "${github_repo}" "${release_name}" "" "# $(git_commit_msg) ${gpl_warning}" "${tmpdir}/to-github/"'*'
  fi
}

# Creates an index of the files contained in folder $1 in mardown format
function create_index_md() {
  # First, add the README.md
  local file=$1/__temp.md
  if [ -f $1/README.md ]; then
    cat $1/README.md
  fi
  # Then, add the list of files
  echo
  echo "## Index of files"
  echo
  # Security notice
  echo "_Security_: All our binaries are signed with our"
  echo "[public key](https://bazel.build/bazel-release.pub.gpg) 48457EE0."
  echo
  for f in $1/*.sha256; do  # just list the sha256 ones
    local filename=$(basename $f .sha256);
    echo " - [${filename}](${filename}) [[SHA-256](${filename}.sha256)] [[SIG](${filename}.sig)]"
  done
}

# Creates an index of the files contained in folder $1 in HTML format
# It supposes hoedown (https://github.com/hoedown/hoedown) is on the path,
# if not, set the HOEDOWN environment variable to the good path.
function create_index_html() {
  local hoedown="${HOEDOWN:-$(which hoedown 2>/dev/null || true)}"
  # Second line is to trick hoedown to behave as Github
  create_index_md "${@}" \
      | sed -E 's/^(Baseline.*)$/\1\
/' | sed 's/^   + / - /' | sed 's/_/\\_/g' \
      | "${hoedown}"
}

function get_gsutil() {
  local gs="${GSUTIL:-$(which gsutil 2>/dev/null || true) -m}"
  if [ ! -x "${gs}" ]; then
    echo "Please set GSUTIL to the path the gsutil binary." >&2
    echo "gsutil (https://cloud.google.com/storage/docs/gsutil/) is the" >&2
    echo "command-line interface to google cloud." >&2
    exit 1
  fi
  echo "${gs}"
}

# Deploy a release candidate to Google Cloud Storage.
# It requires to have gsutil installed. You can force the path to gsutil
# by setting the GSUTIL environment variable. The GCS_BUCKET should be the
# name of the Google cloud bucket to deploy to.
# This methods expects the following arguments:
#   $1..$n files generated by package_build
function release_to_gcs() {
  local gs="$(get_gsutil)"
  local release_name="$(get_release_name)"
  local rc="$(get_release_candidate)"
  if [ -z "${GCS_BUCKET-}" ]; then
    echo "Please set GCS_BUCKET to the name of your Google Cloud Storage bucket." >&2
    return 1
  fi
  if [ -n "${release_name}" ] && [ -n "${rc}" ]; then
    # Make a temporary folder with the desired structure
    local dir="$(mktemp -d ${TMPDIR:-/tmp}/tmp.XXXXXXXX)"
    local prev_dir="$PWD"
    trap "{ cd ${prev_dir}; rm -fr ${dir}; }" EXIT
    mkdir -p "${dir}/${release_name}/rc${rc}"
    cp "${@}" "${dir}/${release_name}/rc${rc}"
    # Add a index.html file:
    create_index_html "${dir}/${release_name}/rc${rc}" \
        >"${dir}/${release_name}/rc${rc}"/index.html
    cd ${dir}
    "${gs}" -m cp -a public-read -r . "gs://${GCS_BUCKET}"
    cd "${prev_dir}"
    rm -fr "${dir}"
    trap - EXIT
  fi
}

function ensure_gpg_secret_key_imported() {
  (gpg --list-secret-keys | grep "${APT_GPG_KEY_ID}" > /dev/null) || \
  gpg --allow-secret-key-import --import "${APT_GPG_KEY_PATH}"
  # Make sure we use stronger digest algorithm。
  # We use reprepro to generate the debian repository,
  # but there's no way to pass flags to gpg using reprepro, so writting it into
  # ~/.gnupg/gpg.conf
  (grep "digest-algo sha256" ~/.gnupg/gpg.conf > /dev/null) || \
  echo "digest-algo sha256" >> ~/.gnupg/gpg.conf
}

function create_apt_repository() {
  mkdir conf
  cat > conf/distributions <<EOF
Origin: Bazel Authors
Label: Bazel
Codename: stable
Architectures: amd64 source
Components: jdk1.7 jdk1.8
Description: Bazel APT Repository
DebOverride: override.stable
DscOverride: override.stable
SignWith: ${APT_GPG_KEY_ID}

Origin: Bazel Authors
Label: Bazel
Codename: testing
Architectures: amd64 source
Components: jdk1.7 jdk1.8
Description: Bazel APT Repository
DebOverride: override.testing
DscOverride: override.testing
SignWith: ${APT_GPG_KEY_ID}
EOF

  cat > conf/options <<EOF
verbose
ask-passphrase
basedir .
EOF

  # TODO(#2264): this is a quick workaround #2256, figure out a correct fix.
  cat > conf/override.stable <<EOF
bazel     Section     contrib/devel
bazel     Priority    optional
EOF
  cat > conf/override.testing <<EOF
bazel     Section     contrib/devel
bazel     Priority    optional
EOF

  ensure_gpg_secret_key_imported

  local distribution="$1"
  local deb_pkg_name_jdk8="$2"
  local deb_pkg_name_jdk7="$3"
  local deb_dsc_name="$4"

  debsign -k ${APT_GPG_KEY_ID} "${deb_dsc_name}"

  reprepro -C jdk1.8 includedeb "${distribution}" "${deb_pkg_name_jdk8}"
  reprepro -C jdk1.8 includedsc "${distribution}" "${deb_dsc_name}"
  reprepro -C jdk1.7 includedeb "${distribution}" "${deb_pkg_name_jdk7}"
  reprepro -C jdk1.7 includedsc "${distribution}" "${deb_dsc_name}"

  "${gs}" -m cp -a public-read -r dists "gs://${GCS_APT_BUCKET}/"
  "${gs}" -m cp -a public-read -r pool "gs://${GCS_APT_BUCKET}/"
}

function release_to_apt() {
  local gs="$(get_gsutil)"
  local release_name="$(get_release_name)"
  local rc="$(get_release_candidate)"
  if [ -z "${GCS_APT_BUCKET-}" ]; then
    echo "Please set GCS_APT_BUCKET to the name of your GCS bucket for apt repository." >&2
    return 1
  fi
  if [ -z "${APT_GPG_KEY_ID-}" ]; then
    echo "Please set APT_GPG_KEY_ID for apt repository." >&2
    return 1
  fi
  if [ -n "${release_name}" ]; then
    # Make a temporary folder with the desired structure
    local dir="$(mktemp -d ${TMPDIR:-/tmp}/tmp.XXXXXXXX)"
    local prev_dir="$PWD"
    trap "{ cd ${prev_dir}; rm -fr ${dir}; }" EXIT
    mkdir -p "${dir}/${release_name}"
    local release_label="$(get_full_release_name)"
    local deb_pkg_name_jdk8="${release_name}/bazel_${release_label}-linux-x86_64.deb"
    local deb_pkg_name_jdk7="${release_name}/bazel_${release_label}-jdk7-linux-x86_64.deb"
    local deb_dsc_name="${release_name}/bazel_${release_label}.dsc"
    local deb_tar_name="${release_name}/bazel_${release_label}.tar.gz"
    cp "${tmpdir}/bazel_${release_label}-linux-x86_64.deb" "${dir}/${deb_pkg_name_jdk8}"
    cp "${tmpdir}/bazel_${release_label}-jdk7-linux-x86_64.deb" "${dir}/${deb_pkg_name_jdk7}"
    cp "${tmpdir}/bazel.dsc" "${dir}/${deb_dsc_name}"
    cp "${tmpdir}/bazel.tar.gz" "${dir}/${deb_tar_name}"
    cd "${dir}"
    if [ -n "${rc}" ]; then
      create_apt_repository testing "${deb_pkg_name_jdk8}" "${deb_pkg_name_jdk7}" "${deb_dsc_name}"
    else
      create_apt_repository stable "${deb_pkg_name_jdk8}" "${deb_pkg_name_jdk7}" "${deb_dsc_name}"
    fi
    cd "${prev_dir}"
    rm -fr "${dir}"
    trap - EXIT
  fi
}

# A wrapper around the release deployment methods.
function deploy_release() {
  local github_args=()
  # Filters out README.md for github releases
  for i in "$@"; do
    if ! ( [[ "$i" =~ README.md$ ]] || [[ "$i" =~ bazel.dsc ]] || [[ "$i" =~ bazel.tar.gz ]] ) ; then
      github_args+=("$i")
    fi
  done
  release_to_github "${github_args[@]}"
  release_to_gcs "$@"
  release_to_apt
}

# A wrapper for the whole release phase:
#   Compute the SHA-256, and arrange the input
#   Sign every binary using gpg and generating .sig files
#   Deploy the release
#   Generate the email
# Input: $1 $2 [$3 $4 [$5 $6 ...]]
#    Each pair denotes a couple (platform, folder) where the platform
#    is the platform built for and the folder is the folder where the
#    artifacts for this platform are.
# Ouputs:
#   RELEASE_EMAIL_RECIPIENT: who to send a mail to
#   RELEASE_EMAIL_SUBJECT: the subject of the email to be sent
#   RELEASE_EMAIL_CONTENT: the content of the email to be sent
function bazel_release() {
  local README=$2/README.md
  tmpdir=$(mktemp -d ${TMPDIR:-/tmp}/tmp.XXXXXXXX)
  trap 'rm -fr ${tmpdir}' EXIT
  ensure_gpg_secret_key_imported

  while (( $# > 1 )); do
    local platform=$1
    local folder=$2
    shift 2
    for file in $folder/*; do
      local filename=$(basename $file)
      if [ "$filename" != README.md ]; then
          if [ "$filename" == "bazel.dsc" ] || [ "$filename" == "bazel.tar.gz" ] \
                 || [[ "$filename" =~ bazel-(.*)-dist\.zip ]]  ; then
          local destfile=${tmpdir}/$filename
        elif [[ "$file" =~ /([^/]*)(\.[^\./]+)$ ]]; then
          local destfile=${tmpdir}/${BASH_REMATCH[1]}-${platform}${BASH_REMATCH[2]}
        else
          local destfile=${tmpdir}/$filename-${platform}
        fi
        # bazel.tar.gz is duplicated under different platforms
        # if the file is already there, skip signing and checksum it again.
        if [ ! -f "$destfile" ]; then
          mv $file $destfile
          checksum $destfile > $destfile.sha256
          gpg --no-tty --detach-sign -u "${APT_GPG_KEY_ID}" "$destfile"
        fi
      fi
    done
  done
  deploy_release $README $(find ${tmpdir} -type f)

  export RELEASE_EMAIL="$(generate_email)"

  export RELEASE_EMAIL_RECIPIENT="$(echo "${RELEASE_EMAIL}" | head -1)"
  export RELEASE_EMAIL_SUBJECT="$(echo "${RELEASE_EMAIL}" | head -2 | tail -1)"
  export RELEASE_EMAIL_CONTENT="$(echo "${RELEASE_EMAIL}" | tail -n +3)"
}

# Use jekyll build to build the site and then gsutil to copy it to GCS
# Input: $1 tarball to the jekyll site
#        $2 name of the bucket to deploy the site to
#        $3 "nobuild" if only publish without build
# It requires to have gsutil installed. You can force the path to gsutil
# by setting the GSUTIL environment variable
function build_and_publish_site() {
  tmpdir=$(mktemp -d ${TMPDIR:-/tmp}/tmp.XXXXXXXX)
  trap 'rm -fr ${tmpdir}' EXIT
  local gs="$(get_gsutil)"
  local site="$1"
  local bucket="$2"
  local nobuild="$3"

  if [ ! -f "${site}" ] || [ -z "${bucket}" ]; then
    echo "Usage: build_and_publish_site <site-tarball> <bucket>" >&2
    return 1
  fi
  local prod_dir="${tmpdir}"
  tar xf "${site}" --exclude=CNAME -C "${tmpdir}"
  if [ "$nobuild" != "nobuild" ]; then
    jekyll build -s "${tmpdir}" -d "${tmpdir}/production"
    prod_dir="${tmpdir}/production"
  fi

  # Rsync:
  #   -r: recursive
  #   -c: compute checksum even though the input is from the filesystem
  "${gs}" rsync -r -c "${prod_dir}" "gs://${bucket}"
  "${gs}" web set -m index.html -e 404.html "gs://${bucket}"
  "${gs}" -m acl ch -R -u AllUsers:R "gs://${bucket}"
}

# Push json file to perf site, also add to file_list
# Input: $1 json file
#        $2 name of the bucket to deploy the site to
function push_benchmark_output_to_site() {
  tmpdir=$(mktemp -d ${TMPDIR:-/tmp}/tmp.XXXXXXXX)
  trap 'rm -fr ${tmpdir}' EXIT
  local gs="$(get_gsutil)"
  local filename="$1"
  local bucket="$2"

  if [ ! -f "${site}"] || [ -z "${bucket}" ]; then
    echo "Usage: push_benchmark_output_to_site <json-file-name> <bucket>" >&2
    return 1
  fi

  # Upload json file
  "${gs}" cp "${filename}" "gs://${bucket}/data/"

  # Download file_list (it might not exist)
  "${gs}" cp "gs://${bucket}/file_list" "${tmpdir}" || true
  # Update file_list
  local list_file="${tmpdir}/file_list"
  echo "${filename}" >> "${list_file}"
  "${gs}" cp "${list_file}" "gs://${bucket}/file_list"

  "${gs}" -m acl ch -R -u AllUsers:R "gs://${bucket}"
}
