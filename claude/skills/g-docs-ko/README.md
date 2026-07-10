# g-docs-ko

Regenerates the bilingual doc viewer of the grimoire repo after definition-file edits: translation skeleton, Korean fill-in, build, and serve for the user's diff review.

## Features

- **Repo-Gated** - refuses to run outside the repo that contains `tools/doc-viewer/doc-viewer.config.json`
- **Skeleton Reuse** - `pnpm build skeleton` carries over unchanged Korean segments; only new/changed blocks get translated
- **Code-Fence Aware** - segments whose source is a code fence keep an empty `ko` by design
- **Batch Translation** - more than 5 pending sidecars are delegated to lightweight-tier agents (max 3 parallel)
- **Review Hand-off** - ends with the viewer running and an explicit stop; committing stays a separate approved action

## Usage

```
/g-docs-ko [rootName]
```

Default root: `grimoire`. Before the final commit of definition-file changes under `claude/`, the assistant asks whether to run this review; it runs only on an explicit yes (or via direct `/g-docs-ko`).

## How It Works

```
/g-docs-ko
  -> Step 1: pnpm build skeleton <root>; list sidecars with empty ko (non-fence)
  -> Step 2: fill empty ko segments; verify zero remain
  -> Step 3: pnpm build; serve on port 4173; ask the user to review the diff panel
  -> STOP (commit is proposed separately after user confirmation)
```
