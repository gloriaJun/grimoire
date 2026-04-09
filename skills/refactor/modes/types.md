# Types Mode

Guide for improving TypeScript type coverage. The goal is to make the type system
work as documentation and a safety net — catching errors at compile time rather
than runtime.

## What to Analyze

Focus on checklist items T1–T6 from `references/analysis-checklist.md`.

### Priority order
1. **Explicit `any`** (T1) — highest signal of type debt
2. **Implicit `any`** (T2) — hidden type gaps
3. **Missing interfaces** (T4) — unlocks downstream type safety
4. **Type assertion overuse** (T3) — masking real type issues
5. **Weak generics** (T5), **non-discriminated unions** (T6)

## Refactoring Strategies

### Function Signature First
Start with the public API — function parameters and return types. These have the
highest leverage because they propagate type safety to all callers.

```
Before: function processUser(data) { ... }
After:  function processUser(data: UserInput): ProcessedUser { ... }
```

### Interface at Boundaries
Define types where data crosses boundaries:
- API response types (from backend contracts or OpenAPI specs)
- Props interfaces for components
- Store/state shape types
- Event handler signatures

### Replace `any` Progressively
Not every `any` needs a full type immediately. Use a graduated approach:
1. `unknown` — safer than `any`, forces explicit narrowing
2. Union types — when a few known shapes exist
3. Full interface — when the shape is stable and well-understood

### Type Guards over Assertions
When the code uses `as Type` to force a type:
- Ask whether the runtime value is actually guaranteed to match
- If yes, a type guard function makes the guarantee explicit and reusable
- If no, the assertion is hiding a bug — fix the data flow instead

## Context for Proposals

When proposing type additions, explain:
- What runtime error this type would have caught
- Whether the type comes from an existing source (API schema, library types)
- If the change is additive (safe) vs corrective (may reveal existing bugs)
