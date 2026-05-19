# Build: Cross-Review

After simplify completes, update `features[i].status` to `"review"`.

## Reviewer Assignment

| Executor | Reviewer | Method |
|----------|----------|--------|
| Claude | Codex | Invoke `code-reviewer` agent → delegates to `/codex:review` |
| Codex | Claude | Invoke `code-reviewer` agent → reviews with Claude |

Set `features[i].reviewer` accordingly.

## Parallel Review (frontend changes exist)

Dispatch `code-reviewer` and `frontend-reviewer` simultaneously (single message, 2 Agent tool calls).
Apply action markers per `agent-guidelines.md`. Wait for both, then aggregate findings.

## Sequential Review (no frontend changes)

Invoke only `code-reviewer`.

## Review Resolution

1. Present review findings to the user.
2. If changes requested: fix and re-review (max 2 iterations).
3. Update `features[i].status` to `"done"`.

---

Cross-review complete — proceed to `Read("steps/build/verification.md")`.
