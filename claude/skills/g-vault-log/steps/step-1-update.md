# Step 1: Update a project doc

Target: `$DOC = $VAULT/projects/<domain>/<slug>.md` from mode detection.
Read `$DOC` in full first (project docs stay small; a doc over 500 lines is
itself worth reporting to the user as an archive candidate).

## A. Gather entries

Invoked from a skill handoff with a summary block -> that block IS the
source; do not re-mine the session. Standalone -> collect from the current
conversation. Either way, only evidenced items, in four groups:

- decisions: what was decided + why + rejected alternatives (when discussed)
- work done: what changed, with evidence (commands + results, commit hash,
  PR or file paths)
- troubleshooting: symptom -> cause -> fix, only for problems actually
  solved this session
- open questions / next steps

All four groups empty -> report "nothing to record" and stop; never write
empty entries.

## B. Regenerate the status block (g-dev projects only)

Markers `<!-- g-dev:status:start -->` / `<!-- g-dev:status:end -->` present
in `$DOC` -> rebuild the content between them:

1. Read `id`, `title`, `status` from the frontmatter of every
   `$VAULT/projects/<domain>/assets/<slug>/tasks/t*.md`. No task files ->
   the block body is the single line `아직 task 없음`.
2. Replace the block content with: a first line
   `<current-step> (기준일 YYYY-MM-DD)` (current-step from the project's
   `state.md`), then a table with columns id | task | status, one row per
   task file.

Markers absent (non-g-dev project) -> skip this section entirely.

## C. Append entries

Entry shapes: `references/note-format.md`. Newest entries go at the TOP of
their section (the vault template rule: latest first).

- decisions -> section `## 결정 기록`
- work done and troubleshooting -> section `## 작업 로그`
- open questions / next steps -> folded into the work-log entry's last
  line, not a separate section
- A target section missing from `$DOC` -> add the section heading at the
  end of the doc (template order) instead of failing.

## D. Finish

1. Write discipline for every `$DOC` change in B and C: re-read the doc
   immediately before editing, use partial Edits anchored on the status
   markers or the section heading, and never rewrite the whole file (a
   full-file Write can clobber a concurrent session's entries).
2. Set frontmatter `updated:` to today (`date +%F`).
3. Report: doc path, sections touched, entry count per section. Never
   commit in the vault.
