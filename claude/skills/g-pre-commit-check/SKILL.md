---
name: g-pre-commit-check
description: >
  Use PROACTIVELY before any git commit, and via /g-pre-commit-check.
  Self-review of staged changes: auto-fix lint, summarize the diff, run
  security and completeness checks. Complete this before the commit proceeds.
---

# g-pre-commit-check Skill

Self-review of staged changes before every commit. Triggered by commit intent
in the session or by explicit `/g-pre-commit-check`.

## Workflow

```mermaid
flowchart TD
    A1(["commit intent detected"]) --> B
    A2(["/g-pre-commit-check"]) --> B
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

## Step Router

Read ONLY the step file for the current step.

| Step | Load file | Description |
|---|---|---|
| 1 | `steps/step-1-gather.md` | Staged diff, scope classification (numeric) |
| 2 | `steps/step-2-autofix.md` | ESLint --fix on staged JS/TS files |
| 3 | `steps/step-3-review.md` | Mechanical greps + judgment checklist + report |

## Principles

- Be concise: the review takes seconds, not minutes.
- Never skip the security greps, even for a one-line diff.
- Flag, do not block: the user decides on every finding.
- This skill never runs `git commit` itself; it ends at the recommendation.

## Note on enforcement

Blocking `git commit` Bash calls until this skill ran requires a PreToolUse
hook registered in settings. That hook is NOT part of this skill; without it
the triggers are this skill's description and explicit invocation.
