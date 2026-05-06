# Idea: Development Ideation

Goal: Expand a vague development idea into a structured brainstorm document.

## Process

### 0. Vault Context Check

Read `shared/vault-context.md` and execute with:
- **keywords**: 2–5 terms extracted from the user's idea description
- **search_focus**: `duplicate`, `past-mistakes`
- **scope_hint**: resolved from cwd (GitHubWork → `work`, GitHubPrivate → `life`, else nil)

Present results before moving to Step 1.
Pass vault findings to the idea-explorer agent prompt as additional context.

### 1. Capture the Idea

Ask the user to describe their idea freely — no structure required yet.
If already provided in the trigger message, use that as input.

### 2. Invoke idea-explorer Agent

Dispatch the `idea-explorer` agent (model: sonnet) with the user's description.

The agent will:
- Ask clarifying questions (one at a time) to explore the idea
- Identify the problem being solved, who benefits, and potential approaches
- Produce `brainstorm.md` in the task directory

### 3. Register Artifact

Save `brainstorm.md` to the devlog task directory:
```
<devlogs-root>/<task-dir>/brainstorm.md
```

Register in `_state.json`:
```json
{ "artifacts": { "brainstorm": "brainstorm.md" } }
```

### 3.5 Readiness Check

brainstorm.md를 아래 5가지 기준으로 평가 (위임 없음, orchestrator inline):

```
[ ] 특정 사용자/유스케이스 명시 (not "모두를 위한")
[ ] 구체적인 성공 신호 또는 AC 1개 이상
[ ] 접근 방법 후보 1개 이상
[ ] 제약 조건 명시 (시간/기술/예산, 또는 "없음")
[ ] MVP와 부가 기능 경계 구분 가능
```

- **2개 이상 미체크**: idea-explorer에 gap당 후속 질문 1개 전달 → brainstorm.md 업데이트 → 재평가
- **1개 이하 미체크**: Step 4로 진행

### 4. Present and Confirm

Show the brainstorm to the user.
Ask: "Ready to move to planning? (y / edit / stop)"

- `y` → proceed to handoff
- `edit` → apply user corrections and re-show
- `stop` → save state and exit (resume later with `/dev plan`)

## State Update

`currentStep` ← `"plan"`, append `"idea"` to `completedSteps`, `artifacts.brainstorm` ← path

Follow update mechanics from `schemas/state.md`.

## Session Handoff

Read `steps/_handoff.md` and follow the handoff instructions.
Next sub-command: `/dev plan`
