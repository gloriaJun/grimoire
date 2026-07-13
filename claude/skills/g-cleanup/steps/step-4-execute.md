# Step 4: Execute Cleanup

Only after the user confirmed the Step 3 preview.

## Prerequisites

Re-check every path against `references/protected-paths.md` before deletion.

## Error rule

Any delete command exiting non-zero: STOP immediately. Report the failed command, its stderr, and the categories already completed. Do not continue to remaining categories.

## Process

1. Delete files matching the retention criteria in each selected category.
2. Directories: `rm -rf` individual old items only, never the parent directory itself.
3. **C3 project sessions**: delete only `.jsonl` files, never `memory/` dirs; then remove empty project dirs that have no `memory/`:

   ```bash
   find ~/.claude/projects -name "*.jsonl" -not -path "*/memory/*" -mtime +<days> | xargs rm -f
   find ~/.claude/projects -mindepth 2 -type d -empty -not -name "memory" -delete 2>/dev/null
   find ~/.claude/projects -mindepth 1 -maxdepth 1 -type d | while read dir; do
     [ ! -d "$dir/memory" ] && [ -z "$(ls -A "$dir" 2>/dev/null)" ] && rm -rf "$dir"
   done
   ```

4. **C7 history**: use the script, never inline the truncation logic:

   ```bash
   bash ~/.claude/skills/g-cleanup/scripts/truncate-history.sh <days>
   ```

5. **M1 memory**: re-run `scripts/audit-memory.sh`, then per issue:
   - **Preserve guard (first)**: any file in a deletion-target `memory/` dir with `preserve: true` frontmatter blocks auto-delete; confirm individually.
   - `ORPHANED`: delete the whole `memory/` dir (no live project).
   - `BROKEN_LINK`: edit MEMORY.md to drop the dead entry (edit, not delete).
   - `DUPLICATE`: ask which to keep, delete the other.
6. **X1 worktrees**: `git worktree remove <path>` when it is a valid worktree; fall back to `rm -rf <path>` only when that fails with "not a working tree".

## Output Format

```
[C9] Shell snapshots: deleted 128 files, freed 28.5MB
[C3] Project sessions: deleted 465 files + 3 empty dirs, freed 214MB
[C7] History: truncated (kept=603, dropped=1035)
[M1] Memory: removed 1 orphaned dir, fixed 1 broken link
[X1] Worktrees: removed 2 of 3 (1 declined), freed 400.0MB

Cleanup complete. Total freed: 548.5MB
```
