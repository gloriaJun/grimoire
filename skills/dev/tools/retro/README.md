# dev retro

Capture a retrospective + learnings note to the Obsidian vault. Works with or without a devlog.
Combines what used to be separate `retro` and `til` steps into one note.

## Features

- **Devlog-aware** — auto-detects completed tasks and pre-fills context from `<task>-log.md`
- **Confirmation** — asks before running when a matching task is found
- **Standalone mode** — works without a devlog; prompts for task name and description
- **inline execution** — saves to `04_Notes/<scope>/YYYY-MM-DD-<task-name>/retro.md` in the Obsidian vault

## Usage

```
/dev retro
```

## How It Works

```
Entry Check
    │
    ├── task found (completed `<task>-log.md`, or active task before complete)
    │       └── Ask confirmation → yes → Execute with log/devlog context
    │                            → no  → Stop (can run later)
    └── no task found
            └── Standalone mode → ask user for context → Execute
```

### Task Detection

Scans MEMORY.md `## Completed Dev Tasks` / `## Active Dev Tasks`, filtered to the current repo
(main repo root, worktree-safe). Completed tasks point to `<task>-log.md`; the note is built from
its `## 결과` / `## 과정에서 고민한 것` / `## 배운 것` sections.

### State Update

- Completed mode: `state.md` is already gone — append a `회고:` link line to `<task>-log.md`.
- Active mode (before complete): add `retro: <path>` to the memory file `## Artifacts`.

## Requirements

- Obsidian vault at `~/Documents/obsidian-vault/`

## License

MIT
