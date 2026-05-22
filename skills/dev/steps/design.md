# Design: Architecture

Goal: Define tech stack, feature list, and overall UI/UX structure in a single `architecture.md`.
For UI projects, also produce a full-app `wireframe.html` mockup.

This step replaces the former TRD + Wireframe + Breakdown steps.

## Skip Condition

Skip if **all** are true:
- No UI changes
- Logic-only change in a single file or module
- Tech stack is already established in the codebase

If skipping:
1. Set `artifacts.architecture` to `"skipped"`
2. Set `artifacts.wireframe` to `"skipped"`
3. Inform the user and proceed to Build

## Agent

`system-architect` (model: sonnet)

Produces `architecture.md`. Wireframe generation is performed inline by the orchestrator after the agent completes.

## Input

- `artifacts.prd` from memory file (required)
- Existing codebase context
- Tech stack defaults: read `~/.claude/instructions/tech-stack.md` and pass relevant sections to the agent prompt

## Vault Context Check

Before invoking the agent, read `shared/vault-context.md` and execute with:
- **keywords**: 2–5 terms extracted from the PRD title/scope/tech stack
- **search_focus**: `references`, `past-mistakes`
- **scope_hint**: resolved from cwd

Pass vault findings (relevant 10_Knowledge docs + past architecture decisions) to the agent prompt.

## Process

### 1. Invoke system-architect agent

Pass: PRD content, codebase context, tech stack defaults, vault findings.

The agent produces `architecture.md` in the devlog task directory.

**Opus Advisor branch**: If the agent output contains `[OPUS_ADVISOR_NEEDED]`:
1. Ask the user:
   > This architecture decision requires Opus's judgment.
   > Opus will only provide direction; Sonnet writes architecture.md.
   > Approve Opus invocation? (Y/n)
2. If approved: invoke Opus (model: opus) with analyzed options → receive Direction Brief
3. Re-invoke system-architect with the Direction Brief to produce final architecture.md
4. If declined: system-architect proceeds with its own judgment (re-invoke)

### 2. architecture.md structure

```markdown
# Architecture — <task-name>

## Tech Stack

| 항목 | 결정 | 비고 |
|------|------|------|
| Frontend | Next.js 14 | ✅ 확정 |
| DB | [ ] TODO: PostgreSQL vs SQLite | 보류 |

## Features

- [ ] F-01: <feature name>  <!-- one-line description only -->
- [ ] F-02: <feature name>  <!-- depends: F-01 -->

## UI/UX — Screens & Navigation

### Screen List

1. /path — Screen name (brief purpose)
2. /path — Screen name

### Navigation Flow

[mermaid flowchart or ASCII diagram]

### Layout Structure

[Key layout components and patterns]

## Wireframe

> wireframe.html — see file://<devlogs-task-dir>/wireframe.html
> (section omitted if no UI changes)

## Open Questions

- [ ] TODO: <unresolved decision> — owner: TBD

## Testing Strategy

| Scope | Framework | Command |
|-------|-----------|---------|
| Unit  | Vitest    | pnpm test |
```

**Feature list rules:**
- One line per feature — name and brief description only. No spec, no AC.
- Dependency notation: `<!-- depends: F-01 -->` inline comment
- Single-session scope: a feature must be implementable, tested, and committed in one session
  - Split signals: > 5 new files, > 300 LOC estimate, 3+ unrelated concerns, blocking dependency
  - Split pattern: `F-Xa` (infra/store) + `F-Xb` (UI/behavior) when the two halves are independently testable
- Tech stack TODO items: `[ ] TODO: <item>` in the Tech Stack table — reviewed before build step

**UI/UX section**: include only when PRD has UI changes. Omit entirely for logic/API-only work.

### 3. Wireframe generation (UI projects only)

After `architecture.md` is approved, generate `wireframe.html` inline (no agent).

> **No auto-deploy.** Never generate `pages.linecorp.com` URLs or auto-call `/deploy-wireframe`.
> Only deploy when the user explicitly requests it.
>
> **No external tool prompts.** Do not generate Figma/Google Stitch prompts unless the user asks.

Write `<devlogs-task-dir>/wireframe.html`:

- **Screens**: each screen from the Screen List in its own section, navigable via sidebar or top tabs
- **Scenario cases**: per-screen toggle buttons derived from PRD requirements (not generic states)
  - Examples: "신규 사용자 첫 진입", "권한 없는 사용자", "데이터 0건 vs 10건 이상", "에러 응답 시"
- **Version badge**: `v1` in header/footer — never in filename. Increment on each revision (v1 → v2).
- Provide the local preview URL: `file://<devlogs-task-dir>/wireframe.html`

```
<header>  ← version badge (e.g., "Mockup v1 · 2026-05-22")
<nav>     ← screen selector
<main>
  <section> per screen
    <div class="case-controls">  ← scenario toggles
    <div class="canvas">         ← rendered mockup
<footer>
```

If the user provides existing assets (Figma URL, image paths):
1. Register the asset in `artifacts.wireframe.design`
2. Set `artifacts.wireframe.mockup` to `null`
3. Skip HTML generation

On wireframe feedback: update the same file, increment version badge, re-provide the same `file://` URL.

## Review

Load `references/review-protocol.md` and execute the full review workflow.
- **Artifact**: `architecture.md` at `artifacts.architecture`
- **Codex focus**: "Review this architecture for tech stack feasibility, missing features, unclear dependencies, and TODO items that should be resolved before building"
- **Structural pre-check**:
  - [ ] Tech Stack section exists (TODO items explicitly marked)
  - [ ] Features checklist exists (minimum 1 feature)
  - [ ] UI project: Screen List + Navigation Flow present
  - [ ] Open Questions section exists (may be empty)

## State Update

Memory file updates:
- frontmatter `current-step` ← `"build"`
- frontmatter `updated` ← today
- `## Completed Steps`: append `- [x] design — YYYY-MM-DD`
- `## Artifacts`: add `architecture: architecture.md`
- `## Artifacts`: add `wireframe: wireframe.html` (or `"skipped"`)
- `## Features` table: populate with all features from architecture.md (status: ⏳ pending)

MEMORY.md pointer: update step display to `build`.

Append review approval entry to `history.md` Decision Log (see `schemas/history.md` Review Approval Entries).

Note: test framework info from the Testing Strategy table is detected on-demand at build time — not stored in the memory file.

Follow update mechanics from `schemas/memory.md`.

## Session Handoff

Read `steps/_handoff.md` and follow the handoff instructions.
Next sub-command: `/dev build`
