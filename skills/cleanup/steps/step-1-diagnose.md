# Step 1: Diagnose

Run disk usage analysis and display a summary table.

## Prerequisites

Read the following reference files before running diagnostics:
- `references/protected-paths.md` — paths to never touch
- `references/cleanup-targets.md` — target IDs, paths, and descriptions

## Process

For each target in cleanup-targets.md, show:
- **Category** name and ID
- **File count** in the directory
- **Total size** (human-readable)
- **Oldest file** date
- **Newest file** date

Sort by size descending. Show grand total at the bottom.

## Output Format

```
=== Claude Code & Codex Cleanup Diagnostic ===

Claude Code (~/.claude/)
  ID   Category           Files   Size     Oldest       Newest
  C9   Shell snapshots      142   30.0M    2025-06-12   2026-04-05
  C3   Project sessions      11   12.0M    2025-09-24   2026-04-06
  C8   File history         320    9.4M    2025-08-01   2026-04-06
  ...

Codex CLI (~/.codex/)
  ID   Category           Files   Size     Oldest       Newest
  X1   Worktrees              8  847.0M    2025-11-03   2026-03-15
  X2   Sessions              57   48.0M    2025-10-01   2026-04-03
  ...

/tmp/
  ID   Category           Files   Size     Oldest       Newest
  T1   Reports                3    1.2M    2026-03-20   2026-04-01
  ...

Total: 952.3M across 6 categories
```

After displaying the table, proceed to Step 2.
