# Skill Authoring Convention

Skills in this project follow these authoring rules.
These rules also apply when using the skill-creator plugin to generate new skills.

## Language Convention

All skill and instruction files must be written in **English only**.
English is more token-efficient (~1.5-2x fewer tokens than Korean for the same content).
These files are loaded into context every session, so token savings compound.

- SKILL.md body, step files, mermaid labels, comments: **English**
- User-facing output (conversation responses): Determined by user preference (e.g. CLAUDE.md `Respond in Korean`), not hardcoded in skill files

## SKILL.md = Orchestrator Only

SKILL.md is a thin orchestrator — it routes to sub-files, not implements logic inline.

- Route the overall flow: what to do, in what order, under what conditions
- Delegate detailed logic to `steps/`, `scripts/`, `references/`
- Reference model: `skills/task-process/SKILL.md`

### Step Extraction

| Condition | Action |
|-----------|--------|
| 3+ steps, each independently describable | Extract to `steps/step-N-*.md` |
| 2 or fewer steps, or tightly coupled flow | Keep inline in SKILL.md |

### Script Extraction

Extract to `scripts/` when any of:
- Same logic is invoked 2+ times within the skill
- Shell commands composing external CLIs exceed 5 lines
- Deterministic processing (file parsing, aggregation, transformation)

## Mermaid Diagram Required

Every skill must include a mermaid diagram in SKILL.md, placed at the top of the body (before the first step/phase section).

### Diagram Type Guide

| Situation | Recommended type |
|-----------|-----------------|
| Linear step flow | `flowchart TD` |
| Branching / conditional process | `flowchart TD` with diamond nodes |
| Complex state transitions with sub-states | `stateDiagram-v2` |
| Agent-to-agent interactions | `sequenceDiagram` |

### Minimum Requirements

- Show the full path from trigger to completion
- Include all branch/condition paths
- Mark external tool dependencies as distinct nodes

## Skill-Local Agent Definitions

Skills that dispatch subagents can define agent prompts within their own directory
instead of registering them globally in `.claude/agents/`.

### Directory Convention

```
skills/<skill-name>/agents/
  <agent-name>.md    # agent prompt file
```

### When to Use

| Scope | Location | Registration |
|-------|----------|-------------|
| **Global** — used by multiple skills or invoked independently | `.claude/agents/` | Auto-registered as `subagent_type` |
| **Skill-local** — used only within one skill | `skills/<skill>/agents/` | Read via Read tool, dispatched via Agent tool |

### Invocation Pattern

Skill-local agents are NOT auto-registered. Invoke them as follows:

1. Read the prompt file: `Read("agents/<agent-name>.md")`
2. Prepend context data (inputs, discovery results)
3. Dispatch: `Agent(subagent_type: "Explore", prompt: <combined prompt>)`

Reference implementation: `skills/my-claude-audit/analyzer-prompts/` (predates this convention; new skills should use `agents/`).

### Migration

Existing skills using non-standard folder names (e.g. `analyzer-prompts/`) are not required to rename immediately. New skills must use `agents/`.

## Agent Rules

For model selection and parallel execution limits, see `@instructions/agent-guidelines.md`.
These rules apply to both skill-local and global agents.

## Post-Task Workflow

When a skill is created, modified, or deleted, always ask the user whether to:
1. Commit and push the changes
2. Run `setup.sh` (or equivalent) to sync symlinks to `$HOME`

## Skill Review & skill-creator Integration

When creating or modifying a skill, load and follow `@instructions/skill-review.md`
for reuse check, duplication detection, and Codex review protocol.
This also includes skill-creator integration rules.
