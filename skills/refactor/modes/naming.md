# Naming Mode

Guide for improving code readability through better naming and separation of concerns.
Good names eliminate the need for comments — the code explains itself.

## What to Analyze

Focus on checklist items N1–N5 from `references/analysis-checklist.md`.

### Priority order
1. **Name-behavior mismatch** (N2) — misleading names cause bugs
2. **SRP violation signals** (N3) — large functions hiding multiple responsibilities
3. **Unclear abbreviations** (N1) — readability friction for every reader
4. **Boolean naming** (N4) — clarity in conditionals
5. **Inconsistent conventions** (N5) — align to project style

## Refactoring Strategies

### Rename with Intent
Replace vague names with ones that reveal purpose:
- `data` → `userProfiles`, `orderItems`, `validationErrors`
- `handle` → `submitOrder`, `dismissModal`, `retryConnection`
- `process` → `normalizeAddress`, `calculateDiscount`, `validateInput`

The test: can a new team member understand what this does without reading the body?

### Split Large Functions
When a function does multiple things (N3):
1. Identify the distinct responsibilities (often separated by blank lines or comments)
2. Extract each into a named function
3. The original function becomes a coordinator calling the extracted functions
4. Each extracted function should be understandable from its name alone

### Align Boolean Naming
Boolean variables and functions should read naturally in conditionals:
- `if (isLoading)` reads better than `if (loading)`
- `if (hasPermission)` reads better than `if (permission)`
- `if (shouldRetry)` reads better than `if (retry)`

Predicates (boolean-returning functions): use `is`, `has`, `can`, `should` prefix.

### Respect Project Conventions
Before proposing naming changes:
- Check existing linter rules (ESLint, Prettier config)
- Look at naming patterns in the same module/directory
- Align with the project's established conventions, not personal preference

## Context for Proposals

When proposing naming changes, explain:
- What the current name implies vs what the code actually does
- How the new name better communicates intent
- For SRP splits: what responsibilities were combined and why separating them helps
