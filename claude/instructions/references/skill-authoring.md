# Skill Authoring Convention

Load on demand when creating or modifying a skill (also applies when a
skill-generator plugin produces the draft). Covers authoring rules, the
pre-creation reuse check, and the post-completion review.
Mechanically checkable rules (file sizes, English-only, mermaid presence,
README presence) are enforced by the PostToolUse hook
`hooks/definition-check.sh`; treat its findings as review findings.

## Language

All skill and instruction files are English-only (repo policy; English costs
roughly 1.5-2x fewer tokens). User-facing conversation output stays governed
by CLAUDE.md ("Respond in Korean"), never hardcoded inside skill files.

## Pre-Creation: Reuse Check

1. Glob existing skills (`skills/**/SKILL.md`) and agents (`agents/*.md`);
   compare the new skill's purpose against their description fields.
2. Overlap found → present "extend existing" vs "create new" with a one-line
   trade-off each, and wait for the user's choice.
3. Partial overlap → propose reuse: which existing skill covers what, what
   remains to build, how the new skill invokes the old one. Proceed only
   after confirmation.

## Structure Rules

- SKILL.md is an orchestrator only: route the flow (what, in what order,
  under which conditions); delegate logic to `steps/`, `scripts/`, `references/`.
- Step extraction: 3 or more independently describable steps →
  `steps/step-N-*.md`; 2 or fewer, or tightly coupled → keep inline.
- Script extraction, when any of: same logic invoked 2+ times; shell composing
  external CLIs exceeds 5 lines; deterministic processing (parsing,
  aggregation, transformation).
- Mermaid diagram at the top of the SKILL.md body: full path from trigger to
  completion, all branch paths, external tool dependencies as distinct nodes.
  Linear flow → `flowchart TD`; sub-states → `stateDiagram-v2`; agent
  interactions → `sequenceDiagram`.
- README.md next to SKILL.md (human-facing, English): name + one-line
  description, Features, Usage, How It Works; Installation, Requirements,
  and License only when non-obvious.
- Sub-command skills always include a `help` sub-command: list it in the
  `description` field, give it an explicit routing branch, add a `help` row
  to the sub-command table, and fall back to printing that table on `help`,
  no sub-command, or unrecognized input. Skills with a default action route
  bare invocation to that default; `help` and unrecognized input still print
  the table.

## Persona

- Skill-level: one sentence, under 30 words, only when domain expertise shapes
  output quality (security, testing, architecture, a11y). Mechanical workflows
  get none. Never stack personas.
- Agent-level: every agent prompt file opens with a one-line persona plus a
  2-3 sentence Role section (isolated context makes this mandatory).
- Skill-local agents live in `skills/<skill>/agents/<name>.md`, are not
  auto-registered, and are dispatched by Read + Agent tool. Register in
  `agents/` only when used by multiple skills or valuable standalone.

## Agent Rules

Model selection, delegation thresholds, visibility reporting, and the
3-concurrent parallelism cap follow CLAUDE.md "Agent operation". Skills never
override them.

## External Research (optional)

When the domain is unfamiliar or the user cites an external tool as
inspiration: WebFetch the repo, read README and entry points, and extract only
step organization, trigger patterns, delegation patterns, and branching logic.
Never copy file names, directory structures, prompt text, or schemas -
re-derive them from these conventions.

## Post-Completion Review

| Scope | Criteria (any) | Review |
|---|---|---|
| Large | 3+ files changed; 20+ net lines in SKILL.md; orchestration flow changed | Cross-review by a separate agent (session model), prompted to refute convention compliance, token efficiency, and redundancy |
| Small | Text-only edits | Self-review with the checklist below |

A cross-review returning FAIL: fix the findings, then re-dispatch the same
agent type once with the fix list, requiring VERIFIED or NOT FIXED per item.
Ship only when no item is NOT FIXED.

Checklist (both scopes):

- [ ] SKILL.md orchestrator-only, no inline logic
- [ ] Mermaid present and covers the full flow
- [ ] Steps/scripts extracted per the thresholds above
- [ ] All files English-only, no em/en dashes
- [ ] No duplication with existing skills/agents/instructions
- [ ] Sizes within `definition-files.md`

External CLIs (e.g. Codex) are used for review only on explicit user request
(CLAUDE.md rule).

## Integration and Completion

- External skills (plugin marketplaces): wrap, do not fork - a local SKILL.md
  delegates to the external entrypoint and owns the trigger description.
- When a skill is created, modified, or deleted: propose a commit per
  CLAUDE.md's commit-proposal rule. Sync to `~/.claude/` runs automatically
  on commit (post-commit hook); never edit `~/.claude/` directly.
