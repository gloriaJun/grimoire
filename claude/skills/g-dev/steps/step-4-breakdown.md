# Step 4: Breakdown (tasks + harness criteria)

Entry condition: `$ASSETS/architecture.md` exists. Missing -> say "run
/g-dev design first" and stop.

## A. Split into tasks

- 2-8 tasks per project. A draft with more than 8 -> merge the smallest
  adjacent tasks until at most 8 remain.
- Each task must leave the repo consistent on its own (build and tests
  green after just that task). An ordering requirement becomes a `depends`
  entry, never a bigger task.
- Map features to tasks 1:1 where possible; bundle only trivial features.
- architecture.md has a Directory Layout tree for a repo or package that
  does not exist yet -> t01 is a scaffold task: create the tree, tooling
  config (lint, formatter, tsconfig, runtime pin), a filename-case lint
  rule, root README.md (repo intro, workspace map, run commands), and
  root CLAUDE.md distilled from architecture.md Tech Stack + Directory
  Layout (monorepo: shared per-language rules live in the root file; a
  package gets its own CLAUDE.md only where it deviates). Criteria
  include the lint and build commands the scaffold introduces -> pass;
  every other task lists t01 in depends.
- architecture.md UI Direction containing `theme pick: deferred` -> the
  first non-scaffold task is a design-system task: it re-renders the candidate sheets
  into the repo docs, carries `manual: user picks the theme` as a
  criterion, and records the pick in the repo design-system doc it
  creates at `<project docs dir per architecture.md Module Map>/design-system.md`;
  every other UI task lists it in depends. Rewrite the architecture.md
  line to `theme pick: deferred to <that path>` now (breakdown owns
  `$ASSETS`; build sessions do not).

## B. Write task files

One file per task at `$ASSETS/tasks/t<NN>-<kebab>.md` per
`references/state-format.md`, initial status `pending`, session `none`.
Quality gate per file - 1-4 always, 5 when it applies:

1. Goal states a deliverable, not an activity.
2. Plan has 3-7 numbered steps.
3. Completion criteria: 2-5 items, each `command -> expected result`, or
   `manual: <named user check>`. Zero executable criteria is allowed only
   for doc-only or user-verification tasks.
4. depends lists only existing task ids; verify each with
   `ls "$ASSETS/tasks/"<id>-*.md`.
5. A task that creates a new package or project folder lists that
   folder's README.md (purpose, commands, structure) as a deliverable
   and carries it in the completion criteria.

Any gate failing -> fix that task file before writing the next one.

## C. Parallel plan

Print two lists for the user:

- claimable now (empty depends, or all depends already done): "each can run
  as its own session with `/g-dev build t<NN>`. Rule for running 2+ build
  sessions at the same time: at most ONE build session per checkout - every
  concurrent session needs its own git worktree"
- blocked: one line per task, `t<NN> waits on t<MM>`

## D. Handoff

Run the handoff procedure in `references/state-format.md` with the next
step `build`.
