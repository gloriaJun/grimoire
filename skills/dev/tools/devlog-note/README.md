# devlog-note — Quick Devlog Note Writing

Write a note to the active devlog without running the full dev planning workflow.

## What it does

Appends a structured entry to the active task's devlog directory based on content type:

| Category | Target file | When to use |
|----------|------------|-------------|
| `decision` | `history.md` → Decision Log | Architecture choice, trade-off, design reason |
| `blocker` | `history.md` → Decision Log | Unresolved dependency, blocked on information |
| `troubleshooting` | `history.md` → Decision Log | Bug root cause, error resolution |
| `progress` | `notes.md` | Progress update, completed item |
| `note` | `notes.md` | General memo, idea, reference |

## Usage

```
/dev devlog-note
devlogs에 기록해줘
devlog에 남겨줘
오늘 작업 기록해줘
작업 노트 써줘
이거 기록해줘
```

## How it works

1. Resolves the active devlog task for the current repo via `MEMORY.md`
2. Determines content from: message text → recent conversation context → user prompt
3. Classifies content type automatically (can be overridden)
4. Appends to `history.md` or `notes.md` in the devlog task directory

## Relationship to MEMORY.md

MEMORY.md is used **only for task resolution** — finding which devlog task to write to.
This tool writes to devlog folder files on disk (`history.md` or `notes.md`).
It does not write to or modify MEMORY.md itself.
