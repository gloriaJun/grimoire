# Step 1: Entry (resume / init / status)

## A. Locate context

```bash
VAULT="$HOME/Documents/obsidian-vault"
ls "$VAULT/projects" >/dev/null 2>&1 && echo VAULT_OK || echo VAULT_MISSING
git rev-parse --show-toplevel 2>/dev/null   # REPO_PATH; empty = not a repo
date +%F
```

- `VAULT_MISSING` -> report that g-dev requires the vault at
  `~/Documents/obsidian-vault` and stop.
- REPO_PATH empty -> ask the user for the project's repo or working
  directory; do not guess.
- DOMAIN: `work` when `$PWD` is under `$HOME/Documents/GithubWork`, else
  `dev`. REPO = `basename "$REPO_PATH"`.

## B. Find this repo's projects

Run the shared lookup script (also used by step 3b):

```bash
bash "$HOME/.claude/skills/g-dev/scripts/find-repo-projects.sh"
```

A `GUARD_FAIL` line means REPO or the vault was invalid - fix that first;
never treat its 0 matches as "new project".

| Matches | Action |
|---|---|
| 0 | new project: section D |
| 1 | resume: section C |
| 2-10 | print `<slug> (<current-step>)` per match, ask which |
| >10 | same list, first 10 only, note the total count |

## C. Resume

1. Derive DOMAIN and SLUG from the matched path itself
   (`projects/<DOMAIN>/assets/<SLUG>/state.md`); this overrides the
   cwd-based DOMAIN guess and also covers domains other than dev/work.
2. Read the matched `state.md` in full, plus the formal doc's frontmatter
   and status block only (first 40 lines).
3. Count tasks by status (ASSETS = the matched state.md's directory):
   `find "$ASSETS/tasks" -name 't*.md' -exec grep -h '^status:' {} + 2>/dev/null | sort | uniq -c`
   (no task files -> empty output, not an error).
4. Print 4 lines: slug / current-step / task counts by status / claimable
   tasks (status pending with every depends id at done).
5. Route to the step file for `current-step` per the SKILL.md router. When
   current-step is build, never auto-claim a task; show the claimable list
   and wait for the user's pick.

## Status mode (`/g-dev status`)

Run section B, then section C items 1-4 for every match, then stop. Zero
matches -> print `No active g-dev projects for this repo.` and stop. Never
route onward in status mode.

## D. New project init

1. Derive a kebab-case slug from the request and confirm it with the user
   (one question, include the proposed slug).
2. Collision check: either of
   `ls "$VAULT/projects/$DOMAIN/$SLUG.md" 2>/dev/null` or
   `ls -d "$VAULT/projects/$DOMAIN/assets/$SLUG" 2>/dev/null` finding an
   entry -> ask for another name (leftover assets count as a collision).
3. Create the formal doc: copy `$VAULT/_system/templates/project.md` to
   `$VAULT/projects/$DOMAIN/$SLUG.md` and fill the frontmatter (title,
   created and updated = today, tags including `dev`). Template file
   missing -> write the skeleton below verbatim instead.
4. `mkdir -p "$VAULT/projects/$DOMAIN/assets/$SLUG/tasks"`, then write
   `state.md` per `references/state-format.md` with `current-step: idea`.
5. Load `steps/step-2-idea.md` and continue - init and idea run in one
   session.

Skeleton (section labels stay in Korean - the vault's document language):

```markdown
---
title: <slug>
created: YYYY-MM-DD
updated: YYYY-MM-DD
tags: [dev]
---

## 목표

## 현황

<!-- g-dev:status:start -->
<!-- g-dev:status:end -->

## 결정 기록

## 작업 로그

## 참고 링크
```
