# Step 3: Set Retention Period

Ask the user how many days of data to keep:

- Default: **30 days** (files older than 30 days are deleted)
- Option: **0 days** (delete everything in selected categories)
- Option: **Custom** number of days

## Special Rules

- `C7` (history.jsonl): Truncate to keep only last N days of entries, do not delete the file entirely.
- `X1` (worktrees): Always list each worktree with its branch name and last modified date. Ask for confirmation on each one individually, since worktrees may contain uncommitted work.
