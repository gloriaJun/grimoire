# Build: Local Verification & UI Verification

Run after cross-review, for every feature regardless of testingApproach.

## Local Verification Checkpoint

### Step 1: testingApproach별 확인

| testingApproach | 확인 항목 |
|-----------------|-----------|
| `skip` | 대상 파일 존재 확인 + 가능하면 lint |
| `test-after` | Flow B-2에서 테스트 통과 재확인 |
| `tdd` | Flow A-2에서 테스트 통과 재확인 |

`skip` 피처의 lint 확인 — 다음 우선순위로 명령을 결정한다 (detect-on-demand):

1. `package.json` scripts에 `lint` 있으면 → `pnpm lint` (또는 해당 패키지 매니저 명령)
2. nx monorepo 감지 시 (`nx.json` 존재) → `pnpm nx lint <project-name>`
3. `eslint.config.*` 또는 `.eslintrc.*` 존재 시 → `pnpm eslint .`
4. 없으면 → lint 확인 skip, 이유 명시 (`/dev setup`으로 lint 설정 권장)

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
4. **If all good** → proceed to session handoff.
5. **If issues found** → fix, then re-present the checklist (max 1 re-verify iteration).
   - If still failing after 1 fix: surface to user and ask how to proceed.

---

Verification complete — proceed to `Read("steps/build/handoff.md")`.
