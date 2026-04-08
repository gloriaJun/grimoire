# Step 4: Dry Run (Default)

**Always show a dry-run preview first.** Never delete without showing what will be removed.

For each selected category, list:
- Number of files to be deleted
- Total size to be freed
- Sample file paths (up to 5)

## Output Format

```
=== Dry Run Preview ===

[C9] Shell snapshots: 128 files, 28.5M to free
  ~/.claude/shell-snapshots/abc123.json (2025-06-12)
  ~/.claude/shell-snapshots/def456.json (2025-06-15)
  ... and 126 more

[X1] Worktrees: 3 worktrees to remove, 520.0M to free
  ~/.codex/worktrees/0dc9/ (branch: feature/foo, last modified: 2025-11-03)
  ~/.codex/worktrees/3741/ (branch: fix/bar, last modified: 2025-12-20)
  ~/.codex/worktrees/7006/ (branch: refactor/baz, last modified: 2026-01-15)

Total: 548.5M to be freed

Proceed with cleanup? [y/N]
```
