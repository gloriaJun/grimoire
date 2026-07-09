# Step 1: Diagnose

## Prerequisites

Read `references/protected-paths.md` and `references/cleanup-targets.md` first.

## Part A: Disk Usage

Run exactly:

```bash
bash "$HOME/.claude/skills/g-cleanup/scripts/diagnose.sh"
```

Output: one `ID|Category|Files|Size|Oldest|Newest` line per target.

- Render as a table grouped by section (C* = Claude Code, X* = Codex CLI, T* = /tmp), sorted by size descending within each group, with a grand total line at the bottom.
- Zero rows (`0|0B`) are shown as-is; they mean nothing to clean.
- Script missing or exit code non-zero: print the exact error and STOP the skill. Do not improvise per-directory commands.

## Part B: Memory Audit

Run exactly:

```bash
bash "$HOME/.claude/skills/g-cleanup/scripts/audit-memory.sh"
```

Output lines: `TYPE|PROJECT_DIR|DETAIL` where TYPE is ORPHANED, BROKEN_LINK, DUPLICATE, or OK.

- Show issues grouped by type; hide OK lines unless the user asks for the full list.
- Only OK lines (or no output): print `✓ 메모리 이상 없음` and continue.
- Exit code non-zero: report the error, mark M1 as unavailable for this run, and continue to Step 2 (disk cleanup does not depend on the memory audit).

## Output Format

```
=== Claude Code & Codex Cleanup Diagnostic ===

Claude Code (~/.claude/)
  ID   Category           Files   Size     Oldest       Newest
  C9   Shell snapshots      142   30.0MB   2025-06-12   2026-04-05
  C3   Project sessions      11   12.0MB   2025-09-24   2026-04-06
  ...

Codex CLI (~/.codex/)
  ID   Category           Files   Size     Oldest       Newest
  X1   Worktrees              8  847.0MB   2025-11-03   2026-03-15
  ...

/tmp/
  ID   Category           Files   Size     Oldest       Newest
  T1   Claude temp           37    1.2MB   2026-03-20   2026-07-01
  ...

Total: 952.3MB across N non-empty categories

=== Memory Audit (M1) ===

  ORPHANED     WorkspaceA-old-repo    -> /Users/.../WorkspaceA/old-repo (path gone)
  BROKEN_LINK  WorkspaceB-app         -> some-note.md (file missing)
  DUPLICATE    WorkspaceA-old-repo    -> same repo as WorkspaceB-app
```

After both parts, load `steps/step-2-scope.md`.
