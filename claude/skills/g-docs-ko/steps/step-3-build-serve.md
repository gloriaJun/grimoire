# Step 3: Build and Serve

```bash
cd tools/doc-viewer && pnpm build
```

- Exit non-zero: print the error and STOP.
- Verify `dist/index.html` exists and its mtime is newer than the build start;
  otherwise report the build as failed and STOP.

## Serve

Start the preview server defined in `.claude/launch.json` under the name
`doc-viewer` (port 4173). When no preview tooling is available, run
`node tools/doc-viewer/serve.mjs` in the background instead.

## Hand-off (end of skill)

Report to the user:

- number of sidecar files updated in Step 2 (and any files excluded as corrupt)
- the viewer URL (default `http://localhost:4173`)
- request: confirm the changes in the viewer's diff panel

Then STOP. Do not propose or run a commit inside this skill; the commit
follows the repo's instruction-change review rule after the user confirms.
