# User-Level Instructions

Source of truth: `~/Documents/GitHubPrivate/grimore2/claude/` - sync scripts assemble these fragments into the tool config dirs (`~/.claude/CLAUDE.md` via `sync.sh`, `~/.codex/AGENTS.md` via `codex-sync.sh`) on commit. Always edit in the repository and commit - direct edits to the generated files get overwritten on the next sync.
Project-specific rules (tech stack details, commands, architecture) go in each repository's own instruction file (CLAUDE.md / AGENTS.md) - this file is only about the 'user'.
