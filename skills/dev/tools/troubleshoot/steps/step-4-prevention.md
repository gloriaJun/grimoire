# Step 4: Prevention Tests

Goal: Write focused regression tests that prevent this specific error from
recurring, and escalate to `/dev test` if broader coverage is needed.

## Input

From Step 3:
- Implemented fix (files changed, approach taken)
- Root cause (What / Where / Why)

## 4a. Detect Test Framework

Scan the project for test configuration:
- `jest.config.*`, `vitest.config.*`, `pytest.ini`, `setup.cfg`
- `package.json` test scripts
- Existing test files: `**/*.test.*`, `**/*.spec.*`, `**/test_*`

If no framework detected: recommend one based on the project stack and confirm
with the user before writing tests.

## 4b. Write Regression Tests (1-3 cases)

Write focused tests that cover:

1. **Error reproduction test**: A test that would have failed before the fix
   (reproduces the original error condition)
2. **Fix verification test**: A test that confirms the fix works correctly
   under the same conditions
3. **Edge case test** (if applicable): A variation of the error condition
   that could bypass the fix

Each test should:
- Have a descriptive name that references the error (e.g., `should not throw when user data is null`)
- Be self-contained — no dependency on other tests
- Follow the project's existing test conventions (naming, structure, patterns)

## 4c. Run and Verify

1. Run the new tests — they should all pass
2. Run the existing test suite to confirm no regressions
3. If tests fail, diagnose and fix before proceeding

## 4d. When Test Writing Is Difficult

If regression tests cannot be written, explain why with specific rationale:

| Reason | Example | Alternative |
|--------|---------|-------------|
| External service dependency | Error occurs only with live third-party API | Add monitoring/alerting rule |
| Non-deterministic condition | Race condition, timing-dependent | Add logging + document manual test procedure |
| Infrastructure-level issue | DNS resolution, network partition | Add health check or retry with backoff |
| No test framework in project | Legacy project, no test setup | Propose adding minimal test setup as follow-up |

Always suggest a concrete alternative when tests are impractical.

## 4e. Escalation to /dev test

If the fix touches multiple modules or the root cause suggests systemic issues:

```
This fix affects a wide area. Consider running /dev test for
comprehensive test coverage of the affected module(s).

Affected areas:
- <module/file 1>
- <module/file 2>

Run /dev test now?
1. Yes — launch comprehensive test generation
2. No — regression tests are sufficient
```

## Output

```
## Prevention Summary
- Tests added: <count>
- Test files: <paths>
- All tests passing: yes/no
- Broader coverage needed: yes/no
```

---

## Completion

After presenting the Prevention Summary (and handling /dev test escalation if chosen):

**Vault save suggestion** — error-analysis / debug mode only (skip for performance mode):

```
이 트러블슈팅 내용을 회고 노트로 정리할까요? (y/n)
```

- **y**: Load `tools/retro/SKILL.md` and run in standalone mode with pre-filled context:
  - `task-name`: derived from error/issue title (from Step 0 triage)
  - `keywords`: error messages, package names, symptom descriptors from triage
  - `## 트러블슈팅` section: pre-fill `증상` (triage summary), `원인` (Step 1), `해결` (Step 3)
  - Audience selection prompt still shown — user chooses personal/team
- **n**: End. No further action.
