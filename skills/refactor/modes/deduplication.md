# Deduplication Mode

Guide for identifying and eliminating code duplication. The goal is DRY (Don't Repeat
Yourself) — but applied with judgment. Not all duplication is bad; premature abstraction
can be worse than a few repeated lines.

## When Duplication Warrants Extraction

Apply the **Rule of Three**: extract when the same pattern appears 3+ times.
For 2 occurrences, flag it but don't force extraction unless the logic is complex.

Exception: even 2 occurrences justify extraction if the duplicated logic is:
- Complex (> 10 lines)
- Likely to change together
- A source of bugs if one copy is updated but the other isn't

## What to Analyze

Focus on checklist items D1–D5 from `references/analysis-checklist.md`.

### Priority order
1. **Copy-paste blocks** (D1) — highest risk of divergence bugs
2. **Scattered utilities** (D3) — quick win, consolidate into one location
3. **Cloned components** (D2) — generalize with props
4. **Repeated conditionals** (D4) — extract shared predicate or strategy
5. **Magic numbers/strings** (D5) — low effort, high readability gain

## Refactoring Strategies

### Extract Utility Function
For duplicated logic that operates on data:
- Create a pure function in a utility module
- Give it a descriptive name that explains the operation
- Import from all usage sites

### Generalize Component
For components that are structurally identical but differ in data:
- Identify the varying parts → these become props
- Create a single component with those props
- Replace all copies with the generalized component

### Extract Custom Hook
For duplicated state + effect patterns:
- Create a hook that encapsulates the shared state logic
- Return the minimal API needed by consumers
- Each consumer calls the hook and renders from its output

### Create Constants
For repeated values:
- Group related constants in a dedicated file
- Use descriptive names that explain the value's purpose
- Prefer `as const` for literal types

## Context for Proposals

When proposing deduplication, explain:
- Where the duplicates are (file paths + line references)
- What risk exists if only one copy gets updated
- Whether the abstraction is stable or likely to diverge later
  (if divergence is likely, note this — sometimes duplication is the right choice)
