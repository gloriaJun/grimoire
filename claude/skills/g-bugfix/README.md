# g-bugfix

Gated bug-fix workflow for Claude Code: reproduce first, diagnose with
evidence, plan as a diff, and never touch code before explicit approval.

## Features

- Reproduction-first: the bug is reproduced locally (or its
  irreproducibility documented) before any diagnosis
- Root-cause report with file:line evidence; unverified claims are
  tagged, not asserted
- Fix plan in diff format (before/after blocks per file) with an
  executable verification list
- Hard approval gate: no repo file changes until the user explicitly
  approves the plan
- Optional subagent implementation after approval

## Usage

```
/g-bugfix <bug description>
```

The workflow runs stages 1-3 without pausing, then stops at the plan and
waits for an explicit go.

## How It Works

1. **Reproduce** - runs or writes a failing test, or drives the reported
   path; records the command as the verification harness
2. **Root cause** - traces backward from the symptom; reports with
   file:line evidence and a causal chain
3. **Plan + gate** - diff-format plan with verification items; stops
   until explicit approval, re-gates after every revision
4. **Implement** - inline or delegated to one subagent; re-runs the
   harness and repo tests, then proposes a commit
