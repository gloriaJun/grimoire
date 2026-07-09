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

## JS/TS File Conventions

Single-responsibility at the file level:

- No mixing constants and functions: a file whose role is to export immutable
  values must not define functions (transformation logic, utilities).
- Split by role, even within the same domain: e.g. `auth-constants.ts` + `auth-utils.ts`.
- This applies regardless of filename (`constants.ts`, `config.ts`, `tokens.ts`, etc.):
  if the file's purpose is "a collection of immutable values", no function mixing.

When file-level conventions grow to 5 or more rules, extract them to a dedicated
conventions reference and add a trigger row for it in CLAUDE.md.
