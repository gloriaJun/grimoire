# Status: Task Summary

Print the status of all tasks. Runs without an active devlog.

## Process

### 1. Primary — Memory-based scan

MEMORY.md is already in context at session start.

Parse both sections:
- `## Active Dev Tasks` — tasks in progress
- `## Completed Dev Tasks` — finished tasks

For each listed memory file: read frontmatter (`repo`, `current-step`, `task-name`, `created`).

### 2. Fallback — Legacy `_state.json` scan

Triggered only when MEMORY.md has no entries or when `--all` flag is given.

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
