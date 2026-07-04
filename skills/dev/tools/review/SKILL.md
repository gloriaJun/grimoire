---
name: review
description: >
  Sub-tool of /dev skill. Triggered by /dev review or natural language
  routed through /dev: "이 코드 리뷰해줘", "이 부분 검토해줘", "코드 봐줘",
  "review this", "check this code".
---

# Review — Code Review

On-demand code review. Does not require an active devlog.
When called from within a build step, returns findings to the build flow.

---

## Scope Detection

1. Check if a PR URL or file path was passed with the command.
2. If not, check for staged changes (`git diff --staged`).
3. If no staged changes, check for unstaged changes (`git diff`).
4. Confirm the review scope with the user before proceeding.

```
Review scope:
  [staged changes / file: <path> / PR: <url>]

Proceed? (y / specify different scope)
```

---

## Review Routing

| Scope | Method |
|-------|--------|
| PR URL | `plannotator-review` skill |
| Staged / unstaged diff | `code-review` skill |
| Specific file (committed code) | `code-reviewer` agent |

If scope includes frontend changes (components, styles, a11y), also dispatch `frontend-reviewer` in parallel.

---

## Execution

### Option A: PR URL provided

Invoke `plannotator-review` skill with the PR URL.

### Option B: Staged/unstaged diff

1. Run the `code-review` skill on the diff.
2. If frontend changes detected, dispatch `frontend-reviewer` in parallel.
3. Wait for all reviewers to complete.

### Option C: Specific file

1. Dispatch `code-reviewer` agent with:
   - The file contents
   - Brief context: what the change does and why
2. If frontend changes detected, dispatch `frontend-reviewer` in parallel.

---

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

---

## Next Steps

After presenting findings:
1. If no active dev task: session ends here after user acknowledges.
2. If called from within a build step: return to `build.md` flow (Step C: Review Resolution).
