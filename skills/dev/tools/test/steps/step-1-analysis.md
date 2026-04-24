# Step 1: Target Code Analysis

Goal: Understand the target code and determine the optimal testing approach.

## Input

One of the following:
- File path or function name provided by the user
- User description of what to test
- If nothing specified: ask the user (Single Choice pattern from task-process references)

## Process

### 1a. Detect Test Framework

Scan the project for test configuration:
- `jest.config.*`, `vitest.config.*`, `.mocharc.*`, `pytest.ini`, `setup.cfg`
- `package.json` test scripts, `tsconfig` paths
- Existing test files: `**/*.test.*`, `**/*.spec.*`, `**/__tests__/**`, `**/test_*`

If no framework detected: recommend one based on the project's tech stack and ask the user to confirm before proceeding.

### 1b. Analyze Target Code

Read the target file(s) and identify:
- **Type**: function, class, module, API endpoint, UI component, hook
- **Complexity**: number of branches, dependencies, side effects
- **Existing tests**: check if tests already exist for this code
- **Dependencies**: external services, database, file system, network

### 1c. Determine Approach

Based on the analysis, recommend an approach:

| Signal | Approach |
|--------|----------|
| New file, no implementation yet | TDD |
| Function/class with clear business logic | TDD |
| Bug fix (user describes a bug) | TDD (failing test first) |
| React/Vue/Svelte component with visual output | Storybook TDD |
| Existing code, no test files found | Test-After |
| Code marked as experimental, POC, or prototype | Defer (inform user) |
| External API client/wrapper | Present both options, let user decide |

### 1d. Present Recommendation

```
대상 코드를 분석했습니다:
- 파일: <path>
- 유형: <type>
- 복잡도: <low/medium/high>
- 기존 테스트: <있음 (coverage gap) / 없음>
- 테스트 프레임워크: <detected or recommended>

권장 접근 방식:
1. <recommended approach> — <reason>
2. <alternative approach> — <reason>

> 번호 입력 또는 자유 응답
```

## Output

Pass to Step 2:
- Target file path(s)
- Detected test framework and config
- Selected approach (TDD / Storybook TDD / Test-After)
- Existing test gap analysis (if tests exist)
- Key characteristics (complexity, dependencies, side effects)
