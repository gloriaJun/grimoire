#!/usr/bin/env bash
# PreToolUse(Write|Edit): review gate for AI definition files.
# Emits permissionDecision "ask" so every definition-file write raises a user
# approval prompt, even in acceptEdits mode. Mechanical backstop for the
# definition-file change flow (instructions/references/definition-files.md):
# present the changed parts in Korean in chat, get confirmation, then save in
# English.
set -euo pipefail

input="$(cat)"
file="$(printf '%s' "$input" | jq -r '.tool_input.file_path // empty')"
[[ -n "$file" ]] || exit 0

# Definition-file scope. Non-matches pass silently (exit 0).
case "$file" in
  # Definition filenames anywhere.
  */CLAUDE.md|*/AGENTS.md|*/SKILL.md) ;;
  # Claude/Codex config trees (unambiguous).
  */.claude/agents/*|*/.claude/commands/*|*/.claude/instructions/*|*/.claude/hooks/*|*/.claude/skills/*|*/.codex/*) ;;
  # claude/ source trees (grimoire layout); extension-limited to cut false
  # positives from unrelated project dirs named claude/.
  */claude/agents/*.md|*/claude/commands/*.md|*/claude/instructions/*.md|*/claude/hooks/*.sh|*/claude/skills/*.md|*/claude/skills/*.sh|*/claude/skills/*.json|*/claude/claude-only.md|*/claude/settings.*.json) ;;
  *) exit 0 ;;
esac

reason="Definition file write. Confirm the changed parts were presented in Korean in chat and approved, and that the file content is English (change flow, instructions/references/definition-files.md)."
jq -cn --arg reason "$reason" \
  '{hookSpecificOutput:{hookEventName:"PreToolUse",permissionDecision:"ask",permissionDecisionReason:$reason}}'
exit 0
