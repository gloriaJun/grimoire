# Step 4: History Restructure Proposal

Proposes squash/reorder/reword of UNPUSHED commits only. This step never runs
`git rebase`, `git reset`, or `git commit --amend`; it ends at the proposal.

## 1. Resolve the unpushed range

Run in order; on any STOP, report the quoted message and end the skill.

1. `git symbolic-ref -q HEAD` prints nothing (detached HEAD): STOP with
   `cannot determine unpushed range: detached HEAD`.
2. `git remote` prints nothing (no remote configured): STOP with
   `cannot determine unpushed range: no remote`.
3. Count commits on HEAD that exist on no remote branch:
   `N=$(git rev-list --count HEAD --not --remotes)`. N < 2: STOP with
   `nothing to restructure: <N> unpushed commit(s)`.
4. Base = parent of the oldest unpushed commit:
   `BASE=$(git rev-list HEAD --not --remotes | tail -1)^`.
   If the oldest unpushed commit is the root commit (resolving `^` fails),
   write `--root` instead of `<base>` in the apply command of section 4.

## 2. Gather

```bash
git log --reverse --oneline --stat HEAD --not --remotes
```

Record per commit: hash, message, files touched, insertions/deletions.
More than 20 commits: analyze only the 20 most recent, and state in the
report how many older commits were excluded.

## 3. Restructure analysis

Mechanical candidates (check every commit):

- fixup: message starts with `fixup`, `wip`, `tmp`, `typo`, `oops`
  (case-insensitive), or the commit touches the exact file set of the
  previous commit
- reword: message does not match the `<type>: <subject>` commit convention

Judgment candidates (against the gathered log):

- squash: consecutive commits of the same type sharing at least 1 file,
  whose combined change is describable in a single `<type>: <subject>` line
- reorder: related commits separated by unrelated ones on disjoint file
  sets; propose only when the regrouping enables a squash

No candidates in any category: report `history already clean` and STOP.

## 4. Proposal report

```
## Commit History Proposal

**Range**: <base>..HEAD (<N> commits)

### Current
- <hash> <message>

### Proposed
- <pick | squash into <hash> | reword> <hash> <message or new message>

### To apply (after your approval, in your own terminal)
git rebase -i <base>

### Risks
- <e.g. reordered commits touch the same file, conflict likely>
```

The apply command is interactive: it is for the user's terminal. In-session
execution after approval requires a non-interactive `GIT_SEQUENCE_EDITOR`
form instead.

## 5. Decision

End at the proposal. If the user approves, execution is a separate task
under the caller's rules (CLAUDE.md confirmation rules apply to history
rewriting).
