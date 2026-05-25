# Build: Session Handoff

## State Update

**Memory file:**
- `## Features` table: update completed feature row
  - Status → ✅ done
  - Executor → selected executor (claude | codex)
  - Testing → confirmed approach from mini-design
- frontmatter `updated` ← today's date
- If all features done: frontmatter `current-step` ← `"complete"`, append `- [x] build — YYYY-MM-DD` to `## Completed Steps`

**Build Context** (on first feature completion of this task):
- `## Build Context - Branch` ← `git branch --show-current`
- `## Build Context - Worktree` ← `git rev-parse --show-toplevel` (set only when repo root differs from workspace root; otherwise "(main repo)")

**architecture.md:**
- `## Features` checklist: mark completed feature `- [ ] F-NN` → `- [x] F-NN`

**MEMORY.md pointer:**
- Update step display: `build (<N>/<M> features)` or `complete` if all done

## history.md Update

Schema: `schemas/history.md`

**Step 1 — Regenerate Current Snapshot:**

Rebuild the Current Snapshot section in full from the memory file (same mechanic as `steps/_handoff.md` step 2).

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

**When features remain:**

```
✅ F-<NN> <feature-name> complete

Remaining: N feature(s) pending

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Next: /dev build — N more feature(s) remain
Start a new session and run `/dev` to resume automatically.
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

**When this was the last feature (all features ✅ done):**

```
✅ F-<NN> <feature-name> complete — 모든 피처 완료!

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
모든 피처가 완료되었습니다.
/dev complete 로 태스크를 마무리하시겠습니까? (Y/n)
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

If Y: load `steps/complete.md` and continue.
If n: stop. Remind that `/dev complete` should be run before closing the task.

Do NOT automatically start the next feature. Stop here.
