# Step 3: Review and Report

## Mechanical checks (run all three; empty output = pass)

Debug leftovers and unfinished markers in added lines:

```bash
git diff --cached | grep -nE '^\+.*(console\.(log|debug|trace)|\bdebugger\b|\bTODO\b|\bFIXME\b)'
```

Secret-looking literals in added lines:

```bash
git diff --cached | grep -inE '^\+.*(api[_-]?key|secret|token|passw(or)?d|private[_-]?key)[[:space:]]*[:=][[:space:]]*["'"'"'][^"'"'"']{8,}'
```

Credential files staged:

```bash
git diff --cached --name-only | grep -E '(^|/)\.env(\..+)?$|\.(pem|p12|key)$'
```

Every hit is a finding with file:line. A hit that is clearly a test fixture or documented placeholder may be downgraded to `note`, but must still appear in the report.

## Judgment checklist (against the diff read in Step 1)

- Correctness: logic matches the stated purpose; edge cases handled; no half-finished implementation
- Quality: no dead code, unused imports, or commented-out blocks; type errors addressed
- Completeness: tests updated for behavior changes; docs updated where the change makes them wrong

## Report format

```
## Pre-Commit Review

**Changes**: <one-line summary>
**Scope**: small | medium | large (<N> changed lines)

### Passed
- <checks that passed>

### Issues Found
- <block|warn|note> <file:line> <description>

### Recommendation
Proceed with commit | Fix issues first
```

## Decision

- No issues: state the recommendation and end. The commit itself stays with the caller (CLAUDE.md commit rules apply).
- Issues found: wait for the user.
  - "fix": apply the fixes, re-stage, restart from Step 1.
  - "proceed": end, keeping the findings on record in the report.
