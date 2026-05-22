# Memory File Schema

Task state file that tracks `/dev` workflow progress across sessions.
Stored in the Claude Code project memory directory.

**Replaces**: `_state.json` (see `schemas/state.md` for legacy reference)

## File Naming

```
{YYYY-MM-DD}-project-{task-name}.md
```

Example: `2026-05-22-project-auth-refactor.md`

- Date prefix: task creation date (ISO 8601, dashes)
- Slug: kebab-case task identifier matching the devlog folder name

## Storage Path

```
~/.claude/projects/<project-id>/memory/{YYYY-MM-DD}-project-{task-name}.md
```

The project-id is the filesystem path encoded (e.g., `-Users-al03155147-Documents-GitHubPrivate-grimoire`).

## Frontmatter

```yaml
---
created: YYYY-MM-DD
updated: YYYY-MM-DD
type: memory/project
task-name: kebab-case-name
devlog-path: ~/Documents/GitHubPrivate/_claude/devlogs/YYYY-MM-DD-<repo>-<task>/
repo: <repo-name>
current-step: idea | plan | design | build | complete
entry-point: idea | plan | design | build
tags:
  - claude-memory
  - project
  - dev-workflow
---
```

| Field | Description |
|---|---|
| `task-name` | kebab-case task identifier |
| `devlog-path` | absolute path to the devlog task directory (artifacts stored here) |
| `repo` | repository name (used for MEMORY.md repo filtering) |
| `current-step` | active step name |
| `entry-point` | step where this task was initialized |

## Body Structure

```markdown
# project-<task-name>

**Why:** `/dev` workflow task state tracking.
**How to apply:** Auto-recognized via MEMORY.md at session start. Used as state source when `/dev` is invoked.

## Current Step

`<current-step>` — <one-line progress summary>

## Completed Steps

- [x] entry — YYYY-MM-DD
- [x] idea — YYYY-MM-DD
- [ ] plan
- [ ] design
- [ ] build
- [ ] complete

## Build Context

- Branch: <branch or —>
- Worktree: <absolute path or "(main repo)">

## Artifacts

- brainstorm: `brainstorm.md`
- prd: `PRD-<task>.md`
- architecture: `architecture.md`
- wireframe: `wireframe.html` | `"skipped"`

## Features

| # | Feature | Status | Executor | Testing |
|---|---------|--------|----------|---------|
| F-01 | <name> | ✅ done | claude | TDD |
| F-02 | <name> | ⏳ pending | — | — |

## Open Blockers

(none)
```

## MEMORY.md Pointer

Add to `## Active Dev Tasks` section when task is created:

```markdown
## Active Dev Tasks

- [project-<name>](YYYY-MM-DD-project-<name>.md) — <repo> / <step> (<N>/<M> features)
```

Move to `## Completed Dev Tasks` section when `/dev complete` is called.

## Creation Rules

- Created at entry point selection (replaces `_state.json` creation)
- `current-step` frontmatter set to the entry point step name
- All `## Artifacts` entries default to absent (omit until created)
- `## Build Context` filled at build step start
- `history.md` is created in the devlog task directory at the same time

## Update Rules

- Update `current-step` frontmatter BEFORE loading the next step file
- Append `- [x] <step> — YYYY-MM-DD` to Completed Steps AFTER user confirms step completion
- Add artifact paths to `## Artifacts` as soon as files are created
- After every update: regenerate `history.md` Current Snapshot from this file (see `schemas/history.md`)
- Update `updated:` frontmatter on every write

## Session Restoration

1. MEMORY.md is auto-loaded at session start — `## Active Dev Tasks` is already in context
2. Match entries by `repo` frontmatter field against current repo name
3. Read the matched memory file to restore full state
4. Verify artifact paths in `## Artifacts` still exist on disk; warn if missing
5. Load the step file for `current-step`

**Fallback**: if no memory file found, scan devlog folder for `_state.json` (legacy) — see `schemas/state.md`

## Feature Tracking

- `## Features` table populated at design step (one row per feature, status: ⏳ pending)
- Status icons: `✅ done`, `🔄 in-progress`, `👀 review`, `⏳ pending`
- Feature rows added/removed freely throughout build step (flexible, not locked at design time)
- `executor` and `testing` columns filled when user chooses at build step
- Dependency notation in architecture.md: `<!-- depends: F-01 -->`
- Stagnation events logged in `history.md` Decision Log, not here

## Removed Fields (detect-on-demand)

Same as `_state.json` removed fields — these are never stored in the memory file:

| Removed field | Replacement |
|---|---|
| `artifacts.testConfig` | Detected at build step: check `vitest.config.*`, `jest.config.*`, `package.json` scripts |
| `artifacts.lintConfig` | Detected at verification: check `eslint.config.*`, `package.json` scripts, nx.json |
| `codexAvailability` | Detected at first cross-review invocation per session |
| review approvals | Logged in `history.md` Decision Log as `type: decision` entries |
| stagnation resolutions | Logged in `history.md` Decision Log as `type: troubleshooting` entries |

## Storage Path Convention

| Workspace | devlogs root |
|-----------|-------------|
| GitHubWork | `~/Documents/GitHubWork/_claude/devlogs/` |
| GitHubPrivate | `~/Documents/GitHubPrivate/_claude/devlogs/` |

Task directory: `<devlogs-root>/YYYY-MM-DD-<repo>-<task-name>/`
Memory file: `~/.claude/projects/<project-id>/memory/YYYY-MM-DD-project-<task-name>.md`

> Artifacts (PRD, architecture.md, wireframe.html, history.md, notes.md) are stored in the devlog task directory.
> The memory file is state-only — no artifact content.
