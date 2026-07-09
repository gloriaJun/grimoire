# Step 2: Fill Korean Translations

For each sidecar from Step 1, edit ONLY segments where `ko == ""` AND `src`
does not start with a code fence marker (three backticks).

## Translation rules

- Translate the `src` markdown into Korean, preserving structure exactly:
  headings stay headings, tables stay tables, inline code and file paths stay
  verbatim in English.
- Register: plain declarative written style, matching the existing `ko`
  segments in the same root (e.g. endings like `"...규칙."`, `"...확인한다."`).
- Avoid translationese (overusing `"~를 통해"`, `"~에 대해"`), double passives
  (`"~되어진다"`), and em/en dashes.
- Code-fence segments keep `ko: ""` - the viewer renders the source only.

## Delegation

More than 5 pending files: split into batches and delegate to
lightweight-tier agents (pure format conversion), max 3 in parallel. Each
batch prompt must contain the full rules above verbatim plus the exact file
list. 5 or fewer: translate in the main context.

## Verification (must pass before Step 3)

Re-run the pending-segment listing from Step 1. Expected: no output.

- Still non-empty: fill the remaining segments and re-verify once.
- Non-empty after the retry: report the exact files and segment counts, STOP.
