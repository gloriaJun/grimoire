# Step 3: Husky — Confirm and Configure

Always ask before configuring Husky. Never install or modify git hooks without explicit user confirmation.

---

## Confirmation

```
Set up Husky git hooks?
Husky runs quality checks at git hook points in all environments (terminal, IDE, CI).

Note: This is separate from the Claude Code pre-commit-check skill, which only runs
inside Claude Code sessions. Husky hooks apply universally.

  1. Yes — configure hooks
  2. No  — skip Husky setup

> Enter number
```

**2 selected:** Skip to Summary section. Do not install or modify anything.

---

## Hook Selection (if user chose 1)

```
Which hooks would you like to configure?
(Enter numbers separated by commas)

  1. pre-commit  — run lint-staged on staged files before each commit  ← recommended
  2. pre-push    — run type-check + tests before each push
  3. commit-msg  — validate conventional commit message format

> Enter numbers (e.g. 1,2)
```

At least one must be selected. If the user enters nothing or an invalid value, re-prompt once.

---

## Installation

```bash
pnpm add -D husky lint-staged
pnpm exec husky init
```

After `husky init`, update the `prepare` script in `package.json`:

```json
{
  "scripts": {
    "prepare": "is-ci || husky"
  }
}
```

Install `is-ci` to prevent Husky from running in CI environments:

```bash
pnpm add -D is-ci
```

> `is-ci || husky` skips the `husky` command when `CI=true` or similar env vars are set.

---

## Hook Files

Create only the hooks the user selected.

### pre-commit

`.husky/pre-commit`:
```sh
#!/bin/sh
pnpm lint-staged
```

Add `lint-staged` config to `package.json`:
```json
{
  "lint-staged": {
    "*.{ts,tsx,js,jsx}": ["eslint --fix", "prettier --write"],
    "*.{json,md,css}": ["prettier --write"]
  }
}
```

> `lint-staged` targets only staged files, keeping commit speed fast regardless of project size.

### pre-push

`.husky/pre-push`:
```sh
#!/bin/sh
pnpm typecheck && pnpm test
```

> Uses `lintConfig.typecheck.command` if available; defaults to `pnpm typecheck`.
> Uses `testConfig.unit.command` if available; defaults to `pnpm test`.
> If either command is unknown, warn and omit it from the hook:
> ```
> ⚠️  Test command not found. Add it manually to .husky/pre-push after setup.
> ```

### commit-msg

`.husky/commit-msg`:
```sh
#!/bin/sh
commit_msg=$(cat "$1")
pattern='^(feat|fix|docs|style|refactor|test|chore|perf|ci|build|revert)(\(.+\))?: .{1,50}'
echo "$commit_msg" | grep -Eq "$pattern" || {
  echo "❌ Commit message does not follow conventional commit format."
  echo "   Expected: <type>(<scope>): <subject>  (max 50 chars)"
  echo "   Types: feat|fix|docs|style|refactor|test|chore|perf|ci|build|revert"
  exit 1
}
```

---

## lintConfig Update

After configuring, update `lintConfig.husky`:

```json
{
  "husky": {
    "configured": true,
    "hooks": ["pre-commit"]
  }
}
```

List only the hooks the user actually selected.

If active devlog is present, write updated `lintConfig` to `_state.json`.

---

## Summary

Print a final summary of everything configured in this setup run:

```
✅ /dev setup complete

──────────────────────────────────────────
ESLint       eslint.config.ts   pnpm lint
Prettier     prettier.config.ts pnpm format
TypeScript   tsconfig.json      pnpm typecheck
Husky        pre-commit         pnpm lint-staged
──────────────────────────────────────────

Next steps:
  - Run "pnpm install" if node_modules are not yet installed
  - Edit eslint.config.ts to add project-specific rules
  - Edit prettier.config.ts to adjust formatting preferences
  - Run /dev build to start implementing features
```

Adjust the table to show only the tools that were actually set up.
For skipped tools, omit them from the table.
