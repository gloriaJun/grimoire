# Step 3b: Design Standalone

Runs when the `design` sub-command carries an inline payload: any non-empty
text after `design` in the invoking message. Needs no vault project, no
state.md, no goal section. Read `references/state-format.md` only when the
merge path in section D is taken.

## A. Classify the payload

1. Mode A signal: two or more numbered items (lines matching `^\s*\d+[.)]`).
2. Mode B signal: at least one feasibility question (interrogative
   sentence, or a request to check whether an API, procedure, or
   capability exists).
3. Exactly one signal present -> that mode. Both or neither -> ask one
   question ("A: judge the proposals per item, or B: investigate the
   questions?") and route by the answer.

## B. Mode A: proposal review

1. Split the payload into items, keeping the user's numbering. An item
   without a number gets the next free number; report the renumbering.
2. Judge each item against the actual repo. Verdict is exactly one of
   `agree | conditional | against`; every verdict cites evidence
   (file:line, command plus output, or spec link). `conditional` states
   its condition in one line. No evidence obtainable -> keep the verdict
   but tag it `unverified` plus a one-line way to verify. Research beyond
   the context-hygiene thresholds in the global instructions goes to
   read-only agents under the global parallelism cap. Cwd is not a git
   repo -> judge against the payload and cited specs only, and put
   `no repo` in the evidence column.
3. Print, in this order:
   - Verdict table: `| # | proposal | verdict | evidence |`
   - Approval table: `| # | state |`, every state `pending`
   - Reply format line: replies name item numbers plus a keyword, e.g.
     "3, 4번 동의" = approve items 3 and 4. Keywords: approve = "동의" or
     "승인"; reject = "기각" or "반대"; hold = "보류"; stop = "종료" or
     "그만".
4. Approval loop, per user reply, in this order:
   - A stop keyword ends the loop even with `pending` rows left.
   - Else parse item numbers plus one keyword; set exactly those rows to
     `approved | rejected | held`, then re-print the approval table only.
   - No item number or no keyword -> re-print the format line and wait;
     never guess.
   - The loop also ends when no row is `pending`. At termination, list
     remaining `held` and `pending` rows as open items.

## C. Mode B: feasibility investigation

1. Split the payload into distinct questions. More than 3 -> ask the user
   to pick up to 3 for this run; the rest wait for a follow-up run.
2. Dispatch one read-only research agent per question, in parallel.
   Each agent prompt contains: the question verbatim, the repo path (or
   `none` when cwd is not a git repo), and the return contract
   "conclusion + evidence (file:line or URL) + confidence (high/med/low);
   conclusions only, no raw dumps".
3. Report one block per question: verdict (`feasible | not feasible |
   conditional`), evidence, confidence. An agent that errors or returns no
   evidence -> verdict `unverified` plus a concrete manual check; never
   turn a guess into a finding.

## D. Handoff: stateless by default, merge on explicit yes

1. Look up this repo's g-dev projects (shared script with step 1):

```bash
bash ~/.claude/skills/g-dev/scripts/find-repo-projects.sh
```

2. `GUARD_FAIL` (lookup could not run: no repo or no vault, so no project
   can be merged into) or 0 matches -> print the result summary and STOP.
   Nothing is written anywhere: this is the stateless path.
3. 1 or more matches -> ask once whether to merge the results into a
   project (2 or more: list slugs, the user picks one). Anything other
   than an explicit yes -> stateless path; silence is not approval.
4. On yes: write the review file per `references/state-format.md`
   (`$ASSETS/reviews/YYYY-MM-DD-<kebab-topic>.md`), then run the shared
   handoff procedure there (g-vault-log update). Never write `state.md`:
   a standalone run is not a step transition, `current-step` is unchanged.
5. STOP.
