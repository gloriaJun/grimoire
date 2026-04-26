# Design: TRD

## Skip Condition

Skip if **both** are true:
- No UI or design changes involved
- Logic-only change within a single system or file

If skipping:
1. Set `artifacts.trd` to `"skipped"`
2. Inform the user and proceed to Breakdown

## Agent

`system-architect` (model: sonnet)

## Input

- `artifacts.prd` from `_state.json` (required)
- Existing codebase context
- Tech stack defaults: read `~/.claude/instructions/tech-stack.md` and pass relevant sections (JS/TS defaults, file conventions) to the agent prompt

## Process

1. Read `~/.claude/instructions/tech-stack.md` to extract JS/TS defaults and file conventions.
2. Invoke the `system-architect` agent with the PRD, codebase context, and tech stack defaults.
3. **Opus Advisor branch**: If the agent output contains the `[OPUS_ADVISOR_NEEDED]` flag:
   a. Ask the user to approve Opus advisor invocation:
      > This architecture decision requires Opus's judgment.
      > Opus will only provide direction; Sonnet writes the TRD.
      > Approve Opus invocation? (Y/n)
   b. If approved: invoke Opus as advisor (model: opus) → receive Direction Brief
      - Include the agent's analyzed options and judgment question in the Opus prompt
      - Specify: "Respond in Direction Brief format only"
   c. Re-invoke system-architect with the Direction Brief as context to produce the TRD
   d. If declined: system-architect proceeds with its own judgment (re-invoke)
4. The agent produces `TRD-<task-name>.md` (+ `architecture.md` if needed).
   - Location: same directory as PRD.
5. Register the TRD path in `_state.json` artifacts.

## Review

Load `references/review-protocol.md` and execute the full review workflow.
- **Artifact**: TRD at `artifacts.trd`
- **Codex focus**: "Review this TRD for technical feasibility, missing edge cases, and security concerns"

## State Update

`currentStep` ← `"wireframe"`, append `"design"` to `completedSteps`
`artifacts.trd` ← TRD path (or `"skipped"`)
`artifacts.testConfig` ← extracted from TRD Testing Strategy table (unit and e2e framework, configFile, command); set to `null` fields if TRD was skipped or framework not yet decided
`reviews.trd` ← `{ mode, fallbackReason, approvedAt }`

Follow update mechanics from `schemas/state.md`.

## Session Handoff

Read `steps/_handoff.md` and follow the handoff instructions.
Next sub-command: `/dev wireframe`
