# Skill Review Protocol

Loaded on demand when creating or modifying skills.
Covers reuse check, post-completion review, and skill-creator integration.

## 1. Pre-Creation: Reuse Check

Before creating a new skill:
1. Glob existing skills (`skills/**/SKILL.md`) and agents (`agents/*.md`)
2. Compare the new skill's purpose against existing description fields
3. If overlap found: present user with extend existing vs create new

## 2. Post-Completion: Review

### Scope Determination

| Criteria | Codex Review? |
|----------|---------------|
| 3+ files changed (SKILL.md + steps/scripts) | Yes |
| 20+ net lines added to SKILL.md | Yes |
| Orchestration flow changed (step add/remove, branch logic) | Yes |
| Text-only edits (typos, descriptions) | No |

### Small Scope: Self-review

- Check for duplicate definitions against existing skills/agents/instructions
- Verify skill-authoring.md compliance (orchestrator principle, mermaid, language)

### Large Scope: Codex Review

Request critical review from the following perspectives:
1. **Convention compliance**: Violates orchestrator principle? Agent pattern misuse?
2. **Token efficiency**: Verbose prompts? Inline logic that should be extracted?
   Non-English in instruction files?
3. **Redundancy**: Overlapping definitions with existing skills/agents/instructions?

Invocation:
- Primary: `/codex:rescue "Review this skill for convention violations, token waste, and redundancy: <path>"`
- Fallback (no Codex): Claude performs same checklist directly

### Review Checklist (for both scopes)

- [ ] SKILL.md is orchestrator only — no inline logic
- [ ] Mermaid diagram present and covers full flow
- [ ] Steps extracted if 3+ independently describable steps
- [ ] Scripts extracted for reusable/long shell logic
- [ ] All files in English
- [ ] No duplication with existing skills or agents
- [ ] No unnecessary token overhead

## 3. skill-creator Integration

When using skill-creator plugin to generate a new skill:
1. Review whether logic separation fits the orchestrator principle
2. Add a mermaid diagram if the draft lacks one
3. Propose `scripts/` extraction for reusable logic
