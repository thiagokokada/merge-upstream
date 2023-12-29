#!/usr/bin/env bash

set -euo pipefail

# https://docs.github.com/en/rest/branches/branches?apiVersion=2022-11-28#sync-a-fork-branch-with-the-upstream-repository
response=$(curl --location --fail \
  -X POST \
  -H "Accept: application/vnd.github+json" \
  -H "Authorization: Bearer $INPUT_TOKEN" \
  -H "X-GitHub-Api-Version: 2022-11-28" \
  "https://api.github.com/repos/$INPUT_REPO/merge-upstream" \
  -d "{\"branch\":\"$INPUT_BRANCH\"}")

{
  jq -r '"message=\(.message)"' <<< "$response"
  jq -r '"merge-type=\(.merge_type)"' <<< "$response"
  jq -r '"base-branch=\(.base_branch)"' <<< "$response"
} >> "$GITHUB_OUTPUT"
