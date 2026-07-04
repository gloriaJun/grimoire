# Step 3: Set Retention Period

Ask the user how many days of data to keep:

- Default: **30 days** (files older than 30 days are deleted)
- Option: **0 days** (delete everything in selected categories)
- Option: **Custom** number of days

## Special Rules

- `C7` (history.jsonl): Truncate to keep only last N days of entries, do not delete the file entirely.
  - **Timestamp format caveat**: the `timestamp` field in `history.jsonl` is a **Unix milliseconds integer**, NOT an ISO string.
    e.g. `{"timestamp": 1775913377966, ...}` — string comparison fails; convert to integer before comparing.
  - Use the `scripts/truncate-history.sh <days>` script for execution.
- `X1` (worktrees): Always list each worktree with its branch name and last modified date. Ask for confirmation on each one individually, since worktrees may contain uncommitted work.
- `M1` (Memory audit): retention period does NOT apply. Confirm deletion per issue type individually.
- **Preserve flag**: a memory whose frontmatter has `preserve: true` is pinned. Exclude it from every auto-delete path (category, retention period, curation); if deletion is needed, delete only after **individual confirmation** with the user.
