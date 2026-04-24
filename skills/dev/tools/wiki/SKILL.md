# Wiki — Process Notes + Devlog Cleanup

Capture process notes to the Obsidian vault and optionally clean up the devlog directory.
Works with or without a devlog. Final step of the dev lifecycle.

---

## Entry Check

1. Detect devlog context (same rules as tools/retro/SKILL.md):
   - Active devlog found matching current repo → **lifecycle mode**
   - Not found → **standalone mode**

2. If lifecycle mode:
   - Ask: "process notes를 작성할까요? (y/n)"
     - `n` → stop. Show: "Skipped. Run `/dev wiki` anytime to write it later."
     - `y` → proceed
   - Read `_state.json`: extract `taskName`, `history`, `artifacts.retro`
   - If `currentStep < 7`: warn "retro step not yet done" — do not block

3. If standalone mode: proceed directly without asking.

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

Delegate to `vault-wiki-process` skill inline:

1. Load `~/Documents/obsidian-vault/.claude/skills/vault-wiki-process/SKILL.md` via Read tool.
2. Execute with task context:
   - **task-name**: from devlog `taskName` or user input
   - **scope**: `work` (default; confirm if ambiguous)
   - **retro-path**: `artifacts.retro` or user-provided (for cross-linking)
3. vault-wiki-process saves to: `~/Documents/obsidian-vault/04_Notes/process/<scope>-YYYY-MM-DD-<task-name>-process.md`

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
   - Read `<devlogs-root>/_index.md`
   - Find the row matching the current task directory name
   - If deleted or archived → remove the row entirely
   - If kept → update status column to `완료`
   - Update frontmatter `updated:` to today's date

---

## State Update (lifecycle mode only)

Update `_state.json` (if not deleting):
- Set `currentStep` to `8`
- Append `7` to `completedSteps`
- Register wiki file path in `artifacts.wiki`
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
