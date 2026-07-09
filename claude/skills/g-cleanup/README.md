# g-cleanup

Diagnose and clean up old Claude Code sessions, Codex CLI sessions, logs, caches, and temporary files. Always performs a dry-run preview before any destructive action.

## Features

- **Disk Usage Diagnosis** - `scripts/diagnose.sh` scans every target and prints count/size/oldest/newest per category
- **Memory Audit** - detects orphaned project paths, broken MEMORY.md links, and duplicate memory dirs from renamed projects
- **Mandatory Dry Run** - preview of everything to be deleted; never skippable
- **Protected Paths** - enforced deny-list; `projects/*/memory/` is never deleted blindly
- **Smart Truncation** - `history.jsonl` is truncated, not deleted (Unix ms timestamp aware)
- **Worktree Safety** - each worktree is confirmed individually (may hold uncommitted work)
- **Fail-Safe Execution** - any failing delete command stops the run and reports what completed

## Usage

```
/g-cleanup
```

## How It Works

```
/g-cleanup
  -> Step 1: diagnose (scripts/diagnose.sh) + memory audit (scripts/audit-memory.sh)
  -> Step 2: select targets (all / by ID / cancel) + retention days (default 30)
  -> Step 3: dry-run preview (mandatory)
  -> user confirms
  -> Step 4: execute, report freed space
```

## Scripts

| Script | Purpose |
|---|---|
| `scripts/diagnose.sh` | Per-target `ID\|Category\|Files\|Size\|Oldest\|Newest` rows |
| `scripts/audit-memory.sh` | Scan `projects/*/memory/` for orphaned/broken/duplicate entries |
| `scripts/truncate-history.sh <days>` | Truncate `history.jsonl` keeping last N days |
