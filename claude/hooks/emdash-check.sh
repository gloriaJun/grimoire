#!/usr/bin/env bash
# PostToolUse(Write|Edit): flag em/en dashes in newly written markdown content
# (hard rule 8: no em dashes in prose, any language).
# Checks only the content being written (not the whole file) so that files
# merely documenting the rule do not re-trigger on unrelated edits.
set -euo pipefail

input="$(cat)"
file="$(printf '%s' "$input" | jq -r '.tool_input.file_path // empty')"
[[ "$file" == *.md ]] || exit 0

content="$(printf '%s' "$input" | jq -r '.tool_input.content // .tool_input.new_string // empty')"
[[ -n "$content" ]] || exit 0

# Match by UTF-8 bytes (em dash e2 80 94, en dash e2 80 93), locale-independent.
hits="$(printf '%s' "$content" | LC_ALL=C grep -nE $'\xe2\x80\x94|\xe2\x80\x93' || true)"
if [[ -n "$hits" ]]; then
  {
    echo "em/en dash written to $file (hard rule 8: no em dashes in prose, any language):"
    printf '%s\n' "$hits" | head -10
    echo "Replace with ' - ' or rewrite the sentence. If this is a deliberate rule-documentation example, leave it and continue."
  } >&2
  exit 2
fi
exit 0
