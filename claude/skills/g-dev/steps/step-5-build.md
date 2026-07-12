# Step 5: Build one task

Entry condition: at least one task file exists under `$ASSETS/tasks/`.
None -> say "run /g-dev breakdown first" and stop.

## A. Select and claim

1. Task id given as an argument -> that task. None given -> list claimable
   tasks (status pending, every depends id at done) and ask. Blocked and
   review tasks never enter the claimable list; they resume only via an
   explicit `/g-dev build t<NN>` - say so when they exist. Zero claimable
   while undone tasks exist -> print the blocked list (`t<NN> waits on
   t<MM>`) and stop.
2. Read the task file. status in-progress with a `session` marker other
   than `none` -> warn "claimed by <marker>" and continue only on an
   explicit user override.
3. Claim: set status in-progress, updated today, and session marker
   `<branch>-<hhmmss>` where branch = `git branch --show-current` (empty
   output -> `basename "$PWD"`) and hhmmss = `date +%H%M%S`.
4. Claim verification (guards the race where two sessions read pending at
   once): re-read the task file now; the session marker must equal the
   exact value written in item 3. Different -> another session won the
   claim; report and stop. From here until handoff, the task file is the
   ONLY state file this session writes.
5. Plan gate: after the claim is verified, before section B or any code,
   state this task's Goal, Scope, the Plan steps you will run, and how you
   will verify (its criteria) in <=6 lines, then get an explicit user go. A
   counter-question or scope change is not a go: resolve it, then re-ask.

## B. Harness first

1. Run every executable completion criterion once, now, and record each
   result.
2. A criterion whose command itself is broken (command not found, wrong
   path) -> fix the criterion text first. Implementing against a broken
   harness is forbidden.
3. Criteria requiring tests that do not exist yet -> write those tests now
   and confirm they FAIL before implementing.
4. A criterion whose command is valid but whose required inputs do not exist
   yet (it checks for data an earlier step never produced) -> produce those
   inputs as part of this task first (delegate research beyond the global
   context-hygiene thresholds), or, if the criterion asks for the wrong
   thing, fix the criterion text. Never fabricate the missing inputs to
   force a pass.

## C. Implementation loop

UI task (its Goal or Scope names screens, mockups, or UI components) ->
before the loop, run the frontend-design wrap per
`references/external-skills.md` scoped to this task's screens, using the
theme pick in architecture.md UI Direction (or the repo design-system doc
it names) as context. The rendered draft is the task's own deliverable
file in the repo: write a first draft before the loop, then iterate it
with the user, max 3 rounds; no agreement -> the stagnation menu.
To let the user actually see a rendered draft or sample: serve it over local
HTTP on a fixed port and open it in the browser preview tool, then capture
the full page (size the viewport tall enough to capture it in one shot);
file:// is blocked, so never rely on it and never ask the user to open the
file manually.

Repeat:

1. Implement the next Plan step. Stay inside the task's Scope; the global
   scope rules apply unchanged.
2. Run all executable criteria.
3. All pass -> exit the loop. Any fail -> fix and repeat.

Stagnation: 3 consecutive full-criteria runs each containing at least one
failure, with no previously-failing criterion turning green between runs ->
stop and present this menu:

1. cut scope - shrink Goal/criteria with the user; log the cut
2. switch approach - log the abandoned approach and why it failed
3. split - create t<NN>a / t<NN>b task files; the current task becomes
   t<NN>a
4. escalate - set status blocked, log the exact failing state, hand off
   without done

Record the pick as a Log entry, reset the failure counter, continue (or
stop, for option 4).

## D. Review and taste gates

- Task diff size = the uncommitted diff (`git diff --stat`) plus
  `git show --stat <hash>` for each commit hash already in the task Log:
  3+ files or 150+ changed lines in total -> dispatch ONE read-only agent
  (inherit the session model) to review those changes against the task's
  Goal and criteria. Apply must-fix items (max 2 fix rounds); note anything
  remaining in the Log.
- UI task (same definition as section C) -> after criteria pass, run
  the taste check per `references/external-skills.md`.

## E. Commit and handoff

1. Propose a commit for this task per the global git rules (proposal ->
   approval -> commit). A declined commit does not block handoff; note it
   in the Log.
2. Final status: done when all criteria pass and none are `manual:`; review
   when a manual criterion awaits the user - list exactly what they must
   check. The user confirming those manual items (in this session, a later
   one, or during step 6) is the review -> done transition: set status done
   with a Log entry naming who confirmed what.
3. Log entry: date, what was done, evidence (criteria commands + results,
   commit hash), leftovers.
4. Run the handoff procedure in `references/state-format.md` (no
   current-step change while other tasks remain). STOP: the next task needs
   an explicit user go or a separate session.
