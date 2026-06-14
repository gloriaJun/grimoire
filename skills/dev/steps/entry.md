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

3. **Fallback — orphaned task directory scan**:
   - Scan `<memory-root>` for `YYYY-MM-DD-*/state.md` not yet listed in MEMORY.md.
   - Filter by `repo` frontmatter field in each `state.md`.
   - If matches found → re-register in MEMORY.md → treat as active tasks → go to step 4.
   - If no matches → check other repos:
     ```
     현재 레포(<repo>)에 진행 중인 작업이 없습니다.
     다른 레포 작업을 이어서 할까요?

       1. 2026-04-28-repo-task-name  (build)
       2. ...

     > 번호 선택 / n 새 작업 시작
     ```
   - If still nothing → proceed to entry menu (step 6).

4. 이어할 작업 선택 (진행 중인 작업이 있을 때):
   ```
   진행 중인 작업:

     1. <task-name>  (<current-step> — <한 줄 진행 상황>)
     2. ...

   이어서 할 작업 번호를 고르거나, 새로 시작할까요?
   > [번호] 이어하기 / [n] 새 작업
   ```

5. 이어하기 선택 시: 메모리 파일(`state.md`)을 읽고, 단계명 마이그레이션이 필요하면 적용
   (`"wireframe"`/`"breakdown"` → `"build"`), `## Artifacts`의 경로가 실제로 있는지 확인한다.
   - 산출물 경로가 없으면: 사용자에게 알리고 건너뛸지 다시 등록할지 묻는다.
   - `current-step`이 `"build"`이고 작업 폴더에 `history.md`가 있으면 아래 요약을 보여준다:
     ```
     이어서 진행: **<taskName>** — 현재 build 단계

     브랜치: <메모리 ## Build Context의 Branch>
     작업 위치: <메모리 ## Build Context의 Worktree, 없으면 "(메인 레포)">
     진행률: 완료 <done>개 / 전체 <total>개 · 다음 작업: <## Features 표의 다음 ⏳ 기능>

     📝 최근 결정·이슈: <history.md 결정·블로커 기록 최근 1~2건, 없으면 "(없음)">
     ⚠️ 막힌 부분: <결정·블로커 기록 중 status: open 항목, 없으면 "(없음)">
     ```
   - 그 외에는 간단한 이어하기 확인 후 단계 파일을 로드한다.

6. 진행 중인 작업이 없으면 → 시작 메뉴로 이동.

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

| Choice | Starts at | 진입 조건 |
|--------|-----------|---------------|
| idea   | `steps/idea.md`   | none |
| plan   | `steps/plan.md`   | none (creates new task directory + memory file) |
| design | `steps/design.md` | PRD exists |
| build  | `steps/build.md`  | architecture.md exists |
| resume | prompts for task  | memory file (`state.md`) exists |
| import | Import Flow below | existing artifacts in any form |

## New Task Initialization

After entry point is confirmed:

1. Ask for task name (kebab-case, e.g., `one-auth-refactor`)
2. Determine task directory:
   - Resolve the **main repo root** (worktree-safe; see `SKILL.md` Task Directory Detection):
     ```bash
     REPO_ROOT=$(dirname "$(git rev-parse --path-format=absolute --git-common-dir 2>/dev/null)")
     [ -d "$REPO_ROOT" ] || REPO_ROOT=$(git rev-parse --show-toplevel 2>/dev/null || pwd)
     ```
   - project-id: `REPO_ROOT` with `/` replaced by `-` (leading `~` removed), e.g. `/Users/al03155147/Documents/GitHubPrivate/my-assistant-hub` → `-Users-al03155147-Documents-GitHubPrivate-my-assistant-hub`
   - memory-root: `~/.claude/projects/<project-id>/memory/`
   - task-dir: `<memory-root>/YYYY-MM-DD-<task-name>/`
   - Create `<task-dir>` (mkdir).
3. Create `<task-dir>/state.md`:
   - frontmatter: `task-name`, `task-dir`, `repo`, `current-step` = entry point, `entry-point`, `created` = today
   - `## Current Step`: entry point name + " — started"
   - `## Completed Steps`: `- [x] entry — YYYY-MM-DD`; remaining steps unchecked
   - `## Build Context`, `## Artifacts`, `## Features`, `## Open Blockers`: empty/placeholder
4. Add MEMORY.md pointer under `## Active Dev Tasks`:
   ```
   - [<task-name>](YYYY-MM-DD-<task-name>/state.md) — <repo> / <step> (0/? features)
   ```
5. Create `<task-dir>/history.md` using the initial template in `schemas/history.md`.
6. Load the step file for the selected entry point.

## Import Flow

Triggered by `/dev import`, entry menu option 6, or an artifact passed after `/dev`.
Use when the user already has completed artifacts (PRD, architecture.md, plan files, or inline content).

1. **Ask for task name** (kebab-case) and determine the task directory
   (same worktree-safe `REPO_ROOT` / project-id derivation as New Task Initialization step 2).
   Create `<memory-root>/YYYY-MM-DD-<task-name>/`.

2. **Collect artifacts in one pass.** Ask the user to point to whatever they already have —
   file paths or inline content — for any of: brainstorm, PRD, architecture. One question, not three:
   ```
   가지고 있는 산출물의 경로(또는 내용)를 알려주세요. 해당되는 것만 적으면 됩니다.
     - brainstorm:
     - PRD:
     - architecture:
   ```
   For each provided source: file path → copy into the task directory; inline/plan content →
   write into the task directory (`brainstorm.md`, `PRD-<task-name>.md`, `architecture.md`).
   Omit unprovided slots from `## Artifacts`.

3. **Infer `current-step`** from what was provided:

   | Artifacts present | `current-step` |
   |---|---|
   | none | `"idea"` |
   | brainstorm only | `"plan"` |
   | PRD (no architecture) | `"design"` |
   | PRD + architecture | `"build"` |

4. **Create memory file + history.md** (see `schemas/memory.md` Creation Rules):
   - frontmatter with inferred `current-step`, `entry-point: "import"`
   - `## Completed Steps`: all lifecycle steps preceding `current-step` marked `[x]`
   - `## Artifacts`: populated from collected artifacts
   - `## Features`: populate from architecture.md `## Features` checklist if available, else empty

5. **Add MEMORY.md pointer** under `## Active Dev Tasks`:
   ```
   - [<task-name>](YYYY-MM-DD-<task-name>/state.md) — <repo> / <step> (0/? features)
   ```

6. Confirm:
   ```
   ✅ 작업 초기화 완료
   경로: <task-dir>
   현재 단계: <current-step>

   <current-step> 단계를 이어서 진행할까요? (Y/n)
   ```
   - Y: load the step file for `current-step`
   - n: stop
