# Session Handoff

Follow these steps at the end of every `/dev` sub-command to ensure cross-session continuity.

## 1. Persist State

Update `_state.json` in the task directory:
- Set `currentStep` to the next step number
- Append the current step to `completedSteps`
- Register any new artifact paths under `artifacts`
- Append to `history`:
  ```json
  { "step": N, "action": "description of what was done", "timestamp": "ISO 8601" }
  ```

## 2. Show Completion Message

```
✅ [<sub-command>] complete — <artifact(s)> saved

📁 <path to saved artifact(s)>

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Next:  /dev <next-sub-command>
Start a new session and run `/dev` — it will detect this task and resume automatically.
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

## 3. Do Not Continue

After showing the handoff message, stop. Do not proceed to the next step in the same session unless the user explicitly asks to continue.
