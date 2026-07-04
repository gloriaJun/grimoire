# Build Flow B: Test-After

## Step B-1: Feature Execution

1. State which feature is being worked on.
2. Use the mini-design context for this feature (from `build.md` Step 1.5).
3. Invoke the `feature-executor` agent with:
   - The mini-design content (scope, AC, technical approach)
   - PRD and architecture.md paths for context
4. If the Agent result contains a worktree path and branch:
   store as `worktree_path` and `worktree_branch` in conversation context for handoff cleanup.
   Subsequent steps reference files under `worktree_path`.

## Step B-2: Test Generation

After implementation is complete:
1. Invoke `/dev test` with Test-After mode context:
   - Implemented code as target
   - `testConfig` (framework, config file)
2. Run `testConfig.unit.command` to verify tests pass.
   If tests fail → fix and retry (max 2 iterations).
   If still failing after 2 iterations: `Read("steps/build/stagnation-escape.md")`

## Step B-3: Simplify (Pre-Review)

1. Invoke the `simplify` skill on the changed files.
2. Wait for simplify to complete — code may be modified.

---

Flow complete — proceed to cross-review (`Read("steps/build/cross-review.md")`).
