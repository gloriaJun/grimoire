#!/usr/bin/env bash
# PostToolUse(Write|Edit): mechanical floor for definition files.
# Enforces the checkable rules from token-budget.md and skill-authoring.md.
# Non-mechanical rules (orchestrator quality, persona fit) stay instruction-level.
set -euo pipefail

input="$(cat)"
file="$(printf '%s' "$input" | jq -r '.tool_input.file_path // empty')"
[[ -n "$file" ]] || exit 0

# Scope and per-type budgets (chars; tokens ~= chars/4). Non-matches pass.
# Order matters: templates/ must match before the generic references/ pattern.
case "$file" in
  */claude/CLAUDE.md|"$HOME/.claude/CLAUDE.md")   budget=14000; type="CLAUDE.md" ;;
  */instructions/shared/*.md)                     budget=5000;  type="shared-fragment" ;;
  */claude/claude-only.md)                        budget=5000;  type="claude-only" ;;
  */instructions/references/templates/*.md)       budget=9000;  type="template" ;;
  */instructions/references/*.md)                 budget=5000;  type="reference" ;;
  */skills/*/SKILL.md)                            budget=3000;  type="SKILL.md" ;;
  */skills/*/steps/*.md)                          budget=6000;  type="step" ;;
  */agents/*.md)                                  budget=2000;  type="agent" ;;
  *) exit 0 ;;
esac
[[ -f "$file" ]] || exit 0

problems=""

size="$(wc -c < "$file" | tr -d ' ')"
if (( size > budget )); then
  problems+="- size ${size} chars > budget ${budget} for ${type}. Split or trim per instructions/references/token-budget.md, or justify the overage in the commit body.\n"
fi

# English-only policy. Hangul is allowed only as quoted examples or template
# skeleton labels inside code fences - verify each flagged line against that
# exception before dismissing.
hangul="$(perl -CSD -ne 'print "$.:$_" if /\p{Hangul}/' "$file" 2>/dev/null | head -5 || true)"
if [[ -n "$hangul" ]]; then
  problems+="- Hangul found (English-only policy; allowed only as quoted examples or fenced template labels):\n${hangul}\n"
fi

if [[ "$type" == "SKILL.md" ]]; then
  grep -q '^```mermaid' "$file" \
    || problems+="- no mermaid diagram (required by instructions/references/skill-authoring.md).\n"
  [[ -f "$(dirname "$file")/README.md" ]] \
    || problems+="- no README.md next to SKILL.md (required by instructions/references/skill-authoring.md).\n"
fi

if [[ -n "$problems" ]]; then
  {
    echo "definition-check: $file"
    printf '%b' "$problems"
    echo "Fix now, or state the justification explicitly before proceeding."
  } >&2
  exit 2
fi
exit 0
