# Work Plan State Management

Rules for maintaining `_state.json` in work-plan directories.
Loaded on demand when an active work plan is detected for the current repo.

## When to Update

Update `_state.json` **after each feature/step is committed** (not before commit).

Triggers:
- Feature implementation committed → update feature status + add history entry
- Step completed (all features in step done) → update currentStep + completedSteps
- Feature started but not finished → do NOT update (avoid partial state)

## What to Update

### On feature completion

1. **features[].status**: `"pending"` → `"done"`
2. **history[]**: append entry with:
   - `step`: current step number
   - `action`: `"feature-{NN}-{name}-complete"`
   - `result`: one-line summary of what was implemented, key decisions, test count
   - `timestamp`: ISO8601 with timezone
3. **notes**: update to reflect current progress and what comes next

### On step completion

1. **completedSteps**: append the step number
2. **currentStep**: increment to next step
3. **notes**: update accordingly

## Path Discovery

Work-plan paths are discovered by convention — no per-project configuration needed.

1. From the current repo, resolve the parent workspace directory (e.g. `~/Documents/GitHubWork/`)
2. Look for `_claude/work-plan/` under that workspace
3. Find folders whose name contains the current repo name (e.g. `2026-04-08-my-app-feature/`)
4. Read `_state.json` from the matching folder

```
<workspace>/_claude/work-plan/<date>-<repo>-<task>/_state.json
```

## Example History Entry

```json
{
  "step": 5,
  "action": "feature-05-scheduler-appcontext-complete",
  "result": "SchedulerManager with MemoryJobStore, AppContext DI, D-1 open-time calc. 24 unit tests.",
  "timestamp": "2026-04-08T00:00:00+09:00"
}
```
