#!/usr/bin/env bash
# Record that the user approved a definition-file Korean review in chat.
# def-review-gate.sh lets Write/Edit on the recorded paths pass without a
# permission prompt for TTL seconds; every other path still prompts.
# Run ONLY right after an explicit user approval (change flow,
# instructions/references/definition-files.md) - never preemptively.
set -euo pipefail

MARKER="$HOME/.claude/.def-review-approvals"
TTL=300

if [[ $# -lt 1 ]]; then
  echo "usage: def-review-approve.sh <file> [file...]" >&2
  exit 1
fi

# Resolve every argument before writing anything: all-or-nothing.
abs_list=()
for f in "$@"; do
  dir="$(cd "$(dirname "$f")" && pwd)"   # parent must exist; new files allowed
  abs_list+=("$dir/$(basename "$f")")
done

now="$(date +%s)"
tmp="$(mktemp)"
trap 'rm -f "$tmp"' EXIT

# Keep only well-formed, unexpired entries.
if [[ -f "$MARKER" ]]; then
  while IFS=$'\t' read -r ts path; do
    if [[ "$ts" =~ ^[0-9]+$ && -n "$path" ]] && (( now - ts < TTL )); then
      printf '%s\t%s\n' "$ts" "$path" >> "$tmp"
    fi
  done < "$MARKER"
fi

for abs in "${abs_list[@]}"; do
  printf '%s\t%s\n' "$now" "$abs" >> "$tmp"
  echo "approved for ${TTL}s: $abs"
done

mv "$tmp" "$MARKER"
