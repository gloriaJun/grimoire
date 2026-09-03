#!/usr/bin/env bash
# PostToolUse(Write|Edit): flag comment blocks over 3 lines in newly written
# code (the per-block cap in tech-stack.md). Checks only the content being
# written, so a file holding older verbose comments does not re-trigger.
set -euo pipefail

input="$(cat)"
file="$(printf '%s' "$input" | jq -r '.tool_input.file_path // empty')"
case "$file" in
  *.ts|*.tsx|*.js|*.jsx|*.mjs|*.cjs|*.vue|*.svelte) ;;
  *) exit 0 ;;
esac

content="$(printf '%s' "$input" | jq -r '.tool_input.content // .tool_input.new_string // empty')"
[[ -n "$content" ]] || exit 0

hits="$(printf '%s' "$content" | awk '
  /^[[:space:]]*(\/\/|\*|\/\*)/ { n++; next }
  { if (n>3) print n" line comment block ending at line "NR-1; n=0 }
  END { if (n>3) print n" line comment block at end of content" }
')"

if [[ -n "$hits" ]]; then
  {
    echo "comment block over 3 lines written to $file (tech-stack.md: 1-3 lines per block):"
    printf '%s\n' "$hits" | head -10
    echo "Cut it to 3 lines or delete it. Comment only what the code cannot say."
  } >&2
  exit 2
fi
exit 0
