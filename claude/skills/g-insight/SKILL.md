---
name: g-insight
description: >
  /g-insight command only. Post-task mini-audit of the Claude Code setup:
  diagnoses gaps between this session's actual work and the definitions that
  could have governed it (CLAUDE.md, instructions, skills, hooks, agents),
  then drives per-finding decisions. May be invoked from another skill's
  completion step. Manual invocation only - do NOT auto-trigger.
---

# g-insight

Session-evidence-driven audit of the definition layer. Compares what actually
happened in this session against every referable definition, reports gaps in
six fixed categories (A-F), and ends with per-finding decisions. Never reviews
project code quality. A full static audit of unexercised files is out of
scope - that belongs to a dedicated audit session.

## Flow Diagram

```mermaid
flowchart TD
    A1(["/g-insight"]) --> B
    A2(["invoked from another skill"]) --> B
    B["Step 1: Enumerate definitions,
mark exercised, extract evidence"] --> C{"exercised beyond CLAUDE.md,
or evidence found?"}
    C -- none --> Z(["Output exactly: 'No suggestions.'"])
    C -- yes --> D["Step 2: Diagnose A-F
(quotes / file:line / test -e)"]
    D --> E{"findings?"}
    E -- none --> Z
    E -- yes --> F["Step 3: Ranked report (max 8)"]
    F --> G{"per finding"}
    G -- undecidable --> H["Ask user: multiple choice,
recommended first, max 3 per batch"] --> G
    G -- Apply --> I["Edit at source of truth
(read-only until here)"]
    G -- Defer --> J["Memory file + MEMORY.md pointer"]
    G -- Skip --> K["Discard"]
    I --> L{"more findings?"}
    J --> L
    K --> L
    L -- yes --> G
    L -- no --> M(["Done"])
```

## Step Router

Read ONLY the step file for the current step.

| Step | Load file | Description |
|---|---|---|
| 1 | `steps/step-1-collect.md` | Enumerate the definition layer, mark exercised, extract session evidence |
| 2 | `steps/step-2-diagnose.md` | Six-category gap diagnosis with mechanical checks |
| 3 | `steps/step-3-decide.md` | Ranked report, questions, Apply / Defer / Skip |

## Hard Rules

- Evidence or silence: every finding carries a verbatim quote, a named tool
  call, or file:line. What cannot be verified is marked `미확인` with how to
  verify it - never presented as a finding.
- Read-only through Steps 1-3. Files change only after the user picks Apply
  for that specific finding.
- Standalone runs stay in the main context (the conversation IS the input; do
  not delegate evidence extraction). Invoked from another skill, it may run
  as a subagent fed that skill's task summary.
- Every Apply that touches a definition file must itself pass the
  lightweight-model test: exact commands, numeric thresholds, termination
  conditions.
