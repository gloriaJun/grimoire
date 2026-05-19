# Build Flow B: Test-After

## Step B-1: Feature Execution

1. State which feature is being worked on.
2. Read the feature spec from `artifacts.featureSpecs[index]`.
3. Invoke the `feature-executor` agent (model: sonnet) with:
   - The feature spec content
   - PRD and TRD paths for context
4. The feature-executor asks the user to choose implementation agent (default: Codex).
5. Set `features[i].executor` in `_state.json`.
6. Implementation proceeds based on user choice.

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
