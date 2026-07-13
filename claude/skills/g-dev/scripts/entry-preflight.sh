#!/usr/bin/env bash
# Step-1 entry preflight: vault presence, main checkout, today's date.
# Output lines: VAULT_OK|VAULT_MISSING, MAIN=<path or empty>, DATE=<YYYY-MM-DD>.
# Callers branch on the output lines; the script itself always exits 0.
VAULT="$HOME/Documents/obsidian-vault"
ls "$VAULT/projects" >/dev/null 2>&1 && echo VAULT_OK || echo VAULT_MISSING
# Main checkout, even from a linked worktree; empty = not a repo.
# Same derivation as find-repo-projects.sh: common-dir not named ".git"
# (submodule, bare) falls back to show-toplevel; bare then yields empty.
COMMON=$(cd "$(git rev-parse --git-common-dir 2>/dev/null)" 2>/dev/null && pwd)
if [ "$(basename "$COMMON")" = ".git" ]; then
  MAIN=$(dirname "$COMMON")
else
  MAIN=$(git rev-parse --show-toplevel 2>/dev/null)
fi
echo "MAIN=$MAIN"
echo "DATE=$(date +%F)"
exit 0
