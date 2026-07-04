# Memory File Schema

Task state file that tracks `/dev` workflow progress across sessions.
Stored in the Claude Code project memory directory as a task subdirectory.

## File Location

```
~/.claude/projects/<project-id>/memory/YYYY-MM-DD-<task-name>/state.md
```

- Task directory: `YYYY-MM-DD-<task-name>/` — date prefix is the task creation date
- State file: `state.md` inside the task directory
- All artifacts (history.md, PRD, brainstorm, architecture, etc.) are stored in the same task directory

Example: `~/.claude/projects/-Users-al03155147-Documents-GitHubPrivate-my-assistant-hub/memory/2026-05-30-lesly-app-design/state.md`

### Project-ID Derivation

Always resolve the **main repo root** first — never the worktree path. This keeps worktree
sessions writing into the main repo's memory directory instead of creating a separate
(usually empty) `...-claude-worktrees-<name>` project directory.

```bash
# Main repo root — returns the main repo even from inside a worktree
REPO_ROOT=$(dirname "$(git rev-parse --path-format=absolute --git-common-dir 2>/dev/null)")
[ -d "$REPO_ROOT" ] || REPO_ROOT=$(git rev-parse --show-toplevel 2>/dev/null || pwd)
```

`git rev-parse --git-common-dir` returns the main `.git` directory even inside a worktree,
so its parent is the main repo root. Encode `REPO_ROOT` by removing the home prefix and
replacing `/` with `-`:
- Repo path: `/Users/al03155147/Documents/GitHubPrivate/my-assistant-hub`
- Project-ID: `-Users-al03155147-Documents-GitHubPrivate-my-assistant-hub`

The actual worktree path (when working in one) is recorded only in `## Build Context` →
`Worktree:`, not in the project-id.

## Frontmatter

```yaml
---
created: YYYY-MM-DD
updated: YYYY-MM-DD
type: memory/project
task-name: kebab-case-name
task-dir: ~/.claude/projects/<project-id>/memory/YYYY-MM-DD-<task-name>/
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
| `task-dir` | absolute path to the task directory (all artifacts stored here) |
| `repo` | repository name (used for MEMORY.md repo filtering) |
| `current-step` | active step name |
| `entry-point` | step where this task was initialized |

## Body Structure

```markdown
# <task-name>

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

| # | Feature | Status | Testing |
|---|---------|--------|---------|
| F-01 | <name> | ✅ done | TDD |
| F-02 | <name> | ⏳ pending | — |

## Open Blockers

(none)
```

## MEMORY.md Pointer

Add to `## Active Dev Tasks` section when task is created:

```markdown
## Active Dev Tasks

- [<task-name>](YYYY-MM-DD-<task-name>/state.md) — <repo> / <step> (<N>/<M> features)
```

When `/dev complete` runs, the task is consolidated into `<task-name>-log.md` and `state.md`
is deleted (see `steps/complete.md`). Move the pointer to `## Completed Dev Tasks` and
**repoint it to the log file**:

```markdown
## Completed Dev Tasks

- [<task-name>](YYYY-MM-DD-<task-name>/<task-name>-log.md) — <repo> / 완료 YYYY-MM-DD
```

## Creation Rules

- Created at entry point selection
- `current-step` frontmatter set to the entry point step name
- All `## Artifacts` entries default to absent (omit until created)
- `## Build Context` filled at build step start
- `history.md` is created in the task directory at the same time

## Update Rules

- Update `current-step` frontmatter BEFORE loading the next step file
- Append `- [x] <step> — YYYY-MM-DD` to Completed Steps AFTER user confirms step completion
- Add artifact paths to `## Artifacts` as soon as files are created
- After every update: regenerate the `history.md` `현재 상태` block from this file (see `schemas/history.md`)
- Update `updated:` frontmatter on every write

## Session Restoration

1. MEMORY.md is auto-loaded at session start — `## Active Dev Tasks` is already in context
2. Match entries by `repo` frontmatter field against current repo name
3. Read the matched `state.md` to restore full state
4. Verify artifact paths in `## Artifacts` still exist on disk; warn if missing
5. Load the step file for `current-step`

**Fallback**: if no MEMORY.md entry found, scan `<memory-root>` for `YYYY-MM-DD-*/state.md` not yet indexed.

## Feature Tracking

- `## Features` table populated at design step (one row per feature, status: ⏳ pending)
- Status icons: `✅ done`, `🔄 in-progress`, `👀 review`, `⏳ pending`
- Feature rows added/removed freely throughout build step (flexible, not locked at design time)
- `testing` column filled from the mini-design at build step
- Dependency notation in architecture.md: `<!-- depends: F-01 -->`
- Stagnation events logged in `history.md` `결정·블로커 기록`, not here

## Plan File Storage

During an active dev task session, if the user requests "계획 저장" or similar:
- Save as `<task-dir>/plan.md` (NOT to `~/.claude/plans/`)

## Detect-on-demand Fields

These are never stored in the memory file — detect them when needed:

| Field | How it's resolved |
|---|---|
| `artifacts.testConfig` | Detected at build step: check `vitest.config.*`, `jest.config.*`, `package.json` scripts |
| `artifacts.lintConfig` | Detected at verification: check `eslint.config.*`, `package.json` scripts, nx.json |
| review approvals | Logged in `history.md` `결정·블로커 기록` as `type: decision` entries |
| stagnation resolutions | Logged in `history.md` `결정·블로커 기록` as `type: troubleshooting` entries |

> Task indexing is handled solely by `MEMORY.md` (`## Active Dev Tasks` / `## Completed Dev Tasks`).
> There is no separate `_index.md`.
