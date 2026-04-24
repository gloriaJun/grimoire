# Review: Code Review

On-demand code review step. Does not require an active devlog.

## Scope Detection

1. Check if a PR URL or file path was passed with the `/dev review` command.
2. If not, check for staged changes (`git diff --staged`).
3. If no staged changes, check for unstaged changes (`git diff`).
4. Confirm the review scope with the user before proceeding.

```
Review scope:
  [staged changes / file: <path> / PR: <url>]

Proceed? (y / specify different scope)
```

## Review Routing

Determine who reviews based on recent authorship:

| Author | Reviewer | Method |
|--------|----------|--------|
| Claude | Codex | `/codex:review` via `code-reviewer` agent |
| Codex | Claude | `code-reviewer` agent (Claude reviews) |
| Unknown / mixed | Claude | `code-reviewer` agent |

If scope includes frontend changes (components, styles, a11y), also dispatch `frontend-reviewer` in parallel.

## Execution

### Option A: PR URL provided

Invoke `plannotator-review` skill with the PR URL.

### Option B: Staged/unstaged diff or file

1. Dispatch `code-reviewer` agent with:
   - The diff or file contents
   - Brief context: what the change does and why
2. If frontend changes detected, dispatch `frontend-reviewer` in parallel.
3. Wait for all reviewers to complete.

## Output

Present findings grouped by severity:

```
## Review Results

### 🔴 Blocking
- <issue> [file:line]

### 🟡 Suggestions
- <issue> [file:line]

### ✅ Looks good
- <summary>
```

## Next Steps

After presenting findings:
1. If no active devlog: session ends here after user acknowledges.
2. If called from within a devlog task: return to `build.md` flow (Step C: Review Resolution).
