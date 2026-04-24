# Step 4: Run & Review

Goal: Execute the generated tests, analyze results, and refine.

## Process

### 4a. Run Tests

Execute using the detected test framework:

- **jest**: `npx jest <test-file> --verbose`
- **vitest**: `npx vitest run <test-file>`
- **mocha**: `npx mocha <test-file>`
- **pytest**: `python -m pytest <test-file> -v`
- **Storybook**: `npx storybook dev` (inform user to check visually)

If the test runner is not available or fails to start, inform the user and provide manual run instructions.

### 4b. Analyze Results

**TDD approach (tests expected to fail):**
- RED phase: all tests should fail — this is correct
- Present the failure summary and guide the user to implement (or offer to implement)
- After implementation: re-run to confirm GREEN phase
- GREEN phase: all tests pass — proceed to refactor suggestions

**Storybook TDD (stories expected to not render):**
- Confirm stories are syntactically valid
- Interaction tests: run via `npx test-storybook` if available
- Guide the user to implement the component

**Test-After approach (tests expected to pass):**
- All tests should pass since they test existing behavior
- Failures indicate either a test bug or a discovered code bug
- For each failure: determine if it's a test issue or a real bug

### 4c. Fix Failures (if unexpected)

For each unexpected failure:
1. Read the error message and stack trace
2. Determine root cause: test issue vs code issue
3. If test issue: fix the test and re-run
4. If code issue: flag to the user (do not fix code without confirmation)

Max 3 fix iterations. If still failing after 3 attempts, present the situation to the user.

### 4d. Self-Review Checklist

Before declaring completion, verify:

- [ ] All test names are descriptive and follow `should <behavior> when <condition>`
- [ ] Each category (normal, edge, error, boundary) has at least 1 test
- [ ] No tests depend on execution order
- [ ] Mocks are minimal and scoped
- [ ] No flaky patterns (timers, random, network without mock)
- [ ] Test file follows project conventions

### 4e. Completion Summary

```
Tests complete:

File: <test file path>
Framework: <framework>
Approach: <TDD / Storybook TDD / Test-After>

Results:
- Normal cases: X ✅
- Edge cases: X ✅
- Error handling: X ✅
- Boundary values: X ✅
- Total: N tests (passed: X, failed: X, skipped: X)

<If TDD>
Next: write the minimum implementation to make tests pass.
Follow the Red-Green-Refactor cycle.
```
