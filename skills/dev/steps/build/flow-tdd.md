# Build Flow A: TDD (Red-Green-Refactor)

## Step A-0: Write Failing Tests

1. State which feature is being worked on.
2. Use the mini-design context for this feature (from `build.md` Step 1.5).
3. Invoke `/dev test` with TDD mode context:
   - Mini-design acceptance criteria → test case design
   - `testConfig` (framework, config file)
   - Goal: write **failing** tests only — no implementation yet
4. Run `testConfig.unit.command` to confirm tests fail (expected at this stage).

## Step A-1: Feature Execution

1. Invoke the `feature-executor` agent with:
   - The mini-design content (scope, AC, technical approach)
   - PRD and architecture.md paths for context
   - `testingApproach: "TDD"` — implement only what is needed to pass the failing tests
   - `testConfig` for framework context
2. If the Agent result contains a worktree path and branch:
   store as `worktree_path` and `worktree_branch` in conversation context for handoff cleanup.
   Subsequent steps reference files under `worktree_path`.

## Step A-2: Test Pass Confirmation

1. Run `testConfig.unit.command`.
2. If all tests pass → proceed to Step A-3.
3. If tests fail → return to feature-executor for fixes (max 2 iterations).
   If still failing after 2 iterations: `Read("steps/build/stagnation-escape.md")`

## Step A-3: Refactor

Invite the user: "Any refactoring needed before review? (skip to continue)"
If the user proceeds: apply structural cleanup without changing behavior, then re-run tests.

## Step A-4: Simplify (Pre-Review)

1. Invoke the `simplify` skill on the changed files.
2. Wait for simplify to complete — code may be modified.

---

Flow complete — proceed to cross-review (`Read("steps/build/cross-review.md")`).
