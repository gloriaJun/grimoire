# Status: Task Summary

Print the status of all tasks. Runs without an active task.

## Process

### 1. Primary — Memory-based scan

MEMORY.md is already in context at session start.

Parse both sections:
- `## Active Dev Tasks` — tasks in progress
- `## Completed Dev Tasks` — finished tasks

For each listed pointer: read frontmatter (`repo`, `current-step`, `task-name`, `created`) from the referenced `state.md`.

### 2. Fallback — Orphaned task directory scan

Triggered when MEMORY.md has no entries or `--all` flag is given.

Scan `<memory-root>` (= `~/.claude/projects/<project-id>/memory/`) for `YYYY-MM-DD-*/state.md` not listed in MEMORY.md. Add found entries to output and re-register in MEMORY.md.

### 3. Legacy fallback — `_state.json` scan

Triggered when steps 1–2 yield no results or `--all` flag is given.

Detect devlog root from `cwd`:

| cwd contains | devlogs root |
|---|---|
| `GitHubWork` | `~/Documents/GitHubWork/_claude/devlogs/` |
| `GitHubPrivate` | `~/Documents/GitHubPrivate/_claude/devlogs/` |
| neither | ask the user |

Find all `_state.json` files. Extract: `taskName`, `currentStep`, `completedSteps`, last `history` entry timestamp.

Classify:
- **active**: `currentStep NOT IN completedSteps`
- **done**: `currentStep IN completedSteps`

### 3. Output

```
Active tasks:

  <task-name>   <current-step>   <repo>   <YYYY-MM-DD>
  ...

Done:
  <task-name>   complete   <repo>   <YYYY-MM-DD>
  ...

No tasks found.
```

Rules:
- Active tasks first; done tasks below
- Omit the Done section if no done tasks
- Date: `created` frontmatter from memory file, or date prefix from directory name (legacy)
- Task name: `task-name` frontmatter, or `taskName` from `_state.json` (legacy)
- Filter by current repo when `--repo` flag or natural language "이 레포" is used
