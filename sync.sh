#!/usr/bin/env bash
# One-way sync: <repo>/claude/ -> ~/.claude/
#
# Ownership rules:
#   - CLAUDE.md                       : single managed file at ~/.claude root
#   - instructions/, hooks/, agents/  : wholly owned -> full mirror (rsync --delete)
#   - skills/                         : shared namespace. Only "g-*" entries are
#                                       managed here. "l-*" belongs to the company
#                                       repo; anything else is unmanaged (warn only).
#
# Usage: sync.sh [--dry-run]

set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SRC="$REPO_DIR/claude"
DEST="$HOME/.claude"

OWNED_DIRS=(instructions hooks agents)
SKILL_PREFIX="g-"

DRY_RUN=0
if [[ "${1:-}" == "--dry-run" ]]; then
  DRY_RUN=1
fi

RSYNC_OPTS=(-a --delete)
if [[ "$DRY_RUN" -eq 1 ]]; then
  RSYNC_OPTS+=(-n)
fi

log()  { printf '%s\n' "$*"; }
warn() { printf 'WARN: %s\n' "$*" >&2; }
run() {
  if [[ "$DRY_RUN" -eq 1 ]]; then
    log "[dry-run] $*"
  else
    "$@"
  fi
}

# Guards: never operate outside the expected destination
if [[ -z "${HOME:-}" || "$DEST" != "$HOME/.claude" ]]; then
  echo "ABORT: unexpected DEST '$DEST'" >&2
  exit 1
fi
if [[ ! -d "$SRC" ]]; then
  echo "ABORT: source '$SRC' not found" >&2
  exit 1
fi

run mkdir -p "$DEST"

# Remove a legacy symlink at a managed destination path so we never
# write through it into another repo (symlink-era leftovers).
clear_symlink() {
  local path="$1"
  if [[ -L "$path" ]]; then
    warn "replacing legacy symlink: $path -> $(readlink "$path")"
    run rm "$path"
  fi
}

# 1. CLAUDE.md (single managed root file)
clear_symlink "$DEST/CLAUDE.md"
run cp "$SRC/CLAUDE.md" "$DEST/CLAUDE.md"

# 2. Wholly owned dirs: full mirror. A top-level dir that disappeared from
#    the repo is NOT auto-deleted (likely a mistake) - warn instead.
for d in "${OWNED_DIRS[@]}"; do
  if [[ -d "$SRC/$d" ]]; then
    clear_symlink "$DEST/$d"
    run rsync "${RSYNC_OPTS[@]}" "$SRC/$d/" "$DEST/$d/"
  elif [[ -e "$DEST/$d" ]]; then
    warn "owned dir '$d' exists in $DEST but not in repo - remove it manually if intended"
  fi
done

# 3. Skills: install/update g-* entries (per-entry mirror)
if [[ -d "$SRC/skills" ]]; then
  run mkdir -p "$DEST/skills"
  for src_skill in "$SRC/skills/$SKILL_PREFIX"*/; do
    [[ -d "$src_skill" ]] || continue
    name="$(basename "$src_skill")"
    clear_symlink "$DEST/skills/$name"
    run rsync "${RSYNC_OPTS[@]}" "$src_skill" "$DEST/skills/$name/"
  done
fi

# 4. Skills: orphan cleanup, strictly scoped to our prefix
if [[ -d "$DEST/skills" ]]; then
  for dest_skill in "$DEST/skills/$SKILL_PREFIX"*/; do
    [[ -d "$dest_skill" ]] || continue
    name="$(basename "$dest_skill")"
    # belt-and-suspenders: only ever delete inside skills/ with our prefix
    [[ "$name" == "$SKILL_PREFIX"* ]] || continue
    if [[ ! -d "$SRC/skills/$name" ]]; then
      log "removing orphan skill: skills/$name"
      run rm -rf "${DEST:?}/skills/${name:?}"
    fi
  done

  # 5. Report unmanaged entries (no g-/l- prefix)
  for entry in "$DEST/skills/"*/; do
    [[ -d "$entry" ]] || continue
    name="$(basename "$entry")"
    if [[ "$name" != g-* && "$name" != l-* ]]; then
      warn "unmanaged skill (no g-/l- prefix): skills/$name"
    fi
  done
fi

# 6. Hooks config: merge the repo-managed "hooks" key into live settings.json.
#    Only .hooks is owned; runtime keys (enabledPlugins, marketplaces, ...) are
#    preserved. settings.hooks.json itself is never copied to $DEST.
HOOKS_SRC="$SRC/settings.hooks.json"
SETTINGS="$DEST/settings.json"
if [[ -f "$HOOKS_SRC" ]]; then
  if ! command -v jq >/dev/null 2>&1; then
    warn "jq not found - hooks config NOT merged into settings.json"
  elif [[ "$DRY_RUN" -eq 1 ]]; then
    log "[dry-run] merge $HOOKS_SRC -> $SETTINGS (.hooks key only)"
  else
    tmp="$(mktemp)"
    if [[ -f "$SETTINGS" ]]; then
      jq --slurpfile h "$HOOKS_SRC" '.hooks = $h[0]' "$SETTINGS" > "$tmp"
    else
      jq -n --slurpfile h "$HOOKS_SRC" '{hooks: $h[0]}' > "$tmp"
    fi
    mv "$tmp" "$SETTINGS"
    log "merged hooks config into settings.json"
  fi
fi

if [[ "$DRY_RUN" -eq 1 ]]; then
  log "sync dry-run complete: $SRC -> $DEST (nothing written)"
else
  log "sync complete: $SRC -> $DEST"
fi
