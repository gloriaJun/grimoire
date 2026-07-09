# Step 2: Scope (Targets + Retention)

## Select targets

Ask the user to choose one:

1. **All** - every target whose Step 1 row has Files > 0
2. **By category** - specific IDs, comma-separated (e.g. `C9, X1, X2`)
3. **Cancel** - print `정리를 취소했습니다.` and end the skill immediately

Unknown IDs in a "By category" answer: list the invalid IDs and re-ask once. Still invalid: cancel.

## Set retention

Ask how many days of data to keep. Files strictly older (mtime) than N days are deletion candidates.

- Default: **30**
- **0** = delete everything in the selected categories
- Any other non-negative integer is accepted. Invalid input: re-ask once, then fall back to 30 and say so.

## Special Rules

- **C7 history.jsonl**: truncated, never deleted. The `timestamp` field is a Unix milliseconds integer, NOT an ISO string (e.g. `{"timestamp": 1775913377966}`); string comparison silently fails. Always use `scripts/truncate-history.sh <days>`.
- **X1 worktrees**: retention is only a pre-filter. Each worktree is listed with branch name and last-modified date and confirmed individually in Step 3/4.
- **M1 memory**: retention does not apply. Every issue is confirmed per item in Step 4.
- **Preserve flag**: a memory file whose frontmatter has `preserve: true` is pinned. Exclude it from every automatic deletion path; deleting it requires individual user confirmation.

Then load `steps/step-3-dry-run.md`.
