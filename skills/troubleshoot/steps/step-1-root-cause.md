# Step 1: Root Cause Analysis

Goal: Identify the fundamental cause of the issue using the mode-specific approach.

## Input

From Step 0:
- Triage summary (error source, mode, key error, related files)
- Mode file already loaded (provides the analysis approach)
- Explore agent results (related code files, recent changes)

## Mode-Specific Analysis

The loaded mode file (`modes/<mode>.md`) defines the detailed approach.
Follow it, but always produce the common output format below.

### error-analysis mode
1. Parse the error log/trace to extract the exception chain
2. Trace the code path from the throw/raise site upward
3. Identify the root cause in the codebase (read the relevant files)
4. Verify: does the identified cause explain all observed symptoms?

### debug mode
1. Form hypotheses based on symptoms (see modes/debug.md for protocol)
2. Verify each hypothesis systematically
3. If all disproved, form new hypotheses (max 2 rounds)
4. Once confirmed, proceed to output

### performance mode
Currently placeholder — inform user and suggest manual profiling.

## Output Format

Present the root cause in this structure:

```
## Root Cause

- **What**: <the fundamental cause — one clear sentence>
- **Where**: <file:line or system component>
- **Why**: <why this caused the observed symptom — the causal chain>
- **Impact**: <what else might be affected by this issue>
```

If the root cause involves multiple contributing factors, list them in order
of significance with the primary cause first.

**Confirm with user before proceeding to Step 2.**
