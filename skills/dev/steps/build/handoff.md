# Build: Session Handoff

## State Update

**Memory file:**
- `## Features` table: update completed feature row
  - Status → ✅ done
  - Testing → confirmed approach from mini-design
- frontmatter `updated` ← today's date
- If all features done: frontmatter `current-step` ← `"complete"`, append `- [x] build — YYYY-MM-DD` to `## Completed Steps`

**Build Context** (on first feature completion of this task):
- `## Build Context - Branch` ← `git branch --show-current`
- `## Build Context - Worktree`:
  - `worktree_path` 컨텍스트 변수가 있으면 해당 경로를 기록
  - 없으면 `"(main repo)"`

**architecture.md:**
- `## Features` checklist: mark completed feature `- [ ] F-NN` → `- [x] F-NN`

**MEMORY.md pointer:**
- Update step display: `build (<N>/<M> features)` or `complete` if all done

## Worktree Merge & Cleanup

`worktree_path` 컨텍스트 변수가 없으면 이 섹션 전체 skip (worktree 미사용).

1. 미커밋 변경 확인:
   ```bash
   git -C <worktree_path> status --porcelain
   ```
   결과가 있으면: 먼저 commit 요청 후 진행.

2. 메인 브랜치로 merge:
   ```bash
   git merge <worktree_branch> --no-ff
   ```

3. Worktree 제거:
   ```bash
   git worktree remove <worktree_path>
   ```

4. 브랜치 삭제:
   ```bash
   git branch -d <worktree_branch>
   ```

5. Build Context - Worktree 항목을 `"(merged: <worktree_branch>)"` 로 업데이트.

---

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

Every completion claim must carry evidence — the commands actually run and their
results (test/lint output, delta check outcome). Anything not directly verified
is reported as `미확인`, never asserted.

**When features remain:**

```
✅ F-<NN> <feature-name> complete
근거: <executed commands + results, e.g. "pnpm test 12 passed · lint clean · 델타 0건">

Remaining: N feature(s) pending

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Next: /dev build — N more feature(s) remain
Start a new session and run `/dev` to resume automatically.
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

**When this was the last feature (all features ✅ done):**

```
✅ F-<NN> <feature-name> 완료 — 모든 기능 완료!
근거: <executed commands + results>

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
모든 기능이 완료되었습니다.
/dev complete 로 작업을 마무리할까요? (Y/n)
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

If Y: load `steps/complete.md` and continue.
If n: stop. Remind that `/dev complete` should be run before closing the task.

Do NOT automatically start the next feature. Stop here.
