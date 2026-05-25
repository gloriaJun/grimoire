---
name: til
description: >
  Tool loaded by /dev skill via Read(). Triggered by /dev til.
  Not a standalone skill — invoked only from dev/SKILL.md.
---

# TIL — Today I Learned Note + Devlog Cleanup

Capture a TIL note to the Obsidian vault and optionally clean up the devlog directory.
Works with or without a devlog. Final step of the dev lifecycle.

---

## Entry Check

**Resolve current repo name:**
```bash
basename $(git rev-parse --show-toplevel 2>/dev/null || pwd)
```

**Scan for candidate tasks** from MEMORY.md:
- Retro done, TIL not started: memory file `current-step == "retro"` AND `til` NOT in Completed Steps
- TIL in progress: memory file `current-step == "til"` AND `til` NOT checked

Filter by current repo. If multiple candidates: list them and ask user to choose.

**Fallback**: if MEMORY.md has no entries, resolve devlogs root from cwd and scan `_state.json` files (legacy):
- `GitHubWork` cwd → `~/Documents/GitHubWork/_claude/devlogs/`
- `GitHubPrivate` cwd → `~/Documents/GitHubPrivate/_claude/devlogs/`

**Lifecycle mode** (candidate task found):
1. Read memory file: extract `task-name`, `devlog-path`, `## Artifacts` (for `retro` path); read `history.md` from devlog if it exists
2. If `current-step` is not `"retro"` or later: warn "retro step not yet done" — do not block
3. Ask: "Write process notes for **<task-name>**? (y/n)"
   - `n` → stop. Show: "Skipped. Run `/dev til` anytime to write it later."
   - `y` → proceed

**Standalone mode** (no candidate task found): proceed directly without asking.

---

## Context

**Lifecycle mode** — from memory file and devlog:
- `task-name`, devlog `## Artifacts - retro` path (for cross-linking)
- From `history.md` Decision Log (if exists): `status: open` entries → `follow_up` candidates; `status: resolved` entries → TIL archiving candidates

**Standalone mode** — ask user:
- Task name
- Retro file path (optional, for cross-linking)

---

## Process

### Step 1: Process Notes

Write `til.md` directly to the task folder:

1. Resolve output path:
   - `~/Documents/obsidian-vault/04_Notes/<scope>/YYYY-MM-DD-<task-name>/til.md`
   - Create the task folder if it doesn't exist.
2. Gather context:
   - **task-name**: from devlog `taskName` or user input
   - **scope**: resolve from cwd (same as retro):
     | cwd contains | scope |
     |---|---|
     | `GitHubWork` | `work` |
     | `GitHubPrivate` | `life` |
     | neither | ask the user |
   - **audience**: ask user (standalone and lifecycle both):
     ```
     이 TIL의 용도를 선택하세요:
     1. 개인 메모 (기본) — 내가 나중에 참고
     2. 팀 공유 — 팀원이 읽을 기술 문서
     ```
     - Select `1` (or Enter): `audience: personal`
     - Select `2`: `audience: team`
   - **retro-path**: `artifacts.retro` or user-provided (for `related` field)
3. Write `til.md` using this template:

```markdown
---
date: YYYY-MM-DD
task: <task-name>
scope: <scope>
audience: personal
tags: []
keywords: []
summary: "<한 줄 요약>"
related: []
follow_up: []
---

## What I Learned

## Context
- **Goal:** (이 태스크에서 해결하려 했던 것 — 태스크명 없이도 읽힐 수 있게)
- Stack / Tool:
- Environment:

## Troubleshooting
### [문제 제목]
- **Symptom:**
- **Root Cause:** (불명확하면 Unknown으로 명시)
- **Solution:**
- **Remaining Questions:** (해결했지만 여전히 이해 못한 부분 — `follow_up`에 연결)

## Commands / Snippets

## Resources

### Task Links
```

