# Tech Stack Preferences

Cross-project tool preferences. Load on demand when initializing a project,
setting up tooling, or deciding JS/TS file structure.
Frameworks and libraries are defined per project in each repo's CLAUDE.md,
and each repository's own configuration always takes precedence over this file.

## Package Manager

- pnpm for all projects.

## Node.js Version Manager

- mise is the default. Global config (`~/.config/mise/config.toml`) sets
  `legacy_version_file = true`, so mise auto-detects `.nvmrc`.

| Situation | Action |
|---|---|
| No `.nvmrc` | Create `.mise.toml` at project root |
| `.nvmrc` exists | Convert to `.mise.toml` and delete `.nvmrc` |

`.mise.toml` format:

```toml
[tools]
node = "22"   # pin major version (mise picks the latest patch)
```

## JavaScript / TypeScript

- Language: TypeScript first. If a project must start in JS, add a TypeScript
  migration TODO (tsconfig setup, then per-file conversion) to the deliverable.
- Linting: ESLint (configure at project init).
- Formatting: Prettier (integrate with ESLint; `.prettierrc` or `prettier.config.ts`).

## Naming Conventions (JS/TS)

Gap-fillers only, per the header precedence rule: a project's own style
definition (lint/formatter config, CLAUDE.md, a conventions doc, or the
dominant existing convention) wins; apply these defaults only where the
project defines nothing.

| Scope | Case | Example |
|---|---|---|
| Folders | kebab-case | `user-profile/` |
| Files (components included) | kebab-case | `auth-utils.ts`, `login-form.tsx` |
| Variables / functions | camelCase | `getUserId` |
| Types / classes / component identifiers | PascalCase | `LoginForm` |
| Constant exports / env vars | UPPER_SNAKE_CASE | `MAX_RETRY`, `API_BASE_URL` |

Enforce folder/file case at project init with eslint-plugin-check-file
(covers folder and file names; fall back to eslint-plugin-unicorn
`filename-case` only when check-file cannot express the rule).

## JS/TS File Conventions

Single-responsibility at the file level:

- No mixing constants and functions: a file whose role is to export immutable
  values must not define functions (transformation logic, utilities).
- Split by role, even within the same domain: e.g. `auth-constants.ts` + `auth-utils.ts`.
- This applies regardless of filename (`constants.ts`, `config.ts`, `tokens.ts`, etc.):
  if the file's purpose is "a collection of immutable values", no function mixing.

When file-level conventions grow to 5 or more rules, extract them to a dedicated
conventions reference and add a trigger row for it in CLAUDE.md.
