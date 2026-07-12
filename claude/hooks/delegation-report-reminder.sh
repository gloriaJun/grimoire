#!/usr/bin/env bash
# PostToolUse(Task|Agent): fires when an agent tool call returns; feeds back
# via stderr + exit 2 (same convention as definition-check.sh) so the turn's
# user-facing text includes the delegation report required by claude-only.md
# "Model visibility". Duplicate reminders on parallel dispatches are
# accepted noise.
set -euo pipefail

input="$(cat)"
tool="$(printf '%s' "$input" | jq -r '.tool_name // empty' 2>/dev/null || true)"
# "Task" is the documented subagent tool name; "Agent" is kept defensively
# for harness variants that rename it.
case "$tool" in
  Task|Agent) ;;
  *) exit 0 ;;
esac

{
  echo "delegation-report-reminder: agent tool call returned."
  echo "Include a one-line delegation report in this turn's user-facing text: task summary / actual model used (if inherited, spell out the inherited model name) / reason for delegating (CLAUDE.md AGENT OPERATION, model visibility)."
} >&2
exit 2
