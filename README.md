# Merge Upstream

Merge changes from an upstream repository branch into a current
repository branch. For example, updating changes from the repository
that was forked from.

Syncs a fork branch with the upstream repository. For example, updating
changes made from the repository that was forked from.

This version uses
[GitHub API](https://docs.github.com/en/rest/branches/branches?apiVersion=2022-11-28#sync-a-fork-branch-with-the-upstream-repository)
to do so, and this brings some advantages and limitations:

- Fast, because it uses GitHub own's API (similar to
  [`Sync fork`](https://docs.github.com/en/pull-requests/collaborating-with-pull-requests/working-with-forks/syncing-a-fork#syncing-a-fork-branch-from-the-web-ui)
  button from Web UI)
- Only merge branches that exist in both upstream and fork
- Merge is only done by either `merge` or `fast-forward` strategies

To merge multiple branches, create multiple jobs.

## Usage

Before starting, ensure that the branch you want to update exist in both
upstream and fork. To do so, run the following commands in your local clone:

```console
$ git remote add upstream <repo-url>
$ git fetch upstream
$ git checkout -b <branch> upstream/<branch>
$ git push origin
```

### Quick start

```yaml
name: Sync fork with upstream
on:
  schedule:
    - cron: "0 */6 * * *" # every 6th hour
  workflow_dispatch: # allow manual triggering via Web UI to test

jobs:
  sync-fork:
    runs-on: ubuntu-latest
    steps:
      - uses: thiagokokada/merge-upstream@v1
        with:
          branch: main
```

### Multiple branches

```yaml
name: Sync fork with upstream
on:
  schedule:
    - cron: "0 */6 * * *"
  workflow_dispatch:

jobs:
  sync-fork:
    strategy:
      # using matrix to trigger sync in multiple branches
      matrix:
        branch:
          - master
          - staging
    runs-on: ubuntu-latest
    steps:
      - uses: thiagokokada/merge-upstream@v1
        with:
          branch: ${{ matrix.branch }}
```

### Advanced usage

```yaml
name: Sync fork with upstream
on:
  schedule:
    - cron: "0 */6 * * *"
  workflow_dispatch:

jobs:
  sync-fork:
    runs-on: ubuntu-latest
    steps:
      - uses: thiagokokada/merge-upstream@v1
        id: merge-upstream
        with:
          # Required.
          branch: main
          # Forked repo to be updated with upstream, may be useful to set if
          # you want to run this action from an arbitrary repository.
          repo: owner/repo
          # GitHub token to be used, defaults to GITHUB_TOKEN.
          # You may want to use a Personal Access Token (PAT) instead,
          # especially if you're running this action from an arbitrary
          # repository.
          token: ${{ secrets.PAT_TOKEN }}
      - run: |
          # The job has the following outputs that matches the API response.
          # They may be useful for further automation.
          echo "${{ steps.merge-upstream.outputs.message }}"
          echo "${{ steps.merge-upstream.outputs.merge-type }}"
          echo "${{ steps.merge-upstream.outputs.base-branch }}"
```

## Development

To run tests, you will need to create a Personal Access Token (PAT) with
access to `repo` permissions, and run:

```console
$ git submodule update --init
$ export GITHUB_TOKEN=<PAT token>
$ export TEST_BRANCH=<branch>
$ export TEST_REPO=<repo>
$ ./tests.sh
```
