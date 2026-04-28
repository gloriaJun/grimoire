# Breakdown: Feature Decomposition

Goal: Decompose work into features, each completable in a single session.

## Single-Session Principle

A feature is scoped so it can be fully implemented, tested, and committed within one Claude Code session. If a feature seems too large, split it further.

## Feature Sizing Heuristics

Use these as split signals — any one criterion triggers a split review:

| Signal | Threshold | Action |
|--------|-----------|--------|
| New files | > 5 files | Consider split |
| New code (est.) | > 300 LOC | Consider split |
| Distinct concerns | 3+ unrelated responsibilities | Split by concern |
| Test setup required | Needs new test infra (mocking layer, harness) | Extract as separate feature or sub-task |
| Blocking dependency | One half cannot be tested without the other half existing | Split and order sequentially |

**Split pattern:** if a feature has an "infrastructure" half and a "UI/behavior" half (e.g., store + component), prefer splitting into `F-Xa` (infra) and `F-Xb` (UI) before writing specs.

Do not split mechanically — a 4-file feature with tight cohesion is better kept together than split into two awkward halves.

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
   Derive the default strategy using this decision tree (override when rationale exists):

   | Feature type | Default strategy |
   |--------------|-----------------|
   | API clients, pure business logic, utility functions | TDD |
   | UI components, pages, hooks, routing | Test-After |
   | Config, Docker, infrastructure, scaffolding | Skip |

   Override when: (a) UI logic is complex enough to benefit from TDD, (b) infra has testable pure logic, (c) TRD specifies a different default.
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
