# Git Workflow

## Commit Message Convention

Format: `<type>: <subject>`

### Types
| Type | Description |
|------|-------------|
| feat | New feature |
| fix | Bug fix |
| perf | Performance improvement |
| refactor | Refactoring |
| revert | Revert previous commit |
| style | Code style (formatting, semicolons; no logic change) |
| docs | Documentation (add, update, delete) |
| test | Tests (add, update, delete; no logic change) |
| build | Build script changes |
| ci | CI/CD script changes |
| chore | Miscellaneous (package install, config changes) |

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
fix/LNSQW-1977_color-scheme       # with ticket
chore/update-deps                  # no ticket
refactor/theme-single-file         # no ticket
```

## Branch Confirmation Rule

When the user specifies a target branch (e.g., "work on branch X", "create branch X and work there"), record it as the **designated branch** for the session.

Before committing or pushing, if the current branch differs from the designated branch, always confirm:

```
Designated branch : fix/LNSQW-1977_color-scheme
Current branch    : worktree-openchat-theme  ← mismatch

Commit to current branch (worktree-openchat-theme)?
Or switch to the designated branch (fix/LNSQW-1977_color-scheme)?
```

## Rules
- Co-Authored-By line is optional — include only when user requests
- Always create new commits, never amend unless explicitly asked
- Stage specific files, avoid `git add -A`
- When editing an existing file, follow the language convention of that file

## GitHub CLI

Use `gh` CLI for all GitHub-related operations.
