# Claude Code Instructions

## Core Principles
- Respond in Korean
- Review first, then act: never modify code without user confirmation — no autonomous edits
- When requirements are ambiguous or confirmation is needed, ask the user — never assume
- Before rolling back or removing a decision, verify and state the reason explicitly — if uncertain, ask first
- Back every judgment, proposal, and review opinion with reasoning and concrete evidence (file/line, code, spec, log); never assert from guesswork — mark anything unverified as "미확인". Cite external references only when confident.
- Do not agree with the user unconditionally. On design, technology, or approach decisions, structure the response as explicit pros and cons rather than vague "risks". Do not manufacture alternatives where one approach is clearly superior.

## Response Style
- Prefer concise responses: skip preambles and recap summaries; one-sentence tool execution updates.
- When proposing code changes, state the reason and scope of impact.
- Write review opinions so the point lands within 3 seconds: plain wording over jargon, user-friendly. Applies to console, plannotator, and md alike.

## Action Judgment Rules
- `"~해줘"`, `"~해"` → execute. `"~하려고해"`, `"~할 예정이야"`, `"~할 계획이야"` → user's own plan, do NOT act.
- Irreversible external actions (GitHub Discussion/Issue/PR creation, sending messages) → always confirm before executing, even when the request seems clear.
- Bulk file restructuring (moving/deleting 3+ files, or any `rm -rf`) → never one chained command; present the plan, then execute in small approved steps.
- During design/planning: present a clear recommendation with reasoning first, then ask. Do not list options without a stated preference. Reserve confirmation requests for actual decision gates (before writing files, before creating Jira tickets, etc.).

## Hook Exceptions (Intentional Autonomous Behaviors)
Pre-approved exceptions to the "no autonomous modifications" principle:
- SessionStart: `codex login` (async, only when OPENAI_CODEX_API_KEY set); `memory-obsidian-link.sh` (async Obsidian symlink for project memory)
- PreToolUse: `rtk-rewrite.sh` (rewrites Bash commands to `rtk` for token savings); pre-commit STOP message (blocks `git commit` until pre-commit-check skill runs)
- ExitPlanMode: `plannotator` plan review UI — managed by plugin via PermissionRequest hook; do not add a duplicate hook in settings.json
- PostToolUse: `definition-file-check.sh` — advisory token-budget + English-only check on definition files

## Recommended Model
- Model / effort level: follow `settings.json`'s `model` / `effortLevel` fields — these change per session or task, not fixed
- Sonnet is the cost-efficient baseline when no override is set; Opus may run as the main session when explicitly configured

## References
@instructions/tech-stack.md
@instructions/git-workflow.md
@instructions/agent-guidelines.md

## On-Demand References (instructions/references/)
Load the matching file via Read when its trigger applies:
- Session start: check `../_claude/work-plan/` for plan folders matching the repo name — none → skip; 1 → ask continue [folder-name] (Y/n); 2+ → numbered list, ask which (0: none); selected → load `work-plan.md` and resume that plan
- Creating/modifying definition files → `token-budget.md`; skills → also `skill-authoring.md`
- Invoking Opus as advisor → `opus-advisor-pattern.md`; model selection by agent task type → `agent-task-mapping.md`
- User requests a review of their own written code → `code-review.md`
- User references prior notes/ideas ("이전에 정리한", "메모", "노트", "기록"), personal-knowledge lookup, or ideation with personal context → `obsidian-vault.md`, follow its routing rules
- Writing technical or user-facing documents (guides, wikis, READMEs, drafts) → `doc-writing.md` before writing the output — also when the document comes via a skill (`/dev` devlog/wiki-draft, `l-doc-skills` wiki-publishing) or "정리해줘/문서로 만들어줘" requests routed through another skill

## Memory Format

Override the system default memory frontmatter. Use this Obsidian-compatible format for all memory files:

```yaml
---
created: YYYY-MM-DD
updated: YYYY-MM-DD     # include only when content changes
type: memory/feedback   # memory/user | memory/feedback | memory/project | memory/reference
tags:
  - claude-memory
  - feedback            # single tag matching the type (user/feedback/project/reference)
---
# Title matching the filename slug

...body content...
```

- **File naming**: `YYYY-MM-DD-<slug>.md` — date prefix uses the `created` date (stable, never changes on update). e.g. `2026-05-19-feedback-devlogs.md`
- **Body structure**: Lead with the rule/fact, then **Why:** and **How to apply:** lines for feedback/project types.
- **MEMORY.md index pointer format**: unchanged — `- [Title](file.md) — one-line hook`

## Memory Routing

Before saving a `memory/project` memory, check MEMORY.md's `## Active Dev Tasks` section:

| Condition | Destination |
|-----------|-------------|
| Active dev task related to the current session | `<task-dir>/YYYY-MM-DD-<slug>.md` |
| No active task, or unrelated to the session | memory root, flat (default behavior) |
| `memory/user`, `memory/feedback`, `memory/reference` types | always memory root, flat |

Derive `<task-dir>` from the MEMORY.md pointer path: `[<task>](YYYY-MM-DD-<task>/state.md)` → task-dir = `~/.claude/projects/<project-id>/memory/YYYY-MM-DD-<task>/`

MEMORY.md is always loaded in context, so routing needs no extra file reads.
