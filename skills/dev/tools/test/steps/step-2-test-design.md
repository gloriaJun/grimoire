# Step 2: Test Case Design

Goal: Design a comprehensive test plan organized by category before writing any code.

## Input

From Step 1:
- Target file path(s) and characteristics
- Selected approach (TDD / Storybook TDD / Test-After)
- Test framework and config
- Existing test gap analysis

## Process by Approach

### TDD Approach

Design tests that define the contract BEFORE implementation:

1. Identify the public interface (function signature, class API, module exports)
2. For each interface method/function, design test cases by category:
   - What should it accept? What should it return? What should it throw?
3. Order tests from simplest to most complex (guides incremental implementation)

### Storybook TDD Approach

Design stories that define component behavior BEFORE implementation:

1. Identify component variants (props, states, sizes, themes)
2. Design stories by category:
   - **Default**: base rendering
   - **Variants**: each prop combination
   - **States**: loading, error, empty, disabled, active
   - **Edge cases**: long text, missing data, i18n
   - **Interactions**: click, input, hover, keyboard (play functions)
   - **Responsive**: viewport breakpoints
3. For logic-heavy components, also design unit tests for hooks/utils

### Test-After Approach

Design tests that capture existing behavior:

1. Read the implementation to understand current behavior
2. Identify all code paths (branches, loops, early returns)
3. Design tests that document each path as a behavioral contract
4. Flag any discovered bugs as separate test cases (expected to fail)

## Test Case Design Template

For each category, list cases in this format:

```
## <TargetName> Test Plan

### Normal Cases
- should <expected behavior> when <typical condition>
- should <expected behavior> when <another typical condition>

### Edge Cases
- should handle <empty/null/undefined input>
- should handle <single element / minimum viable input>
- should handle <unicode / special characters>
- should handle <concurrent access> (if applicable)

### Error Handling
- should throw <ErrorType> when <invalid input>
- should return <fallback> when <service unavailable>
- should <behavior> when <timeout / permission denied>

### Boundary Values
- should <behavior> at <minimum value>
- should <behavior> at <maximum value>
- should <behavior> at <boundary ± 1>
```

See `references/test-patterns.md` for detailed patterns per code type.

## Grouping Strategy

Cases that share setup or context should be grouped under a nested describe:

```
describe('<TargetName>')
  describe('<method or feature>')
    describe('Normal Cases')
      it('should ...')
    describe('Edge Cases')
      it('should ...')
    describe('Error Handling')
      it('should ...')
    describe('Boundary Values')
      it('should ...')
```

## User Confirmation

Present the test plan to the user before proceeding to generation:

```
Test plan ready:
- Normal cases: N
- Edge cases: N
- Error handling: N
- Boundary values: N
- Total: N tests

Let me know if you want to add or remove any cases.
Type "done" or "confirm" when ready to proceed.
```

## Output

Pass to Step 3:
- Complete test plan (case list with categories)
- Grouping structure (describe/it hierarchy)
- Approach-specific notes (TDD order, Story variants, etc.)
