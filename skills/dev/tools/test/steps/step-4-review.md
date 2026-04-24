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
테스트 작성이 완료되었습니다:

파일: <test file path>
프레임워크: <framework>
접근 방식: <TDD / Storybook TDD / Test-After>

결과:
- 정상 케이스: X개 ✅
- 엣지 케이스: X개 ✅
- 에러 처리: X개 ✅
- 경계값: X개 ✅
- 합계: N개 테스트 (통과: X, 실패: X, 스킵: X)

<TDD인 경우>
다음 단계: 테스트를 통과시키는 최소 구현을 작성하세요.
Red-Green-Refactor 사이클을 따라 진행합니다.
```
