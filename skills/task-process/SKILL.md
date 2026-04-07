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

# g-task-process Skill

Single orchestrator managing the full lifecycle from ideation to completion.
Each step is handled by an independent agent. Confirmation required at every step.

---

## Setup: Detect Work Directory

Resolve the work directory from the current project path:

- Path contains `GitHubWork` -> `~/Documents/GitHubWork/_claude/work-plan/`
- Path contains `GitHubPrivate` -> `~/Documents/GitHubPrivate/_claude/work-plan/`
- Otherwise -> ask the user to confirm which work directory to use.

Create a task subdirectory: `<work-dir>/YYYY-MM-DD-<repo>-<task-name>/`

Read `_index.md` in the work directory at session start (if it exists) to resume any active tasks.

---

## Step 0: Entry Point Selection

Ask the user to select their starting point:

| Choice | What you have | Starts at |
|--------|--------------|-----------|
| "I have an idea" | Vague concept | Step 1 (idea-explorer) |
| "I want to define requirements" | Rough requirements | Step 2 (requirements-analyst) |
| "I have a PRD / planning doc" | External PRD | Step 3 (system-architect) |
| "Design is done" | PRD + TRD | Step 4 (feature breakdown) |
| "Just implement" | Clear scope | Step 5 (feature-executor) |

If the user has an external document (planning doc, PRD, etc.):
- Ask for the file path
- Copy or link it into the task subdirectory
- Use it as input for the appropriate agent

**Confirm selection with user before proceeding.**

---

## Step 1: Ideation (idea-explorer agent)

Goal: Expand a vague idea into concrete directions.

1. Invoke the `idea-explorer` agent with the user's idea description.
2. The agent produces `brainstorm.md` in the task subdirectory.
3. Present `brainstorm.md` to the user.

**Confirm with user before proceeding to Step 2.**

---

## Step 2: Requirements -> PRD (requirements-analyst agent)

Goal: Structure requirements into a formal PRD.

### Input
- `brainstorm.md` (from Step 1), OR
- User's requirements description, OR
- External planning document

### Process
1. Invoke the `requirements-analyst` agent with available inputs.
2. The agent produces `PRD-<task-name>.md`.
   - Location: project `docs/` if it exists, otherwise task subdirectory.

### Review (3-layer)
1. **Plannotator**: Open PRD in Plannotator for visual review.
   - If Plannotator is not available, present the PRD as text.
2. **User approval**: Wait for user to approve or request changes.
3. **Codex cross-review**: After user approval, request Codex review.
   - Via codex-plugin-cc: `/codex:rescue "Review this PRD for missing requirements, ambiguity, and feasibility: <path>"`
   - Via Codex CLI: `codex exec --read <PRD-path> "Review this PRD: identify missing requirements, ambiguous items, and feasibility concerns"`
   - If Codex is not available, skip and note it.
4. Present Codex review results -> user decides whether to incorporate.

**Confirm with user before proceeding to Step 3.**

---

## Step 3: Design -> TRD (system-architect agent)

### Skip Condition
Skip if **both** are true:
- No UI or design changes involved
- Logic-only change within a single system or file

If skipping, inform the user and proceed to Step 4.

### Input
- `PRD-<task-name>.md` (from Step 2 or external)
- Existing codebase context

### Process
1. Invoke the `system-architect` agent with the PRD and codebase context.
2. The agent produces `TRD-<task-name>.md` (+ `architecture.md` if needed).
   - Location: same as PRD.

### Review (3-layer)
1. **Plannotator**: Open TRD in Plannotator for visual review.
2. **User approval**: Wait for approval or changes.
3. **Codex cross-review**: Request Codex review of TRD.
   - Focus: technical feasibility, missing edge cases, security concerns.
4. Present Codex review results -> user decides whether to incorporate.

**Confirm with user before proceeding to Step 4.**

---

## Step 4: Feature Breakdown

Goal: Decompose work into features, each completable in a single session.

### Single-Session Principle
A feature is scoped so it can be fully implemented, tested, and committed within one Claude Code session. If a feature seems too large, split it further.

### Process
1. Based on PRD + TRD, produce a numbered feature list:
   - Feature name
   - Brief description
   - Files or modules affected
   - Acceptance criteria (from PRD)
2. Write `features.md` in the task subdirectory.
3. Write individual `feature-XX-<name>.md` files with detailed specs.
4. **Plannotator**: Open feature breakdown for visual review.
5. Update `_index.md` with task entry (status: `in-progress`).

**Confirm with user before proceeding to Step 5.**

---

## Step 5: Feature Execution (feature-executor agent, per feature)

Execute features one at a time, in order.

### Per Feature:

#### 5a. Implementation
1. State which feature is being worked on.
2. Invoke the `feature-executor` agent with:
   - The feature spec (`feature-XX-<name>.md`)
   - PRD and TRD paths for context
3. The feature-executor asks the user: **Claude or Codex** for implementation.
4. Implementation proceeds based on user choice.

#### 5b. Cross-Review
After implementation:
- **Claude implemented** -> invoke `code-reviewer` agent, which delegates to `/codex:review`
- **Codex implemented** -> invoke `code-reviewer` agent, which reviews with Claude

If the feature involves frontend changes:
- Additionally invoke `frontend-reviewer` agent.

#### 5c. Review Resolution
1. Present review findings to the user.
2. If changes requested: fix and re-review (max 2 iterations).
3. Update `_index.md` to mark the feature complete.

**Confirm with user before starting the next feature.**

---

## Step 6: Completion

When all features are done:

1. Final update of PRD and TRD to reflect any changes made during execution.
2. Update `_index.md`: mark the task as `complete`.
3. If documents were saved in the task subdirectory (temporary):
   - Ask: "These files were saved temporarily. Delete, keep, or move?"
   - Delete only after explicit confirmation.
4. Present summary: what was built, files changed, follow-up items.

---

## Cross-Agent Review Protocol

| Artifact | 1st Review | 2nd Review |
|----------|-----------|-----------|
| brainstorm.md | User confirmation | - |
| PRD | Plannotator + User | Codex |
| TRD / architecture | Plannotator + User | Codex |
| Feature breakdown | Plannotator + User | - |
| Code (Claude impl.) | Codex (`/codex:review`) | frontend-reviewer (if applicable) |
| Code (Codex impl.) | Claude (`code-reviewer` agent) | frontend-reviewer (if applicable) |

---

## External Tool Dependencies

| Tool | Purpose | Fallback when unavailable |
|------|---------|--------------------------|
| Plannotator plugin | Visual review of documents/plans | Present as text, user reviews inline |
| codex-plugin-cc | Cross-review, implementation delegation | Claude-only review/implementation |
| Codex CLI (`codex exec`) | Non-interactive task delegation | Claude agent handles directly |

Never stop the workflow because a tool is missing. Fall back gracefully.

---

## _index.md Schema

```markdown
# Claude Work Index

## Active Tasks

### <task-name>
- Status: in-progress | complete
- Entry: idea | requirements | external-prd | design | direct
- PRD: <path> | external:<path>
- TRD: <path> | skipped
- Features:
  - [ ] Feature 1 (executor: claude | codex)
  - [x] Feature 2 (executor: codex, reviewer: claude)
```
