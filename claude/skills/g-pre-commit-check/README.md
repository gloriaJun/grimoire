# g-pre-commit-check

Self-review before git commits: summarizes staged changes, auto-fixes lint, greps for security and debug leftovers, and reports a structured verdict before the commit proceeds.

## Features

- **Staged Diff Analysis** - `git diff --cached` with numeric scope classes (<=50 / 51-300 / >300 changed lines)
- **ESLint Auto-fix** - staged JS/TS files only, with explicit skip conditions and re-staging
- **Mechanical Security Greps** - secret-looking literals, credential files, debug leftovers; empty output = pass
- **Judgment Checklist** - correctness, quality, completeness on top of the mechanical layer
- **Flag, Don't Block** - findings are reported; the user decides fix vs proceed
- **History Restructure Proposal** - `history` sub-command proposes squash/reorder/reword of unpushed commits before push/PR; proposal only, never executes the rebase

## Usage

```
/g-pre-commit-check            # staged-diff review (Steps 1-3)
/g-pre-commit-check history    # unpushed-commit restructure proposal
/g-pre-commit-check help       # print the sub-command table
```

Also used proactively whenever a commit is about to happen in the session
(default flow only).

## How It Works

```
commit intent (or /g-pre-commit-check)
  -> Step 1: gather staged diff, classify scope
  -> Step 2: eslint --fix staged files, re-stage fixer output
  -> Step 3: security/debug greps + judgment checklist
  -> structured report -> no issues: proceed / issues: user decides
```
