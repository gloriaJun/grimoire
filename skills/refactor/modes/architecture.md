# Architecture Mode

Guide for analyzing and refactoring code structure toward clean architecture principles.
The goal is clear layer separation with unidirectional dependencies — higher layers
depend on lower layers, never the reverse.

## Layer Model (typical frontend app)

```
UI (Components/Pages)
  ↓ depends on
Hooks / State Management
  ↓ depends on
Services / API Layer
  ↓ depends on
Models / Types / Utilities
```

Violations occur when arrows point upward or skip layers.

## What to Analyze

Focus on checklist items A1–A7 from `references/analysis-checklist.md`.

### Priority order
1. **Circular dependencies** (A4) — break these first, other fixes may depend on it
2. **Reverse imports** (A3) — structural violation, blocks clean refactoring
3. **Direct data access in UI** (A1) — most impactful for separation
4. **Business logic in components** (A2) — improves testability
5. **God objects** (A5), **missing abstractions** (A6), **tight coupling** (A7)

## Refactoring Strategies

### Extract Service Layer
When components directly call APIs:
- Create a service module that encapsulates API calls
- Service returns typed data, component consumes it
- Enables mocking for tests, centralizes error handling

### Extract Custom Hooks
When components contain state + effect logic that could be reused:
- Move state management and side effects into a custom hook
- Component becomes a pure renderer of hook output
- Hook can be tested independently

### Split by Responsibility
When a module does too many things:
- Identify distinct responsibilities (data fetching, transformation, rendering, validation)
- Each responsibility becomes its own module or function
- Connected via explicit interfaces

## Context for Proposals

When proposing architecture changes, explain:
- Which layer boundary is being violated and why it matters
- How the refactoring restores proper dependency direction
- What becomes easier after the change (testing, reuse, modification)
