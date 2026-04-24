# Step 3: Test Code Generation

Goal: Generate test code from the designed test plan.

## Input

From Step 2:
- Complete test plan with categories and grouping
- Selected approach and framework
- Target code path and characteristics

## Generation Principles

### Universal Rules

- **AAA pattern**: Arrange → Act → Assert (clearly separated with blank lines)
- **One logical assertion per test**: related assertions on the same subject are fine, but don't test multiple behaviors in one `it` block
- **Descriptive test names**: `should return empty array when input is null` not `test1`
- **Meaningful test data**: `"valid-username"` not `"test"`, named constants over magic numbers
- **Category grouping**: maintain the describe/it hierarchy from Step 2
- **No test interdependence**: each test must be runnable in isolation
- **Match project conventions**: follow existing test file patterns (naming, location, imports)

### TDD-Specific Rules

Generate tests in order from simplest to most complex:

1. Start with the simplest normal case (defines the basic contract)
2. Add normal case variations
3. Add edge cases (reveals interface decisions)
4. Add error handling (defines error contract)
5. Add boundary values (stress-tests the design)

For each test, add a comment indicating the TDD phase:

```typescript
// RED: this test should fail until <feature> is implemented
it('should return the sum of two numbers', () => {
  expect(add(1, 2)).toBe(3);
});
```

### Storybook TDD-Specific Rules

Generate stories following CSF3 (Component Story Format 3):

```typescript
// ComponentName.stories.tsx
import type { Meta, StoryObj } from '@storybook/react';
import { ComponentName } from './ComponentName';

const meta: Meta<typeof ComponentName> = {
  component: ComponentName,
  title: 'Components/ComponentName',
};
export default meta;
type Story = StoryObj<typeof ComponentName>;

// Default state
export const Default: Story = {
  args: { /* default props */ },
};

// Variants
export const Small: Story = {
  args: { size: 'small' },
};

// States
export const Loading: Story = {
  args: { isLoading: true },
};

// Interaction test
export const WithClick: Story = {
  play: async ({ canvasElement }) => {
    const canvas = within(canvasElement);
    await userEvent.click(canvas.getByRole('button'));
    await expect(canvas.getByText('clicked')).toBeInTheDocument();
  },
};
```

Additionally generate unit tests for:
- Custom hooks used by the component
- Utility functions within the component module
- Complex conditional rendering logic

### Test-After-Specific Rules

- Test observed behavior, not implementation details
- Use the actual function signatures (no mocking internal state)
- Mark discovered bugs with `it.todo` or `it.skip` with explanation:

```typescript
// BUG: discovered during test-after analysis — returns undefined instead of []
it.skip('should return empty array when filter matches nothing', () => {
  expect(filterItems([], 'query')).toEqual([]);
});
```

## Mock Strategy

- **Prefer real implementations** for internal modules
- **Mock external boundaries**: network, database, file system, timers
- **Use dependency injection** when available over module mocking
- **Collocate mocks**: define mocks near the test, not in global setup files
- **Type-safe mocks**: use framework-provided typed mock utilities

## File Output

- Test file location: follow project convention, or `__tests__/<name>.test.<ext>` next to source
- Story file location: `<ComponentName>.stories.<ext>` next to component
- One test file per source module (don't split across files unless module is huge)

## Confirm Before Writing

Present the generated test code to the user before writing to disk:

```
Test code ready:
- File: <test file path>
- Tests: N (normal: X, edge: X, error: X, boundary: X)
- Approach: <TDD / Storybook TDD / Test-After>

Review the code above. Let me know if you want any changes.
Write to file? (Y/n)
```
