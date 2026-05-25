# _state.json Schema (Legacy)

> **Deprecated.** New tasks use memory files (`schemas/memory.md`).
> This file is kept as a migration reference for existing devlogs that still use `_state.json`.
>
> **Safe to delete when:** all `_state.json` devlogs are migrated or completed.
> Currently active: `2026-04-22-fe-marketplace-sentry-alert-setup` (step 2, F-03/F-04 pending).

## Migration

When `entry.md` detects a devlog with `_state.json` but no matching memory file:
1. Display: "⚠️ Legacy task detected. Migrate to memory file? (Y/n)"
2. On Y: create `~/.claude/projects/<project-id>/memory/YYYY-MM-DD-project-<task-name>.md` from the mapping below
3. Add MEMORY.md pointer under `## Active Dev Tasks`
4. Continue using the memory file going forward (`_state.json` left in place but no longer updated)

## Field Mapping (_state.json → memory file)

| `_state.json` field | Memory file location |
|---|---|
| `taskName` | frontmatter `task-name` + `# project-<task-name>` heading |
| `currentStep` | frontmatter `current-step` + `## Current Step` body |
| `entryPoint` | frontmatter `entry-point` |
| `completedSteps[].step` + `.at` | `## Completed Steps` checklist: `- [x] <step> — YYYY-MM-DD` |
| `branch` | `## Build Context - Branch` |
| `worktreePath` | `## Build Context - Worktree` |
| `artifacts.brainstorm` | `## Artifacts - brainstorm` |
| `artifacts.prd` | `## Artifacts - prd` |
| `artifacts.trd` | `## Artifacts - architecture` (map to architecture if exists, else omit) |
| `artifacts.wireframe` | `## Artifacts - wireframe` |
| `artifacts.features` | omit (features.md no longer used) |
| `artifacts.featureSpecs[]` | omit (feature specs no longer pre-generated) |
| `features[].id/name/status` | `## Features` table row |
| `features[].testingApproach` | `## Features` table Testing column |
| `features[].executor` | `## Features` table Executor column |

## Legacy Step Name Migration

| Legacy `currentStep` value | Maps to |
|---|---|
| `"wireframe"` | `"build"` (wireframe merged into design) |
| `"breakdown"` | `"build"` (breakdown step removed) |
| numeric `0` | `"entry"` |
| numeric `1` | `"idea"` |
| numeric `2` | `"plan"` |
| numeric `3` | `"design"` |
| numeric `4` | `"build"` (was breakdown) |
| numeric `5` | `"build"` |
| numeric `6` | `"complete"` |
| numeric `7` | `"retro"` |
| numeric `8` | `"til"` |

## Legacy Schema Reference

```json
{
  "taskName": "string",
  "currentStep": "entry | idea | plan | design | wireframe | breakdown | build | complete | retro | til",
  "entryPoint": "idea | plan | design | wireframe | breakdown | build | direct",
  "completedSteps": [{ "step": "string", "at": "ISO 8601" }],
  "branch": "string | null",
  "worktreePath": "string | null",
  "artifacts": {
    "brainstorm": "string | null",
    "prd": "string | null",
    "trd": "string | null",
    "wireframe": "\"skipped\" | { mockup: string, design: string | null } | null",
    "features": "string | null",
    "featureSpecs": ["string"]
  },
  "features": [
    {
      "id": "string",
      "name": "string",
      "status": "pending | in-progress | review | done",
      "testingApproach": "TDD | Test-After | Skip",
      "dependsOn": ["string"],
      "executor": "claude | codex | null",
      "reviewer": "claude | codex | null",
      "frontendReviewer": "claude | null"
    }
  ]
}
```

## Storage Path Convention (Legacy)

| Workspace | devlogs root |
|-----------|-------------|
| GitHubWork | `~/Documents/GitHubWork/_claude/devlogs/` |
| GitHubPrivate | `~/Documents/GitHubPrivate/_claude/devlogs/` |

Task directory: `<devlogs-root>/YYYY-MM-DD-<repo>-<task-name>/_state.json`
