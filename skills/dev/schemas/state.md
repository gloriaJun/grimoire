# _state.json Schema

Task state file that tracks orchestration progress across sessions.
Stored in the devlog task subdirectory: `_claude/devlogs/<task-dir>/_state.json`

## Schema

```json
{
  "taskName": "string — kebab-case task identifier",
  "currentStep": "string — step name: entry | idea | plan | design | wireframe | breakdown | build | complete | retro | til",
  "entryPoint": "idea | plan | design | wireframe | breakdown | build | direct",
  "completedSteps": ["entry", "idea"],
  "artifacts": {
    "brainstorm": "string | null — relative path from task dir",
    "prd": "string | null",
    "trd": "string | null",
    "wireframe": "\"skipped\" | { mockup: \"path/to/wireframe-<task>.md\", design: \"url-or-path | null\" } | null",
    "features": "string | null — path to features.md",
    "featureSpecs": ["feature-01-auth.md", "feature-02-api.md"],
    "testConfig": {
      "unit": {
        "framework": "vitest | jest | pytest | null",
        "configFile": "string | null — e.g. vitest.config.ts",
        "command": "string | null — e.g. pnpm test"
      },
      "e2e": {
        "framework": "playwright | cypress | null",
        "configFile": "string | null — e.g. playwright.config.ts",
        "command": "string | null — e.g. pnpm e2e"
      }
    }
  },
  "reviews": {
    "prd": {
      "mode": "plannotator | text | skipped | null",
      "fallbackReason": "plannotator_cli_unavailable | plannotator_launch_failed | null",
      "approvedAt": "ISO 8601 | null"
    },
    "trd": {
      "mode": "plannotator | text | skipped | null",
      "fallbackReason": "plannotator_cli_unavailable | plannotator_launch_failed | null",
      "approvedAt": "ISO 8601 | null"
    },
    "features": {
      "mode": "plannotator | text | skipped | null",
      "fallbackReason": "plannotator_cli_unavailable | plannotator_launch_failed | null",
      "approvedAt": "ISO 8601 | null"
    }
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
      "frontendReviewer": "claude | null",
      "stagnationResolution": "pending-tests | null"
    }
  ],
  "history": [
    {
      "step": "string — step name at time of action (e.g., \"idea\", \"build\")",
      "action": "string — what happened",
      "timestamp": "ISO 8601"
    }
  ]
}
```

## Storage Path Convention

| Workspace | devlogs root |
|-----------|-------------|
| GitHubWork | `~/Documents/GitHubWork/_claude/devlogs/` |
| GitHubPrivate | `~/Documents/GitHubPrivate/_claude/devlogs/` |

Task directory: `<devlogs-root>/YYYY-MM-DD-<repo>-<task-name>/`

## Rules

### Step File Convention

Step files declare only the unique transition values (target `currentStep`, artifact paths to register).
The general mechanics — persist to disk, append to `history`, resolve paths — apply from the rules below.

### Creation
- Created at entry point selection with initial values
- `currentStep` set to the entry point step name (e.g., `"idea"`, `"plan"`)
- All `artifacts` fields default to `null`
- All `reviews` fields default to `null`

### Updates
- Update `currentStep` BEFORE loading the next step file
- Append to `completedSteps` AFTER user confirms step completion
- Register artifact paths as soon as files are created
- Append to `history` at every state transition

### Session Restoration
1. Read `_state.json` from the task directory
2. **Migration**: if `currentStep` is a number, convert to step name using the legacy mapping:
   - `0` → `"entry"`, `1` → `"idea"`, `2` → `"plan"`, `3` → `"design"`,
     `4` → `"breakdown"`, `5` → `"build"`, `6` → `"complete"`, `7` → `"retro"`, `8` → `"til"`
   - Write the converted string back to `_state.json` immediately
3. Set `currentStep` (string) as the active step
4. Verify all artifact paths in `artifacts` still exist on disk
5. If an artifact is missing, warn the user and block progression
6. Load the step file for `currentStep`

### Artifact Registry
- Paths are **relative to the task subdirectory** unless prefixed with `/`
- Exception: PRD/TRD stored in project `docs/` use absolute paths
- The orchestrator resolves paths from this registry — never from hardcoded filenames

### History Step Field

- `step` must be the **step name** at the time the action occurred
- Valid values: `"entry"`, `"idea"`, `"plan"`, `"design"`, `"wireframe"`, `"breakdown"`, `"build"`, `"complete"`, `"retro"`, `"til"`
- Do NOT use numbers or arbitrary values
- Example: all features built during build step should record `"step": "build"`

### Feature Tracking
- `features` array populated at breakdown step
- Status transitions: `pending` → `in-progress` → `review` → `done`
- One feature per session (build step session-per-feature pattern)
- `executor` and `reviewer` set when user chooses at build step
