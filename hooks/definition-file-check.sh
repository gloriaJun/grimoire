#!/usr/bin/env bash
# PostToolUse hook (Write|Edit): definition-file guard.
# Advisory check for token budget (instructions/references/token-budget.md) and
# the English-only convention (instructions/references/skill-authoring.md)
# on skill / agent / instruction definition files.
set -u

command -v jq >/dev/null 2>&1 || exit 0
input=$(cat)
file=$(printf '%s' "$input" | jq -r '.tool_input.file_path // empty')
[ -n "$file" ] && [ -f "$file" ] || exit 0

# Scope: markdown definition files only
case "$file" in
  *.md) ;;
  *) exit 0 ;;
esac
case "$file" in
  */memory/*) exit 0 ;;  # memory files are out of scope
esac
case "$file" in
  */skills/*|*/agents/*|*/instructions/*) ;;
  */claude/CLAUDE.md|*/.claude/CLAUDE.md) ;;  # global entry-point CLAUDE.md only
  *) exit 0 ;;
esac

chars=$(wc -c < "$file" | tr -d ' ')
tokens=$((chars / 4))

# Budget tiers per token-budget.md
case "$file" in
  */instructions/references/*) budget=1000 ;;
  */instructions/*)            budget=500 ;;
  */SKILL.md)                  budget=750 ;;
  */agents/*)                  budget=500 ;;
  *CLAUDE.md)                  budget=500 ;;
  *)                           budget=1500 ;;  # steps/, tools/, shared/ files
esac

msgs=""
if [ "$tokens" -gt "$budget" ]; then
  msgs="Token budget: ~${tokens} tok vs ~${budget} tok ceiling (token-budget.md). Compress, split, or justify the overage."
fi

# English-only check: count Hangul outside YAML frontmatter, excluding
# fenced code blocks (user-facing output templates stay Korean) and quoted
# spans ("...", `...`) — Korean trigger phrases must stay Korean to match
# Korean user input and are allowed anywhere.
# Frontmatter is recognized only when line 1 is `---`; body `---` rules are not delimiters.
body=$(awk 'NR==1 && /^---[ \t]*$/{fm=1; next} fm==1 && /^---[ \t]*$/{fm=2; next} fm!=1' "$file" \
  | awk 'BEGIN{cb=0} /^[ \t]*```/{cb=!cb; next} !cb')
hangul=$(printf '%s' "$body" | perl -CSD -pe 's/"[^"]*"//g; s/`[^`]*`//g' \
  | perl -CSD -ne '$c += () = /[\x{AC00}-\x{D7A3}]/g; END{print $c+0}')
if [ "${hangul:-0}" -gt 20 ]; then
  msgs="$msgs Definition files must be English-only (skill-authoring.md): found ${hangul} Hangul chars outside frontmatter."
fi

[ -z "$msgs" ] && exit 0
jq -n --arg ctx "[definition-file-check] $msgs If skill-authoring.md and token-budget.md are not loaded in this session, load them and re-verify this file." \
  '{hookSpecificOutput:{hookEventName:"PostToolUse",additionalContext:$ctx}}'
