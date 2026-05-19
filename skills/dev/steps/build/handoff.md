# Build: Session Handoff

## State Update

- `features[i].status` ← `"done"`, `features[i].executor/reviewer` ← from selection
- If all features done: `currentStep` ← `"complete"`, append `{ "step": "build", "at": "<ISO 8601>" }` to `completedSteps`
- On first feature completion of this task: set `branch` (via `git branch --show-current`) and `worktreePath`
  (null unless repo root differs from workspace root)

## Feature Spec Update

- Open the completed feature's spec file (`artifacts.featureSpecs[i]`).
- Mark all implemented checklist items: `[ ]` → `[x]`.
- If the actual implementation diverges from the spec (design change, extra commands, different storage strategy, etc.):
  - Add a `> **구현 변경**:` callout block at the top explaining the deviation and reason.
  - Update affected sections (file paths, interfaces, verification steps) to match reality.
- If implementation matches spec exactly: only update the checklist.

## history.md Update

Schema: `schemas/history.md`

**Step 1 — Regenerate Current Snapshot:**

Rebuild the Current Snapshot section in full from `_state.json` (same mechanic as `steps/_handoff.md` step 2).

**Step 2 — Append to Decision Log (conditional):**

For each of the following that applies to this feature, append a Decision Log entry:

- Non-obvious architecture or design choice made during implementation → `type: decision · status: resolved`
- Key files introduced or significantly changed → fold into a `decision` entry as context (not a separate entry)
- Unresolved blocker or open question → `type: blocker · status: open`
- Troubleshooting finding worth preserving → `type: troubleshooting · status: resolved`

If none of the above apply (straightforward feature, no surprises): do not append.

Format: `### [build] YYYY-MM-DD — <title>`

## _index.md Update

- Find the row matching the current task directory in `<devlogs-root>/_index.md`
- If more features pending: update step column to `build (N/M done)`
- If all done: update step column to `complete`
- Update frontmatter `updated:` to today's date

## Completion Message

```
✅ feature-<XX> complete

Remaining: N feature(s) pending

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Next:  /dev build      (more features remain)
  OR
Next:  /dev complete   (all features done)
Start a new session and run `/dev` — it will detect this task automatically.
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

Do NOT automatically start the next feature. Stop here.
