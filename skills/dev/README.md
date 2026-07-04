# dev

Unified development workflow skill — single entry point for the full lifecycle from ideation to documentation.

## Features

- **Planning lifecycle** — idea → plan → design → build → complete (devlog-tracked, cross-session)
- **Utility tools** — test, refactor, troubleshoot, review, retro, devlog-note, setup (devlog optional)
- **State persistence** — memory files in `~/.claude/projects/` enable seamless session resumption
- **Review** — Plannotator for planning artifacts; `code-review` skill + frontend-reviewer for build diffs
- **Natural language routing** — refactoring and debugging requests auto-routed without `/dev` prefix
- **insight integration** — post-completion grimoire improvement suggestions via isolated agent

## Usage

```
/dev                    # active devlog check → resume or entry menu
/dev idea               # ideation → brainstorm.md
/dev plan               # requirements → PRD
/dev design             # PRD → architecture.md + wireframe
/dev build              # implement one feature (mini-design + TDD/Test-After/Skip)
/dev complete           # wrap-up: consolidate into <task>-log.md, keep PRD/architecture
/dev retro              # retrospective + learnings → vault note
/dev review             # code review (PR URL or local diff)
/dev test               # test code generation
/dev refactor           # code restructuring
/dev troubleshoot       # debug errors and stack traces
/dev devlog-note        # write a quick note to the active devlog
/dev setup              # configure lint, prettier, type-check, husky
/dev status             # show all devlog task statuses
/dev help               # show this command list
```

## How It Works

```
/dev [sub-command]
    │
    ├── no sub-command → Active devlog check → resume or entry menu
    ├── planning sub-command → steps/<name>.md (devlog-tracked)
    └── utility sub-command → tools/<name>/SKILL.md (devlog optional)
```

### Planning Lifecycle

| Step | Sub-command | Output |
|------|-------------|--------|
| 1 | `idea` | brainstorm.md |
| 2 | `plan` | PRD |
| 3 | `design` | architecture.md + wireframe.html |
| 4 | `build` | implemented feature (repeated per feature) |
| 5 | `complete` | wrap-up + insight |

Each `build` session implements one feature via mini-design → TDD/Test-After/Skip → cross-review.
Steps 2–3 use the Plannotator review protocol (`references/review-protocol.md`).

### Devlog

Task state and artifacts live in a task directory under the **main repo's** project memory:
`~/.claude/projects/<project-id>/memory/YYYY-MM-DD-<task-name>/`. The project-id is derived from
the main repo root, so working inside a git worktree still writes to the main repo's memory
(no stray `...-claude-worktrees-*` directories).

While active, the directory holds `state.md`, `history.md`, and artifacts (brainstorm, PRD,
architecture, wireframe). At `/dev complete`, the process files are consolidated into a single
`<task-name>-log.md` (결과 · 과정에서 고민한 것 · 배운 것) and deleted; PRD and architecture are
kept as reference.

### External Dependencies

| Tool | Purpose |
|------|---------|
| Plannotator | Visual review of PRD / architecture |
| `code-review` skill | Build-time diff review |

## Installation

```bash
ln -s /path/to/grimoire/skills/dev ~/.claude/skills/dev
```

Or run `setup.sh` from the grimoire repo root.

## License

MIT
