# Step 2: ESLint Auto-fix

1. Collect staged lintable files:

```bash
STAGED=$(git diff --cached --name-only --diff-filter=ACM | grep -E '\.(js|jsx|ts|tsx|mjs|cjs|vue|svelte)$')
```

2. Skip conditions - report `lint skipped: <reason>` and load Step 3 directly when any holds:
   - `$STAGED` is empty
   - no ESLint config: no `eslint.config.*` and no `.eslintrc*` at the repo root, and no `"eslint"` entry in root package.json dependencies/devDependencies

3. Run (pnpm repo, i.e. `pnpm-lock.yaml` exists; otherwise use `npx` instead of `pnpm exec`):

```bash
pnpm exec eslint --fix $STAGED
```

4. Post-run branches:
   - Fixer changed files (`git diff --name-only -- $STAGED` non-empty): `git add` exactly those files and report `formatter applied to N files`.
   - ESLint exits non-zero with remaining errors: do NOT fix code logic here; carry the error list into Step 3 as findings.
   - ESLint binary not found at run time: report `lint skipped: eslint not installed`, continue.

Then load `steps/step-3-review.md`.
