# Complete: Task Wrap-up

When all features are done.

## Process

1. Final update of PRD and TRD to reflect any changes made during execution.
2. Update `_state.json` in the devlogs task subdirectory:
   - Set `currentStep` to `6`
   - Append `6` to `completedSteps`
3. If documents were saved in the task subdirectory (temporary):
   - Ask (follow Single Choice pattern):
     ```
     Temporary files found in the task subdirectory.

     What to do with them?
     1. Delete
     2. Keep
     3. Move to another location

     > Enter number or free text
     ```
   - Delete only after explicit confirmation.
4. Present summary:
   - What was built
   - Files changed
   - Follow-up items
5. Run **insight**: Load and execute `skills/insight/SKILL.md` inline (in main context).
   This reviews the entire task workflow and suggests grimoire improvements.
6. Clean up `_state.json` in the devlogs directory: optionally archive or delete based on user preference.

## Next

Optionally capture post-completion notes (both will ask for confirmation):
- `/dev retro` — session retrospective → vault note
- `/dev wiki` — process notes + devlog cleanup

## Session Handoff

Read `steps/_handoff.md` and follow the handoff instructions for this step.
