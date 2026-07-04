---
name: retro
description: >
  Tool loaded by /dev skill via Read(). Triggered by /dev retro.
  Not a standalone skill — invoked only from dev/SKILL.md.
---

# Retro — Retrospective + Learnings Note

Publish one note to the Obsidian vault combining the retrospective (what went
well / what didn't / what to change) and technical learnings for a finished task.
Works with or without a devlog.

> Merges the former `retro`/`til` steps. `/dev complete` already wraps up the task
> internals into `<task>-log.md`; this command only distills that into the vault.

---

## Entry Check

**Current repo name** (main repo root — worktree-safe):
```bash
REPO_ROOT=$(dirname "$(git rev-parse --path-format=absolute --git-common-dir 2>/dev/null)")
[ -d "$REPO_ROOT" ] || REPO_ROOT=$(git rev-parse --show-toplevel 2>/dev/null || pwd)
basename "$REPO_ROOT"
```

**Find candidates** — filter MEMORY.md `## Completed Dev Tasks` and `## Active Dev Tasks`
by current repo:
- **Completed**: pointer targets `<task>-log.md` (most common)
- **In-progress**: `state.md` whose `current-step` is near complete

Multiple candidates → show a list and let the user pick.

**Mode:**
- **Completed mode** (`<task>-log.md` exists): use its 결과/고민/배운 것 sections as input.
- **In-progress mode** (only `state.md`): warn but don't block; gather context from
  `state.md` and `history.md`.
- **Standalone mode** (no candidates): ask the user directly.

Confirm once: "**<task-name>** 회고 노트를 작성할까요? (y/n)"
- `n` → stop: "건너뜀. 나중에 `/dev retro`로 언제든 작성할 수 있습니다."
- `y` → proceed

---

## Execution

Write one note (`retro.md`) to the vault.

1. Output path: `~/Documents/obsidian-vault/04_Notes/<scope>/YYYY-MM-DD-<task-name>/retro.md`
   (create the folder if missing).
2. Resolve `scope` from cwd: `GitHubWork` → `work`, `GitHubPrivate` → `life`, else ask.
3. **Audience** — ask once:
   ```
   이 노트의 용도를 선택하세요:
     1. 개인 메모 (기본) — 내가 나중에 참고
     2. 팀 공유 — 팀원이 읽을 기술 문서
   ```
   `1`/Enter → `audience: personal` · `2` → `audience: team`
4. **Action Items draft** (completed/in-progress mode, when input context exists):
   derive 3–5 candidates from `배운 것`/`고민한 것` (or history.md), present for
   edits, then finalize. Skip in standalone mode.
5. Write `retro.md` per `references/note-format.md` — Read it first
   (template, writing rules, field guide, team-mode extras).

## Note Quality Pass (automatic, right after writing)

Read `references/quality-pass.md` and execute all three steps:
self-check → link weaving → distillation check (Notes → Knowledge).

---

## State Update

- **Completed mode**: `state.md` is already gone. Append one line under
  `## 참고 문서` in `<task>-log.md`:
  `- 회고: 04_Notes/<scope>/YYYY-MM-DD-<task-name>/retro.md`.
  Leave the MEMORY.md completed pointer unchanged.
- **In-progress mode**: add `retro: <path>` to `state.md` `## Artifacts`,
  update `updated` to today.

## 03_Logs Archive Offer (completed mode only)

If `~/Documents/obsidian-vault/03_Logs/<scope>/` has a folder for this task, ask:

```
📦 03_Logs에 완료된 작업 폴더가 남아 있습니다: <folder>
20_Archive로 이동할까요? (Y/n)
```

- Y: `mv` the folder into `20_Archive/` — keeps finished work out of the active log list.
- n: leave it.

---

## Done

```
✅ 회고 노트 저장 완료 — <task-name>

📄 <retro-path>
```

The task lifecycle is fully finished. There is no next step.
