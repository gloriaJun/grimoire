# _state.json Schema

Task state file that tracks orchestration progress across sessions.
Stored in the devlog task subdirectory: `_claude/devlogs/<task-dir>/_state.json`

## Schema

```json
{
  "taskName": "string — kebab-case task identifier",
  "currentStep": "string — step name: entry | idea | plan | design | wireframe | breakdown | build | complete | retro | til",
  "entryPoint": "idea | plan | design | wireframe | breakdown | build | direct",
  "completedSteps": [
    { "step": "entry", "at": "ISO 8601" },
    { "step": "idea", "at": "ISO 8601" }
  ],
  "branch": "string | null — current working branch (set at build step start)",
  "worktreePath": "string | null — absolute worktree path; null if working in main repo",
  "artifacts": {
    "brainstorm": "string | null — relative path from task dir",
    "prd": "string | null",
    "trd": "string | null",
    "wireframe": "\"skipped\" | { mockup: \"path/to/wireframe-<task>.md\", design: \"url-or-path | null\" } | null",
    "features": "string | null — path to features.md",
    "featureSpecs": ["feature-01-auth.md", "feature-02-api.md"]
  },
  "features": [
    {
      "id": "01",
      "name": "string",
      "status": "pending | in-progress | review | done",
      "testingApproach": "TDD | Test-After | Skip",
      "dependsOn": ["02", "03"],
      "executor": "claude | codex | null",
      "reviewer": "claude | codex | null",
      "frontendReviewer": "claude | null"
    }
  ]
}
```

## Removed Fields (detect-on-demand)

The following fields were removed from `_state.json` to reduce schema complexity.
They are now detected fresh at each invocation rather than persisted:

| Removed field | Replacement |
|---|---|
| `artifacts.testConfig` | Detected at build step: check `vitest.config.*`, `jest.config.*`, `package.json` scripts |
| `artifacts.lintConfig` | Detected at verification: check `eslint.config.*`, `package.json` scripts, nx.json |
| `codexAvailability` | Detected at first cross-review invocation per session |
| `reviews.prd/trd/features` | Review approvals logged in `history.md` Decision Log as `type: decision` entries |
| `features[].stagnationResolution` | Stagnation events logged in `history.md` Decision Log as `type: troubleshooting · status: open` |

## Storage Path Convention

| Workspace | devlogs root |
|-----------|-------------|
| GitHubWork | `~/Documents/GitHubWork/_claude/devlogs/` |
| GitHubPrivate | `~/Documents/GitHubPrivate/_claude/devlogs/` |

Task directory: `<devlogs-root>/YYYY-MM-DD-<repo>-<task-name>/`

## Rules

### Step File Convention

Step files declare only the unique transition values (target `currentStep`, artifact paths to register).
The general mechanics — persist to disk, update `completedSteps`, resolve paths — apply from the rules below.

### Creation
- Created at entry point selection with initial values
- `currentStep` set to the entry point step name (e.g., `"idea"`, `"plan"`)
- All `artifacts` fields default to `null`
- All `reviews` fields default to `null`
- `branch` and `worktreePath` default to `null`
- `history.md` is created alongside `_state.json` at this same time (see `schemas/history.md`)

### Updates
- Update `currentStep` BEFORE loading the next step file
- Append `{ "step": "<name>", "at": "<ISO 8601>" }` to `completedSteps` AFTER user confirms step completion
- Register artifact paths as soon as files are created
- Set `branch` and `worktreePath` at build step start (detect via `git branch --show-current` and `git rev-parse --show-toplevel`; set `worktreePath` only when the repo root differs from the workspace root)
- After every `_state.json` update: regenerate `history.md` Current Snapshot from the new state (see `schemas/history.md`)

### Session Restoration
1. Read `_state.json` from the task directory
2. **Migration**: if `currentStep` is a number, convert to step name using the legacy mapping:
   - `0` → `"entry"`, `1` → `"idea"`, `2` → `"plan"`, `3` → `"design"`,
     `4` → `"breakdown"`, `5` → `"build"`, `6` → `"complete"`, `7` → `"retro"`, `8` → `"til"`
   - Write the converted string back to `_state.json` immediately
3. **Migration (completedSteps)**: if `completedSteps` contains plain strings (legacy format), convert to `{ step, at }` objects; set `at` to `null` for migrated entries
4. Set `currentStep` (string) as the active step
5. Verify all artifact paths in `artifacts` still exist on disk
6. If an artifact is missing, warn the user and block progression
7. Load the step file for `currentStep`

### Artifact Registry
- Paths are **relative to the task subdirectory** unless prefixed with `/`
- Exception: PRD/TRD stored in project `docs/` use absolute paths
- The orchestrator resolves paths from this registry — never from hardcoded filenames

### Codex Availability

Detected fresh at first cross-review invocation each session. Not persisted in `_state.json`.

### Feature Tracking
- `features` array populated at breakdown step
- Status transitions: `pending` → `in-progress` → `review` → `done`
- One feature per session (build step session-per-feature pattern)
- `executor` and `reviewer` set when user chooses at build step
- Stagnation events are NOT tracked in state — logged in `history.md` Decision Log instead
