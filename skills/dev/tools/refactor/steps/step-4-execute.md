# Step 4: Execute Approved Changes

Goal: Implement only the approved proposals, in dependency order,
with progress reporting and behavioral safety checks.

## Input

From Step 3:
- List of approved proposal IDs
- Proposal details from Step 2 (Before/After code)

## 4a. Determine Execution Order

Apply changes in this order to respect dependencies:

1. **Architecture** (A) — structural changes first, they create the scaffolding
2. **Types** (T) — type definitions before code that uses them
3. **Deduplication** (D) — extractions may depend on new structure
4. **Naming** (N) — renames after structure is stable
5. **Performance** (P) — optimizations on final code shape

If Step 2 noted explicit dependencies between proposals, respect those.

## 4b. Execute with Progress

For each approved item:

```
[A1] Extracting API calls to userService... done
[T1] Adding User interface... done
[D1] Consolidating date utils... done
```

Apply one item at a time. After each:
- Verify the file is syntactically valid
- Check that imports resolve correctly
- Ensure no unintended deletions

## 4c. Behavioral Safety Check

After all changes are applied, verify:

1. **Public API unchanged** — exported functions/types have the same signatures
2. **Import integrity** — all imports resolve, no broken references
3. **No side-effect changes** — unless explicitly part of an approved proposal
4. **Test files unmodified** — refactoring should not require test changes
   (if tests break, the refactoring changed behavior)

If any check fails, report which item caused it and ask the user how to proceed.

## 4d. Execution Summary

```
## Execution Complete

Applied N of M approved changes:
- [A1] ✓ Extract API calls to service layer
- [T1] ✓ Add User interface
- [D1] ✓ Consolidate date formatting

Files modified: X | Files created: Y | Files deleted: Z
```

**Proceed to Step 5 for review.**
