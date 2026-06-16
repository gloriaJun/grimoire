# Document Writing Conventions

Applies when writing user-facing documents: guides, wikis, READMEs, technical documents.
Does NOT apply to internal config files (CLAUDE.md, SKILL.md, settings.json, etc.).

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
