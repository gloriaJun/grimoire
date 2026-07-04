# Note Quality Pass

Runs automatically right after a vault note is written. Loaded by `tools/retro/SKILL.md`.

## 1. Self-check (silent)

Validate the file just written — required frontmatter (`date`, `tags`, `summary`,
`scope`) present, every `[[wikilink]]` target exists. Fix issues immediately, no prompt.

## 2. Link Weaving

Read `shared/vault-context.md`, run with **keywords** (frontmatter `keywords`,
else `tags` + task-name terms), **search_focus**: `references`, `error-history`,
`past-mistakes`, **scope_hint** = `scope`.

With the top matches (max 3):
- `04_Notes` files → `related:` as `"[[path/to/file]]"`
- `10_Knowledge` files → `참고 자료` as `[[path/to/file]] — <frontmatter summary>`
- Show the planned links in one line and apply on Y/Enter. Also append a backlink
  to this retro in each matched note (`related:` or `## 링크` — additive only,
  never rewrite their content).
- No matches → skip silently.

## 3. Distillation Check (Notes → Knowledge)

If step 2 surfaced **2+ notes on the same topic** (same dominant tag/keyword),
draft the topic note `10_Knowledge/<area>/<topic>.md` inline — merge into the
existing topic note if one exists. Generalized facts only ("X 상황에서는 Y" form),
plain language, `[[links]]` back to the source notes.

Show a ~5-line draft summary and ask once:
"같은 주제 노트 N개 발견 — 10_Knowledge로 증류할까요? (Y/n)"
- Y: write/update the Knowledge note. n: skip.
