#!/usr/bin/env bash
# Locate the current repo's g-dev projects in the Obsidian vault.
# Output: one state.md path per line; empty output = no projects.
# GUARD_FAIL on stdout (exit 1) = repo or vault missing; fix the inputs,
# never treat it as "no results".
# find, not a glob: zsh aborts the whole command on an unmatched glob.
VAULT="$HOME/Documents/obsidian-vault"
# Repo identity = main checkout basename. In a linked worktree,
# show-toplevel names the worktree dir and would break repo: matching;
# git-common-dir points into the main checkout (may be relative, hence
# the cd+pwd normalization). Layouts where common-dir is not ".git"
# (submodule, bare) fall back to show-toplevel; bare then guard-fails.
COMMON=$(cd "$(git rev-parse --git-common-dir 2>/dev/null)" 2>/dev/null && pwd)
if [ "$(basename "$COMMON")" = ".git" ]; then
  REPO=$(basename "$(dirname "$COMMON")")
else
  REPO=$(basename "$(git rev-parse --show-toplevel 2>/dev/null)")
fi
if [ -z "$REPO" ] || ! ls "$VAULT/projects" >/dev/null 2>&1; then
  echo GUARD_FAIL
  exit 1
fi
find "$VAULT/projects" -maxdepth 4 -name state.md -path '*/assets/*' \
  -exec grep -lxF "repo: $REPO" {} + 2>/dev/null
exit 0
