---
name: g-wrap
description: >
  Session wrap-up. Trigger: /g-wrap OR natural language ("마무리",
  "세션 마무리", "세션 종료"). Inventories this session's artifacts (git state,
  Claude-created vault notes, plans, scratchpad, worktrees), asks at most once
  whether a vault record is needed, then removes per-item confirmed
  leftovers. Sub-commands: help.
---

# g-wrap

Closes a session deterministically: one artifact inventory, one record
decision, one confirmed teardown. Owns the record-declined rollback path.

## Flow Diagram

```mermaid
flowchart TD
    A(["/g-wrap or a wrap-up request"]) --> H{"help or
unrecognized input?"}
    H -- yes --> HT(["print the sub-command table"])
    H -- no --> B["Step 1: inventory
scripts/collect-artifacts.sh"]
    B -- script file missing --> FB["git status only"] --> Z
    B --> D{"deletable rows?"}
    D -- none --> Z(["report git state, end"])
    D -- some --> E["Step 2: record gate"]
    E -- record needed --> V["invoke g-vault-log
(Skill tool), lock its notes to keep"] --> P
    E -- already written this session --> P
    E -- declined --> P["per-item keep/delete pick
vault rows row by row"]
    P -- nothing picked --> Z2(["report: nothing removed"])
    P -- delete picked --> G["Step 3: files, servers,
worktrees, branches"]
    G --> Z3(["result table with skips
and failures"])
```

## Sub-commands

| Input | Route |
|---|---|
| none | Step 1 (default action) |
| `help`, unrecognized input | print this table |

## Step Router

Read ONLY the step file for the current step.

| Step | Load file | Description |
|---|---|---|
| 1 | `steps/step-1-inventory.md` | Session window, git state, artifact surfaces |
| 2 | `steps/step-2-decide.md` | Record decision, then per-item keep/delete |
| 3 | `steps/step-3-execute.md` | Guarded deletion and result table |

## Hard Rules

- Record-declined is a delete signal, never a write signal: after the
  decline, never create, append to, relocate, or promote a vault note.
- Deletion needs an explicit pick per row. Vault rows are confirmed one row
  at a time and are never covered by a bulk approval.
- Never delete the current worktree, the current branch, or anything holding
  uncommitted or unpushed work.
- Memory files under `~/.claude/projects/*/memory/` are report-only here;
  g-cleanup owns them (`g-cleanup/references/protected-paths.md`).
- Scope is the Step 1 session window. Older artifacts belong to /g-cleanup.
- Never git commit or push inside the vault (CLAUDE.md).
