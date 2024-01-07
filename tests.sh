#!/usr/bin/env bash

setUp() {
  tmpdir="$(mktemp -d)"

  # Needs jq in PATH
  export PATH="$PWD/mocks:$PATH"
  export INPUT_BRANCH="master"
  export INPUT_REPO="thiagokokada/nixpkgs"
  export INPUT_TOKEN="$RANDOM"
  export GITHUB_OUTPUT="$tmpdir/output"
}

tearDown() {
  rm -rf "$GITHUB_OUTPUT"

  unset MOCKED_CURL_STDOUT
  unset MOCKED_CURL_EXIT_CODE
}

testSuccess() {
  export MOCKED_CURL_STDOUT='{
  "message": "Successfully fetched and fast-forwarded from upstream NixOS:master.",
  "merge_type": "fast-forward",
  "base_branch": "NixOS:master"
}'

  ./merge-upstream.sh
  assertEquals 0 "$?"

  assertTrue "cat $GITHUB_OUTPUT | fgrep 'message=Successfully fetched and fast-forwarded from upstream NixOS:master.'"
  assertTrue "cat $GITHUB_OUTPUT | fgrep 'merge-type=fast-forward'"
  assertTrue "cat $GITHUB_OUTPUT | fgrep 'base-branch=NixOS:master'"
}

testFail() {
  export MOCKED_CURL_EXIT_CODE=1

  ./merge-upstream.sh
  assertEquals 1 "$?"
}

. ./shunit2/shunit2
