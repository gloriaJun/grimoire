#!/usr/bin/env bash
# PreToolUse(Bash) guard for `gh pr create`.
# Enforces the mechanically checkable rules from
# ~/.claude/instructions/references/templates/pr.md:
#   - PRs are always created as draft (--draft)
#   - base branch must be explicit (--base)
# Everything else in the procedure is conversational and stays instruction-level.
set -euo pipefail

input="$(cat)"
cmd="$(printf '%s' "$input" | jq -r '.tool_input.command // empty')"

# Only inspect gh pr create invocations; let help lookups through.
printf '%s' "$cmd" | grep -qE 'gh[[:space:]]+pr[[:space:]]+create' || exit 0
printf '%s' "$cmd" | grep -qE -- '--help' && exit 0

missing=""
printf '%s' "$cmd" | grep -qE -- '(^|[[:space:]])(--draft|-d)([[:space:]=]|$)' \
  || missing="${missing}  - --draft: PRs are always created as draft\n"
printf '%s' "$cmd" | grep -qE -- '(^|[[:space:]])(--base|-B)([[:space:]=]|$)' \
  || missing="${missing}  - --base: confirm the base branch and pass it explicitly\n"

if [[ -n "$missing" ]]; then
  {
    echo "BLOCKED: gh pr create is missing required flags:"
    printf '%b' "$missing"
    echo "Follow the registration procedure in ~/.claude/instructions/references/templates/pr.md."
  } >&2
  exit 2
fi
exit 0
