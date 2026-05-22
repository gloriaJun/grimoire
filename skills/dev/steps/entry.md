# Entry: Starting Point Selection

## External Artifact Registration

If an artifact context was detected by the argument pre-processor (URL, file path, or descriptor phrase):

1. Scan for active tasks (same logic as Active Task Check below).
2. Present matching tasks and ask which task this artifact belongs to:
   ```
   이 아티팩트를 등록할 태스크를 선택하세요:

     1. 2026-04-28-repo-task-name  (build — design 완료)
     2. 2026-04-20-repo-other-task  (design)
     n. 새 태스크 시작

   > Enter number
   ```
3. On selection: identify the appropriate artifact slot from memory file `## Artifacts`:
   - URL ending in known design tool domain → `wireframe.design`
   - `.md` / `.pdf` path → ask "PRD, architecture, or other?"
   - Unrecognized → ask explicitly which field
4. Update the memory file `## Artifacts` section with the artifact value.
5. Confirm: "✅ {field} 등록 완료 → 현재 단계: {current-step}. 계속 진행할까요? (Y/n)"
   - Y: load the step file for `current-step`
   - n: stop

---

## Active Task Check

MEMORY.md is auto-loaded at session start and contains `## Active Dev Tasks` pointers.
No devlog folder scanning required — read from memory.

1. Resolve current repo name:
   ```bash
   basename $(git rev-parse --show-toplevel 2>/dev/null || pwd)
   ```

2. **Primary — memory-based detection**:
   - MEMORY.md `## Active Dev Tasks` is already in context.
   - For each listed memory file: read frontmatter `repo` field.
   - Filter entries matching the current repo name.
   - If matches found → go to step 4 (resume menu)
   - If no matches → go to step 3

3. **Fallback — legacy `_state.json` scan**:
   - Detect workspace from `cwd`:
     - Path contains `GitHubWork` → `~/Documents/GitHubWork/_claude/devlogs/`
     - Path contains `GitHubPrivate` → `~/Documents/GitHubPrivate/_claude/devlogs/`
     - Neither → ask the user
   - List folder names under devlogs root. Filter by repo name substring.
   - If matches: read `_state.json` for matched folders only.
     - Active: `currentStep NOT IN completedSteps`
   - If active legacy tasks found: display migration prompt:
     ```
     ⚠️ 레거시 태스크가 감지됐습니다: <folder-name>
     메모리 파일로 마이그레이션하시겠습니까? (Y/n)
     ```
     - Y: create memory file from `_state.json` per `schemas/state.md` Migration section
          → add MEMORY.md pointer → go to step 4 using the new memory file
     - n: continue using `_state.json` directly → go to step 4
   - If no active legacy tasks: check other repos (same Pass 2 logic as before):
     ```
     현재 레포(<repo>)와 일치하는 태스크가 없습니다.
     다른 태스크를 이어하시겠습니까?

       1. 2026-04-28-repo-task-name  (build)
       2. ...

     > 번호 선택 / n 새 태스크
     ```

4. Resume menu (when active tasks found):
   ```
   Active tasks found:

     1. <task-name>  (<current-step> — <one-line progress>)
     2. ...

   Resume one, or start a new task?
   > [number] to resume / [n] for new task
   ```

5. On resume: read the memory file (or legacy `_state.json`), apply step name migration if needed (see `schemas/state.md` Legacy Step Name Migration), verify artifact paths in `## Artifacts`.
   - If an artifact path is missing: warn the user and ask whether to skip or re-register.
   - If `current-step` is `"build"` and `history.md` exists in the devlog task directory:
     - Read `history.md` and display context block:
       ```
       Resuming **<taskName>** at step build

       Branch: <branch from memory file ## Build Context>
       Worktree: <worktree from memory file ## Build Context, or "(main repo)">
       Progress: <done count>/<total> features done · Next: <next ⏳ feature from ## Features table>

       📝 최근 결정사항: <last 1-2 Decision Log entries, or "(없음)">
       ⚠️ 블로커: <open blocker entries from Decision Log, or "(없음)">
       ```
   - Otherwise: display standard resume confirmation and load the step file.

6. No active tasks → proceed to entry menu.

---

