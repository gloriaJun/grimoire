# Protected Paths (NEVER delete)

These paths must be excluded from all cleanup operations:

```
~/.claude/CLAUDE.md              # instruction file (symlink)
~/.claude/instructions/          # instruction files (symlink)
~/.claude/hooks/                 # hook scripts (symlink)
~/.claude/skills/                # skills (symlink)
~/.claude/settings.json          # user settings
~/.claude/config.json            # config
~/.claude/policy-limits.json     # policy
~/.claude/projects/*/memory/     # auto-memory (persists across sessions)
~/.codex/AGENTS.md               # agent instructions
~/.codex/config.toml             # config
~/.codex/rules/                  # approval rules (symlink)
~/.codex/.codex-global-state.json
```
