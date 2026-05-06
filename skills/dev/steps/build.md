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

### Pre-check: Testing Approach

1. Read `features[i].testingApproach` from `_state.json`.
2. Read `artifacts.testConfig` for framework and run command.
   If `testConfig` is null, warn the user and ask for framework details before proceeding.
3. Proceed to the matching flow (A: TDD, B: Test-After, C: Skip).

---

### Flow A: TDD (Red-Green-Refactor)

**Step A-0: Write Failing Tests**

1. State which feature is being worked on.
2. Read the feature spec from `artifacts.featureSpecs[index]`.
3. Invoke `/dev test` with TDD mode context:
   - Feature spec (acceptance criteria → test case design)
   - `testConfig` (framework, config file)
   - Goal: write **failing** tests only — no implementation yet
4. Run `testConfig.unit.command` to confirm tests fail (expected at this stage).

**Step A-1: Feature Execution**

1. Invoke the `feature-executor` agent (model: sonnet) with:
   - The feature spec content
   - PRD and TRD paths for context
   - `testingApproach: "TDD"` — implement only what is needed to pass the failing tests
   - `testConfig` for framework context
2. The feature-executor asks the user to choose implementation agent (default: Codex).
3. Set `features[i].executor` in `_state.json`.
4. Implementation proceeds based on user choice.

**Step A-2: Test Pass Confirmation**

1. Run `testConfig.unit.command`.
2. If all tests pass → proceed to Step A-3.
3. If tests fail → return to feature-executor for fixes (max 2 iterations).
   If still failing after 2 iterations, surface failures to the user and ask how to proceed.

**Step A-3: Refactor**

Invite the user: "Any refactoring needed before review? (skip to continue)"
If the user proceeds: apply structural cleanup without changing behavior, then re-run tests.

**Step A-4: Simplify (Pre-Review)**

1. Invoke the `simplify` skill on the changed files.
2. Wait for simplify to complete — code may be modified.
3. Proceed to cross-review with the simplified code.

---

### Flow B: Test-After

**Step B-1: Feature Execution**

1. State which feature is being worked on.
2. Read the feature spec from `artifacts.featureSpecs[index]`.
3. Invoke the `feature-executor` agent (model: sonnet) with:
   - The feature spec content
   - PRD and TRD paths for context
4. The feature-executor asks the user to choose implementation agent (default: Codex).
5. Set `features[i].executor` in `_state.json`.
6. Implementation proceeds based on user choice.

**Step B-2: Test Generation**

After implementation is complete:
1. Invoke `/dev test` with Test-After mode context:
   - Implemented code as target
   - `testConfig` (framework, config file)
2. Run `testConfig.unit.command` to verify tests pass.

**Step B-3: Simplify (Pre-Review)**

1. Invoke the `simplify` skill on the changed files.
2. Wait for simplify to complete — code may be modified.
3. Proceed to cross-review with the simplified code.

---

### Flow C: Skip

**Step C-1: Feature Execution**

1. State which feature is being worked on.
2. Read the feature spec from `artifacts.featureSpecs[index]`.
3. Invoke the `feature-executor` agent (model: sonnet) with:
   - The feature spec content
   - PRD and TRD paths for context
4. The feature-executor asks the user to choose implementation agent (default: Codex).
5. Set `features[i].executor` in `_state.json`.

**Step C-2: Simplify (Pre-Review)**

1. Invoke the `simplify` skill on the changed files.
2. Wait for simplify to complete — code may be modified.
3. Proceed to cross-review with the simplified code.

---

## Cross-Review (all flows)

After simplify completes, update `features[i].status` to `"review"`.

| Executor | Reviewer | Method |
|----------|----------|--------|
| Claude | Codex | Invoke `code-reviewer` agent → delegates to `/codex:review` |
| Codex | Claude | Invoke `code-reviewer` agent → reviews with Claude |

Set `features[i].reviewer` accordingly.

### Parallel Review (frontend changes exist)

Dispatch `code-reviewer` and `frontend-reviewer` simultaneously (single message, 2 Agent tool calls).
Apply action markers per `agent-guidelines.md`. Wait for both, then aggregate findings.

### Sequential Review (no frontend changes)

Invoke only `code-reviewer`.

## Review Resolution

