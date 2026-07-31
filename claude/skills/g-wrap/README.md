# g-wrap

Session wrap-up skill: inventory this session's artifacts, decide once whether
a vault record is needed, then remove the leftovers the user confirms.

## Features

- One fixed wrap-up shape instead of a per-session improvisation: git state,
  artifact inventory, record decision, guarded teardown.
- Covers the leftover surfaces in one pass: Claude-created vault notes,
  `~/.claude/plans/`, scratchpad files, untracked files, worktrees, plus
  servers and branches noted from the conversation. Memory files are
  reported, never deleted here.
- Owns the record-declined rollback: when the record is unnecessary, notes
  already written by Claude are removed, never rewritten or relocated.
- Guards teardown: the current worktree, the current branch, and anything
  holding uncommitted or unpushed work are skipped and reported.

## Usage

```
/g-wrap          # inventory, decide, clean
/g-wrap help     # print the sub-command table
```

Natural language also triggers it: "세션 마무리", "마무리하자", "세션 종료".

## How It Works

1. `scripts/collect-artifacts.sh` computes the session window from the newest
   transcript for the current working directory (clamped to at most 24h, 12h
   fallback) and prints one TSV row per artifact, each marked deletable or
   report-only. `collect-artifacts.sh vault` rescans the vault surface alone.
2. The record gate fires only when the session produced a diagnosed root
   cause, a multi-source conclusion, or a reasoned decision. Otherwise the
   record is treated as unnecessary with no question asked. When the user
   wants a record, g-vault-log is invoked and its notes are locked to keep.
3. Every deletable row carries a default action; the user picks per item, and
   vault rows are confirmed one row at a time.
4. Execution runs files, then servers, then worktrees, then branches, and
   reports a result table including every skip and failure.

macOS only: the collector uses BSD `stat -f %B` and `date -r`. Artifacts
outside the session window belong to `/g-cleanup`.
