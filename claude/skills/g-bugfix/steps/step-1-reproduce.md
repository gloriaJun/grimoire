# Step 1: Reproduce

Entry condition: a bug description exists (user message or a linked
issue). None -> ask for the symptom, the expected behavior, and where it
happens; stop until answered.

## A. Collect the claim

1. Restate internally: observed behavior vs expected behavior, one line
   each. These two lines anchor every later step.
2. Locate the surface: Grep/Glob for symptom keywords, error strings,
   route or command names. Record candidate files (paths only, no fix
   ideas yet).

## B. Choose a reproduction vehicle (first matching row wins)

| Situation | Vehicle |
|---|---|
| A failing test for this symptom already exists | run that test |
| The buggy behavior is unit-testable | write a NEW test encoding the expected behavior |
| Runtime-only (server, UI) | launch and drive the reported path (see below) |
| CLI | run the exact reported command |

Runtime vehicle: find the launch command in this order -
`.claude/launch.json`, `package.json` scripts (`dev`, then `start`),
the README's run instructions. Drive HTTP paths with `curl` against the
reported endpoint. UI-only paths need a browser tool or the user's
hands; when neither is available, count it as one failed attempt and
try another vehicle. A launch that itself errors also counts as one
failed attempt.

Then run the vehicle and record verbatim: the command, its exit code,
and the relevant output lines.

A test written here must FAIL before it counts: a passing "repro" test
proves nothing - fix the test or pick another vehicle. Writing this
test is a named exception to the approval-gate hard rule (SKILL.md).

## C. Outcome (exactly one)

- Reproduced: the output shows the reported symptom -> record the
  command as REPRO. REPRO is the verification harness for steps 3-4.
  Continue to step 2.
- Not reproduced after 3 distinct attempts (each with a different
  vehicle or input): stop attempting and write an irreproducibility
  note containing: every attempt (command + result), the most likely
  blocking factor (environment, data, credentials, timing), and what
  the user could provide to unblock. Present the note, then continue to
  step 2 with claims capped: anything only a reproduction could confirm
  must be tagged unverified in the step 2 report.
