# Test Patterns by Code Type

Reference for common test patterns. Used by Step 2 (Test Design) to select
relevant cases based on the target code type.

---

## Pure Function

```
Normal:  typical inputs → expected outputs
Edge:    null, undefined, empty string, empty array, NaN, Infinity
Error:   wrong types, out-of-range values
Boundary: 0, -1, MAX_SAFE_INTEGER, empty vs single-element
```

## Class / Module

```
Normal:  construct → method calls → expected state
Edge:    construct with edge params, call methods in unusual order
Error:   invalid constructor args, method calls on disposed instance
Boundary: max capacity, concurrent method calls
Lifecycle: init → use → dispose (resource cleanup verification)
```

## Async / Promise-based

```
Normal:  resolve path → expected value
Edge:    empty response, slow response (verify no timeout issues)
Error:   rejection, network error, timeout, abort signal
Boundary: concurrent calls, rapid sequential calls
Mock:    external service responses (success, error, partial)
```

## API Endpoint / Route Handler

```
Normal:  valid request → correct status + body
Edge:    empty body, missing optional fields, extra fields
Error:   401 (unauthenticated), 403 (unauthorized), 404, 422 (validation), 500
Boundary: max payload size, query param limits, pagination bounds
Security: injection attempts, auth token expiry, CORS
```

## React / Vue Component

```
Normal:  render with required props → expected output
Edge:    missing optional props, extreme prop values
Error:   error boundary trigger, failed data fetch
State:   loading, empty, populated, error, disabled
Interaction: click, type, submit, keyboard navigation
Accessibility: role, aria attributes, focus management
```

## React Hook

```
Normal:  initial state, state after action
Edge:    rapid re-renders, unmount during async
Error:   error state handling, cleanup on unmount
Boundary: dependency array changes, stale closure detection
```

## Storybook Story Patterns

```
Default:      base props, no interaction
Variants:     size (sm/md/lg), color, type, layout
States:       loading, error, empty, disabled, active, hover, focus
Content:      short text, long text, no text, unicode, RTL
Responsive:   mobile (375px), tablet (768px), desktop (1280px)
Interaction:  click, input, drag, keyboard (via play function)
Composition:  with parent context, with sibling components
Dark mode:    if theme system exists
```

---

## Category Checklist (universal)

Use this as a minimum checklist regardless of code type:

| Category | Minimum | Question to ask |
|----------|---------|-----------------|
| Normal | 2+ cases | Does the happy path work for typical inputs? |
| Edge | 2+ cases | What happens with empty, null, or minimal input? |
| Error | 1+ case | What should happen when things go wrong? |
| Boundary | 1+ case | What are the limits, and what happens at ±1? |
