---
name: g-docs-ko
description: >
  Regenerate the bilingual doc viewer for the grimoire repo after definition
  files under claude/ change: rebuild translation sidecars, fill empty Korean
  segments, build the viewer, and hand off for diff review. Invoke via
  /g-docs-ko or right after editing definition files in that repo.
---

# g-docs-ko Skill

Viewer regeneration pipeline for the grimoire repo (currently
`~/Documents/GitHubPrivate/grimoire`). Produces the review state the repo
requires before committing `claude/` definition files.

## Workflow

```mermaid
flowchart TD
    A(["/g-docs-ko or definition-file edits done"]) --> B{"repo has tools/doc-viewer/doc-viewer.config.json?"}
    B -- no --> Z(["Stop: not the grimoire repo"])
    B -- yes --> C["Step 1: Regenerate skeleton"]
    C -- build error --> Z2(["Stop with error"])
    C --> D{"empty ko segments found?"}
    D -- yes --> E["Step 2: Fill Korean translations"]
    D -- no --> F
    E --> F["Step 3: Build + serve viewer"]
    F --> G(["User reviews diff panel - STOP, no commit"])
```

## Preconditions

- Resolve the repo root: `git rev-parse --show-toplevel`. If
  `<root>/tools/doc-viewer/doc-viewer.config.json` does not exist, print
  `g-docs-ko runs only in the grimoire repo` and stop.
- Root name: default `grimoire`. A different root defined in
  `doc-viewer.config.json` may be passed as an argument.

## Step Router

Read ONLY the step file for the current step.

| Step | Load file | Description |
|---|---|---|
| 1 | `steps/step-1-skeleton.md` | Regenerate translation sidecars |
| 2 | `steps/step-2-translate.md` | Fill empty `ko` fields (code fences stay empty) |
| 3 | `steps/step-3-build-serve.md` | Build dist, start the viewer, hand off |

## Hard Rules

- The English source file is the only authority; sidecars are display-only.
  Never edit a source md to match a translation.
- The skill ends at "viewer ready for review". Committing is a separate
  user-approved action (CLAUDE.md commit-proposal rule).
- Never run the final `pnpm build` before Step 2 finishes: dist must include
  the new translations.