Field guidance:
- `tags`: required — use 1–3 topic tags
- `keywords`: optional — concrete search terms (error messages, package names, symptom descriptions)
- `summary`: required — one sentence capturing what was learned/solved
- `follow_up`: optional — technical debt or follow-up exploration items
- `What I Learned` = technical facts/patterns ("X 상황에서는 Y 방법을 쓴다" 형태로 일반화)
- `Context` > `Goal`: 필수. 태스크명을 모르는 독자가 이 TIL을 발견했을 때 배경을 한 문장으로 이해할 수 있게 작성한다 (Every Page is Page One 원칙).
- `Troubleshooting` > `Remaining Questions`: 해결은 됐지만 왜 작동했는지 명확하지 않은 부분. 비워도 되지만 있으면 반드시 `follow_up` 필드와 연결한다.
- `Resources` entries: each link must include a one-line description of why it's useful
- `Task Links`: PR, ticket links — no description needed

**Share mode (`audience: team`) overrides:**
- `Context > Goal`: 배경 지식 없는 독자가 이해할 수 있도록 상세 작성 (Every Page is Page One 원칙 강화; personal의 한 문장 → 2–3 문장)
- `What I Learned`: "X 상황에서 Y 방법을 쓴다" 형태에 더해 "왜 X 상황이 생기는지" 배경 설명 추가
- `Troubleshooting > Root Cause`: `Unknown` 표기 금지 — 확인된 사실만 기재 (불명확하면 해당 섹션 삭제)
- `Resources`: 독자 학습용 자료 필수 (personal에서는 optional)

After writing the file, fill `related:` and `Resources`:

1. Read `shared/vault-context.md` and execute with:
   - **keywords**: `keywords` field values (if set), else `tags` + `task-name` terms
   - **search_focus**: `references`, `error-history`
   - **scope_hint**: same as `scope` field
2. From top matching files (max 3):
   - Files in `04_Notes` → add to `related:` as `"[[path/to/file]]"`
   - Files in `10_Knowledge` → add to `Resources` section as `[[path/to/file]] — <summary from frontmatter>`
3. If no matches → leave fields as-is.

### Step 2: Decision Log Review (lifecycle mode only, if history.md exists)

After process note is saved, review `history.md` Decision Log:

1. Identify entries by status:
   - `status: open` → already surfaced as `follow_up` in TIL note. No action needed here.
   - `status: resolved` with clear TIL value → candidates for archiving
   - Entries without clear TIL value → leave in place

2. If archive candidates exist, ask:
   ```
   Decision Log에 아카이브 가능한 항목이 있습니다:
   - [build] 2026-05-19 — F-01: httpOnly cookie 채택 (resolved)
   - [troubleshooting] 2026-05-20 — CORS preflight 오류 해결 (resolved)

   이 항목들을 archived/history-YYYY-MM-DD.md로 이동할까요? (y/n)
   ```
   - `y`: move matched entries to `<task-dir>/archived/history-<date>.md`; remove them from Decision Log in `history.md`; regenerate Current Snapshot
   - `n`: leave Decision Log as-is

### Step 3: Devlog Cleanup (lifecycle mode only)

After Decision Log review:

1. Show contents of the task directory for review.
2. Ask (Single Choice):
   ```
   Devlog task directory: <task-dir>
   Contents: _state.json, <artifacts list>

   What to do with the devlog?
   1. Delete entirely
   2. Archive (move to _archive/)
   3. Keep as-is

   > Enter number
   ```
3. Execute the chosen action. Delete only after explicit confirmation.

4. Update `_index.md`:
   - Find the row matching the task directory in `<devlogs-root>/_index.md`
   - If deleted or archived → remove the row entirely
   - If kept → update step column to `Step 8 (wiki — done)`
   - Update frontmatter `updated:` to today's date

---

## State Update (lifecycle mode only, if not deleting)

Update memory file:
- frontmatter `current-step` ← `"til"`
- frontmatter `updated` ← today
- `## Completed Steps`: append `- [x] til — YYYY-MM-DD`
- `## Artifacts`: add `til: 04_Notes/<scope>/YYYY-MM-DD-<task-name>/til.md`

If devlog was deleted or archived:
- Remove pointer from MEMORY.md `## Active Dev Tasks` (or `## Completed Dev Tasks`)
- Memory file itself is kept (historical record)

---

## Completion

```
🎉 Task complete — <taskName>

Vault artifacts:
  📄 retrospect: <retro-path>
  📄 process:    <wiki-path>

Devlog: <deleted / archived / kept>
```

Task lifecycle is now complete. No next step.
