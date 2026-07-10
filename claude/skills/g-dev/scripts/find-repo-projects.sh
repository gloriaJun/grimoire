#!/usr/bin/env bash
# Locate the current repo's g-dev projects in the Obsidian vault.
# Output: one state.md path per line; empty output = no projects.
# GUARD_FAIL on stdout (exit 1) = repo or vault missing; fix the inputs,
# never treat it as "no results".
# find, not a glob: zsh aborts the whole command on an unmatched glob.
VAULT="$HOME/Documents/obsidian-vault"
REPO=$(basename "$(git rev-parse --show-toplevel 2>/dev/null)")
if [ -z "$REPO" ] || ! ls "$VAULT/projects" >/dev/null 2>&1; then
  echo GUARD_FAIL
  exit 1
fi
find "$VAULT/projects" -maxdepth 4 -name state.md -path '*/assets/*' \
  -exec grep -lxF "repo: $REPO" {} + 2>/dev/null
exit 0
