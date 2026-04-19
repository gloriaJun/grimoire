# Step 5: Feature Execution (per feature loop)

Execute features one at a time, in order.

## Loop: For Each Feature in `_state.json.features` where `status != "done"`

### 5a. Implementation

1. State which feature is being worked on.
2. Read the feature spec from `artifacts.featureSpecs[index]`.
3. Invoke the `feature-executor` agent (model: sonnet) with:
   - The feature spec content
   - PRD and TRD paths for context
4. The feature-executor asks the user to choose implementation agent (default: Codex). See agent prompt for numbered choice format.
5. Update `features[i].status` to `"in-progress"` and set `executor`.
6. Implementation proceeds based on user choice.

### 5a-2. Simplify (Pre-Review)

Before cross-review, clean up the implementation:

1. Invoke the `simplify` skill on the changed files.
2. Wait for simplify to complete — code may be modified.
3. Proceed to 5b with the simplified code.

### 5b. Cross-Review

After implementation, update `features[i].status` to `"review"`:

| Executor | Reviewer | Method |
|----------|----------|--------|
| Claude | Codex | Invoke `code-reviewer` agent -> delegates to `/codex:review` |
| Codex | Claude | Invoke `code-reviewer` agent -> reviews with Claude |

Set `features[i].reviewer` accordingly.

### Parallel Review (when frontend changes exist)

If the feature involves frontend changes, invoke both reviewers **in parallel**:

1. Dispatch `code-reviewer` and `frontend-reviewer` simultaneously (single message, 2 Agent tool calls).
2. Apply action markers per `agent-guidelines.md` (parallel dispatch format).
3. Wait for both to complete, then aggregate findings.

### Sequential Review (no frontend changes)

If no frontend changes, invoke only `code-reviewer`.

### 5c. Review Resolution

1. Present review findings to the user.
2. If changes requested: fix and re-review (max 2 iterations).
3. Update `features[i].status` to `"done"`.
4. Log to `history`.

**Confirm with user before starting the next feature.**

## Loop Exit

When all features have `status: "done"`:
1. Set `currentStep` to `6`
2. Append `5` to `completedSteps`
