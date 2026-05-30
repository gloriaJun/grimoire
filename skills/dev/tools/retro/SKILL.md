---
name: retro
description: >
  Tool loaded by /dev skill via Read(). Triggered by /dev retro.
  Not a standalone skill — invoked only from dev/SKILL.md.
---

# Retro — Session Retrospective

Capture a retrospective note for a completed task and save it to the Obsidian vault.
Works with or without a devlog.

---

## Entry Check

**Resolve current repo name:**
```bash
basename $(git rev-parse --show-toplevel 2>/dev/null || pwd)
```

**Scan for candidate tasks** from MEMORY.md `## Active Dev Tasks` and `## Completed Dev Tasks`:
- Post-complete, retro not started: memory file `current-step == "complete"` AND `retro` NOT in Completed Steps
- Retro in progress: memory file `current-step == "retro"` AND `retro` NOT checked

Filter by current repo (`repo` frontmatter). If multiple candidates: list them and ask user to choose.

**Fallback**: if MEMORY.md has no entries, resolve devlogs root from cwd and scan `_state.json` files (legacy):
- `GitHubWork` cwd → `~/Documents/GitHubWork/_claude/devlogs/`
- `GitHubPrivate` cwd → `~/Documents/GitHubPrivate/_claude/devlogs/`

**Lifecycle mode** (candidate task found):
1. Read memory file: extract `task-name`, `task-dir`, `## Artifacts`; read `history.md` from task directory if it exists
2. If `current-step` is not `"complete"`: warn "complete step not yet done" — do not block
3. Ask: "Write a retrospective for **<task-name>**? (y/n)"
   - `n` → stop. Show: "Skipped. Run `/dev retro` anytime to write it later."
   - `y` → proceed

**Standalone mode** (no candidate task found): proceed directly without asking.

---

## Context

**Lifecycle mode** — from memory file and devlog:
- `task-name`, `task-dir`, `## Artifacts` from memory file
- `history.md` Decision Log from task directory (if exists)

**Standalone mode** — ask user:
- Task name
- Brief description of what was accomplished

---

## Execute

Write `retrospect.md` directly to the task folder:

1. Resolve output path:
   - `~/Documents/obsidian-vault/04_Notes/<scope>/YYYY-MM-DD-<task-name>/retrospect.md`
   - Create the task folder if it doesn't exist.
2. Gather context:
   - **task-name**: from memory file `task-name` or user input
   - **scope**: resolve from cwd:
     | cwd contains | scope |
     |---|---|
     | `GitHubWork` | `work` |
     | `GitHubPrivate` | `life` |
     | neither | ask the user |
   - **context**: summarize from `history` + artifacts (lifecycle) or user description (standalone)
3. **Action Items 초안 확인** (lifecycle mode only, `history.md`가 있을 때):
   - `history.md` Decision Log의 `status: resolved` 항목 + `artifacts` 목록에서 후보 3–5개 도출
   - 사용자에게 제시:
     ```
     Action Items 초안:
     - [ ] ...
     - [ ] ...

     수정하거나 추가할 항목이 있으면 알려주세요. 없으면 그대로 진행합니다.
     ```
   - 사용자 응답을 반영해 Action Items 확정 후 다음 단계 진행
   - `history.md` 없거나 standalone mode이면 이 단계를 건너뜀
4. Write `retrospect.md` using this template:

```markdown
---
date: YYYY-MM-DD
task: <task-name>
scope: <scope>
tags: []
summary: "<한 줄 요약>"
effort: S | M | L
related: []
---

## What Went Well

## What Didn't Go Well

## Key Takeaways

## Action Items

## Process Reflection

## Task Links
```

Field guidance:
- `tags`: required — use 1–3 topic tags
- `summary`: required — one sentence capturing what was reflected on and the key lesson
- `effort`: optional — S (< 2h), M (2–8h), L (> 8h)
- `What I Learned` vs `Key Takeaways`: Key Takeaways = behavior/habit change ("다음엔 X 하겠다"); til What I Learned = technical facts
- `What Didn't Go Well` vs `Process Reflection`: former = "무엇이 문제였나", latter = "다음에 프로세스를 어떻게 바꿀까"

After writing the file, fill the `related:` field:

1. Read `shared/vault-context.md` and execute with:
   - **keywords**: `tags` values + `task-name` terms
   - **search_focus**: `references`, `past-mistakes`
   - **scope_hint**: same as `scope` field
2. Top matching files (max 3) → rewrite `related:` as:
   ```yaml
   related:
     - "[[04_Notes/work/2026-04-07-sentry-insight/til]]"
     - "[[10_Knowledge/dev/debugging-tips]]"
   ```
3. If no matches → leave `related: []` as-is.

---

## State Update (lifecycle mode only)

1. Update memory file:
   - frontmatter `current-step` ← `"retro"`
   - frontmatter `updated` ← today
   - `## Completed Steps`: append `- [x] retro — YYYY-MM-DD`
   - `## Artifacts`: add `retro: 04_Notes/<scope>/YYYY-MM-DD-<task-name>/retrospect.md`
   - Update MEMORY.md pointer step display

2. Update `_index.md`:
   - Find the row matching the task directory in `<memory-root>/_index.md`
   - Update step column to `retro`
   - Update frontmatter `updated:` to today's date

---

## Completion

```
✅ [retro] complete — retrospect note saved

📄 <retro-path>

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Next:  /dev til
Start a new session and run `/dev til` — it will detect this task and resume.
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```
