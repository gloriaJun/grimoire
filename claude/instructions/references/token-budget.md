# Token Budget for Definition Files

Guidelines for sizing and placement of definition files.
Loaded on demand when creating or modifying definition files.

## Sizing Guidelines

Token estimation: `characters / 4`.

| File type | Load timing | Recommended max | Notes |
|-----------|------------|-----------------|-------|
| CLAUDE.md (global) | Every session | ~500 tok (~2,000 chars) | Entry point; keep minimal, delegate to @imports |
| instructions/*.md (@import) | Every session | ~500 tok (~2,000 chars) | Compounds across all files; strict budget |
| instructions/references/*.md | On-demand (Read) | ~1,000 tok (~4,000 chars) | Only loaded when needed; more lenient |
| SKILL.md body | On skill trigger | ~750 tok (~3,000 chars) | Orchestrator only; extract to steps/ |
| steps/*.md | On-demand (Read) | ~1,500 tok (~6,000 chars) | Single task scope; largest allowed |
| agents/*.md | On agent dispatch | ~500 tok (~2,000 chars) | Isolated context; keep focused |

## When to Split

- @import file exceeds ~500 tok → split by topic or move details to references/
- SKILL.md exceeds ~750 tok → extract steps to `steps/` files
- Agent prompt exceeds ~500 tok → move runtime context to Agent tool call, keep static role definition in file

## Conditional Loading: Placement Rules

When creating a new instruction file, decide its placement:

| Condition | Placement | Loading method |
|-----------|-----------|----------------|
| Needed every session (commit, package, daily workflow) | `instructions/` root | @import in CLAUDE.md |
| Needed only for specific tasks (skill authoring, review, planning) | `instructions/references/` | Read tool, triggered by CLAUDE.md on-demand rules |
| Needed only in specific projects | Project's own CLAUDE.md | @import or inline in project CLAUDE.md |

**Default to `references/`** unless you can justify always-loading.
The cost of an unnecessary @import is paid every session; the cost of an on-demand Read is paid only when relevant.

## Enforcement

- Before writing a definition file, measure it: tokens = `wc -c` / 4. State actual vs budget in the result.
- A PostToolUse hook (`hooks/definition-file-check.sh`) re-checks size and the English-only convention
  after every definition-file Write/Edit. Treat its warnings as review findings: fix or explicitly justify.
- Budgets are advisory ceilings, not hard blocks. Hub-style SKILL.md files with many sub-commands
  (e.g. `dev`) may exceed the SKILL.md ceiling — justify the overage in the commit body.
- When adding a rule to an always-loaded file, compress or remove an equivalent (one in, one out).
  One-off incidents belong in memory; only recurring patterns earn instruction lines.
