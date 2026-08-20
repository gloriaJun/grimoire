# Korean Writing Guide

Rules for reproducing the user's writing style. Apply to all Korean prose deliverables.
The "Document Format" section applies only to document deliverables (guides, wikis, READMEs, drafts, technical docs).
Do not apply to internal config files (CLAUDE.md, SKILL.md, settings.json, etc.).

## Sentences

- One idea per sentence. Keep prose sentences within 60 characters.
- Write explanatory/instructional prose in the plain declarative style ("~한다/~하지 않는다"). Do not use the same "~다" ending 4 times in a row.
- End bullets and table cells in noun forms ("검토 완료", "링크 추가"). Do not attach predicates.
- State confident content assertively. Do not hedge with phrases like "~할 수 있을 것으로 보인다".
  Attach "미확인" (unverified) only to unverified content.

## Vocabulary and Notation

- No 번역투 (translationese): "X를 논의", not "X에 대해 논의". Replace "~를 통해" with "~로".
  No 이중피동 (double passive; "~되어진다").
- Never use em dashes or en dashes. Connect with hyphens (-), colons, or parentheses.
- Use the middle dot (·) for compact enumeration, and the arrow (→) for conversion and flow.
- Wrap identifiers, commands, and file paths in backticks. Leave technical terms in English.
- Replace difficult jargon with plain wording; for jargon you keep, add a one-line explanation on first use.
- Do not use emoji. Limit bold to at most 3 uses per document.
- Sentence-initial conjunctions (또한/따라서/즉) at most 4 per document. Connect through content flow instead.

## Structure

- Put the conclusion or key point in the first 1-2 lines. Do not use openings like "이 문서에서는 ~를 설명합니다".
- Delete meta narration and self-reference.
- Write headings in noun form, without number prefixes ("## 배경", not "## 1. 배경").
- Do not use horizontal rules (---) to separate sections. Divide structure with headings only.
  (Table separator rows `|---|---|` are markdown syntax and exempt.)
- Express comparisons and enumerations as pipe tables. Express procedural flows as step tables;
  use a mermaid flowchart only when the flow branches.
- When writing rules or criteria, attach numeric thresholds ("3개 이상", "4회 연속").

## Writing Workflow

- The deliverable language defaults to Korean unless requested otherwise.
- Even when the final deliverable is in English, draft it in Korean first.
  Translate to English after the user gives final confirmation on the Korean version.
- Review and revise local md drafts with plannotator:
  run `plannotator annotate <file.md>` → apply feedback → rerun.
  Stop when plannotator approves or after 3 rounds; if items remain after round 3,
  list them and hand the decision to the user.
  If the `plannotator` command is not installed, skip this review, tell the user it
  was skipped, and continue.
- Procedure for externally posted content (Confluence, GitHub issue/PR bodies, etc.):
  1. Draft as an md file in the current working directory
  2. Review with plannotator, get the user's final confirmation
  3. Post in the target platform's format (pre-posting confirmation follows CLAUDE.md hard rule 5)
  4. After the user verifies the posted result, delete the local md file
- For the deliverable types below, load the matching template with Read and follow its skeleton and rules.
  Base path: `~/.claude/instructions/references/templates/`

  | Deliverable type | Template |
  |---|---|
  | PR title and body | `pr.md` |
  | Procedural guides (how-to, onboarding, migration) | `guide.md` |
  | Development guides (CONTRIBUTING, recurring reference rules and command collections) | `dev-guide.md` |
  | Execution plans (implementation/work plans) | `plan.md` |
  | Proposals/reviews (tech choices, design reviews, position papers) | `proposal.md` |
  | README (project intro and usage) | `readme.md` |
  | Troubleshooting records (retros, issue write-ups, devlog resolved items) | `troubleshooting.md` |

## Document Format (document deliverables only)

- Callouts: follow `callouts.md` in this directory for the allowed set and limits.

### TOC

- Include only when there are 3 or more `##` sections. Omit with 2 or fewer.
- Position: right below the document title (before the intro paragraph).
- Format: bullet list with anchor links.

### Recording completed/resolved work

For finished work or resolved issues, keep only what a future reader needs.
The full process already lives in PRs, commits, and tickets, so do not re-document it.

- Keep: root cause (1 line), fix/result (1 line), reusable lesson (1 line), reference links (PR/commit/ticket).
- Delete: call-chain traces, log dumps, rejected-alternative comparisons, step-by-step verification logs.
- Detail is allowed only for unresolved/follow-up work.
- If the TL;DR already summarizes the resolution, do not create a separate detailed "해결된 이슈" (resolved issues) section.
