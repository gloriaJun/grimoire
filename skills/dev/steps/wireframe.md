# Wireframe: UI Design

Goal: Produce an interactive HTML mockup for browser preview before feature decomposition.

## Rules

> **deploy-wireframe은 자동 호출하지 않는다.**
> 사용자가 명시적으로 `/deploy-wireframe`을 실행할 때만 배포한다.
> 절대로 `pages.linecorp.com` URL을 자동 생성하거나 공유하지 않는다.

> **외부 도구 프롬프트(Figma, Google Stitch 등)는 사용자가 별도 요청할 때만 생성한다.**
> Claude가 직접 HTML 디자인을 진행하는 경우, 외부 도구용 프롬프트는 생성하지 않는다.

## Skip Condition

Skip if **either** is true:
- No UI or visual changes involved (logic-only work)
- User provides existing design assets (Figma URL, image paths, etc.)

If skipping:
1. Set `artifacts.wireframe` to `"skipped"`
2. Inform the user and proceed to Breakdown

If the user provides existing assets:
1. Register the asset path/URL in `artifacts.wireframe.design`
2. Set `artifacts.wireframe.mockup` to `null`
3. Proceed to Breakdown

## Input

- `artifacts.prd` (required)
- `artifacts.trd` (required, may be `"skipped"`)

## Process

### 1. Analyze PRD + TRD

Read both artifacts and extract:
- List of screens and pages that need design
- UI components and their relationships
- Interaction flows and state transitions
- Data display requirements
- **User scenario cases per screen** (derived from requirements — not generic states)
  - Examples: "신규 사용자 첫 진입", "권한 없는 사용자", "데이터 0건 vs 10건 이상", "에러 응답 시" etc.
  - These scenarios are the toggle cases shown in the HTML mockup

### 2. Generate HTML Mockup (Primary Artifact)

Write an interactive HTML file to `/tmp/<task-name>-mockup.html`:

- **Screens**: each screen in its own section, navigable via sidebar or top tabs
- **Scenario cases**: for each screen, include toggle buttons derived from PRD requirements
  - Generic states (empty, loading, error) are included only when relevant to requirements
  - Primary cases are requirement-based user scenarios
- **Version badge**: display `v1` badge in a header/footer area that does not overlap the design canvas. On each revision, update only the badge (v1 → v2 → ...) — do NOT create a new file.
- Provide the local preview URL:
  ```
  file:///private/tmp/<task-name>-mockup.html
  ```

HTML structure guidance:
```
<header>  ← version badge here (e.g., "Mockup v1 · 2026-05-13")
<nav>     ← screen/page selector
<main>    ← design canvas
  <section> per screen
    <div class="case-controls"> ← scenario case toggles from requirements
    <div class="canvas">        ← rendered mockup state
<footer>  ← optional version note / last updated
```

### 3. User Review

The user opens `file:///private/tmp/<task-name>-mockup.html` in the browser to review scenario cases.

On feedback:
- Update the same file (no new file)
- Increment the version badge (v1 → v2 → ...)
- Re-provide the same `file://` URL

Repeat until the user approves.

### 4. Register Artifacts

Register in `_state.json`:
- `artifacts.wireframe.mockup` ← `/tmp/<task-name>-mockup.html` (path stays the same across versions)
- `artifacts.wireframe.design` ← user-provided URL/path if supplied, otherwise `null`

## State Update

`currentStep` ← `"breakdown"`, append `"wireframe"` to `completedSteps`
`artifacts.wireframe.mockup` ← `/tmp/<task-name>-mockup.html` (or `null` if skipped)
`artifacts.wireframe.design` ← URL/path (user-provided, or `null`)

If skipped entirely: `artifacts.wireframe` ← `"skipped"`

Follow update mechanics from `schemas/state.md`.

## Session Handoff

Read `steps/_handoff.md` and follow the handoff instructions.
Next sub-command: `/dev breakdown`
