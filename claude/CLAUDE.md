# Claude Code Instructions

## Core Principles
- Respond in Korean
- Never modify code without user confirmation
- Provide rationale and explanation for every proposed change
- Review first, then proceed — no autonomous code modifications

## Recommended Model
- Default CLI model: **Sonnet** (cost-efficient orchestrator)
- Opus: invoked as advisor only via Agent tool (direction/judgment, never as main session)

## References
@instructions/tech-stack.md
@instructions/git-workflow.md
@instructions/agent-guidelines.md

## On-Demand References (instructions/references/)
- Session start: check `../_claude/work-plan/` for active plan matching current repo. If found, load `@instructions/references/work-plan.md` and resume.
- When creating or modifying definition files, load `@instructions/references/token-budget.md`
- When creating or modifying skills, load `@instructions/references/skill-authoring.md`
- When invoking Opus as advisor, load `@instructions/references/opus-advisor-pattern.md`

@RTK.md
