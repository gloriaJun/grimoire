# Step 2: Refactoring Proposal

Goal: Present each proposed change with rationale, impact assessment, and
before/after code comparison so the user can make informed decisions.

## Input

From Step 1:
- Classified findings with IDs
- Code context and dependency information
- User's priority preferences (if filtered)

## 2a. Generate Proposals

For each finding, create a proposal using this format:

```markdown
---

### [ID] Title describing the change

**Rationale**: Why this change improves the code. Explain the principle being
applied and what concrete benefit it brings (testability, readability,
safety, performance). Avoid generic statements — be specific to this code.

**Impact**: N file(s) affected | Risk: Low/Medium/High

**Before** — `path/to/file.ext:line`
\```language
// The problematic code, with enough surrounding context to understand it
\```

**After** — `path/to/file.ext`
\```language
// The refactored code in the same file
\```

**After** — `path/to/new-file.ext` (new file, if applicable)
\```language
// Extracted code in a new file
\```
```

### Format rules

- **Rationale** is mandatory for every proposal — no change without explanation
- **Before** block: show the actual current code with file path and line reference
- **After** block: show the proposed replacement; if multiple files are involved,
  use separate After blocks with file paths
- **Risk levels**:
  - Low — no behavior change, additive (type additions, renames, extractions)
  - Medium — behavior is preserved but call sites change (interface changes, moves)
  - High — potential behavior change (logic restructuring, algorithm changes)
- Keep code blocks focused — show only the relevant section, not entire files
- Include enough context lines (2-3 above and below) for the reader to orient

## 2b. Order Proposals

Present proposals grouped by category, ordered by severity within each group:

1. Architecture (A) — structural issues first
2. Types (T) — type safety
3. Deduplication (D) — DRY improvements
4. Naming (N) — readability
5. Performance (P) — efficiency

## 2c. Summary Table

After all proposals, provide a summary:

```markdown
## Proposal Summary

| ID | Category | Description | Risk | Files |
|----|----------|-------------|------|-------|
| A1 | Architecture | Extract API calls to service layer | Low | 2 |
| T1 | Types | Add User interface for API response | Low | 1 |
| D1 | Duplication | Consolidate date formatting utils | Low | 3 |
| P1 | Performance | Fix missing useEffect cleanup | High | 1 |

**Total**: N changes across M files
```

## 2d. Dependencies Between Proposals

If proposals depend on each other (e.g., A1 must be applied before D1 because
the extraction creates the file that deduplication targets), note this:

```
Note: [D1] depends on [A1] — the shared utility assumes the service layer exists.
If you approve [D1], [A1] will be applied first.
```

**Proceed to Step 3 for user approval.**
