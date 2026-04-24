# Step 3: User Approval Gate

Goal: Get explicit approval from the user before making any code changes.
This is a HARD STOP — never proceed to Step 4 without user confirmation.

## 3a. Present Approval Options

After the proposal (Step 2), present:

```
Which changes would you like to apply?

1. Approve all — apply all N proposals
2. Select by ID — choose specific items (e.g., "A1, T1, D1")
3. Reject all — cancel this refactoring session
4. Revise — request changes to specific proposals before deciding
```

## 3b. Handle User Response

### Approve all
Record all proposal IDs as approved. Proceed to Step 4.

### Select by ID
Record only the selected IDs as approved. Rejected items are permanently
excluded — do not re-propose them in this session.

If selected items have dependencies on rejected items, warn:
```
[D1] depends on [A1] which was not selected. Options:
1. Include [A1] as well (required for [D1])
2. Skip [D1] too
```

### Reject all
End the session. Summarize what was found in case the user wants to revisit later.

### Revise
The user wants changes to specific proposals. Ask which IDs need revision
and what should change. Return to Step 2 to regenerate those proposals only.
Keep unchanged proposals intact.

## Rules

- **No implicit approval.** Silence or ambiguous responses require clarification.
- **No re-proposing rejected items.** If the user says no to [A1], it stays rejected.
- **Partial approval is normal.** Users often approve safe changes (types, naming)
  first and defer risky ones (architecture) for later.

**Proceed to Step 4 only with explicit approval.**
