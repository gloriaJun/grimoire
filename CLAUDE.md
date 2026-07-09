# grimoire (grimore2)

Source of truth for the user-level Claude Code configuration (v2). `claude/` is copy-synced one-way to `~/.claude/`. Repo rename to `grimoire` is planned at project completion.

## Critical rules

- Edit only in this repo. Direct edits in `~/.claude/` are overwritten on the next sync.
- Sync runs automatically on commit: `githooks/post-commit` (wired via `git config core.hooksPath githooks`) calls `sync.sh` when the commit touched `claude/`. It syncs the working tree state, not the commit. Preview with `./sync.sh --dry-run`.
- Sync ownership (see header of `sync.sh`):
  - `claude/CLAUDE.md` → `~/.claude/CLAUDE.md` (single managed file)
  - `claude/instructions/`, `claude/hooks/`, `claude/agents/` → full mirror with `--delete`. Deleting a file here deletes it live.
  - `claude/skills/`: only `g-*` entries are managed. `l-*` belongs to the company repo (`~/Documents/GithubWork/my-claude-skills`); anything else is warn-only.
  - `claude/settings.hooks.json` → merged into the `hooks` key of `~/.claude/settings.json` via jq. The file itself is never copied; other settings keys stay untouched.
- All definition files under `claude/` are English-only. Korean readability comes from the doc viewer (`tools/doc-viewer`), never from Korean source files. Korean is allowed inside files only as quoted examples (style pairs, trigger phrases) or template skeleton labels inside code fences.
- v1 backup at `~/.claude_bak` is read-only reference. It contains company-specific data (e.g. Jira ticket prefixes); never copy such content into this repo.
- Instruction change review: after editing definition files under `claude/`, do not commit right away. Regenerate translations (`pnpm build skeleton grimoire` → fill empty `ko` → `pnpm build`), start the viewer (launch.json `doc-viewer`), and ask the user to confirm the change in the viewer's diff panel. Commit only after confirmation - the post-commit sync makes it live.

## Layout

- `claude/` - the synced payload: CLAUDE.md, instructions/references (writing-style, tech-stack, code-review, skill-authoring, token-budget, templates/), hooks (pr-guard.sh, emdash-check.sh, definition-check.sh), settings.hooks.json
- `sync.sh`, `githooks/post-commit` - sync mechanism
- `tools/doc-viewer/` - bilingual static-site viewer (TypeScript)
- `.claude/launch.json` - preview server config for the viewer (port 4173)

## Hooks (claude/hooks/)

- Shell scripts reading tool-call JSON from stdin; exit 2 blocks (PreToolUse) or feeds back (PostToolUse).
- Inventory:
  - `pr-guard.sh` (PreToolUse, Bash): `gh pr create` must carry `--draft` and `--base`.
  - `emdash-check.sh` (PostToolUse, Write|Edit): flags em/en dashes written to md files.
  - `definition-check.sh` (PostToolUse, Write|Edit): definition-file size budgets, English-only check, mermaid/README presence for SKILL.md.
- `settings.hooks.json` also carries an inline SessionStart hook that logs codex in from `$OPENAI_CODEX_API_KEY`. It exists solely so explicit codex requests work; autonomous codex use stays forbidden (user CLAUDE.md).
- Test manually before commit: `echo '<tool-call json>' | claude/hooks/<script>.sh; echo $?`.
- Registered in `claude/settings.hooks.json`, which references them at their live path `$HOME/.claude/hooks/`.
- Changes take effect from the next Claude Code session (settings load at session start).

## doc-viewer (tools/doc-viewer/)

- `pnpm install` once; `pnpm build` regenerates `dist/`; `pnpm build skeleton [rootName]` regenerates translation sidecars in `translations/` (carries over `ko` for unchanged segments; fill only the empty `ko` fields).
- `dist/` and `translations/` are gitignored: translations are display-only, the English source is the sole authority.
- Roots (this repo + company repo) are defined in `doc-viewer.config.json`.
- Serve with the preview tool (launch.json `doc-viewer`) or `node tools/doc-viewer/serve.mjs`.
