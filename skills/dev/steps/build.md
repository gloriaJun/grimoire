# Build: Feature Execution

Execute one feature per session. Routes to sub-files for each execution phase.

## Flow Diagram

```mermaid
flowchart TD
    A(["build"]) --> B["Step 1: Feature Selection"]
    B --> M["Step 1.5: Mini-Design\n(scope · AC · wireframe · approach · testing)"]
    M --> C["Step 2: Confirm Testing Approach"]
    C --> W{"wireframe exists\n+ UI feature?"}
    W -- Yes --> WR["Step 2.5: UI/UX Wireframe Pre-check\n(review → update → approve)"]
    WR --> D
    W -- No/Skip --> D
    D{"testingApproach"}
    D -- TDD --> E["Read(flow-tdd.md)"]
    D -- Test-After --> F["Read(flow-test-after.md)"]
    D -- Skip --> G["Read(flow-skip.md)"]
    E & F & G --> H["Read(cross-review.md)"]
    H --> I["Read(verification.md)"]
    I --> J["Read(handoff.md)"]

    E -.->|"tests fail ×2"| K["Read(stagnation-escape.md)"]
    F -.->|"tests fail ×2"| K
    K -.-> H
```

---

## Step 1: Feature Selection

1. Read the memory file for this task.
2. Read `architecture.md` `## Features` checklist from the devlog task directory.
3. Display pending features:
   - Features with `⏳ pending` status where all `<!-- depends: F-XX -->` entries are done: selectable
   - Features with incomplete dependencies: shown as `[blocked: F-XX]`
   ```
   Pending features:
   [ ] F-01: <name>
   [ ] F-02: <name>        [blocked: F-01]
   ...

   Which feature would you like to work on? (enter number or name)
   ```
4. Wait for user selection.
5. Update the selected feature row in:
   - Memory file `## Features` table: Status → 🔄 in-progress
   - `architecture.md` `## Features`: `- [ ]` → `- [~]` (in-progress marker, optional)

---

## Step 1.5: Mini-Design

Before any implementation, define the feature concretely.
Performed inline by the orchestrator — no agent delegation.

```
## Mini-Design: F-<NN> <feature-name>

### Scope
- Files / components to create or modify
- Public interfaces (props, function signatures, API endpoints)

### Requirements (Acceptance Criteria)
- [ ] AC-1: <testable criterion>
- [ ] AC-2: ...

### Wireframe (UI feature only)
- Reference: file://<devlogs-task-dir>/wireframe.html → <screen name>
- Interaction details and state variations for this feature
- Any delta from the overall wireframe (new elements, layout changes)

### Technical Approach
- Implementation strategy
- Patterns / libraries to use
- Edge cases and error handling

### Testing
- Strategy: TDD | Test-After | Skip
- Reason: <why this approach>
- Test scope: unit only | unit + e2e | e2e only
```

After generating the mini-design:
> "Mini-design 확인. 계속할까요? (Y / 수정사항 입력)"

- Y → proceed to Step 2
- User provides changes → update mini-design, re-confirm

The mini-design lives in the conversation context only.
If the user asks to persist it, append to `<devlogs-task-dir>/notes.md`.

---

## Step 2: Confirm Testing Approach

1. Use `testingApproach` from the mini-design (`### Testing` section).
2. Detect test framework on-demand (only needed for TDD and Test-After flows):
   - Check `vitest.config.*` → vitest (`pnpm test`)
   - Check `jest.config.*` → jest (`pnpm test`)
   - Check `package.json` scripts for `test` entry → use that command
   - Check `playwright.config.*` → playwright e2e (`pnpm e2e`)
   - Check `cypress.config.*` → cypress e2e
   - None found and testingApproach is not Skip → ask user for framework details
3. Proceed to the matching execution flow.

---

## Step 2.5: UI/UX Wireframe Pre-check

Skip this step entirely if **either** is true:
- `artifacts.wireframe` in memory file is `"skipped"` or absent
- Mini-design `### Wireframe` section is empty (pure logic, API clients, config, infra)

If both conditions are met (wireframe exists AND feature has UI changes):

1. Display the wireframe reference:
   ```
   🖥️  와이어프레임: file://<devlogs-task-dir>/wireframe.html
   관련 화면: <screen name from mini-design ### Wireframe>
   ```
2. Ask the user:
   ```
   이 기능 구현 전 와이어프레임에서 UI/UX 업데이트할 내용이 있나요?
   (있으면 변경사항 설명 / 없으면 skip)
   ```
3. **If update is needed:**
   - Modify `wireframe.html` in the devlogs task directory directly
   - Increment the version badge (v1 → v2 → ...)
   - Re-provide the same `file://` URL
   - Wait for user approval — repeat until approved
4. **If skip or approved** → proceed to Step 3

---

## Step 3: Execution Flow

Load the file matching the mini-design `testingApproach`:

| testingApproach | Load file |
|---|---|
| `TDD` | `Read("steps/build/flow-tdd.md")` |
| `Test-After` | `Read("steps/build/flow-test-after.md")` |
| `Skip` | `Read("steps/build/flow-skip.md")` |

If the flow encounters stagnation (tests fail ×2): `Read("steps/build/stagnation-escape.md")`

---

## Step 4: Cross-Review

When the execution flow signals "Flow complete":

`Read("steps/build/cross-review.md")`

---

## Step 5: Verification

When cross-review is complete:

`Read("steps/build/verification.md")`

---

## Step 6: Session Handoff

When verification is complete:

`Read("steps/build/handoff.md")`
