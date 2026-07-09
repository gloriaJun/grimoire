# Protected Paths (NEVER delete)

These paths must be excluded from all cleanup operations.
`~/.claude/` config content is copy-synced from the grimoire repo
(`~/Documents/GitHubPrivate/grimoire/claude/`); deleting it here breaks the
live setup until the next sync.

```
~/.claude/CLAUDE.md              # instruction file (repo-managed)
~/.claude/instructions/          # instruction files (repo-managed)
~/.claude/hooks/                 # hook scripts (repo-managed)
~/.claude/skills/                # skills (repo-managed g-*, company l-*)
~/.claude/agents/                # agent prompts (repo-managed)
~/.claude/plugins/               # installed plugins and marketplaces
~/.claude/settings.json          # user settings (hooks key merged by sync)
~/.claude/config.json            # config
~/.claude/policy-limits.json     # policy
~/.claude/projects/*/memory/     # auto-memory (persists across sessions)
~/.codex/AGENTS.md               # agent instructions
~/.codex/config.toml             # config
~/.codex/rules/                  # approval rules
~/.codex/.codex-global-state.json
```
