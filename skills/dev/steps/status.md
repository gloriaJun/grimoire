# Status: Devlog Summary

Print the status of all tasks in the current devlogs root. Runs without a devlog.

## Process

### 1. Detect Devlog Root

Apply Devlog Path Detection rules from main SKILL.md:

| cwd contains | devlogs root |
|---|---|
| `GitHubWork` | `~/Documents/GitHubWork/_claude/devlogs/` |
| `GitHubPrivate` | `~/Documents/GitHubPrivate/_claude/devlogs/` |
| neither | ask the user |

### 2. Scan _state.json

Find all `_state.json` files under the devlogs root.

Extract from each:
- `taskName`
- `currentStep`
- `completedSteps`
- `timestamp` of the last `history` entry (most recent activity)

### 3. Classify Active / Done

- **active**: `currentStep NOT IN completedSteps`
- **done**: `currentStep IN completedSteps`

### 4. Step Name Mapping

| currentStep | step name |
|-------------|-----------|
| 0 | entry |
| 1 | idea |
| 2 | plan |
| 3 | design |
| 4 | breakdown |
| 5 | build |
| 6 | complete |
| 7 | retro |
| 8 | wiki |

### 5. Output

```
Active devlogs (<workspace>):

  <task-name>   step <N> (<step-name>)   <YYYY-MM-DD>
  ...

Done:
  <task-name>   step <N> (<step-name>)   <YYYY-MM-DD>
  ...

No devlogs found.
```

Rules:
- Print active tasks first; done tasks below
- Omit the Done section if no done tasks exist
- Timestamp: extract `YYYY-MM-DD` from the last `history` entry
- If no timestamp, use the date prefix from the directory name
- Task name: use `taskName` field; if absent, strip the date prefix from the directory name
