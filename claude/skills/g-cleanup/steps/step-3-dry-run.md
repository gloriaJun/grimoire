# Step 3: Dry Run (Mandatory)

Always show this preview. Never delete without it.

For each selected category, list:

- Number of files to be deleted
- Total size to be freed
- Sample file paths (up to 5)

## Size Calculation

Collect the file list first, then sum once. Piping a large file count through `xargs du -ch` double-counts (xargs splits into multiple du invocations, each printing its own total). Use:

```bash
FILES=$(find <path> -type f -mtime +<days> 2>/dev/null)
COUNT=$(echo "$FILES" | wc -l | tr -d ' ')
SIZE=$(echo "$FILES" | tr '\n' '\0' | xargs -0 stat -f '%z' 2>/dev/null | awk '{s+=$1} END {printf "%.1fMB", s/1048576}')
```

`$FILES` empty: report the category as `0 files, nothing to delete` and skip it in Step 4.

## Output Format

```
=== Dry Run Preview ===

[C9] Shell snapshots: 128 files, 28.5MB to free
  ~/.claude/shell-snapshots/abc123.json (2025-06-12)
  ... and 126 more

[C3] Project sessions: 465 files, 214MB to free
  ~/.claude/projects/-Users-...-WorkspaceA-repo/*.jsonl
  ... and 463 more
  note: empty project dirs without memory/ are removed too

[C7] History: 1,035 entries to drop, 603 entries to keep
  executed via scripts/truncate-history.sh <days>

[X1] Worktrees: 3 candidates, 520.0MB
  ~/.codex/worktrees/0dc9/ (branch: feature/foo, last modified: 2025-11-03)
  each requires individual confirmation

[M1] Memory issues: 2 items
  ORPHANED     WorkspaceA-old-repo -> /Users/.../WorkspaceA/old-repo
  BROKEN_LINK  WorkspaceB-app      -> some-note.md

Total: 548.5MB to be freed

Proceed with cleanup? [y/N]
```

Answer is not an explicit yes: abort without deleting anything. Yes: load `steps/step-4-execute.md`.
