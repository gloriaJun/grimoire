# Build: Feature Execution

Execute one feature per session.

## Session Start: Feature Selection

1. Read `_state.json` from the devlogs task subdirectory.
2. Display pending features:
   ```
   Pending features:
   [ ] feature-01-<name>
   [ ] feature-02-<name>
   ...

   Which feature would you like to work on? (enter number or name)
   ```
3. Wait for user selection.
4. Update `features[i].status` to `"in-progress"` in `_state.json`.

## Implementation

### Step A: Feature Execution

1. State which feature is being worked on.
2. Read the feature spec from `artifacts.featureSpecs[index]`.
3. Invoke the `feature-executor` agent (model: sonnet) with:
   - The feature spec content
   - PRD and TRD paths for context
4. The feature-executor asks the user to choose implementation agent (default: Codex). See agent prompt for numbered choice format.
5. Set `features[i].executor` in `_state.json`.
6. Implementation proceeds based on user choice.

### Step A-2: Simplify (Pre-Review)

Before cross-review, clean up the implementation:

1. Invoke the `simplify` skill on the changed files.
2. Wait for simplify to complete — code may be modified.
3. Proceed to cross-review with the simplified code.

### Step B: Cross-Review

After implementation, update `features[i].status` to `"review"`:

| Executor | Reviewer | Method |
|----------|----------|--------|
| Claude | Codex | Invoke `code-reviewer` agent -> delegates to `/codex:review` |
| Codex | Claude | Invoke `code-reviewer` agent -> reviews with Claude |

Set `features[i].reviewer` accordingly.

#### Parallel Review (when frontend changes exist)

If the feature involves frontend changes, invoke both reviewers **in parallel**:

1. Dispatch `code-reviewer` and `frontend-reviewer` simultaneously (single message, 2 Agent tool calls).
2. Apply action markers per `agent-guidelines.md` (parallel dispatch format).
3. Wait for both to complete, then aggregate findings.

#### Sequential Review (no frontend changes)

If no frontend changes, invoke only `code-reviewer`.

### Step C: Review Resolution

1. Present review findings to the user.
2. If changes requested: fix and re-review (max 2 iterations).
3. Update `features[i].status` to `"done"`.
4. Log to `history` in `_state.json`.

## Feature Complete

After the feature is marked `"done"`, display:

```
✅ feature-XX complete

Remaining: N feature(s) pending
Next: `/dev build` in a new session to continue, or `/dev complete` if all done.
```

Do NOT automatically start the next feature. This session ends here.

## State Update (on completion)

1. Verify `features[i].status` is `"done"`
2. If all features are done:
   - Set `currentStep` to `6`
   - Append `5` to `completedSteps`
3. Log to `history`

Paths: devlogs task subdirectory for `_state.json`.

## Session Handoff

Read `steps/_handoff.md` and follow the handoff instructions for this step.
