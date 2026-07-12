# Token Budget for Definition Files

Sizing and placement rules for definition files.
Load on demand when creating or modifying any definition file
(CLAUDE.md, references, templates, skills, hooks, agent prompts).

## Sizing

Token estimation: `wc -c` / 4.

| File type | Load timing | Max |
|---|---|---|
| `~/.claude/CLAUDE.md` (global, assembled) | Every session | ~3,500 tok (~14,000 chars) |
| `instructions/shared/*.md` + `claude-only.md` (assembly fragments) | Every session (via assembly) | ~1,250 tok (~5,000 chars) each; assembled total within the CLAUDE.md budget |
| `instructions/references/*.md` | On-demand (Read) | ~1,250 tok (~5,000 chars) |
| `references/templates/*.md` | On-demand (Read) | ~2,250 tok (~9,000 chars) |
| `SKILL.md` body | On skill trigger | ~750 tok (~3,000 chars) |
| `skills/*/steps/*.md` | On-demand (Read) | ~1,500 tok (~6,000 chars) |
| `agents/*.md` | On agent dispatch | ~500 tok (~2,000 chars) |

- Budgets are advisory ceilings, not hard blocks. Exceeding one requires a
  one-line justification in the commit body.
- Enforcement: the PostToolUse hook `hooks/definition-check.sh` re-checks size
  and the English-only convention after every definition-file Write/Edit.
  Treat its findings as review findings: fix, or justify explicitly.

## Placement

| Condition | Placement | Loading |
|---|---|---|
| Needed every session | CLAUDE.md itself | Always loaded |
| Needed only for specific tasks | `instructions/references/` | Trigger row in CLAUDE.md's on-demand table + Read |
| Needed only in specific projects | That project's CLAUDE.md | Project-local |

Default to `references/`: an unnecessary CLAUDE.md line costs every session;
an on-demand Read costs only when relevant.

## When to Split or Trim

- A reference file exceeds its budget → split by topic, or move detail into a
  skill's `steps/`.
- Adding a rule to CLAUDE.md → compress or remove an equivalent line
  (one in, one out).
- One-off incidents belong in memory; only recurring patterns earn instruction lines.
