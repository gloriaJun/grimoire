# Build: Local Verification & UI Verification

Run after cross-review, for every feature regardless of testingApproach.

## Requirement Delta Check

Run FIRST, before local verification.

1. Scan this session's conversation (and `history.md` 결정·블로커 기록) for user
   corrections that reversed or amended an earlier decision after the feature
   started — e.g. "A가 아니라 B", "그게 아니라", a re-stated instruction.
2. For each delta found:
   - Record in `history.md` as `type: decision` with title `요구사항 변경: <before> → <after>`
     (skip if an entry for this delta already exists)
   - Verify the change is actually applied in the current diff — cite evidence (file:line)
3. If a delta is NOT applied: fix it now, before proceeding. Never defer a
   user-stated correction to review or a later feature.

## Local Verification Checkpoint

### Step 1: Check by testingApproach

| testingApproach | What to verify |
|-----------------|----------------|
| `skip` | Target files exist + lint if possible |
| `test-after` | Re-confirm tests pass from Flow B-2 |
| `tdd` | Re-confirm tests pass from Flow A-2 |

Lint check for `skip` features — resolve the command in this priority (detect-on-demand):

1. `package.json` scripts has `lint` → `pnpm lint` (or the project's package manager)
2. nx monorepo detected (`nx.json` exists) → `pnpm nx lint <project-name>`
3. `eslint.config.*` or `.eslintrc.*` exists → `pnpm eslint .`
4. None → skip lint, state the reason (recommend `/dev setup` for lint config)

If node_modules is missing and commands cannot run: state the reason and defer
verification to the build/deploy stage.

### Step 2: Announce local UI preview availability

Output exactly one of the following:

- **Preview available**: the feature adds a navigable page or visible UI
  ```
  🖥️  로컬에서 확인 가능합니다:
  pnpm nx dev <project-name>  →  http://localhost:<port>
  확인 항목: <spec의 acceptance criteria 중 UI 관련 항목>
  ```
- **Preview not available**: types, utils, API clients, constants — no direct UI
  ```
  ⏭️  로컬 UI 확인: F-XX (<feature-name>) 완료 후 가능합니다.
  ```

Proceed to the next step without waiting (wait only in the preview-available case).

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
