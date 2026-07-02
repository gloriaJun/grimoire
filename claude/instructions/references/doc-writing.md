# Document Writing Conventions

Applies when writing user-facing documents: guides, wikis, READMEs, technical documents.
This INCLUDES `/dev` devlog artifacts (review.md, state.md, reference notes) and memory reference docs.
Does NOT apply to internal config files (CLAUDE.md, SKILL.md, settings.json, etc.).

## Readability (default - do not wait to be asked)

Write reader-friendly by default. The user should never have to request "사용자 친화적으로" - assume it.

- Lead with the conclusion or key point (TL;DR first).
- Write so the reader grasps the point within 3 seconds. Replace hard jargon with plain wording; stay user-friendly.
- One sentence states one thing. Avoid dense comma-packed enumerations; write them out.
- Define a technical term on first use with a one-line gloss.
- Use tables/lists to make comparisons scannable.
- Cut meta-commentary and self-reference.

## Completed / Resolved Content

For finished work or a resolved issue, keep only what a future reader needs. Do not re-document the full process - it already lives in the PR, commits, or ticket.

- Keep: root cause (1 line), fix/outcome (1 line), any reusable gotcha or lesson (1 line), and reference links (PR / commit / ticket).
- Drop: call-chain traces, log dumps, rejected-option comparisons, and step-by-step verification logs.
- Detail belongs only to unresolved or follow-up work (pending review, next steps).
- If the TL;DR already summarizes the resolution, do not add a separate detailed "resolved issue" section.

## Dashes and Hyphens

Use a plain hyphen `-` for connectors, appositives, and ranges. Do NOT use the em dash `—` or en dash `–`.
(Em dash overuse reads as AI-generated and lowers scannability.)

- Connector/aside: write `A - B`, or use `:` / parentheses instead.
- Range: `1-5` (Korean `1~5` is also fine).

## Section Separators

Do NOT use horizontal rules (`---`, `----`, `***`) as section dividers.
Use headings (`##`, `###`) for all structural separation.

Note: table separator rows (`|---|---|`) are required Markdown table syntax — they are NOT horizontal rules and are exempt from this rule.

## Heading Numbering

Do NOT prefix headings with sequential numbers (`## 1. 배경`, `## 2. 개요`).
Use plain-text headings (`## 배경`, `## 개요`). Ordering is implied by document flow.

## Table of Contents

Include a TOC only when the document has **3 or more top-level sections** (`##` headings).

- Position: immediately below the document title (before any intro paragraph)
- Heading: `## Table of Contents`
- Format: bullet list with anchor links

```markdown
## Table of Contents

- [Overview](#overview)
- [Installation](#installation)
- [Usage](#usage)
```

Omit the TOC when the document has 2 or fewer `##` headings.
