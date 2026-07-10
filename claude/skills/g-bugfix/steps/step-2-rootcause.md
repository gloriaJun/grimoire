# Step 2: Root cause

Entry condition: step 1 recorded REPRO or an irreproducibility note.
Neither -> return to step 1.

## A. Trace

1. Start from the symptom output (stack-trace line, wrong value, error
   string) and walk backward through the code, reading only functions on
   the causal path.
2. For state or timing bugs with a REPRO, bisect with targeted logging
   or debugger runs against REPRO. Temporary instrumentation is a named
   exception to the approval-gate hard rule (SKILL.md) and must be
   removed no later than step 4 verification.
3. Stop tracing at the first code whose change would remove the symptom
   without masking it - the root cause, not the nearest patch point.
   When a caller merely passes bad input through, keep walking up to
   where the bad value originates.

## B. Report format (use this structure verbatim)

```markdown
## Root cause
<1-2 sentences>

## Evidence
- <file>:<line> - <what this line does wrong and why>
- <file>:<line> - <supporting fact>

## Causal chain
<symptom> <- <intermediate step(s)> <- <root cause file:line>

## Unverified
- <claim> - verify by: <command or observation>
(or: none)
```

Rules:

- Every claim in Root cause and Causal chain must either appear in
  Evidence with a file:line, or be listed under Unverified with a
  concrete verification method. No third category.
- Report the unverified tag in the conversation using the user's global
  tagging convention (CLAUDE.md); this file governs structure only.
- Never propose or sketch a fix in this step.

## C. Termination

Present the report and continue directly to step 3 (the approval gate
lives there, not here). If the user challenges the diagnosis, re-trace
and re-present before moving on.
