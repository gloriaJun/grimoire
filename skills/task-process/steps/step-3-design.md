# Step 3: Design -> TRD (system-architect agent)

## Skip Condition

Skip if **both** are true:
- No UI or design changes involved
- Logic-only change within a single system or file

If skipping:
1. Set `artifacts.trd` to `"skipped"`
2. Inform the user and proceed to Step 4

## Agent

`system-architect` (model: sonnet)

## Input

- `artifacts.prd` from `_state.json` (required)
- Existing codebase context

## Process

1. Invoke the `system-architect` agent with the PRD and codebase context.
2. The agent produces `TRD-<task-name>.md` (+ `architecture.md` if needed).
   - Location: same directory as PRD.
3. Register the TRD path in `_state.json` artifacts.

## Review (3-layer)

1. **Review mode selection (required)**: Ask the user to choose one mode.
   - 1) Plannotator visual review (default)
   - 2) Inline text review
   - 3) Skip review
2. **Plannotator attempt (when mode=1)**:
   - Check `plannotator` command availability first.
   - If available, run Plannotator review on the TRD.
   - If unavailable or launch fails, show a visible warning and ask confirmation:
     - `[WARN] Plannotator CLI is unavailable. Switching to inline text review.`
     - `Continue with inline text review? (Y/n)`
   - If user says no: stay in this step and let the user choose retry/skip.
   - If user says yes (or default): fall back to inline text review.
3. **User approval**: Wait for approval or changes.
   - If revision requested: re-invoke agent, do NOT advance step.
4. **Codex cross-review**: Request Codex review of TRD.
   - Focus: technical feasibility, missing edge cases, security concerns.
   - If Codex is not available (Bash restricted or CLI missing):
     - Invoke `code-reviewer` agent (model: sonnet) for cross-review instead.
     - Note the fallback in `_state.json` history.
5. Present review results -> user decides whether to incorporate.

## State Update

After user confirms:
1. Set `currentStep` to `4`
2. Append `3` to `completedSteps`
3. Verify `artifacts.trd` is set (or `"skipped"`)
4. Record review metadata in `_state.json.reviews.trd`:
   - `mode`: `plannotator | text | skipped`
   - `fallbackReason`: `plannotator_cli_unavailable | plannotator_launch_failed | null`
   - `approvedAt`: ISO 8601
5. Log to `history`

**Confirm with user before proceeding to Step 4.**
