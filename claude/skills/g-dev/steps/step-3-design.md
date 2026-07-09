# Step 3: Design (architecture)

Entry condition: the formal doc's goal section (`## 목표`) has at least one
non-blank line. Empty -> say "run /g-dev idea first" and stop.

## A. Inputs

1. Read the goal section of `$DOC`.
2. Detect the repo's harness commands:

```bash
REPO_PATH=$(git rev-parse --show-toplevel 2>/dev/null)
jq -r '.scripts | to_entries[] | "\(.key): \(.value)"' "$REPO_PATH/package.json" 2>/dev/null
```

Command fails or file missing -> record `harness: none detected` and
continue; the Testing Strategy section must then state the concrete
alternative.

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
architecture explicitly; silence is not approval.

## D. Handoff

Run the handoff procedure in `references/state-format.md` with the next
step `breakdown`. Decisions and their reasons go in the g-vault-log summary
block.
