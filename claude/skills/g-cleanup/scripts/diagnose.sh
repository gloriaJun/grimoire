#!/usr/bin/env bash
# Scans cleanup targets and prints one row per target:
#   ID|Category|Files|Size|Oldest|Newest
# Missing/empty paths print a zero row. A failing target never aborts the
# whole scan (no -e on purpose). macOS (BSD stat/date) only.

CLAUDE="${HOME}/.claude"
CODEX="${HOME}/.codex"

emit() { # emit <id> <label> <stats:"mtime size" lines>
  local id="$1" label="$2" stats="$3"
  if [ -z "$stats" ]; then
    echo "${id}|${label}|0|0B|-|-"
    return
  fi
  local count bytes oldest newest size
  count=$(printf '%s\n' "$stats" | wc -l | tr -d ' ')
  bytes=$(printf '%s\n' "$stats" | awk '{s+=$2} END {print s+0}')
  oldest=$(date -r "$(printf '%s\n' "$stats" | awk '{print $1}' | sort -n | head -1)" '+%Y-%m-%d' 2>/dev/null || echo '-')
  newest=$(date -r "$(printf '%s\n' "$stats" | awk '{print $1}' | sort -n | tail -1)" '+%Y-%m-%d' 2>/dev/null || echo '-')
  size=$(awk -v b="$bytes" 'BEGIN{split("B KB MB GB TB",u," "); i=1; while (b>=1024 && i<5) {b/=1024; i++} printf "%.1f%s", b, u[i]}')
  echo "${id}|${label}|${count}|${size}|${oldest}|${newest}"
}

scan() { # scan <id> <label> <path...>
  local id="$1" label="$2"; shift 2
  emit "$id" "$label" "$(find "$@" -type f -print0 2>/dev/null | xargs -0 stat -f '%m %z' 2>/dev/null)"
}

# Claude Code
scan C1  "Sessions"         "${CLAUDE}/sessions" "${CLAUDE}/session-env"
scan C2  "Transcripts"      "${CLAUDE}/transcripts"
emit C3  "Project sessions" "$(find "${CLAUDE}/projects" -type f -name '*.jsonl' -not -path '*/memory/*' -print0 2>/dev/null | xargs -0 stat -f '%m %z' 2>/dev/null)"
scan C4  "Backups"          "${CLAUDE}/backups"
scan C5  "Cache"            "${CLAUDE}/cache" "${CLAUDE}/paste-cache"
scan C6  "Logs"             "${CLAUDE}/logs" "${CLAUDE}/debug"
scan C7  "History"          "${CLAUDE}/history.jsonl"
scan C8  "File history"     "${CLAUDE}/file-history"
scan C9  "Shell snapshots"  "${CLAUDE}/shell-snapshots"
scan C10 "Todos/Plans"      "${CLAUDE}/todos" "${CLAUDE}/plans" "${CLAUDE}/tasks"
scan C11 "Stats"            "${CLAUDE}/usage-data" "${CLAUDE}/statsig"

# Codex CLI
scan X1  "Worktrees"        "${CODEX}/worktrees"
scan X2  "Sessions"         "${CODEX}/sessions" "${CODEX}/archived_sessions"
scan X3  "Temp files"       "${CODEX}/.tmp" "${CODEX}/tmp"
scan X4  "Logs"             "${CODEX}/log"
scan X5  "Shell snapshots"  "${CODEX}/shell_snapshots"
scan X6  "Database"         "${CODEX}/sqlite"

# /tmp
scan T1  "Claude temp"      /tmp/claude-*
