# Tech Stack Preferences

## Package Manager
- pnpm preferred for all projects

## Node.js Version Manager

- mise is the default Node.js version manager
- Global config (`~/.config/mise/config.toml`) sets `legacy_version_file = true`, so mise auto-detects `.nvmrc`

### Per-Project Rules

| Situation | Action |
|-----------|--------|
| No `.nvmrc` | Create `.mise.toml` at project root |
| `.nvmrc` exists | Convert to `.mise.toml` and delete `.nvmrc` |

### `.mise.toml` Format

```toml
[tools]
node = "22"   # pin major version (mise picks the latest patch)
```

## JavaScript / TypeScript

Defaults for JS/TS projects:
- **Language**: Prefer TypeScript. If starting in JS, plan a migration path.
- **Linting**: ESLint (configure at project init)
- **Formatting**: Prettier (integrate with ESLint, use `.prettierrc` or `prettier.config.ts`)
- Project-specific ESLint rule sets and Prettier config may override these in each repo's CLAUDE.md

## JS/TS File Conventions

Single-responsibility principle at the file level:

- **No mixing constants and functions**: A file whose role is to export immutable values must not define functions (transformation logic, utilities)
- **Split by role, even within the same domain**: e.g. `auth-constants.ts` + `auth-utils.ts`
- This applies regardless of filename (`constants.ts`, `config.ts`, `tokens.ts`, etc.) — if the file's purpose is "a collection of immutable values", no function mixing allowed

When file-level conventions grow to 5+ rules, extract to `instructions/js-ts-conventions.md`.

## Terminal Environment

- **Terminal**: cmux (macOS native, AI-agent-optimized, Ghostty-based; no tmux prefix key)
- When suggesting "open in browser" (e.g., `/tmp/` HTML reports), mention cmux's built-in browser alongside the system default
- Split panes are native — suggest them for parallel long-running processes (e.g., dev server + test watcher)

## General
- Specific frameworks and libraries are defined per project in each repo's CLAUDE.md
- This file covers cross-project preferences only
