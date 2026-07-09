#!/usr/bin/env bash
# Fresh-machine bootstrap: reproduce the Claude/Codex environment from this
# repo. Idempotent - safe to re-run; satisfied steps are skipped. External
# installs (marketplaces, plugins, third-party skills) come from external.json.
#
# Usage: bootstrap.sh [--dry-run]
set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
MANIFEST="$REPO_DIR/external.json"

DRY_RUN=0
[[ "${1:-}" == "--dry-run" ]] && DRY_RUN=1

log()  { printf '%s\n' "$*"; }
warn() { printf 'WARN: %s\n' "$*" >&2; }
run() {
  if [[ "$DRY_RUN" -eq 1 ]]; then log "[dry-run] $*"; else "$@"; fi
}

# 1. Tooling. Required tools abort; optional ones only warn.
missing=0
for t in git jq rsync; do
  command -v "$t" >/dev/null 2>&1 || { warn "required tool missing: $t (brew install $t)"; missing=1; }
done
if [[ "$missing" -eq 1 ]]; then
  echo "ABORT: install the required tools first" >&2
  exit 1
fi
for t in mise pnpm fzf gh claude codex; do
  command -v "$t" >/dev/null 2>&1 || warn "optional tool missing: $t"
done

# 2. Git hooks (post-commit -> sync)
run git -C "$REPO_DIR" config core.hooksPath githooks

# 3. Initial sync of both config surfaces
run "$REPO_DIR/sync.sh"
if command -v codex >/dev/null 2>&1; then
  run "$REPO_DIR/codex-sync.sh"
else
  warn "codex CLI missing - codex-sync skipped"
fi

# 4. Codex config.toml from template. Never overwrite an existing one:
#    it holds per-machine values (providers, trusted projects, MCP servers).
if [[ ! -f "$HOME/.codex/config.toml" ]]; then
  run mkdir -p "$HOME/.codex"
  run cp "$REPO_DIR/templates/codex-config.toml.template" "$HOME/.codex/config.toml"
  log "created ~/.codex/config.toml from template - fill the per-machine sections"
fi

# 5. External installs from the manifest
if [[ ! -f "$MANIFEST" ]]; then
  warn "external.json missing - external installs skipped"
  exit 0
fi

if ! command -v claude >/dev/null 2>&1; then
  warn "claude CLI missing - marketplace/plugin installs skipped"
else
  # 5a. Marketplaces: compare manifest sources against registered ones
  #     (source lives nested at .source.repo / .source.url).
  KNOWN="$HOME/.claude/plugins/known_marketplaces.json"
  registered=""
  [[ -f "$KNOWN" ]] && registered="$(jq -r '.[] | .source.repo // .source.url // empty' "$KNOWN" 2>/dev/null)"
  while IFS= read -r src; do
    [[ -n "$src" ]] || continue
    if printf '%s\n' "$registered" | grep -qxF "$src"; then
      log "marketplace ok: $src"
    else
      run claude plugin marketplace add "$src"
    fi
  done < <(jq -r '.marketplaces[]' "$MANIFEST")

  # 5b. Plugins: compare against installed_plugins.json.
  INSTALLED="$HOME/.claude/plugins/installed_plugins.json"
  while IFS= read -r p; do
    [[ -n "$p" ]] || continue
    if [[ -f "$INSTALLED" ]] && jq -e --arg p "$p" '.plugins[$p] // empty' "$INSTALLED" >/dev/null 2>&1; then
      log "plugin ok: $p"
    else
      run claude plugin install "$p"
    fi
  done < <(jq -r '.plugins[]' "$MANIFEST")

  # 5c. Report live entries the manifest does not declare (company or manual
  #     installs) - never touched here, listed so drift stays visible.
  if [[ -f "$KNOWN" ]]; then
    while IFS= read -r extra; do
      [[ -n "$extra" ]] || continue
      jq -e --arg s "$extra" '.marketplaces | index($s)' "$MANIFEST" >/dev/null 2>&1 \
        || log "note: marketplace outside manifest (left as is): $extra"
    done < <(jq -r '.[] | .source.repo // .source.url // empty' "$KNOWN" 2>/dev/null)
  fi

  # 5d. User-scope MCP servers from claude/settings.mcpServers.json.
  #     Claude Code reads them only from ~/.claude.json, and add-json errors
  #     on an existing name, so check first. Entries with disabled:true are
  #     declared-but-off: skipped here. The disabled key is stripped before
  #     install (not part of the Claude MCP schema).
  MCP_SRC="$REPO_DIR/claude/settings.mcpServers.json"
  CLAUDE_JSON="$HOME/.claude.json"
  if [[ -f "$MCP_SRC" ]]; then
    while IFS=$'\t' read -r name json; do
      [[ -n "$name" ]] || continue
      if [[ -f "$CLAUDE_JSON" ]] && jq -e --arg n "$name" '.mcpServers | has($n)' "$CLAUDE_JSON" >/dev/null 2>&1; then
        log "mcp ok: $name"
      else
        run claude mcp add-json --scope user "$name" "$json"
      fi
    done < <(jq -r '.mcpServers // {} | to_entries[] | select(.value.disabled != true) | [.key, (.value | del(.disabled) | tojson)] | @tsv' "$MCP_SRC")
    if [[ -f "$CLAUDE_JSON" ]]; then
      while IFS= read -r extra; do
        [[ -n "$extra" ]] || continue
        jq -e --arg n "$extra" '.mcpServers | has($n)' "$MCP_SRC" >/dev/null 2>&1 \
          || log "note: mcp server outside manifest (left as is): $extra"
      done < <(jq -r '.mcpServers // {} | keys[]' "$CLAUDE_JSON" 2>/dev/null)
    fi
  fi
fi

# 6. Third-party skills installed straight into ~/.claude/skills.
#    Installer target dir is verified after each run because the npx
#    installer's destination semantics are not guaranteed.
while IFS=$'\t' read -r dir repo skill; do
  [[ -n "$dir" ]] || continue
  if [[ -d "$HOME/.claude/skills/$dir" ]]; then
    log "skill ok: $dir"
    continue
  fi
  run npx -y skills add "$repo" --skill "$skill"
  if [[ "$DRY_RUN" -eq 0 && ! -d "$HOME/.claude/skills/$dir" ]]; then
    warn "installer did not create ~/.claude/skills/$dir - check where it installed (project-local .claude/skills?) and move it manually"
  fi
done < <(jq -r '.skills[] | [.dir, .repo, .skill] | @tsv' "$MANIFEST")

log "bootstrap complete. Plugin/skill changes need a new Claude Code session."
