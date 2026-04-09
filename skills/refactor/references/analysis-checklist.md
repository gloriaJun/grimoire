# Analysis Checklist

Unified checklist for Step 1 analysis. Load only the sections matching the active mode(s).
In auto mode, run all sections and prioritize by severity.

## Architecture

| ID | Pattern | Severity | What to look for |
|----|---------|----------|------------------|
| A1 | Direct data access in UI | High | Components calling `fetch()`, `axios`, DB queries directly |
| A2 | Business logic in components | High | Conditional logic, calculations, transformations inside render/component |
| A3 | Reverse layer imports | High | Service/util importing from component; lower layer depending on higher |
| A4 | Circular dependencies | High | Module A imports B, B imports A (directly or transitively) |
| A5 | God object / fat module | Medium | File > 300 lines, class/function with 5+ responsibilities |
| A6 | Missing abstraction layer | Medium | Same external API called from 3+ unrelated locations |
| A7 | Tight coupling | Medium | Concrete implementations passed instead of interfaces/abstractions |

### Suggested refactoring patterns
- A1, A2 → Extract to service layer, custom hooks, or utility modules
- A3, A4 → Restructure imports, introduce interface/barrel files
- A5 → Split by responsibility (single-responsibility principle)
- A6 → Create shared service or adapter
- A7 → Dependency injection, interface extraction

## Types

| ID | Pattern | Severity | What to look for |
|----|---------|----------|------------------|
| T1 | Explicit `any` usage | High | `any` type annotation in parameters, return types, variables |
| T2 | Implicit `any` | High | Function parameters without type annotation (noImplicitAny off) |
| T3 | Type assertion overuse | Medium | Frequent `as Type` casts, especially `as any` |
| T4 | Missing interface/type | Medium | Object literals passed around without a named type definition |
| T5 | Weak generic usage | Low | `Array<any>`, `Record<string, any>` where specific types exist |
| T6 | Non-discriminated unions | Low | Union types without a discriminant field for narrowing |

### Suggested refactoring patterns
- T1, T2 → Add explicit type annotations; start from function signatures
- T3 → Replace assertions with type guards or proper generics
- T4 → Define interfaces at module boundaries
- T5 → Replace with specific generic parameters
- T6 → Add discriminant property (`kind`, `type`, `status`)

## Deduplication

| ID | Pattern | Severity | What to look for |
|----|---------|----------|------------------|
| D1 | Copy-paste code blocks | High | Identical or near-identical code in 2+ locations |
| D2 | Cloned components | Medium | Components with same structure, only props/data differ |
| D3 | Scattered utilities | Medium | Same helper function reimplemented across files |
| D4 | Repeated conditionals | Medium | Same if/switch pattern in multiple places |
| D5 | Magic numbers/strings | Low | Hardcoded values repeated without named constants |

### Suggested refactoring patterns
- D1 → Extract shared function/utility
- D2 → Generalize component with props/generics
- D3 → Consolidate into single utility module
- D4 → Extract strategy pattern, lookup table, or shared predicate
- D5 → Create constants file or enum

## Naming

| ID | Pattern | Severity | What to look for |
|----|---------|----------|------------------|
| N1 | Unclear abbreviations | Medium | Variable/function names like `tmp`, `data`, `info`, `val`, `res` |
| N2 | Name-behavior mismatch | High | Function name implies one thing but does another |
| N3 | SRP violation signal | Medium | Function > 40 lines or doing 3+ distinct things |
| N4 | Boolean naming | Low | Boolean variables missing `is/has/should/can` prefix |
| N5 | Inconsistent conventions | Low | Mixed camelCase/snake_case, inconsistent plural/singular |

### Suggested refactoring patterns
- N1 → Rename with descriptive, intention-revealing names
- N2 → Rename to match actual behavior, or split if doing too much
- N3 → Extract sub-functions with clear names
- N4 → Add semantic prefix (`isLoading`, `hasPermission`, `shouldRetry`)
- N5 → Align to project convention (check existing linter/prettier config)

## Performance

| ID | Pattern | Severity | What to look for |
|----|---------|----------|------------------|
| P1 | Unnecessary re-renders | High | Missing deps in useEffect/useMemo/useCallback; inline objects/functions in JSX props |
| P2 | N+1 data access | High | API calls or DB queries inside loops |
| P3 | Memory leaks | High | Event listeners without cleanup; uncleared intervals/timeouts; unsubscribed observables |
| P4 | Bundle bloat | Medium | Full library imports (`import _ from 'lodash'`); large deps for small tasks |
| P5 | Inefficient algorithms | Medium | Nested loops on large collections; repeated array scans; O(n^2) where O(n) is possible |
| P6 | Missing memoization | Low | Expensive computations re-running on every render without useMemo |
| P7 | Unnecessary data loading | Low | Fetching full objects when only a subset of fields is needed |

### Suggested refactoring patterns
- P1 → Stabilize references with useMemo/useCallback; extract constants outside component
- P2 → Batch requests, use DataLoader pattern, or restructure query
- P3 → Add cleanup in useEffect return; use AbortController for fetch
- P4 → Tree-shakable imports (`import { debounce } from 'lodash-es'`); evaluate lighter alternatives
- P5 → Use Map/Set for lookups; reduce nested iterations; consider indexing
- P6 → Wrap expensive computations in useMemo with proper dependencies
- P7 → Select specific fields in queries; use GraphQL fragments or API field selection
