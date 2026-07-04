# Work Plan State Management

Rules for maintaining `_state.json` in work-plan directories.
Loaded on demand when an active work plan is detected for the current repo.

## When to Update

Update `_state.json` **after each feature/step is committed** (not before commit).

Triggers:

- Feature implementation committed → update feature status + add history entry
- Step completed (all features in step done) → update currentStep + completedSteps
- Feature started but not finished → do NOT change `features[].status` (avoid partial state)
- **Session ends without a commit** → still write a handoff record: update `notes`
  with actual progress and an `"uncommitted"` marker, and append a history entry
  (`action: "session-handoff"`). Without this, `_state.json` freezes at a stale step
  even though work exists on disk.

## Resume Integrity Check

On plan resume, before continuing work:

1. Pick 1–2 features still marked `"pending"` in `_state.json`.
2. Spot-check against repo reality: do the target files exist? does
   `git log --oneline -20` show related commits?
3. If reality is ahead of the state (work done but still `"pending"`),
   reconcile `_state.json` first — with the user's confirmation — then continue.

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

## README Index Convention

Create or update `README.md` whenever a document is added to a work-plan folder.
Purpose: allow future sessions to route to the right file without reading everything.

### README.md Structure

```markdown
# <Project Name> — Work Plan Index

**Project**: one-line description
**Current phase**: current status

## Documents

### [`filename`](./filename)

**When to read**: <what question or task requires this file>

- key point 1
- key point 2
- key point 3
```

### Trigger Conditions

- When the first document is created in a folder → create README at the same time
- When a new document is added → append its entry to README
- When a document changes significantly → update its bullet points in README

### Writing Rules

- "When to read" must be **task/question driven**, not a content summary
- Keep bullet points to **3–5 per document** — enough to decide whether to open the file
- Do not duplicate detailed content from the document itself

---

## Example History Entry

```json
{
  "step": 5,
  "action": "feature-05-scheduler-appcontext-complete",
  "result": "SchedulerManager with MemoryJobStore, AppContext DI, D-1 open-time calc. 24 unit tests.",
  "timestamp": "2026-04-08T00:00:00+09:00"
}
```
