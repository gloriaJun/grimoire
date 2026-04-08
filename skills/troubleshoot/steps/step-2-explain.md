# Step 2: User-Friendly Explanation

Goal: Explain the root cause so that anyone on the team — not just the developer
who wrote the code — can understand what went wrong and why.

## Input

From Step 1:
- Root cause (What / Where / Why / Impact)

## Process

### 2a. Plain-Language Explanation

Rewrite the root cause without jargon. Focus on the "why" — what sequence of
events led to this failure. Use analogies when they genuinely help, but do not
force them.

**Good**: "The API returns user data before the database query finishes, so
the response contains stale or empty values."

**Bad**: "A race condition occurs in the asynchronous execution context of the
data access layer." (too technical for this step)

### 2b. Code Flow Visualization

Show a simplified call chain that traces how the error propagates:

```
[Trigger] → [Component A] → [Component B] → [Failure point] → [Observed error]
```

Keep it to 3-5 nodes. This is a communication aid, not a full architecture diagram.

### 2c. Recurrence Conditions

Explain when this error will happen again if left unfixed:
- What user actions or system states trigger it?
- Is it deterministic or intermittent?
- Are there related scenarios that could produce similar failures?

## Output

Present all three sections together. This step has no user confirmation gate —
proceed directly to Step 3.
