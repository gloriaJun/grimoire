# Step 5: Execute Cleanup

Only after user confirms.

## Prerequisites

Read `references/protected-paths.md` and double-check every path against the protected list before deletion.

## Process

1. Delete files matching the retention criteria in each selected category.
2. For directories: use `rm -rf` on individual old items, NOT on the parent directory itself.
3. For `C3` (project sessions): delete only `.jsonl` files and UUID-named directories, NEVER `memory/` directories.
4. For `C7` (history.jsonl): create a temp file with recent entries, then replace the original.
5. For `X1` (worktrees): use `git worktree remove` if inside a git repo, otherwise `rm -rf`.

## Output Format

Report results as each category is cleaned:

```
[C9] Shell snapshots: deleted 128 files, freed 28.5M
[X1] Worktrees: removed 3 worktrees, freed 520.0M
...

Cleanup complete. Total freed: 548.5M
```
