# Performance Mode

Guide for identifying performance issues through static code analysis.
This is not runtime profiling — it catches common patterns that are known to
cause performance problems, especially in React/TypeScript applications.

## Scope and Limitations

This mode detects structural performance anti-patterns visible in code.
It does NOT replace:
- Runtime profiling (Chrome DevTools, React Profiler)
- Load testing or benchmarking
- Network performance analysis

If deeper investigation is needed, recommend appropriate runtime tools.

## What to Analyze

Focus on checklist items P1–P7 from `references/analysis-checklist.md`.

### Priority order
1. **Memory leaks** (P3) — can crash the application over time
2. **N+1 data access** (P2) — scales poorly, often causes visible slowness
3. **Unnecessary re-renders** (P1) — most common React performance issue
4. **Inefficient algorithms** (P5) — O(n^2) becomes visible at scale
5. **Bundle bloat** (P4) — affects initial load time
6. **Missing memoization** (P6), **unnecessary data loading** (P7)

## Refactoring Strategies

### Fix Re-render Patterns
Common React re-render causes and fixes:

| Cause | Fix |
|-------|-----|
| Inline object/array in JSX props | Extract to `useMemo` or module-level constant |
| Inline arrow function in JSX props | Extract to `useCallback` or named handler |
| Missing dependency array in useEffect | Add correct dependencies |
| Parent re-render cascading to children | `React.memo` on pure child components |
| Context value changing every render | Memoize context value, split contexts by update frequency |

### Eliminate N+1 Patterns
When API calls or DB queries happen inside loops:
- Batch into a single request with an array parameter
- Use DataLoader pattern for GraphQL resolvers
- Prefetch related data in the parent query

### Prevent Memory Leaks
Ensure every subscription has a matching cleanup:

```
useEffect(() => {
  const controller = new AbortController();
  fetchData({ signal: controller.signal });
  return () => controller.abort();  // cleanup
}, []);
```

Check for: `addEventListener` without `removeEventListener`, `setInterval` without
`clearInterval`, observable subscriptions without `unsubscribe`.

### Reduce Bundle Size
- Replace full library imports with specific imports
- Check if a lighter alternative exists (e.g., `date-fns` over `moment`)
- Lazy-load heavy components with `React.lazy` + `Suspense`
- Audit with `npx webpack-bundle-analyzer` or equivalent

## Context for Proposals

When proposing performance fixes, explain:
- What the observable impact would be (slow renders, memory growth, large bundle)
- How confident we are this is actually a problem (pattern-based vs measured)
- Whether the fix adds complexity — performance optimizations should justify their cost
