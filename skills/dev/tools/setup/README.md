# dev setup

Project quality tooling setup for `/dev setup`.

## What it does

1. **Detects** existing ESLint, Prettier, TypeScript, and Husky configuration
2. **Configures** only what is missing — never touches existing config without confirmation
3. **Asks** before setting up Husky git hooks

## Usage

```
/dev setup
```

No arguments needed. The tool detects your project's current state automatically.

## Features

- ESLint v9+ flat config (`eslint.config.ts`) with framework auto-detection (React, Next.js, TypeScript)
- Legacy ESLint migration prompt (`.eslintrc.*` → `eslint.config.ts`)
- Prettier config with sensible defaults
- TypeScript `typecheck` script (`tsc --noEmit`)
- Husky git hooks (pre-commit, pre-push, commit-msg) — opt-in, always confirmed

## How It Works

```
Step 1: Detect  →  Step 2: Configure  →  Step 3: Husky
```

Each step is defined in `steps/`:

| File | Purpose |
|------|---------|
| `step-1-detect.md` | Scan filesystem for existing config files |
| `step-2-configure.md` | Generate ESLint/Prettier/tsc config and install packages |
| `step-3-husky.md` | Confirm with user, then install Husky hooks |

## Notes

- Runs as a utility tool — no devlog required
- Tooling config is not persisted; `build.md`'s Local Verification detects the lint command
  on-demand from `package.json` scripts and config files
- Works alongside the `pre-commit-check` skill (Claude Code-only) without conflict
