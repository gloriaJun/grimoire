# Step 3: Design (architecture)

Payload guard: the invocation carried inline text after `design` -> that is
the standalone mode; load `steps/step-3b-design-standalone.md` instead of
this file.

Entry condition: the formal doc's goal section (`## 목표`) has at least one
non-blank line. Empty -> say "run /g-dev idea first, or pass a proposal
list or feasibility question inline for standalone mode" and stop.

## A. Inputs

1. Read the goal section of `$DOC`. A trailing `**설계 검토 항목:**` list
   there seeds section 8 (Open Questions): carry every item; none may be
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
3. Directory Layout - new project or new package only: the folder tree
   the Module Map projects onto (one fenced tree, top 2 levels plus one
   path per Module Map component), and a conventions table: scope
   (folder, file, identifier) | case rule | example, per language.
   Precedence: rules the repo already defines - detect with
   `ls eslint.config.* .eslintrc* .prettierrc* prettier.config.* .editorconfig CLAUDE.md 2>/dev/null`
   at the repo root - win as-is; the tech-stack reference in the global
   instructions fills only the gaps, and a deviation from it needs a
   reason in its row. Existing repo with no new package -> write
   `layout: follows existing repo structure` plus deviations only.
4. Data Flow - how data moves between modules; a mermaid diagram counts.
5. Feature List - `F-01`..`F-NN` one-liners; a feature depending on another
   ends with `(depends: F-01)`.
6. UI Direction - UI projects only: record 2-3 candidate directions
   (palette, two type roles, layout concept, signature element each) from
   the frontend-design wrap or the fallback. Render one self-contained
   HTML sample sheet per candidate at
   `$ASSETS/ui-samples/candidate-<N>.html`, tell the user how to open
   them, and record the pick made at the review gate. User defers ->
   write `theme pick: deferred` here; step 4 then creates the
   design-system task and the pick lands in the repo design-system doc
   it produces.
7. Testing Strategy - which detected commands verify what; none detected ->
   the concrete alternative (a script to add, named manual scenarios).
8. Open Questions - unresolved items; an empty section is allowed.

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
