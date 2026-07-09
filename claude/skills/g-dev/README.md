# g-dev

Development lifecycle skill: takes one project from idea to completion with
architecture design, task breakdown, and a harness-first build loop. Built
on loop engineering (implement -> verify -> iterate against an executable
harness) and designed so independent tasks run as parallel Claude Code
sessions.

## Highlights

- **Harness first** - every task fixes 2-5 completion criteria (exact
  commands + expected results) before any implementation; build loops until
  the harness passes, with a stagnation menu after 3 consecutive failures
- **Parallel sessions** - task state lives in the Obsidian vault (a fixed
  absolute path), so any session or git worktree can claim a task with
  `/g-dev build tNN`; per-task state files plus a post-claim verification
  keep concurrent sessions off each other's state
- **Vault-native records** - the human-readable record is the vault's formal
  project doc (goal, status, decisions, work log), updated through
  g-vault-log at every handoff; machine state stays in `assets/<slug>/`
- **External skill wrapping** - UI direction defers to `frontend-design`
  (anthropics/skills), implementation taste checks defer to
  `design-taste-frontend` (Leonxlnx/taste-skill); presence-checked, never
  copied
- **Stop discipline** - one task per session; every step ends with a handoff
  and an explicit stop

## Layout

- `SKILL.md` - router: sub-command to step file, entry conditions, hard rules
- `steps/step-1-entry.md` .. `step-6-complete.md` - one file per lifecycle
  step, loaded on demand
- `references/state-format.md` - state.md and task file schemas, shared
  handoff procedure
- `references/external-skills.md` - install/presence-check/invoke/fallback
  for the two wrapped skills

## Usage

```
/g-dev                  # resume the repo's active project, or start one
/g-dev status           # read-only dashboard
/g-dev build t03        # claim task t03 (works in a parallel session)
/g-dev complete         # final verification + archive handoff
```
