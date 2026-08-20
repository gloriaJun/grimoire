# Callouts

Obsidian callout syntax for document deliverables and vault notes. Reached from
`writing-style.md` and the vault `CLAUDE.md`.

## Set

Use only these six. Do not invent types.

| Syntax | Use for | Confluence macro | GitHub |
|---|---|---|---|
| `> [!tldr] TL;DR` | Whole-document summary at the top, at most 1 | `panel`, `titleBGColor=#0052CC` | plain paragraph |
| `> [!note]` | Side context the reader may skip | `ui-text-box`, `light-blue` + `note` | `[!NOTE]` |
| `> [!tip]` | Recommended option, shortcut | `tip` | `[!TIP]` |
| `> [!warning]` | Unverified content, caution, irreversible action | `warning` | `[!WARNING]` |
| `> [!example]-` | Folded bulk supplement: long tables, logs, URL catalogs | `expand` | ships expanded |
| `> [!quote]-` | Folded verbatim source: scripts, account rows, citations | `expand` | ships expanded |

The trailing `-` means collapsed by default; use it whenever the body runs over
5 lines. `+` is not used. Lowercase by default; uppercase the type when the
draft targets a GitHub comment or PR body.

## Rules

- At most 5 callouts per document, at most 1 `[!tldr]`.
- Callout body within 5 lines. Longer content moves into `[!example]-`.
- No nesting, and no callout inside a list item.
- Never two callouts back to back; prose or a heading separates them.
- A callout is not a heading substitute: the content it labels goes inside it.
- `[!tldr]` body is one framing sentence plus 3 to 5 `**label**: value` bullets.
  Leading labels inside a callout, and leading labels in table cells, do not
  count against the 3-bold-per-document limit in `writing-style.md`.
- Callout icons replace emoji. The no-emoji rule still holds inside a body.
- Existing notes are not migrated: `[!caution]` and `[!info]` already in the
  vault stay as they are, new writing uses `[!warning]` and `[!note]`.

## Where This Does Not Apply

| Target | Handling |
|---|---|
| Definition files (CLAUDE.md, SKILL.md, hooks, agents) | No callouts; `writing-style.md` already excludes this layer |
| g-vault-log entry shapes (decision, work-log, `[TS]` entries) | No callouts; those are append-only one-line bullets |
| Vault `output/` notes, and posting outside Confluence or GitHub | Only if the target renders them; Jira and Slack do not |
| `l-c-review` evidence appendix | Lines must match `- [source] `; the helper script rejects anything else |
| Confluence pages | The draft carries callouts, the page carries the macro above; see `l-wiki/write/references/page-format.md` |
