# Retro — Session Retrospective

Capture a retrospective note for a completed task and save it to the Obsidian vault.
Works with or without a devlog.

---

## Entry Check

1. Detect devlog context:
   - Resolve devlogs root from cwd (main SKILL.md Devlog Path Detection rules)
   - Scan for task directories containing `_state.json` with `currentStep NOT IN completedSteps`
   - Prioritize entries whose `taskName` matches the current repo
   - If a matching active devlog is found: **lifecycle mode**
   - If not found: **standalone mode**

2. If lifecycle mode:
   - Ask: "retrospective를 작성할까요? (y/n)"
     - `n` → stop. Show: "Skipped. Run `/dev retro` anytime to write it later."
     - `y` → proceed
   - Read `_state.json`: extract `taskName`, `history`, `artifacts`
   - If `currentStep < 6`: warn "complete step not yet done" — do not block

3. If standalone mode: proceed directly without asking.

---

## Context

**Lifecycle mode** — from `_state.json`:
- `taskName`, `history` entries, `artifacts` list

**Standalone mode** — ask user:
- Task name
- Brief description of what was accomplished

---

## Execute

Delegate to `vault-retro` skill inline:

1. Load `~/Documents/obsidian-vault/.claude/skills/vault-retro/SKILL.md` via Read tool.
2. Execute with task context:
   - **task-name**: from devlog `taskName` or user input
   - **scope**: `work` (default; confirm if ambiguous)
   - **context**: summarize from `history` + artifacts (lifecycle) or user description (standalone)
3. vault-retro saves to: `~/Documents/obsidian-vault/04_Notes/retrospect/<scope>-YYYY-MM-DD-<task-name>-retrospect.md`

---

## State Update (lifecycle mode only)

After vault-retro completes:

1. Update `_state.json`:
   - Set `currentStep` to `7`
   - Append `6` to `completedSteps`
   - Register retro file path in `artifacts.retro`
   - Append to `history`: `{ "step": 6, "action": "retro saved", "timestamp": "ISO 8601" }`
2. Follow `steps/_handoff.md` rules for `_index.md` update and completion message.

```
✅ [retro] complete — retrospect note saved

📄 <retro-path>

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Next:  /dev wiki
Start a new session and run `/dev wiki` — it will detect this task and resume.
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```
