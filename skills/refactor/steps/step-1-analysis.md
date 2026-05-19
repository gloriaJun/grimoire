# Step 1: Code Analysis

Goal: Systematically analyze the target code against the active mode's checklist
and discover structural context through codebase exploration.

## Input

From Step 0:
- Target file(s) and scope
- Active mode(s)
- User's stated goal

## 1a. Dispatch Explore Agent (Parallel)

Dispatch an Explore agent to gather structural context while you read the target files:

**Agent prompt template:**
```
Analyze the codebase around these files for refactoring context:
- Target files: <file paths from Step 0>
- Find: import/dependency graph, similar patterns elsewhere, existing utilities/hooks
  that could be reused, project conventions (naming style, directory structure)
- Report: file paths, dependency relationships, reusable existing code, conventions observed
```

Use `subagent_type: Explore` with `model: sonnet`.

## 1b. Read Target Code

While the Explore agent runs, read the target files directly.
Understand the code before judging it — note what it does, not just what it gets wrong.

## 1c. Apply Checklist

Load the relevant section(s) from `references/analysis-checklist.md` based on the active mode.
In auto mode, apply all sections.

For each checklist item, record:
- Whether the pattern exists in the target code
- Specific locations (file:line)
- Severity (from the checklist)
- A brief note on what's happening

## 1d. Merge with Explore Results

Combine your direct analysis with the Explore agent's findings:
- Existing utilities that could replace duplicated code
- Import relationships that reveal architecture issues
- Project conventions that inform naming suggestions

## 1e. Classify Findings

Assign each finding an ID using the category prefix:
- `[A1]`–`[A7]` for architecture
- `[T1]`–`[T6]` for types
- `[D1]`–`[D5]` for deduplication
- `[N1]`–`[N5]` for naming
- `[P1]`–`[P7]` for performance

Present a findings summary:

```
## Analysis Findings

Found N issues across M categories:

### Architecture (X issues)
- [A1] Direct API call in UserProfile component — src/components/UserProfile.tsx:42

### Types (X issues)
- [T1] Explicit `any` in API response handler — src/api/users.ts:15

(continue for each category with findings)
```

## 1f. Scope Check

If auto mode produced more than 10 findings, ask the user to prioritize:

```
Found N issues. To keep the refactoring focused, which categories
should we prioritize?

1. All — review everything (may be a large changeset)
2. High severity only — focus on the most impactful issues
3. Select categories — choose specific areas (e.g., "Architecture + Types")
```

**Proceed to Step 2 with the prioritized findings.**
