# Step 3: Fix plan and approval gate

Entry condition: a step 2 root-cause report exists in this conversation.
None -> return to step 2.

## A. Write the plan (use this structure verbatim)

````markdown
## Fix plan

Root cause: <1 line, copied from the step 2 report>

### Changes

#### <path/to/file>

Before:
```<lang>
<exact current code, copied from the file>
```

After:
```<lang>
<proposed code>
```

### Verification
- [ ] REPRO from step 1 now shows the expected behavior: `<command>`
- [ ] `<repo test command>` exits 0 (when the repo defines one)
- [ ] `<repo lint or build command>` exits 0 (when the repo defines one)

### Out of scope
- <adjacent issue noticed, 1 line> (or: none)
````

Rules:

- One `####` block per changed file; one Before/After pair per changed
  region within it. Before blocks are copied from the current file
  content, never paraphrased or abbreviated.
- Include only files required to remove the root cause. Refactoring off
  the causal path goes under Out of scope, one line each.
- Irreproducible bugs: Verification lists the closest executable proxy
  plus a `manual:` item stating exactly what the user must confirm.

## B. Approval gate

1. Present the plan, ask for approval in one sentence, and END the turn.
2. Proceed to step 4 ONLY on an explicit go (quoted examples: "승인",
   "진행", "approve", "go ahead"). Not approval: silence, a question, a
   compliment, feedback on part of the plan.
3. A question or comment that is neither approval nor a change request
   -> answer it, re-state the approval ask in one sentence, and end the
   turn again.
4. A change request -> revise the plan, re-present it in full, and gate
   again. Every revision passes the gate; there is no small-tweak
   exemption.
5. Until approval, Write/Edit on repo files is forbidden per the
   approval-gate hard rule (SKILL.md).
