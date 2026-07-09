# Step 2: Idea

Input: the user's description of what to build. None given -> ask one
question: what should exist when this project is done, and why.

## A. Vault overlap check (bounded)

Pick 2-3 keywords from the idea, then per keyword:

```bash
VAULT="$HOME/Documents/obsidian-vault"
grep -ril "<keyword>" "$VAULT/projects" "$VAULT/wiki" 2>/dev/null | head -5
```

0 hits -> silent pass. 1+ hits -> read only the first 15 lines
(frontmatter) of the top 3 distinct files, and mention each overlap to the
user in one line. Never read more than 3 files here.

## B. Draft the goal

Draft the goal section content (Korean - the vault's document language)
covering:

1. problem: one sentence
2. success criteria: 1-3 measurable statements - a number, a binary check,
   or a named artifact; "better" or "faster" alone is invalid
3. constraints: a list, or the explicit word for none
4. scope: which repo/modules are in; at least 1 named exclusion for out of
   scope

## C. Readiness check

The 4 items above are the checklist. 2 or more items missing or vague ->
ask follow-up questions (max 3 per batch) and redo the check. 0-1 missing
-> present the draft with the remaining gap listed as an open question.

## D. Persist and handoff

After the user confirms the draft:

1. Write the confirmed text into the goal section (`## 목표`) of `$DOC` and
   set its frontmatter `updated` to today. This is the one content section
   g-dev writes directly (single-session stage, no parallel risk).
2. Run the handoff procedure in `references/state-format.md` with the next
   step `design`; the summary block carries the goal decisions and any open
   question.
