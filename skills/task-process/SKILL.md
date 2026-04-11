---
name: g-task-process
description: >
  /g-task-process command only. Structured task workflow from ideation
  to completion. Supports multiple entry points: idea, requirements,
  external PRD, existing design, or direct implementation.
  Orchestrates agents (idea-explorer, requirements-analyst, system-architect,
  feature-executor, code-reviewer) with cross-agent review via Codex.
  Manual invocation only.
---

# g-task-process Orchestrator

Lightweight orchestrator that routes to step-specific instructions via lazy loading.
Each step's details live in `steps/step-N-*.md` and are loaded only when needed.

---

## Flow Diagram

```mermaid
stateDiagram-v2
    [*] --> Entry: invoke /g-task-process

    Entry --> Ideation: "I have an idea"
    Entry --> Requirements: "I want to define requirements"
    Entry --> Design: "I have a PRD"
    Entry --> Breakdown: "Design is done"
    Entry --> Execution: "Just implement"

    state "Step 1: Ideation" as Ideation
    state "Step 2: Requirements -> PRD" as Requirements
    state "Step 3: Design -> TRD" as Design
    state "Step 4: Feature Breakdown" as Breakdown
    state "Step 5: Execution Loop" as Execution
    state "Step 6: Completion" as Completion

    Ideation --> Requirements: brainstorm.md + user confirm
    Requirements --> Review_PRD: PRD draft ready

    state "PRD Review (3-layer)" as Review_PRD {
        [*] --> Plannotator_PRD
        Plannotator_PRD --> User_Approve_PRD
        User_Approve_PRD --> Codex_Review_PRD
        Codex_Review_PRD --> [*]
    }

    Review_PRD --> Design: user confirm
    Review_PRD --> Requirements: revision requested

    Design --> Skip_TRD: no UI + single system
    Design --> Review_TRD: TRD draft ready
    Skip_TRD --> Breakdown

    state "TRD Review (3-layer)" as Review_TRD {
        [*] --> Plannotator_TRD
        Plannotator_TRD --> User_Approve_TRD
        User_Approve_TRD --> Codex_Review_TRD
        Codex_Review_TRD --> [*]
    }

    Review_TRD --> Breakdown: user confirm
    Review_TRD --> Design: revision requested

    Breakdown --> Review_Features: feature list ready

    state "Feature Review (2-layer)" as Review_Features {
        [*] --> Plannotator_Features
        Plannotator_Features --> User_Approve_Features
        User_Approve_Features --> Codex_Review_Features
        Codex_Review_Features --> [*]
    }

    Review_Features --> Execution: user confirm
    Review_Features --> Breakdown: revision requested

    state "Feature Execution" as Execution {
        [*] --> Pick_Feature
        Pick_Feature --> Implement: feature-executor
        Implement --> Cross_Review

        state "Cross Review" as Cross_Review {
            [*] --> code_review: code-reviewer
            [*] --> frontend_review: frontend-reviewer (if applicable)
            code_review --> [*]
            frontend_review --> [*]
        }

        Cross_Review --> Resolve
        Resolve --> Pick_Feature: next feature
        Resolve --> [*]: all features done
    }

    Execution --> Completion: all features done
    Completion --> Insight: summary done
    state "g-insight" as Insight
    Insight --> [*]: task complete
```

---

## Setup: Detect Work Directory

Resolve the work directory from the current project path:

- Path contains `GitHubWork` -> `~/Documents/GitHubWork/_claude/work-plan/`
- Path contains `GitHubPrivate` -> `~/Documents/GitHubPrivate/_claude/work-plan/`
- Otherwise -> ask the user to confirm which work directory to use.

Create a task subdirectory: `<work-dir>/YYYY-MM-DD-<repo>-<task-name>/`

---

## Session Restoration

1. Check if `_state.json` exists in the task directory.
2. **Exists**: Read it. Verify all `artifacts` paths exist on disk.
   - Announce: "Resuming task **<taskName>** at Step <currentStep>."
   - Load the step file for `currentStep`.
3. **Does not exist**: This is a new task. Load `steps/step-0-entry.md`.

---

## Output Format

에이전트를 위임하는 모든 step에서 `agent-guidelines.md`의 **Action Markers** 규칙을 반드시 따른다.
Agent tool 호출 시 `## 🤖 Agent:` 헤딩과 액션 유형별 이모지 마커를 적용한다.
병렬 실행 시에는 각 에이전트 블록에 `— parallel N/M` 접미사를 추가한다.

## Parallel Execution

step 내에서 독립적인 에이전트 작업이 2개 이상일 때 병렬 실행한다.
`agent-guidelines.md`의 병렬 실행 규칙을 따른다.

### Parallelizable Points

| Step | Condition | Parallel Agents |
|------|-----------|-----------------|
| 5b | Frontend 변경 포함 | code-reviewer ∥ frontend-reviewer |

---

## Step Router

Read ONLY the step file for the current step. Never preload other steps.

| currentStep | Load file              | Pre-condition guard                    |
|-------------|------------------------|----------------------------------------|
| 0           | steps/step-0-entry.md  | (none)                                 |
| 1           | steps/step-1-ideation.md | (none)                                |
| 2           | steps/step-2-requirements.md | `artifacts.brainstorm` OR user input exists |
| 3           | steps/step-3-design.md | `artifacts.prd` exists                 |
| 4           | steps/step-4-breakdown.md | `artifacts.prd` exists (trd optional) |
| 5           | steps/step-5-execution.md | `artifacts.features` exists           |
| 6           | steps/step-6-completion.md | all `features[].status == "done"`    |

**Pre-condition check**: Before loading a step file, verify its pre-condition.
If the condition is not met, warn the user and do NOT proceed.

---

## State Management

All state is persisted in `_state.json` within the task subdirectory.
See `schemas/state.md` for the full schema and update rules.

Key rules:
- Update `currentStep` BEFORE loading the next step file.
- Register artifact paths as soon as files are created.
- Record review mode/fallback/approval timestamps under `reviews`.
- Append to `history` at every state transition.

---

## Cross-Agent Review Protocol

| Artifact | 1st Review | 2nd Review |
|----------|-----------|-----------|
| brainstorm.md | User confirmation | - |
| PRD | Plannotator + User | Codex |
| TRD / architecture | Plannotator + User | Codex |
| Feature breakdown | Plannotator + User | Codex |
| Code (Claude impl.) | Codex (`/codex:review`) | frontend-reviewer (if applicable) |
| Code (Codex impl.) | Claude (`code-reviewer` agent) | frontend-reviewer (if applicable) |

---

## External Tool Dependencies

| Tool | Purpose | Fallback when unavailable |
|------|---------|--------------------------|
| Plannotator plugin + CLI (`plannotator`) | Visual review of documents/plans | Auto-fallback to text review, then continue |
| codex-plugin-cc | Cross-review, implementation delegation | Claude-only review/implementation |
| Codex CLI (`codex exec`) | Non-interactive task delegation | Claude agent handles directly |

Never stop the workflow because a tool is missing. Fall back gracefully.

---

## Review Mode Policy (Step 2/3/4)

For PRD/TRD/Feature breakdown reviews, always require mode selection:
1. Plannotator visual review (default)
2. Inline text review
3. Skip review

When mode 1 is selected:
- Check `plannotator` command availability first.
- If unavailable or launch fails, show a visible warning message and ask:
  `Continue with inline text review? (Y/n)`
- Only switch to mode 2 when the user confirms (default yes).
- Persist the final review mode and fallback reason in `_state.json.reviews`.
