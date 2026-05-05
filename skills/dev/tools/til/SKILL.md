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

**Resolve devlogs root** from cwd:

| cwd contains | devlogs root |
|---|---|
| `GitHubWork` | `~/Documents/GitHubWork/_claude/devlogs/` |
| `GitHubPrivate` | `~/Documents/GitHubPrivate/_claude/devlogs/` |
| neither | ask the user |

**Scan for candidate tasks** (either condition qualifies):
- Retro done, wiki not started: `currentStep == 7 AND 7 NOT IN completedSteps`
- Wiki in progress: `currentStep == 8 AND 8 NOT IN completedSteps`

Prefer tasks whose `taskName` matches: `basename $(git rev-parse --show-toplevel 2>/dev/null || pwd)`

If multiple candidates: list them and ask user to choose.

**Lifecycle mode** (candidate task found):
1. Read `_state.json`: extract `taskName`, `history`, `artifacts.retro`
2. If `currentStep < 7`: warn "retro step not yet done" — do not block
3. Ask: "Write process notes for **<taskName>**? (y/n)"
   - `n` → stop. Show: "Skipped. Run `/dev wiki` anytime to write it later."
   - `y` → proceed

**Standalone mode** (no candidate task found): proceed directly without asking.

---

## Context

**Lifecycle mode** — from `_state.json`:
- `taskName`, `history`, `artifacts.retro` (for cross-linking)

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
   - **scope**: `work` (default; confirm if ambiguous)
   - **retro-path**: `artifacts.retro` or user-provided (for `related` field)
3. Write `til.md` using this template:

```markdown
---
date: YYYY-MM-DD
task: <task-name>
scope: <scope>
tags: []
keywords: []
summary: "<한 줄 요약>"
related: []
follow_up: []
---

## What I Learned

## Context
- Stack / Tool:
- Environment:

## Troubleshooting
### [문제 제목]
- **Symptom:**
- **Root Cause:** (불명확하면 Unknown으로 명시)
- **Solution:**

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
- `Resources` entries: each link must include a one-line description of why it's useful
- `Task Links`: PR, ticket links — no description needed

After writing the file, fill `related:` and `Resources`:

1. Read `shared/vault-context.md` and execute with:
   - **keywords**: `keywords` field values (if set), else `tags` + `task-name` terms
   - **search_focus**: `references`, `error-history`
   - **scope_hint**: same as `scope` field
2. From top matching files (max 3):
   - Files in `04_Notes` → add to `related:` as `"[[path/to/file]]"`
   - Files in `10_Knowledge` → add to `Resources` section as `[[path/to/file]] — <summary from frontmatter>`
3. If no matches → leave fields as-is.

### Step 2: Devlog Cleanup (lifecycle mode only)

After process note is saved:

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

- `currentStep` → 8, append 7 and 8 to `completedSteps`
- `artifacts.wiki` ← `04_Notes/<scope>/YYYY-MM-DD-<task-name>/til.md`
- Append to `history`: `{ "step": 7, "action": "wiki saved + devlog cleaned", "timestamp": "ISO 8601" }`

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
