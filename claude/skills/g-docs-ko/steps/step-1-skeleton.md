# Step 1: Regenerate Skeleton

From the repo root:

```bash
cd tools/doc-viewer
[ -d node_modules ] || pnpm install
pnpm build skeleton <rootName>
```

`<rootName>` defaults to `grimoire`.

- Any command exits non-zero: print its stdout+stderr and STOP the skill.

## Find pending segments

List sidecars that still have empty `ko` outside code fences:

```bash
find translations/<rootName> -name '*.md.json' | while read -r f; do
  n=$(jq '[.segments[] | select(.ko == "" and (.src | startswith("```") | not))] | length' "$f")
  [ "$n" -gt 0 ] && echo "$f $n"
done
```

- No output: report `translations already up to date`, then load `steps/step-3-build-serve.md`.
- Output: pass the file list (path + pending count) to `steps/step-2-translate.md`.
- `jq` parse error on any file: report that file as corrupt, exclude it, continue with the rest; list excluded files in the final hand-off.
