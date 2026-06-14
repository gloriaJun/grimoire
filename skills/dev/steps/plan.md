# Plan: Requirements → PRD

Goal: Structure requirements into a formal PRD.

## Agent

`requirements-analyst` (model: sonnet)

## Input

One of the following (check the memory file `## Artifacts`):
- `brainstorm` (from idea step), OR
- User's requirements description, OR
- External planning document

## Vault Context Check

Before invoking the agent, read `shared/vault-context.md` and execute with:
- **keywords**: 2–5 terms extracted from the brainstorm title/summary (or user input)
- **search_focus**: `duplicate`, `past-mistakes`
- **scope_hint**: resolved from cwd

Pass vault findings to the `requirements-analyst` agent prompt as background context.

## Process

1. Invoke the `requirements-analyst` agent with available inputs.
2. The agent produces `PRD-<task-name>.md`.
   - Location: project `docs/` if it exists, otherwise task subdirectory.
3. Register the PRD path in the memory file `## Artifacts`.

## Review

Load `references/review-protocol.md` and execute the full review workflow.
- **Artifact**: PRD at `## Artifacts` prd path
- **Codex focus**: "Review this PRD for missing requirements, ambiguity, and feasibility"

## State Update

`current-step` ← `"design"`, append `"plan"` to `## Completed Steps`
`## Artifacts` prd ← PRD path

Append review approval entry to the `history.md` 결정·블로커 기록 (see `schemas/history.md` Review Approval Entries).

Follow update mechanics from `schemas/memory.md`.

## Session Handoff

Read `steps/_handoff.md` and follow the handoff instructions.
Next sub-command: `/dev design`
