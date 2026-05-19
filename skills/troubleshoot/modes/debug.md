# Debug Mode

Hypothesis-driven systematic debugging for issues where the root cause is not
immediately apparent from error logs. This mode absorbs the former g-debug-process
skill workflow.

Use this mode when the user reports unexpected behavior but there is no clear
error message or stack trace pointing to the cause.

## Principles

These principles guide the entire debug process:

- **Do not jump to fixing before understanding the root cause.** A premature fix
  often masks the real problem or introduces new ones.
- **One hypothesis at a time.** Shotgunning multiple changes makes it impossible
  to know what actually worked.
- **If stuck after 2 rounds of hypotheses, step back and reconsider assumptions.**
  The bug might not be where you think it is.
- **Document findings as you go.** This helps if the issue recurs and builds
  institutional knowledge.

## Debug Flow

```
Symptoms → Reproduce → Form hypotheses (max 3)
→ Verify one at a time → Confirmed? → Root cause
                       → All disproved? → New hypotheses (max 2 rounds)
```

## Phase 1: Reproduction

Before forming hypotheses, verify the issue is reproducible:

1. Follow the reproduction steps provided by the user (or construct them from the symptom description)
2. Confirm the observed behavior matches the reported symptoms
3. If not reproducible:
   - Ask for more details (environment, timing, specific inputs)
   - Check if the issue is intermittent — try multiple runs
   - If still not reproducible after 3 attempts, document findings and inform user

Document the exact reproduction result before proceeding.

## Phase 2: Hypothesis Formation

Form up to 3 hypotheses, ranked by likelihood:

```
### Hypothesis 1 (most likely): <title>
- Reasoning: <why this is suspected, based on symptoms>
- Verification: <specific check, test, or experiment>
- Files to examine: <file paths>

### Hypothesis 2: <title>
- Reasoning: ...
- Verification: ...
- Files to examine: ...

### Hypothesis 3: <title>
- Reasoning: ...
- Verification: ...
- Files to examine: ...
```

**Ranking criteria:**
- How well does the hypothesis explain ALL observed symptoms?
- How likely is this given recent changes (git log)?
- Is this a known failure mode for this type of system?

**Confirm with user before starting verification.**

## Phase 3: Hypothesis Verification

Test hypotheses in order of likelihood:

For each hypothesis:
1. Perform the verification step defined above
2. Record the result: **confirmed** / **disproved** / **inconclusive**
3. Present finding to the user

| Result | Action |
|--------|--------|
| Confirmed | Proceed to root cause output (Step 1 common format) |
| Inconclusive | Note uncertainty, continue to next hypothesis |
| All disproved | Return to Phase 2 with new hypotheses |

**Retry limit**: Maximum 2 rounds of hypothesis formation. After 2 rounds
with no confirmation, step back:
- Reconsider the initial assumptions
- Look at broader system interactions
- Ask the user if any relevant context was missed
- Consider if the issue is environmental (infra, config, data)

## Integration with Step 1

After a hypothesis is confirmed, format the finding using Step 1's common
output format (What / Where / Why / Impact) and proceed normally through
Steps 2-4.
