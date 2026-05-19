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
    },
    "lintConfig": {
      "eslint": {
        "version": "v9-flat | legacy | null",
        "configFile": "string | null — e.g. eslint.config.ts",
        "command": "string | null — e.g. pnpm lint"
      },
      "prettier": {
        "configFile": "string | null — e.g. prettier.config.ts",
        "command": "string | null — e.g. pnpm format"
      },
      "typecheck": {
        "configFile": "string | null — e.g. tsconfig.json",
        "command": "string | null — e.g. pnpm typecheck"
      },
      "husky": {
        "configured": "boolean | null",
        "hooks": ["pre-commit", "pre-push", "commit-msg"]
      }
    }
  },
  "codexAvailability": "plugin | cli | unavailable | null",
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

### Codex Availability Cache
- `codexAvailability` starts as `null` (unchecked)
- Values: `"plugin"` (codex-plugin-cc available), `"cli"` (CLI only), `"unavailable"` (neither)
- Set once at first Stage 4 review invocation; reused for all subsequent reviews in the session
- Reset to `null` if the session environment changes (e.g., plugin reinstalled)

### Feature Tracking
- `features` array populated at breakdown step
- Status transitions: `pending` → `in-progress` → `review` → `done`
- One feature per session (build step session-per-feature pattern)
- `executor` and `reviewer` set when user chooses at build step
