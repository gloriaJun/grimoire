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

**Resolve devlogs root** from cwd:

| cwd contains | devlogs root |
|---|---|
| `GitHubWork` | `~/Documents/GitHubWork/_claude/devlogs/` |
| `GitHubPrivate` | `~/Documents/GitHubPrivate/_claude/devlogs/` |
| neither | ask the user |

**Scan for candidate tasks** (either condition qualifies):
- Post-complete, retro not started: `currentStep == 6 AND 6 IN completedSteps`
- Retro in progress: `currentStep == 7 AND 7 NOT IN completedSteps`

Prefer tasks whose `taskName` matches: `basename $(git rev-parse --show-toplevel 2>/dev/null || pwd)`

If multiple candidates: list them and ask user to choose.

**Lifecycle mode** (candidate task found):
1. Read `_state.json`: extract `taskName`, `history`, `artifacts`
2. If `currentStep < 6`: warn "complete step not yet done" — do not block
3. Ask: "Write a retrospective for **<taskName>**? (y/n)"
   - `n` → stop. Show: "Skipped. Run `/dev retro` anytime to write it later."
   - `y` → proceed

**Standalone mode** (no candidate task found): proceed directly without asking.

---

## Context

**Lifecycle mode** — from `_state.json`:
- `taskName`, `history` entries, `artifacts` list

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
   - **task-name**: from devlog `taskName` or user input
   - **scope**: resolve from cwd (mirrors devlogs root resolution):
     | cwd contains | scope |
     |---|---|
     | `GitHubWork` | `work` |
     | `GitHubPrivate` | `life` |
     | neither | ask the user |
   - **context**: summarize from `history` + artifacts (lifecycle) or user description (standalone)
3. Write `retrospect.md` using this template:

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

1. Update `_state.json`:
   - `currentStep` → 7, append 6 to `completedSteps`
   - `artifacts.retro` ← `04_Notes/<scope>/YYYY-MM-DD-<task-name>/retrospect.md`
   - Append to `history`: `{ "step": 6, "action": "retro saved", "timestamp": "ISO 8601" }`

2. Update `_index.md`:
   - Find the row matching the task directory in `<devlogs-root>/_index.md`
   - Update step column to `Step 7 (retro)`
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
