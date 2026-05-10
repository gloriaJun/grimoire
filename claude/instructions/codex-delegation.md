# Codex Delegation Guidelines

Common rules for delegating work to Codex CLI (`codex exec`).
Applies to all contexts: task-process features, ad-hoc tasks, skill-internal delegation.

## Reasoning Effort Policy

Agent 위임 시 기본값은 `--effort low`.

- Tier 3 Worker (Codex) 역할에 부합: bounded, scoped work (리뷰, 탐색, 기계적 리팩토링)
- 직접 CLI 호출은 `~/.codex/config.toml` 전역 설정 유지 (`medium`)
- 예외적으로 deep reasoning이 필요한 위임이면 call site에서 `--effort medium`으로 override

## Work Sizing

A single `codex exec -c model_reasoning_effort="low"` call should be scoped to a **focused, completable unit**.

| Metric | Guideline | Rationale |
|--------|-----------|-----------|
| Files changed | 5 or fewer | Codex performs best with focused scope |
| Lines changed | ~200 lines or fewer | Keeps within reliable output quality range |
| Logical scope | One concern / one behavior | Prevents partial completion and tangled changes |

These are soft guidelines, not hard limits. Use judgment — a 300-line mechanical rename
is simpler than a 100-line algorithm change.

## Pre-Delegation Assessment

Before calling `codex exec -c model_reasoning_effort="low"`, estimate the work size:

1. **List affected files** from the spec or feature description.
2. **Estimate change volume** — rough line count per file.
3. **Assess complexity** — mechanical (rename, boilerplate) vs. creative (new logic, architecture).

| Assessment result | Action |
|-------------------|--------|
| Within guidelines | Delegate as a single `codex exec -c model_reasoning_effort="low"` call |
| Exceeds guidelines but mechanical | Acceptable as single call — note the exception |
| Exceeds guidelines and complex | Split into sub-tasks before delegating |

## Sub-Task Splitting

When a unit of work exceeds Codex's effective scope, split it before delegating.

### Splitting Strategy

1. **By file group** — split along module/component boundaries.
2. **By layer** — data layer first, then logic, then UI.
3. **By dependency order** — foundational changes first, dependent changes after.

### Execution Pattern

```
Sub-task 1: codex exec -c model_reasoning_effort="low" "<prompt-1>" → verify result
Sub-task 2: codex exec -c model_reasoning_effort="low" "<prompt-2>" → verify result
...
```

- Execute sub-tasks **sequentially**, not in parallel.
- Verify each result before starting the next — later sub-tasks may depend on earlier changes.
- Include prior sub-task context in subsequent prompts so Codex understands the current state.

### Context Cap Rule (for sequential sub-tasks)

Prior context accumulates linearly and inflates Codex input tokens.
Apply a hard cap when N > 2 sub-tasks are in progress:

- Include at most the **2 most recent** sub-task summaries (not all previous ones).
- Each summary: 1–2 sentences, max 150 chars. No diffs, no full code snippets.
- Prepend a single-sentence overall goal as anchor.
- Older sub-task history is in git log — do not repeat it in the prompt.

### Prompt Template for Sequential Sub-Tasks

```
Goal: <one-sentence overall feature goal>
Context: This is sub-task N of M for feature "<name>".
Recent sub-tasks completed (last 2 only):
- Sub-task N-1: <max 150-char summary>
- Sub-task N-2: <max 150-char summary>

Current sub-task: <description>
Files to modify: <list>
Acceptance criteria: <criteria>
```

## Incomplete Result Handling

Codex may return partial or unsuccessful results. Handle gracefully:

| Situation | Action |
|-----------|--------|
| Partial completion (some files done, others not) | Commit completed work, re-delegate remaining as a new sub-task |
| Quality issues (works but messy) | Accept and address in cross-review phase |
| Outright failure or timeout | Retry once with a simplified prompt; if still fails, fall back to Claude implementation |
| Scope creep in output (extra changes) | Revert unrelated changes, keep only what was requested |

**Max retries**: 1 retry per sub-task. After that, switch executor (Codex → Claude or vice versa).

## Prompt Quality

A well-structured prompt is the primary lever for Codex delegation success.

### Required Elements

1. **What to do** — clear, specific action (not vague goals)
2. **Which files** — explicit file paths to read/modify
3. **Constraints** — what NOT to change, style/pattern to follow
4. **Acceptance criteria** — how to verify the result is correct

### Anti-Patterns

- Avoid dumping an entire PRD as the prompt — extract only the relevant AC and technical approach section. Combined extracted context must stay under ~500 lines total.
- Avoid ambiguous instructions like "improve the code" — specify exactly what to change.
- Avoid omitting file paths — Codex works better with explicit `--read` targets.
- Avoid accumulating all prior sub-task summaries — apply the Context Cap Rule above.

## Integration with Cross-Review

Codex delegation does not change the review protocol:
- Code produced by Codex is reviewed by Claude (`code-reviewer` agent).
- Code produced by Claude is reviewed by Codex.

See `@instructions/agent-guidelines.md` for the full cross-review protocol.
