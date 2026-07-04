# Build: Cross-Review

After simplify completes, update `features[i].status` to `"review"`.

## Review Execution

1. Run the `code-review` skill on the current diff
   (when `worktree_path` is set, review the diff inside the worktree).
2. If the change includes frontend files (components, styles, hooks):
   also dispatch the `frontend-reviewer` agent, then aggregate findings.

## Review Resolution

1. Present findings to the user with evidence (file:line). Mark anything
   not directly verified as unverified — never present speculation as fact.
2. If changes requested: fix and re-review (max 2 iterations).
3. Update `features[i].status` to `"done"`.

---

Cross-review complete — proceed to `Read("steps/build/verification.md")`.
