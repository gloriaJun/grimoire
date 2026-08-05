# Step 1: Gather Staged Changes

Run:

```bash
git diff --cached --stat
git diff --cached --shortstat
```

- Both empty (nothing staged): run `git status --short`, report that nothing is staged and what unstaged changes exist, then STOP the skill.
- Not a git repository (`fatal: not a git repository`): report exactly that and STOP.

## Scope classification

From shortstat, changed lines = insertions + deletions:

| Changed lines | Scope | Diff reading rule |
|---|---|---|
| <= 50 | small | read full `git diff --cached` |
| 51-300 | medium | read full `git diff --cached` |
| > 300 | large | read `--stat`, then per-file diffs (`git diff --cached -- <file>`) for the 10 files with the most changed lines; name every skipped file in the report |

Exemption: a file written or edited in this same session, whose full content
is already in context, needs no diff re-read. Name every file exempted this
way in the Step 3 report.

Record for Step 3: files added/modified/deleted, nature of change (feature, bugfix, refactor, docs, config), scope class.

Then load `steps/step-2-autofix.md`.
