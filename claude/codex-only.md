# Codex-Only Instructions

These instructions are included only in `~/.codex/AGENTS.md`; they are not
included in `~/.claude/CLAUDE.md`.

## Git / GitHub Policy

You may:
- Run read-only Git inspection commands: `git status`, `git diff`, `git log`, and `git branch`.
- Modify files inside the workspace only within the current requested or explicitly approved task scope.
- Run repository-local verification commands such as tests, lint, typecheck, and build.
- Use `gh` for read-only operations such as viewing/listing PRs, issues, diffs, checks, runs, and repository metadata.

You may conditionally:
- Run `git add` only for explicit paths created or modified by the current task, or paths the user explicitly approves for the current commit. Never use `git add -A`.
- Propose a commit after summarizing the diff, target file list, commit message, and anything intentionally excluded.

You must ask for approval before:
- Running `git commit`.
- Running `git push`, including pushes needed for PR creation.
- Creating a PR.
- Posting comments, review replies, issue comments, discussion messages, or any other remote-visible message.
- Changing PR/issue metadata such as labels, assignees, milestones, project fields, status, title, or body.
- Merging, closing, reopening, or otherwise changing PR/issue state.

You must not run destructive or history-rewriting commands unless explicitly requested and separately approved immediately before execution:
- `gh pr merge`
- `git reset --hard`
- `git clean -fd`
- `git checkout -- .`
- `git restore .`
- `git rebase`
- `git push --force`
- `git push --force-with-lease`
- Destructive filesystem commands such as `rm`, `rm -r`, `rm -rf`, `find ... -delete`, or commands that overwrite existing files outside the approved task scope.
