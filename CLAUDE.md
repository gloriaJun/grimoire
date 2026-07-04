# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Grimoire is a personal AI coding assistant configuration hub — the single source of truth for Claude Code and Codex CLI settings. It manages instruction files, hooks, and skills via symlinks from `$HOME` config directories.

There is no build system, no package manager, and no test runner. The repo contains Markdown specifications, prompt templates, shell scripts, and static HTML/CSS/JS.

## Repository Structure

```
claude/          # Custom instruction files (CLAUDE.md, instructions/)
                 # instructions/references/ for on-demand guidelines
                 # Symlinked to ~/.claude/
hooks/           # Hook scripts, symlinked to ~/.claude/hooks/
agents/          # Custom agent definitions, symlinked to ~/.claude/agents/
  idea-explorer.md          # Idea exploration via strategic questioning
  requirements-analyst.md   # Requirements analysis -> PRD
  system-architect.md       # Architecture design -> TRD
  feature-executor.md       # Feature implementation (Claude/Codex selection)
  code-reviewer.md          # Cross-agent code review (Claude<->Codex)
  frontend-reviewer.md      # Frontend-specific review (a11y, responsive)
codex/           # Codex CLI settings
  rules/         # Shell command approval rules, symlinked to ~/.codex/rules/
skills/          # Claude Code skills, symlinked to ~/.claude/skills/
  dev/           # Unified development workflow (/dev idea|plan|design|build|complete|test|refactor|troubleshoot|review|retro|setup|devlog-note|status|help)
    steps/       # Planning lifecycle step files
    tools/       # Utility tools: refactor/, troubleshoot/, test/, review/, retro/, devlog-note/, setup/
    schemas/     # State schema (memory.md, history.md)
    references/  # review-protocol.md
    shared/      # vault-context.md (shared across tools)
  my-claude-audit/
  sync-config/   # Link shared config to project .claude/
  cleanup/       # Diagnose and clean up sessions, logs, caches
  insight/       # Post-task improvement suggestions for grimoire
  pre-commit-check/  # Auto self-review before commit
ccstatusline/    # ccstatusline widget config, symlinked to ~/.config/ccstatusline/
  settings.json        # Status bar widget layout
  worktree-widget.sh   # Custom widget: detects active git worktree from cwd
templates/       # Settings templates (no secrets, reference only)
plugins.json     # Plugin marketplace manifest (reference only)
setup.sh         # Symlink setup script
```

## Key Files

- **`claude/CLAUDE.md`** — Entry point instruction file, symlinked to `~/.claude/CLAUDE.md`.
- **`setup.sh`** — Creates symlinks, generates `~/.codex/AGENTS.md`, shows plugin info. Run with `--dry-run` to preview.
- **`plugins.json`** — Tracks which plugin marketplaces and plugins to install. Not auto-applied; reference for manual setup.

## Skill Anatomy

Each skill lives in `skills/<skill-name>/` and must have a `SKILL.md` with YAML frontmatter:

```yaml
---
name: skill-name
description: >
  Trigger description. First line determines when Claude activates the skill.
---
```

### Naming Convention

The `name:` field in SKILL.md frontmatter determines the slash command — folder names do not need to match.

| Scope | `name:` prefix | Example |
|-------|----------------|---------|
| Global (grimoire-wide) | `g-` | `g-cleanup`, `g-my-claude-audit` |
| Project-local | `l-` | `l-pr` |
| No prefix | workspace-specific or paired with project CLAUDE.md | `dev` |

### Authoring Convention

For skill authoring rules (orchestrator pattern, mermaid diagrams, script extraction),
see `claude/instructions/references/skill-authoring.md`.

### Subagent Pattern (for my-claude-audit)

1. **Prompt files** in `analyzer-prompts/` define each subagent's task
2. Prompts are loaded via the **Read tool** (never `@`-import)
3. Subagents are dispatched via the **Agent tool** with `subagent_type: Explore`
4. Subagents return **JSON only** — no prose, no markdown
5. Results are combined and injected into an HTML template via `{{PLACEHOLDER}}` replacement

## Agent Anatomy

Each agent lives in `agents/<name>.md` with YAML frontmatter:

```yaml
---
name: agent-name
description: >
  When to use this agent. Claude matches tasks to agents by description.
model: sonnet
---
```

Agents run in isolated context windows. They do NOT inherit the parent's context, so all necessary information must be included in each agent's `.md` file or passed via the Agent tool prompt.

## Key Conventions

- **No hardcoded paths.** Discover paths from `~/.claude/settings.json` at runtime.
- **Read prompt files, don't @-import them.** Use the Read tool to get content, then pass it in the Agent prompt.
- **Token estimation:** `chars / 4`. Context window assumed at 200,000 tokens.
- **HTML reports** are written to `/tmp/` and opened in the browser. Do not delete them.
- **No secrets in repo.** `settings.json` and `config.toml` stay local. Templates in `templates/` for reference.

## Workspace Structure

Each workspace maintains a shared config directory outside of individual repos:

```
~/Documents/GitHubWork/
  _claude/config/       # team shared settings (settings.local.json)
  _claude/work-plan/    # active task documents

~/Documents/GitHubPrivate/
  _claude/config/       # personal shared settings (optional)
  _claude/work-plan/    # task documents
```

- `_claude/config/settings.local.json` → symlinked per project via `sync-config` skill
- `_claude/work-plan/` → work-plan path discovery reads from here (see `instructions/references/work-plan.md`)
- Company/team plugins go in `settings.local.json` (not global `settings.json`)

## Post-Task Workflow

When a task is completed in this repository, always ask the user whether to:
1. Commit and push the changes
2. Verify `$HOME` symlinks reflect the latest state (run `setup.sh` if needed)

**setup.sh가 필요한 경우 (반드시 실행):**
- `hooks/` 에 새 스크립트를 추가했을 때 — 심링크를 만들지 않으면 hook이 실행되지 않음
- `agents/`, `skills/` 에 새 파일/디렉토리를 추가했을 때
- 새 머신에서 처음 설정할 때
