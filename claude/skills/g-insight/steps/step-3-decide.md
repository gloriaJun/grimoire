# Step 3: Report and Decide

## Report

Rank findings: C first, then E, D, A, B, F; within a category by count of
supporting evidence entries, descending. Show at most 8 in full; list any
overflow as a one-line backlog with category tags.

```
## Insight Report (N findings, M backlog)

### 1. [C] title
- Evidence: <quote or file:line>
- Suggestion: <the exact change>
- Target: <exact file path>
```

## Questions (only when a finding is undecidable)

A finding whose fix has 2+ defensible designs becomes a question instead of a
suggestion: multiple choice, recommended option FIRST and marked `(권장)`
with a one-line reason, at most 3 questions per batch. An answer conflicting
with an existing hard rule is pointed out on the spot and re-confirmed.
Never ask what the evidence already answers.

## Per-finding decision

| Choice | Action |
|---|---|
| Apply | Edit the target now at its source of truth. The edit must pass the lightweight-model test (SKILL.md hard rule). Post-completion review and commit flow follow skill-authoring.md and the repo's rules. |
| Defer | Write one memory file per item in the Defer format below, plus a one-line MEMORY.md pointer. MEMORY.md stays an index, never content. |
| Skip | Nothing. |

## Defer format

Directory: `~/.claude/projects/<project-dir>/memory/` where `<project-dir>`
is the current project's entry under `ls ~/.claude/projects/` (the sanitized
cwd path). File `<kebab-title>.md`:

```markdown
---
name: <kebab-title>
description: <one line - used for recall relevance>
metadata:
  type: project
---

<finding: evidence quote, suggestion, target file path>
```

## Completion criterion

The run is complete when every finding is Applied, Deferred, or Skipped;
answers to questions must resolve into one of the three. Questions left
unanswered at session end are listed as pending and the run is reported as
incomplete, never as done.
