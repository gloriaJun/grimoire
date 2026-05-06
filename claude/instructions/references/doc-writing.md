# Document Writing Conventions

Applies when writing user-facing documents: guides, wikis, READMEs, technical documents.
Does NOT apply to internal config files (CLAUDE.md, SKILL.md, settings.json, etc.).

## Section Separators

Do NOT use horizontal rules (`---`, `----`, `***`) as section dividers.
Use headings (`##`, `###`) for all structural separation.

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
