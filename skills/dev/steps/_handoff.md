# Session Handoff

Follow these steps at the end of idea, plan, and design.
Build and complete handle their own handoff inline.

## 1. Persist State

Update the memory file per the values declared in the step file's "State Update" section.
Follow `schemas/memory.md` update mechanics:
- frontmatter `current-step` ← new step name
- frontmatter `updated` ← today's date
- `## Completed Steps`: mark completed step as `[x] <step> — YYYY-MM-DD`
- `## Artifacts`: add any newly created artifact paths
- `## Features` table: update if features were added (design step)

Update MEMORY.md pointer for the current task:
- Change the step display in the `## Active Dev Tasks` entry

## 2. Update the `history.md` 현재 상태 block

Read `schemas/history.md` for the 현재 상태 format.

Regenerate the entire block between the two comment markers in `history.md`:
- `<!-- AUTO-GENERATED ... -->` to `<!-- END AUTO-GENERATED ... -->`
- Rebuild from the memory file values (current-step, artifacts, features, branch)

If `history.md` does not exist yet, create it using the initial template in `schemas/history.md`.

## 3. Show Completion Message

The next sub-command is declared in the step file's "Next sub-command:" line.

```
✅ [<sub-command>] complete — <artifact(s)> saved

📁 <path to saved artifact(s)>

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Next:  /dev <next-sub-command>
Start a new session and run `/dev` — it will detect this task and resume automatically.
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

## 4. Do Not Continue

After showing the handoff message, stop. Do not proceed to the next step in the same session unless the user explicitly asks.
