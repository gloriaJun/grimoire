# Entry: Starting Point Selection

## External Artifact Registration

If an artifact context was detected by the argument pre-processor (URL, file path, or descriptor phrase):

1. Scan devlogs for active tasks (same logic as Active Task Check below).
2. Present matching tasks and ask which task this artifact belongs to:
   ```
   이 아티팩트를 등록할 태스크를 선택하세요:

     1. 2026-04-28-repo-task-name  (build — breakdown 완료)
     2. 2026-04-20-repo-other-task  (wireframe)
     n. 새 태스크 시작

   > Enter number
   ```
3. On selection: identify the appropriate artifact slot from `_state.json.artifacts`:
   - URL ending in known design tool domain → `wireframe.design`
   - `.md` / `.pdf` path → ask "PRD, TRD, wireframe, or other?"
   - Unrecognized → ask explicitly which field
4. Update `_state.json` with the artifact value and append to `history`.
5. Confirm: "✅ {field} 등록 완료 → 현재 단계: {currentStep}. 계속 진행할까요? (Y/n)"
   - Y: load the step file for `currentStep`
   - n: stop

---

## Active Task Check

Before showing the entry menu, check for an existing task:

1. Detect workspace from `cwd`:
   - Path contains `GitHubWork` → `~/Documents/GitHubWork/_claude/devlogs/`
   - Path contains `GitHubPrivate` → `~/Documents/GitHubPrivate/_claude/devlogs/`
   - Neither → ask the user which workspace to use

2. Resolve current repo name:
   ```bash
   basename $(git rev-parse --show-toplevel 2>/dev/null || pwd)
   ```

3. Pass 1 — repo-matched folders only (no broad scan):
   - List folder names under the devlogs root (directory names only, no file reads).
   - Filter: folders whose name contains the repo name as a substring.
   - If matches found: read `_state.json` for matched folders only.
     - Active: `currentStep NOT IN completedSteps`
     - Note: a task at currentStep=6 with 6 in completedSteps is considered done.
     - If active tasks found → go to step 5 (resume menu)
     - If all matched tasks are done → go to step 7 (entry menu)

4. Pass 2 — triggered only when Pass 1 finds no folder matches:
   - List all folder names under the devlogs root (no file reads).
   - Show to the user:
     ```
     현재 레포(<repo>)와 일치하는 devlog가 없습니다.
     다른 태스크를 이어하시겠습니까?

       1. 2026-04-28-openchat-release-op-release-lifecycle-app
       2. 2026-04-22-my-playground-work-hub
       ...

     > 번호 선택 / n 새 태스크
     ```
   - On number: read `_state.json` for that folder only → go to step 5
   - On `n`: go to step 7 (entry menu)

5. Resume menu (when active tasks found):
   ```
   Active devlogs found:

     1. 2026-04-29-one-insight-one  (breakdown — features.md 미작성)
     2. ...

   Resume one, or start a new task?
   > [number] to resume / [n] for new task
   ```

6. On resume: load `_state.json`, apply migration if `currentStep` is a number (see SKILL.md Session Restoration), verify artifact paths, load the step file for `currentStep`.

7. No active tasks → proceed to entry menu.

---

## Entry Menu

```
Select your starting point:

  1. idea       — vague concept, start from ideation
  2. plan       — requirements ready, skip to PRD
  3. design     — PRD exists, go to TRD
  4. wireframe  — TRD exists, go to UI design (optional)
  5. breakdown  — TRD exists, go to feature decomposition
  6. build      — planning done, go straight to implementation
  7. resume     — continue an existing task by path
  8. import     — already have artifacts, bootstrap devlog from them

> Enter number or sub-command name
```

| Choice | Starts at | Pre-condition |
|--------|-----------|---------------|
| idea      | `steps/idea.md` | none |
| plan      | `steps/plan.md` | none (creates new devlog) |
| design    | `steps/design.md` | PRD exists |
| wireframe | `steps/wireframe.md` | TRD exists (or `"skipped"`) |
| breakdown | `steps/breakdown.md` | PRD exists (TRD optional) |
| build     | `steps/build.md` | feature breakdown exists |
| resume    | prompts for devlog path | `_state.json` exists |
| import    | Import Flow (below) | existing artifacts in any form |

## New Task Initialization

After entry point is confirmed:

1. Ask for task name (kebab-case, e.g., `one-auth-refactor`)
2. Create task directory: `<devlogs-root>/YYYY-MM-DD-<repo>-<task-name>/`
3. Create `_state.json` with:
   - `taskName`: confirmed name
   - `currentStep`: entry point step name (e.g., `"idea"`, `"plan"`)
   - `entryPoint`: selected entry
   - `completedSteps`: `["entry"]`
   - All other fields at defaults
4. Update `_index.md`:
   - Read `<devlogs-root>/_index.md`
   - Append row under `## Active Tasks` table:
     `` | `YYYY-MM-DD-<repo>-<task-name>/` | <task-name> | Step N (<step-name>) | in progress | ``
   - Update frontmatter `updated:` to today's date
5. Load the step file for the selected entry point

## Import Flow

Triggered by `/dev import` or entry menu option 8.
Use when the user already has completed artifacts (PRD, TRD, feature specs, plan files, or inline content from the conversation).

1. **Resolve devlog root** (same as Active Task Check step 1).
2. **Ask for task name** (kebab-case).
3. **Create task directory**: `<devlogs-root>/YYYY-MM-DD-<repo>-<task-name>/`
4. **Collect artifacts**: for each slot, ask for source or "skip":

   | Slot | `_state.json` key | File to create |
   |------|-------------------|----------------|
   | Brainstorm | `artifacts.brainstorm` | `brainstorm.md` |
   | PRD | `artifacts.prd` | `PRD-<task-name>.md` |
   | TRD | `artifacts.trd` | `TRD-<task-name>.md` |
   | Feature breakdown | `artifacts.features` | `features.md` |
   | Feature specs | `artifacts.featureSpecs[]` | `feature-NN-<name>.md` |

   Source can be:
   - **File path**: copy file content into task directory
   - **Inline / plan file**: user points to content in conversation or another file → write to task directory
   - **Skip**: leave as `null` in `_state.json`

5. **Infer `currentStep`** from artifacts provided:

   | Artifacts present | `currentStep` |
   |---|---|
   | none | `"idea"` |
   | brainstorm only | `"plan"` |
   | PRD (no TRD) | `"design"` |
   | PRD + TRD | `"breakdown"` |
   | PRD + TRD + features | `"build"` |

6. **Create `_state.json`**:
   - `taskName`, `currentStep` (inferred above), `entryPoint: "import"`
   - `completedSteps`: all lifecycle steps preceding `currentStep`
   - `features[]`: populate from feature spec files if provided, else `[]`

7. **Update `_index.md`** (same as New Task Initialization step 4).

8. Confirm:
   ```
   ✅ Devlog 초기화 완료
   경로: <task-dir>
   현재 단계: <currentStep>

   /dev <currentStep> 을 이어서 실행하시겠습니까? (Y/n)
   ```
   - Y: load the step file for `currentStep`
   - n: stop
