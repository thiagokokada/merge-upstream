#!/usr/bin/env bash

setUp() {
  assertNotEquals "GITHUB_TOKEN needs to be set" "" "$GITHUB_TOKEN"
}

testSuccess() {
  tmpdir="$(mktemp -d)"
  export INPUT_BRANCH="${TEST_BRANCH:-master}"
  export INPUT_REPO="${TEST_REPO:-thiagokokada/nixpkgs}"
  export INPUT_TOKEN="$GITHUB_TOKEN"
  export GITHUB_OUTPUT="$tmpdir/output"

  ./merge-upstream.sh
  assertEquals 0 "$?"

  assertTrue "cat $GITHUB_OUTPUT | fgrep message"
  assertTrue "cat $GITHUB_OUTPUT | fgrep merge-type"
  assertTrue "cat $GITHUB_OUTPUT | fgrep base-branch"
}

testFail() {
  export INPUT_BRANCH="${TEST_BRANCH:-master}"
  export INPUT_REPO="${TEST_REPO:-thiagokokada/nixpkgs}"
  export INPUT_TOKEN="$RANDOM"

  ./merge-upstream.sh

  assertNotEquals 0 "$?"
}

. ./shunit2/shunit2
