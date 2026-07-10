---
name: g-pre-commit-check
description: >
  Use PROACTIVELY before any git commit, and via /g-pre-commit-check.
  Self-review of staged changes: auto-fix lint, summarize the diff, run
  security and completeness checks. Complete this before the commit proceeds.
  Sub-commands: history (propose squash/reorder of unpushed commits before
  push/PR), help.
---

# g-pre-commit-check Skill

Self-review of staged changes before every commit. Triggered by commit intent
in the session or by explicit `/g-pre-commit-check [sub-command]`.

## Workflow

```mermaid
flowchart TD
    A1(["commit intent detected"]) --> B
    A2(["/g-pre-commit-check"]) --> R{"sub-command?"}
    R -- none --> B
    R -- history --> S4["Step 4: History restructure proposal"]
    R -- "help / unrecognized" --> HP(["Print sub-command table, stop"])
    S4 --> S4C{"range resolved, 2+ commits,<br>candidates found?"}
    S4C -- no --> S4Z(["Report reason, stop"])
    S4C -- yes --> S4R(["Proposal report, stop"])
    B["Step 1: Gather staged diff"] --> C{"anything staged?"}
    C -- no --> Z(["Report unstaged state, stop"])
    C -- yes --> D["Step 2: ESLint auto-fix"]
    D --> E["Step 3: Mechanical greps + review"]
    E --> F{"issues found?"}
    F -- no --> G(["Proceed to commit"])
    F -- yes --> H{"user decision"}
    H -- fix --> B
    H -- proceed anyway --> G
```

## Sub-commands

| Sub-command | Action |
|---|---|
| (none) | Staged-diff review: Steps 1-3 |
| `history` | Propose squash/reorder of unpushed commits: Step 4 only |
| `help` | Print this table and stop |

Unrecognized sub-command: print the table and stop, same as `help`.
Proactive (commit-intent) triggering always runs the default flow; `history`
runs only on explicit invocation.

## Step Router

Read ONLY the step file for the current step.

| Step | Load file | Description |
|---|---|---|
| 1 | `steps/step-1-gather.md` | Staged diff, scope classification (numeric) |
| 2 | `steps/step-2-autofix.md` | ESLint --fix on staged JS/TS files |
| 3 | `steps/step-3-review.md` | Mechanical greps + judgment checklist + report |
| 4 | `steps/step-4-history.md` | Unpushed-commit restructure proposal (`history` only) |

## Principles

- Be concise: the review takes seconds, not minutes.
- Never skip the security greps, even for a one-line diff.
- Flag, do not block: the user decides on every finding.
- This skill never runs `git commit` or history-rewriting commands (`rebase`,
  `reset`, `commit --amend`) itself; it ends at the recommendation.

## Note on enforcement

Blocking `git commit` Bash calls until this skill ran requires a PreToolUse
hook registered in settings. That hook is NOT part of this skill; without it
the triggers are this skill's description and explicit invocation.
