# Breakdown: Feature Decomposition

Goal: Decompose work into features, each completable in a single session.

## Single-Session Principle

A feature is scoped so it can be fully implemented, tested, and committed within one Claude Code session. If a feature seems too large, split it further.

## Input

From `_state.json` artifacts:
- `artifacts.prd` (required)
- `artifacts.trd` (optional, may be `"skipped"`)
- `artifacts.wireframe` (optional, may be `"skipped"`)

## Process

> Performed inline by the orchestrator — no agent delegation. Breakdown requires simultaneous
> reasoning over the full PRD + TRD context; agent dispatch adds overhead without benefit at this scale.

1. Based on PRD + TRD + wireframe (if available), produce a numbered feature list:
   - If wireframe exists: decompose at screen/component granularity using the mockup as reference
   - Feature name, brief description, files/modules affected, acceptance criteria
2. Write `features.md` in the task subdirectory.
3. Write individual `feature-XX-<name>.md` files with detailed specs.
   Each spec must include a **Testing Approach** section:
   ```markdown
   ## Testing Approach
   - Strategy: TDD | Test-After | Skip
   - Reason: <why this approach for this feature>
   - Test scope: <unit only | unit + e2e | e2e only>
   ```
   Derive the default strategy from the TRD Testing Strategy. Override per-feature when rationale exists.
   If `artifacts.testConfig` is null, ask the user to supply framework info before proceeding.
4. Register paths in `_state.json`:
   - `artifacts.features` ← `"features.md"`
   - `artifacts.featureSpecs` ← array of spec filenames
   - `features` ← array of feature objects with `status: "pending"` and `testingApproach` from each spec

## Review

Load `references/review-protocol.md` and execute the full review workflow.
- **Artifact**: feature breakdown at `artifacts.features`
- **Codex focus**: "Review this feature breakdown for missing features, session-scoping issues, and dependency ordering"

## State Update

`currentStep` ← `"build"`, append `"breakdown"` to `completedSteps`
`artifacts.features` ← features.md path
`artifacts.featureSpecs` ← array of spec filenames
`features` ← array with `status: "pending"` and `testingApproach` from each feature spec
`reviews.features` ← `{ mode, fallbackReason, approvedAt }`

Follow update mechanics from `schemas/state.md`.

## Session Handoff

Read `steps/_handoff.md` and follow the handoff instructions.
Next sub-command: `/dev build`
