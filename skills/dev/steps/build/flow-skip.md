# Build Flow C: Skip (No Tests)

## Step C-1: Feature Execution

1. State which feature is being worked on.
2. Read the feature spec from `artifacts.featureSpecs[index]`.
3. Invoke the `feature-executor` agent (model: sonnet) with:
   - The feature spec content
   - PRD and TRD paths for context
4. The feature-executor asks the user to choose implementation agent (default: Codex).
5. Set `features[i].executor` in `_state.json`.

## Step C-2: Simplify (Pre-Review)

1. Invoke the `simplify` skill on the changed files.
2. Wait for simplify to complete — code may be modified.

---

Flow complete — proceed to cross-review (`Read("steps/build/cross-review.md")`).
