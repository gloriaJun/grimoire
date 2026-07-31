#!/usr/bin/env bash
# g-wrap artifact collector (read-only, never deletes).
# macOS only: `stat -f %B` is BSD-specific and returns a block size on GNU
# coreutils, which the SINCE sanity check below rejects.
# Usage: collect-artifacts.sh [vault]   (no arg = every surface)
# Output: TSV "surface<TAB>path<TAB>detail<TAB>deletable(yes|no)".
# The first line is always the session window row.
set -uo pipefail

MODE="${1:-all}"
VAULT="$HOME/Documents/obsidian-vault"
SAN=$(pwd | sed 's|[^A-Za-z0-9]|-|g')
PROJ="$HOME/.claude/projects/$SAN"
NOW=$(date +%s)

# Window: birth time of the newest transcript for this cwd. Unreadable,
# older than 24h, or in the future -> 12h (43200s) fallback.
SINCE=""
SESSION=""
newest=$(ls -t "$PROJ"/*.jsonl 2>/dev/null | head -1)
if [ -n "$newest" ]; then
  SESSION=$(basename "$newest" .jsonl)
  SINCE=$(stat -f %B "$newest" 2>/dev/null)
fi
case "$SINCE" in '' | *[!0-9]*) SINCE=0 ;; esac
if [ "$SINCE" -lt $((NOW - 86400)) ] || [ "$SINCE" -gt "$NOW" ]; then
  SINCE=$((NOW - 43200))
fi
printf 'window\t@%s\tsession start epoch\tno\n' "$SINCE"

# BSD find cannot parse `-newermt @epoch`, so compare against a marker file.
# Marker setup failing would silently empty every surface, so fail loudly.
MARKER=$(mktemp -t gwrap) || {
  printf 'error\t-\tmktemp failed, no inventory possible\tno\n'
  exit 1
}
trap 'rm -f "$MARKER"' EXIT
if ! touch -t "$(date -r "$SINCE" +%Y%m%d%H%M.%S)" "$MARKER" 2>/dev/null; then
  printf 'error\t-\tmarker timestamp failed, no inventory possible\tno\n'
  exit 1
fi

emit() { # $1 surface, $2 detail, $3 deletable
  while IFS= read -r p; do
    [ -n "$p" ] && printf '%s\t%s\t%s\t%s\n' "$1" "$p" "$2" "$3"
  done
}

# Vault: only notes under inbox/ and projects/, and only `source: claude`
# frontmatter is deletable. Everything else is hand-written, report only.
scan_vault() {
  find "$VAULT/inbox" "$VAULT/projects" -name '*.md' -newer "$MARKER" \
    2>/dev/null | while IFS= read -r f; do
    if awk '/^---$/{n++; next} n==1' "$f" | grep -q '^source: claude$'; then
      printf 'vault\t%s\tclaude-created note\tyes\n' "$f"
    else
      printf 'vault\t%s\thand-written, report only\tno\n' "$f"
    fi
  done
}

if [ "$MODE" = vault ]; then
  scan_vault
  exit 0
fi

if git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  ROOT=$(git rev-parse --show-toplevel)
  CURWT=$(cd "$ROOT" && pwd -P)
  # -z keeps paths raw (no quoting, no octal escapes); tr makes them lines.
  # git prints repo-relative paths, so prefix ROOT: every emitted path must
  # be absolute or a later `rm` would resolve it against a different cwd.
  git status --porcelain -z -uall 2>/dev/null | tr '\0' '\n' |
    sed -n 's/^?? //p' | while IFS= read -r p; do
      case "$p" in
        */) printf 'untracked\t%s/%s\tdirectory\tno\n' "$ROOT" "$p" && continue ;;
      esac
      [ -n "$(find "$ROOT/$p" -maxdepth 0 -newer "$MARKER" 2>/dev/null)" ] &&
        printf 'untracked\t%s/%s\tuntracked file\tyes\n' "$ROOT" "$p"
    done
  git status --porcelain -uall 2>/dev/null | sed -n '/^??/!s/^...//p' |
    emit git-dirty 'uncommitted change' no
  git log @{u}..HEAD --oneline 2>/dev/null |
    emit git-unpushed 'unpushed commit' no
  git worktree list --porcelain | sed -n 's/^worktree //p' | tail -n +2 |
    while IFS= read -r wt; do
      # Physical-path compare: a symlinked cwd would defeat a string prefix.
      [ "$(cd "$wt" 2>/dev/null && pwd -P)" = "$CURWT" ] && continue
      touched=$(find "$wt" -newer "$MARKER" -type f -not -path '*/.git/*' \
        -print -quit 2>/dev/null)
      [ -n "$touched" ] && printf 'worktree\t%s\tworktree\tyes\n' "$wt"
    done
fi

find "$PROJ/memory" -name '*.md' -newer "$MARKER" 2>/dev/null |
  emit memory 'memory file, report only' no
find "$HOME/.claude/plans" -name '*.md' -newer "$MARKER" 2>/dev/null |
  emit plans 'plan file' yes
[ -n "$SESSION" ] &&
  find /private/tmp/claude-*/"$SAN/$SESSION/scratchpad" -type f \
    -newer "$MARKER" 2>/dev/null | emit scratchpad 'scratchpad file' yes
scan_vault

exit 0
