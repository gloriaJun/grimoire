# g-vault-log

Records Claude Code session work (design decisions, troubleshooting, work
results) into the Obsidian vault, following the vault's own pipeline rules
(inbox -> projects -> archive/wiki). Works standalone via `/g-vault-log` and
as the record-keeping backend other skills call at their handoff points
(g-dev does this at every step boundary).

## Highlights

- **Three modes** - update (append decisions/work-log entries to a project's
  formal doc and regenerate its status block), capture (one-off records to
  inbox with `source: claude`), complete (archive move proposal + wiki
  distillation candidates, all user-confirmed)
- **Timing by design** - records land at phase boundaries (skill handoffs)
  or on explicit user call, never by auto-trigger; this keeps the vault
  signal-dense instead of chatty
- **Evidence-only entries** - every work-log line names something checkable
  (command + result, commit hash, path, URL); nothing unverified gets
  recorded as fact
- **Vault-rule compliant** - single formal doc per project, newest-first
  logs, frontmatter per RULE.md, no git operations inside the vault

## Layout

- `SKILL.md` - mode detection and router
- `steps/step-1-update.md` - project doc update (status regen + appends)
- `steps/step-2-capture.md` - inbox capture for sessions without a project
- `steps/step-3-complete.md` - archive move, assets disposition, wiki
  candidates
- `references/note-format.md` - exact entry shapes (decision, work log,
  troubleshooting, status block)

## Usage

```
/g-vault-log             # record this session into the matching project doc
                         # (or inbox when no project exists)
/g-vault-log complete    # close a finished project: archive + wiki proposals
```
