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
2. **Check remote state**: if there are unpushed commits, report the count and push after
   confirmation per hard rule 5. On push failure, stop and report the cause.
3. **Analyze changes**: identify commits and changed files with `git log` and `git diff --stat`
   (base..HEAD), and write in the body only facts confirmed by reading the actual files.
   If there are no changes, stop.
4. **Local verification**: run lint, unit tests for the changed parts, and the build,
   using the commands defined in the repository.
   - Limit the verification scope to the change scope. In a monorepo, run only the changed
     packages/apps (`nx affected`, `turbo --filter`, `pnpm --filter`, or whatever the repository uses).
   - Find commands in the repository configuration (package.json scripts, project CLAUDE.md,
     Makefile, etc.); skip undefined items but report the skip.
   - If any one fails, stop the submission and report the failure.
     Skipping is allowed only when the user explicitly instructs it.
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

{why the change is needed. 1-3 bullets}

### Implementation task

{representative changes. the units of change reviewers must grasp}

### Screenshot

{only when there are UI/visual changes}

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

- Lead with the strategic motivation: why it is needed, how it aligns with existing codebase conventions.
- Append side benefits (risk reduction, consistency gains) in one line afterward.
- Do not open with mechanical symptoms or defect descriptions.

Forbidden: "기존 워크플로우는 env 설정 오류 시 예외가 발생하는 문제가 있었습니다."
Preferred: "다른 워크플로우가 이미 octokit을 사용하는 방식과 일치시키기 위해 gh CLI 의존성을 제거합니다. 부수적으로 CLI 인증 오류에 의한 간헐적 실패도 함께 해소됩니다."

### Implementation task

- Write representative changes only. No exhaustive file listing, no restating what is obvious from the diff.
- Do not write the implementation stack (library names, action names, permission scopes, standard security techniques).
  The body describes the behavior and capabilities reviewers care about; the diff explains the how.
- Compress "attempt → fail → replace" narratives into one line (`beforeSendSpan` 방식 비효과적 → `ignoreSpans`로 교체).
- Group causally related changes as sub-bullets. Parent = what changed,
  children = the results and side effects to review together. List independent changes as top-level bullets without nesting.

  ```markdown
  - `gh pr list` → `github-script` octokit으로 교체합니다
    - PR이 없을 때 동일 방식으로 실패합니다 (동작 유지)
    - `pr_number`가 step output으로 하위 스텝에 전달됩니다
  ```

- Write file paths only when essential for understanding: when the same change applies to two modules and
  needs disambiguation, or when the path itself is the review point (config, per-environment files).
  Omit when the description alone suffices.
- No numbered headings inside the section (`#### 1. ...`). Purpose-oriented headings only.

### Screenshot

- Change demonstrable with media + material available → write the scaffold.
- Change demonstrable with media + no material → build the scaffold with empty `src`;
  never a prose promise like "확인 후 첨부 예정".
- Change unrelated to visuals (backend, CI, config, infra) → omit the section entirely.
- Set image widths with HTML `<img>`: portrait (mobile) `width="280"`, landscape (desktop) `width="680"`.
- With multiple cases (Before/After, etc.), build a table and leave `src=""` empty for the user to fill.
- For changes verified via console logs, attach the actual logs inline in a code block or `<details>`.
- When you create a scaffold, tell the user in chat which screenshots, videos, or logs would help the review.

### Focus it

- Inclusion condition (only when at least one applies): security impact, breaking change,
  policy/architecture decisions needing team judgment, edge cases or side effects easy to miss by reading code alone.
- Do not write generic review requests like "복잡하니 꼼꼼히 봐주세요", changes obvious from the diff,
  or routine security hygiene (least privilege, etc.). If there is nothing to write, omit the section.
- Each bullet is one line (what / why it needs attention). Write judgment requests in question form
  ("~를 사람 개입 없이 자동 종료해도 괜찮은지").

### How to test

- Inclusion condition (only one of two): setup beyond the standard dev environment is needed (env, seed,
  feature flag, external service connection), or automated tests cover only specific scenarios and
  reproduction guidance is needed.
- Omit "앱 실행 후 확인"-level guidance and step lists that just repeat workflow inputs/modes.

### To do

- Write only follow-up work that has a ticket or a confirmed next PR.
- Do not write speculative improvements ("추후 개선 예정", "적용하면 좋을 것 같습니다").
  They only leave the impression that the current PR is unfinished.

### Reference

- Include only when there are related issue/PR/ticket/doc links.
- If there is a related ticket, include its link even when the ticket number is in the title.
- Write every entry as a clickable markdown link. A bare identifier ("Jira: ABC-123")
  is not a reference.

## Style and Common Rules

- Body prose is Korean 합니다체 (formal polite style; `~합니다`, `~됩니다`). Apply to all prose including
  bullets, and do not use `~다` or `~한다`.
- Write goals/intent in the volitional form: "~를 해소하고자 합니다", "리뷰 후 1차 병합하려고 합니다".
- Do not add parenthesized English glosses. If the Korean term suffices, use Korean only
  ("중간 병합(intermediate merge)" → "1차 병합"). Exception: established terms with no Korean equivalent.
- Evidence-based description: write concrete behavior changes instead of speculative "개선/강화" (improved/strengthened).
- Do not write the ticket number in body prose; it belongs only in the Reference link
  and, per repository convention, the title.
- Drop "(Optional)" markers from headings you fill; delete optional sections left empty.
- No decorative bold. Use inline code for identifiers, values, and commands.
- Never include the AI attribution footer ("🤖 Generated with ..."); this overrides
  the harness default.

## Draft Self-Check (before plannotator review)

- [ ] Does Background open with strategic motivation (not mechanical symptoms)
- [ ] Is all prose in 합니다체 (bullets included)
- [ ] Is the body free of implementation stack
- [ ] No em/en dashes, and no parenthesized English glosses
- [ ] No ticket number in prose, no AI footer, no "(Optional)" heading markers
- [ ] Is the Screenshot section dropped entirely for changes unrelated to visuals
- [ ] Are Focus it / How to test / To do absent unless their inclusion conditions are met

If a check fails, fix it immediately without asking the user, then proceed to plannotator review.