1. Present review findings to the user.
2. If changes requested: fix and re-review (max 2 iterations).
3. Update `features[i].status` to `"done"`.

---

## Local Verification Checkpoint

Run after Review Resolution, for every feature regardless of testingApproach.

### Step 1: testingApproach별 확인

| testingApproach | 확인 항목 |
|-----------------|-----------|
| `skip` | 대상 파일 존재 확인 + 가능하면 lint |
| `test-after` | Flow B-2에서 테스트 통과 재확인 |
| `tdd` | Flow A-2에서 테스트 통과 재확인 |

`skip` 피처의 lint 확인:
```bash
pnpm nx lint <project-name>
```
node_modules 미설치로 실행 불가 시: 사유를 명시하고 F-09(build/deploy) 단계로 검증 defer.

### Step 2: 로컬 UI 미리보기 가능 여부 안내

아래 중 하나를 명시적으로 출력한다:

- **미리보기 가능**: 이 feature로 navigable page 또는 visible UI가 생긴 경우
  ```
  🖥️  로컬에서 확인 가능합니다:
  pnpm nx dev <project-name>  →  http://localhost:<port>
  확인 항목: <spec의 acceptance criteria 중 UI 관련 항목>
  ```
- **미리보기 불가**: 타입, 유틸, API client, 상수 등 직접 UI 없는 경우
  ```
  ⏭️  로컬 UI 확인: F-XX (<feature-name>) 완료 후 가능합니다.
  ```

사용자 확인을 기다리지 않고 다음 단계로 진행한다 (미리보기 가능 케이스만 대기).

---

## UI Verification (frontend changes only)

### Trigger Condition

Check whether this feature introduced visible UI. Apply **either** heuristic:
- Changed/added files include at least one non-test `.tsx` file (e.g., `.tsx` but not `.test.tsx`)
- Feature spec explicitly mentions pages, components, layouts, or UI elements

If neither applies (pure logic, API clients, config, infra) → skip this section entirely.

### Verification Flow

1. Start the dev server if not already running:
   ```
   pnpm dev
   ```
2. Present a concise checklist derived from the feature spec's **acceptance criteria**:
   ```
   🖥️  UI Verification — <feature name>
   Please check the following in your browser:

   [ ] <criterion 1 — e.g., "/ → /dashboard 자동 리다이렉트">
   [ ] <criterion 2>
   ...

   Run: pnpm dev → http://localhost:5173
   Confirm when done (or describe any issues found).
   ```
3. Wait for user response.
4. **If all good** → proceed to Session Handoff.
5. **If issues found** → fix, then re-present the checklist (max 1 re-verify iteration).
   - If still failing after 1 fix: surface to user and ask how to proceed.

---

## Session Handoff

### State Update

- `features[i].status` ← `"done"`, `features[i].executor/reviewer` ← from selection
- If all features done: `currentStep` ← `"complete"`, append `"build"` to `completedSteps`
- Append to `history`

### Feature Spec Update

- Open the completed feature's spec file (`artifacts.featureSpecs[i]`).
- Mark all implemented checklist items: `[ ]` → `[x]`.
- If the actual implementation diverges from the spec (design change, extra commands, different storage strategy, etc.):
  - Add a `> **구현 변경**:` callout block at the top of the spec explaining the deviation and reason.
  - Update affected sections (file paths, interfaces, verification steps) to match reality.
- If implementation matches spec exactly: only update the checklist.

### next-session.md Update

- Move the completed feature from "잔여" to "완료된 Feature" table (with branch name).
- Update "잔여 Feature 목록" — remove done items, mark the next recommended feature as `next`.
- Update "현재 코드베이스 주요 파일" to reflect any new or changed files introduced by this feature.
- Update frontmatter `updated:` to today's date and `branch:` to current branch.

### _index.md Update

- Find the row matching the current task directory in `<devlogs-root>/_index.md`
- If more features pending: update step column to `build (N/M done)`
- If all done: update step column to `complete`
- Update frontmatter `updated:` to today's date

### Completion Message

```
✅ feature-<XX> complete

Remaining: N feature(s) pending

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Next:  /dev build      (more features remain)
  OR
Next:  /dev complete   (all features done)
Start a new session and run `/dev` — it will detect this task automatically.
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

Do NOT automatically start the next feature. Stop here.
