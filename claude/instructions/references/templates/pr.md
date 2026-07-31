# PR Template

Applies to writing and submitting GitHub PRs. Use the `gh` CLI for GitHub operations.

## Submission Procedure

On a PR creation request, follow this order.

1. **Confirm the base branch**: if the user does not specify one, detect it from the fork point.
   Run in order:
   - `git fetch origin --prune`
   - Candidates: the default branch (`gh repo view --json defaultBranchRef -q .defaultBranchRef.name`)
     plus every `git branch -r --list 'origin/release/*'` entry.
   - For each candidate: `git rev-list --count $(git merge-base HEAD origin/<candidate>)..HEAD`
   - Pick the candidate with the smallest count (nearest fork point). On a tie, pick the
     default branch.
     Tell the user the detection result before submitting, and do not submit with the base
     undetermined.
2. **Check remote state**: unpushed commits → report the count and push after confirmation
   (hard rule 5). Push failure → stop and report the cause.
3. **Analyze changes**: identify commits and changed files with `git log` and `git diff --stat`
   (base..HEAD), and write in the body only facts confirmed by reading the actual files.
   If there are no changes, stop.
   - Before writing Implementation task, list every reviewer-visible change from the diff:
     rendered text, layout dimensions, colors, added or removed controls, new env vars,
     changed defaults. Confirm each one is either in the body or deliberately omitted.
4. **Local verification**: run the repository's lint, unit tests, and build for the changed scope
   only (`nx affected`, `turbo --filter`, `pnpm --filter`, or whatever the repository uses).
   - Find commands in the repository configuration (package.json scripts, project instruction file,
     Makefile); skip undefined items but report the skip.
   - Any failure stops the submission. Skipping is allowed only on explicit user instruction.
5. **Write the body**: follow the skeleton and writing rules below and writing-style.md's
   external posting procedure (local md draft → plannotator review → user confirmation).
6. **Submit**: always create as draft (`gh pr create --draft`). Pass the body as multiline
   text with real newlines (`--body-file` recommended). Submit the reviewed draft
   byte-identical (no footer or trailer appended here). The confirmation right before
   submitting follows hard rule 5; after submitting, report the PR number and URL.

## Title