## Entry Menu

```
Select your starting point:

  1. idea    — vague concept, start from ideation
  2. plan    — requirements ready, skip to PRD
  3. design  — PRD exists, go to architecture + wireframe
  4. build   — planning done, go straight to implementation
  5. resume  — continue an existing task by path
  6. import  — already have artifacts, bootstrap devlog from them

> Enter number or sub-command name
```

| Choice | Starts at | Pre-condition |
|--------|-----------|---------------|
| idea   | `steps/idea.md`   | none |
| plan   | `steps/plan.md`   | none (creates new devlog + memory file) |
| design | `steps/design.md` | PRD exists |
| build  | `steps/build.md`  | architecture.md exists |
| resume | prompts for task  | memory file or `_state.json` exists |
| import | Import Flow below | existing artifacts in any form |

## New Task Initialization

After entry point is confirmed:

1. Ask for task name (kebab-case, e.g., `one-auth-refactor`)
2. Create task directory: `<devlogs-root>/YYYY-MM-DD-<repo>-<task-name>/`
3. Create memory file `~/.claude/projects/<project-id>/memory/YYYY-MM-DD-project-<task-name>.md`:
   - frontmatter: `task-name`, `devlog-path`, `repo`, `current-step` = entry point, `entry-point`, `created` = today
   - `## Current Step`: entry point name + " — started"
   - `## Completed Steps`: `- [x] entry — YYYY-MM-DD`; remaining steps unchecked
   - `## Build Context`, `## Artifacts`, `## Features`, `## Open Blockers`: empty/placeholder
4. Add MEMORY.md pointer under `## Active Dev Tasks`:
   ```
   - [project-<task-name>](YYYY-MM-DD-project-<task-name>.md) — <repo> / <step> (0/? features)
   ```
5. Create `history.md` in the devlog task directory using the initial template in `schemas/history.md`.
6. Update `_index.md`:
   - Read `<devlogs-root>/_index.md`
   - Append row under `## Active Tasks`:
     `` | `YYYY-MM-DD-<repo>-<task-name>/` | <task-name> | <step-name> | in progress | ``
   - Update frontmatter `updated:` to today's date
7. Load the step file for the selected entry point.

## Import Flow

Triggered by `/dev import` or entry menu option 6.
Use when the user already has completed artifacts (PRD, architecture.md, plan files, or inline content).

1. **Resolve devlog root** (same as Active Task Check step 3).
2. **Ask for task name** (kebab-case).
3. **Create task directory**: `<devlogs-root>/YYYY-MM-DD-<repo>-<task-name>/`
4. **Collect artifacts**: for each slot, ask for source or "skip":

   | Slot | Memory file key | File to create |
   |------|-----------------|----------------|
   | Brainstorm | `artifacts - brainstorm` | `brainstorm.md` |
   | PRD | `artifacts - prd` | `PRD-<task-name>.md` |
   | Architecture | `artifacts - architecture` | `architecture.md` |

   Source can be:
   - **File path**: copy file content into task directory
   - **Inline / plan file**: user points to content in conversation → write to task directory
   - **Skip**: omit from `## Artifacts`

5. **Infer `current-step`** from artifacts provided:

   | Artifacts present | `current-step` |
   |---|---|
   | none | `"idea"` |
   | brainstorm only | `"plan"` |
   | PRD (no architecture) | `"design"` |
   | PRD + architecture | `"build"` |

6. **Create memory file** (see `schemas/memory.md` Creation Rules):
   - frontmatter with inferred `current-step`, `entry-point: "import"`
   - `## Completed Steps`: all lifecycle steps preceding `current-step` marked `[x]`
   - `## Artifacts`: populated from collected artifacts
   - `## Features`: populate from architecture.md `## Features` checklist if available, else empty

7. **Add MEMORY.md pointer** under `## Active Dev Tasks`.

8. **Update `_index.md`** (same as New Task Initialization step 6).

9. Confirm:
   ```
   ✅ Devlog 초기화 완료
   경로: <task-dir>
   현재 단계: <current-step>

   /dev <current-step> 을 이어서 실행하시겠습니까? (Y/n)
   ```
   - Y: load the step file for `current-step`
   - n: stop
