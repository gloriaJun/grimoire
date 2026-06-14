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
- `## Build Context - Worktree`: set to the current worktree path only when working inside one;
  otherwise "(main repo)". Detect with:
  ```bash
  TOP=$(git rev-parse --show-toplevel 2>/dev/null)
  MAIN=$(dirname "$(git rev-parse --path-format=absolute --git-common-dir 2>/dev/null)")
  [ "$TOP" != "$MAIN" ] && echo "$TOP" || echo "(main repo)"
  ```
  (The memory directory itself always lives under the main repo — see `SKILL.md` Task Directory Detection.)

**architecture.md:**
- `## Features` checklist: mark completed feature `- [ ] F-NN` → `- [x] F-NN`

**MEMORY.md pointer:**
- Update step display: `build (<N>/<M> features)` or `complete` if all done

## history.md Update

Schema: `schemas/history.md`

**Step 1 — Regenerate the 현재 상태 block:**

Rebuild the 현재 상태 section in full from the memory file (same mechanic as `steps/_handoff.md` step 2).

**Step 2 — Append to 결정·블로커 기록 (conditional):**

For each of the following that applies to this feature, append a 결정·블로커 기록 entry:

- Non-obvious architecture or design choice made during implementation → `type: decision · status: resolved`
- Key files introduced or significantly changed → fold into a `decision` entry as context (not a separate entry)
- Unresolved blocker or open question → `type: blocker · status: open`
- Troubleshooting finding worth preserving → `type: troubleshooting · status: resolved`

If none of the above apply (straightforward feature, no surprises): do not append.

Format: `### [build] YYYY-MM-DD — <title>`

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
✅ F-<NN> <feature-name> 완료 — 모든 기능 완료!

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
모든 기능이 완료되었습니다.
/dev complete 로 작업을 마무리할까요? (Y/n)
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

If Y: load `steps/complete.md` and continue.
If n: stop. Remind that `/dev complete` should be run before closing the task.

Do NOT automatically start the next feature. Stop here.
