# Step 5: Review + Cross-Review

Goal: Verify the refactoring result, offer cross-review, and suggest
follow-up actions if needed.

## 5a. Result Summary

Present the final state:

```
## Refactor Complete

### Changes Applied
| ID | Description | Files |
|----|-------------|-------|
| A1 | Extract API calls to service layer | UserProfile.tsx, userService.ts |
| T1 | Add User interface | types/user.ts |

### File Changes
- Modified: N files
- Created: N files
- Deleted: N files
```

## 5b. Optional Cross-Review

Offer cross-review via the global `code-reviewer` agent:

```
Would you like a cross-review of the refactored code?
1. Yes — run code-reviewer for an independent quality check
2. No — skip review
```

If yes:
- Dispatch the `code-reviewer` global agent with the diff context
- Include: what was changed, why (the rationale from Step 2), and the approved IDs
- If Codex is available, use cross-review protocol (Claude implemented → Codex reviews)
- Present review findings; if actionable issues found, offer to fix (max 2 rounds)

## 5c. Test Coverage Suggestion

If the refactoring included Architecture (A) or Deduplication (D) changes —
categories with higher risk of behavioral side effects:

```
This refactoring restructured code that may affect behavior.
Running tests is recommended to verify nothing broke.

1. Run existing tests now
2. Generate new tests with /g-test-writer
3. Skip — I'll verify manually
```

For Types (T) and Naming (N) only changes, this step is informational:
```
All changes were additive (types) or cosmetic (naming).
No behavioral risk — tests should pass without changes.
```

## 5d. Wrap Up

End with a brief summary of what was accomplished and any deferred items:

```
Refactoring complete:
- Applied: A1, T1, D1 (3 changes)
- Skipped: P1 (user deferred)

Deferred items can be revisited anytime with /g-refactor.
```
