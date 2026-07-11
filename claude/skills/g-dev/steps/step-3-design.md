# Step 3: Design (architecture)

Payload guard: the invocation carried inline text after `design` -> that is
the standalone mode; load `steps/step-3b-design-standalone.md` instead of
this file.

Entry condition: the formal doc's goal section (`## 목표`) has at least one
non-blank line. Empty -> say "run /g-dev idea first, or pass a proposal
list or feasibility question inline for standalone mode" and stop.

## A. Inputs

1. Read the goal section of `$DOC`. A trailing `**설계 검토 항목:**` list
   there seeds section 7 (Open Questions): carry every item; none may be
   dropped silently. Also carry every work-log `남은 것:` line whose value
   is not `없음`, deduplicated against the goal list; stale ones get
   pruned at the review gate.
2. Detect the repo's harness commands:

```bash
REPO_PATH=$(git rev-parse --show-toplevel 2>/dev/null)
jq -r '.scripts | to_entries[] | "\(.key): \(.value)"' "$REPO_PATH/package.json" 2>/dev/null
```

Command fails or file missing -> record `harness: none detected` and
continue; the Testing Strategy section must then state the concrete
alternative. Commands detected but inapplicable (= every deliverable is a
document or mockup while the command targets code) -> treat that part the
same as none detected: Testing Strategy must name a concrete alternative,
never cite an inapplicable command.

3. UI question: does this project render user-facing UI? Not obvious from
   the goal -> ask (one question). UI project -> run the frontend-design
   wrap per `references/external-skills.md` BEFORE drafting.

## B. Write architecture.md

Write `$ASSETS/architecture.md` with exactly these sections:

1. Tech Stack - table: layer | choice | reason. Respect the repo's existing
   conventions; for new projects follow the tech-stack reference in the
   global instructions.
2. Module Map - components and their responsibilities.
3. Data Flow - how data moves between modules; a mermaid diagram counts.
4. Feature List - `F-01`..`F-NN` one-liners; a feature depending on another
   ends with `(depends: F-01)`.
5. UI Direction - UI projects only: the frontend-design output or the
   4-point fallback from `references/external-skills.md`.
6. Testing Strategy - which detected commands verify what; none detected ->
   the concrete alternative (a script to add, named manual scenarios).
7. Open Questions - unresolved items; an empty section is allowed.

## C. Review gate

Present a summary (max 15 lines) plus every Open Question as a question to
the user (max 3 per batch, recommended answer first). Edit answers into
architecture.md before proceeding. Proceed only after the user approves the
architecture explicitly; silence is not approval. A skipped question, a
counter-question, or a new option from the user is NOT approval: resolve
that item first, then re-ask. A bare go signal while any item is open ->
re-present the open items and wait; never enter section D.

## D. Handoff

Run the handoff procedure in `references/state-format.md` with the next
step `breakdown`. Decisions and their reasons go in the g-vault-log summary
block.