English, `<type>: <description>` format (the commit type list matches CLAUDE.md's Git work rules).

## Skeleton

The only required sections are Background and Implementation task.
Include the others only when their inclusion conditions are met; otherwise omit the section entirely.
When unsure, omit.

```markdown
### Background

{prose, not bullets, within 300 chars (usually 1-2 sentences): the requirement/request or bug that prompted the work. Do not break it into symptoms or impact analysis.}

### Screenshot

{only when there are UI/visual changes}

### Implementation task

{representative changes. the units of change reviewers must grasp}

### Focus it

{only when there are items reviewers must not skip}

### How to test

{only when extra environment setup or scenario guidance is needed}

### To do

{only when there is confirmed follow-up work}

## Reference

{only when there are related issue/PR/ticket/doc links}
```

## Per-Section Rules

### Background

- When the ticket has a background or description, base this section on it instead of composing a new narrative.
- Write as prose (not bullets), within 300 characters. Length follows the ticket: a one-line ticket gets one sentence.
- Problem or symptom framing is allowed when the work is a fix and the reader needs the trigger. Do not add it to feature work with no incident behind it.
- Do not expand into a symptom-by-symptom or impact breakdown, and do not restate what Implementation task already says.

### Implementation task

- Representative changes only: no exhaustive file listing, nothing obvious from the diff, and no
  scope-negation lines about unmodified parts ("X는 변경하지 않음").
- Do not write the implementation stack (library names, action names, permission scopes, standard security techniques).
  The body describes the behavior and capabilities reviewers care about; the diff explains the how.
- Compress "attempt → fail → replace" narratives into one line.
- Group causally related changes as sub-bullets: parent = the goal or the change, children = the
  results and side effects to review together. When the children are a list of measures, the parent
  states the goal ("~를 예방하기 위해 다음과 같이 처리했습니다"). Independent changes are top-level
  bullets without nesting.

- File paths only when they disambiguate two modules or are themselves the review point
  (config, per-environment files).
- No numbered headings inside the section (`#### 1. ...`). Purpose-oriented headings only.
- Describe the net diff against the base branch. A value introduced and then changed again inside
  this branch is invisible to reviewers, so describe only the final state. Before writing an
  "A에서 B로" sentence, confirm A exists in the base with `git diff <base>...HEAD -- <path>`.
- Exclude changes with no reviewer-visible effect: constant relocation, config consolidation,
  codegen removal, dead-code deletion. Keep them when behavior changes with them (a mapping fix,
  a default that now resolves differently); in that case write the behavior, not the relocation.

### Screenshot

- Visual change → always write the scaffold, with empty `src` when material is missing.
  Never a prose promise like "확인 후 첨부 예정". Non-visual change (backend, CI, config) → omit the section.
- Widths via HTML `<img>`: portrait `width="280"`, landscape `width="680"`. Multiple cases go in a
  single-row table, one column per case.
- Console-verified changes: attach the actual logs in a code block or `<details>`.
- Tell the user in chat which screenshots or logs would help the review.

### Focus it

- Inclusion condition (only when at least one applies): security impact, breaking change,
  a deployment prerequisite reviewers must act on. At most 2 bullets.
- Do not write generic review requests, changes obvious from the diff, routine security hygiene,
  or requests for the reviewer to endorse a decision already made. If there is nothing to write,
  omit the section.
- Each bullet is one line: what, and what the reviewer must do or check.

### How to test

- Inclusion condition (only one of two): setup beyond the standard dev environment is needed (env, seed,
  feature flag, external service connection), or automated tests cover only specific scenarios and
  reproduction guidance is needed.
- Omit "앱 실행 후 확인"-level guidance and step lists that just repeat workflow inputs/modes.

### To do

- Only follow-up work with a ticket or a confirmed next PR. Speculative improvements
  ("추후 개선 예정") just make the current PR look unfinished.

### Reference

- Include only when there are related issue/PR/ticket/doc links, and include the ticket link even
  when the number is already in the title.
- Every entry is a clickable markdown link. A bare identifier ("Jira: ABC-123") is not a reference.

## Style and Common Rules

- Korean prose follows writing-style.md (합니다체, no em/en dashes, no parenthesized English glosses,
  no 번역투). Only the PR-specific rules below are repeated here.
- Write goals/intent in the volitional form: "~를 해소하고자 합니다", "리뷰 후 1차 병합하려고 합니다".
- Evidence-based description: write concrete behavior changes instead of speculative "개선/강화" (improved/strengthened).
- No ticket number in body prose: it belongs to the Reference link and the title only.
- Drop "(Optional)" markers, delete empty optional sections, no decorative bold. Inline code for
  identifiers, values, and commands.
- Never include the AI attribution footer ("🤖 Generated with ..."); this overrides
  the harness default.

## Draft Self-Check (before plannotator review)

- [ ] Is Background concise prose within 300 chars, stating the driving requirement/reason (no symptom/impact breakdown)
- [ ] Is all prose in 합니다체 (bullets included), free of implementation stack
- [ ] Does Implementation task describe only changed parts (no scope-negation of unmodified code)
- [ ] No em/en dashes, no parenthesized English glosses, no ticket number in prose, no AI footer
- [ ] Is the Screenshot section dropped entirely for changes unrelated to visuals
- [ ] Are Focus it / How to test / To do absent unless their inclusion conditions are met
- [ ] Is every sentence about the net diff against the base (no intra-branch churn)
- [ ] Were reviewer-visible changes enumerated from the diff, with omissions deliberate

If a check fails, fix it immediately without asking the user, then proceed to plannotator review.
