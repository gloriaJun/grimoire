# Git Workflow

## Commit Message Convention

Format: `<type>: <subject>`

### Types
`feat` new feature · `fix` bug fix · `perf` performance · `refactor` refactoring ·
`revert` revert commit · `style` formatting only (no logic change) · `docs` documentation ·
`test` tests only (no logic change) · `build` build scripts · `ci` CI/CD scripts ·
`chore` misc (packages, config)

### Format Rules
- Subject: max 50 characters, lowercase first letter, imperative mood, no trailing period
- Body: max 72 characters per line, explain "what" and "why" (not "how"), use `-` for multiple points
- Separate subject and body with a blank line
- Write commit messages (title and body) in English only

## Branch Naming Convention

Format: `<type>/<ticket>_<short-description>` or `<type>/<short-description>` (no ticket)

- `type`: same set as commit types (feat, fix, refactor, chore, etc.)
- `ticket`: Jira ticket ID (e.g., `LNSQW-1977`). Omit entirely when there is no ticket — no placeholder needed.
- `short-description`: kebab-case, concise

```
feat/LNSQW-1234_add-dark-mode     # with ticket
chore/update-deps                 # no ticket
```

## Branch Confirmation Rule

When the user specifies a target branch (e.g., "work on branch X", "create branch X and work there"), record it as the **designated branch** for the session.

Before committing or pushing, if the current branch differs from the designated branch, always confirm: show designated vs current branch side by side and ask whether to commit to the current branch or switch to the designated one.

### Worktree Branch Guard

Before committing or pushing, if the current branch matches the `worktree-*` pattern AND no designated branch has been recorded, always block and ask which feature branch the commit should go to (worktree branches are typically not deployment targets). After the user answers, `git checkout <branch>` and proceed.

This check applies to every commit and push until a designated branch is confirmed for the session.

## Rules
- Co-Authored-By line is optional — include only when user requests
- Always create new commits, never amend unless explicitly asked
- Stage specific files, avoid `git add -A`
- When editing an existing file, follow the language convention of that file

## GitHub CLI

Use `gh` CLI for all GitHub-related operations.
