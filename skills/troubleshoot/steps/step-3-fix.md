# Step 3: Fix Recommendations

Goal: Present actionable fix options with clear trade-offs, implement the
user's choice, and optionally cross-review the result.

## Input

From Step 2:
- Root cause explanation
- Code flow and recurrence conditions

## 3a. Generate Fix Options

Analyze the root cause and produce fix recommendations.

**Single viable fix**: Present it directly with implementation details.

**Multiple approaches (2+)**: Present each option in this format:

```
## Fix Options

### Option 1: <title>
- **Approach**: what to change and how
- **Pros**: advantages of this approach
- **Cons**: disadvantages or risks
- **Impact**: affected files/components, risk level (low/medium/high)
- **Error handling**: how errors are handled in this approach

### Option 2: <title>
- (same structure)
```

Every option must include error handling considerations — a fix that silences
errors without handling them properly is not a fix.

## 3b. User Selection

```
Which fix would you like to apply?
> Enter option number or describe a different approach
```

## 3c. Implement the Fix

1. Apply the selected fix
2. Verify the fix resolves the original error (re-run, check logs, etc.)
3. Check for regressions in related functionality

## 3d. Optional Cross-Review

After implementation, offer cross-review:

```
Do you want a cross-review of this fix?
1. Yes — run code-reviewer / Codex review
2. No — proceed to prevention tests
```

If yes:
- Dispatch the `code-reviewer` global agent with the diff and root cause context
- If Codex is available, use the cross-review protocol (Claude impl → Codex review)
- Present review findings; if changes needed, iterate (max 2 rounds)

If no or if code-reviewer is unavailable: proceed to Step 4.

**Confirm with user before proceeding to Step 4.**
