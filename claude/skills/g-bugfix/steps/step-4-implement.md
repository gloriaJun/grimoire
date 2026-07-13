# Step 4: Implement (post-approval)

Entry condition: the user explicitly approved the step 3 plan in this
conversation. No approval on record -> return to step 3.

## A. Mode selection

| Condition | Mode |
|---|---|
| The plan touches 3+ files, or its diff blocks total 150+ changed lines | delegate to ONE subagent |
| Otherwise | implement inline |

An explicit user request overrides the table in either direction.

## B. Delegation (when selected)

1. The subagent prompt contains: the approved plan verbatim (all
   Before/After blocks), a file allowlist (exactly the paths in the
   plan), and the instruction: "Apply the plan exactly. If a Before
   block no longer matches the file, stop and report the mismatch
   instead of improvising."
2. Inherit the session model; report the delegation in one line per the
   global agent rules (task / model tier / reason).
3. On a mismatch report: re-read the file and update the plan. The
   approved After code still applies with only line-number or
   whitespace differences -> proceed. Any token of the After code
   changes -> re-run the step 3 approval gate first.

## C. Verify

1. Run every Verification item from the approved plan; record each
   command and its result verbatim.
2. REPRO must show the expected behavior. A failing item -> fix within
   the approved scope and re-run all items. After 3 fix-and-rerun
   cycles with no previously failing item turning green, or when the
   approved scope is no longer sufficient, return to step 3 with the
   failure evidence and a revised plan; do not widen scope silently.
3. Remove any instrumentation left from step 2 and confirm
   `git status` shows only intended changes.

## D. Report and close

1. Report: root cause (1 line), changed files, verification evidence
   (commands + results), remaining `manual:` or unverified items.
2. The root cause generalizes beyond this repo (environment, tooling,
   library or API behavior - not a repo-local typo or logic slip) ->
   append the vault capture proposal line per the global Obsidian
   rules; otherwise skip silently.
3. Propose a commit per the global git rules (proposal -> approval ->
   commit); type `fix`.
4. STOP. Out-of-scope items from the plan are re-listed as one-liners,
   never acted on in this run.
