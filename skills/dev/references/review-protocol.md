# Review Protocol

Standard review workflow for planning artifacts: PRD, TRD, and feature breakdown.
Loaded inline by plan.md, design.md, and breakdown.md at review time.

The calling step file specifies the **artifact** and **Codex focus**.

---

## 0. Stage 0: Structural Pre-Check

Run before Mode Selection. Orchestrator inline — no delegation.
Evaluate checklist items matching the artifact type.

**PRD:**
```
[ ] Problem / background statement present
[ ] Acceptance criteria present for every functional requirement
[ ] Non-goals section present (may be empty, but must be explicitly stated)
[ ] MVP scope boundary defined
[ ] Open items marked TBD:[owner or "TBD"]
```

**TRD:**
```
[ ] Testing strategy table present (framework / configFile / command)
[ ] Each key architecture decision has ≥2 alternatives recorded (or a stated reason for a single option)
[ ] External dependencies have fallback or "none" stated
```

**Feature Breakdown:**
```
[ ] Testing Approach section present for every feature
[ ] At least one AC present for every feature
[ ] Dependent features ordered after their prerequisites
```

Unchecked items → fix inline immediately, then proceed to Stage 0.5.
All checked → proceed to Stage 0.5.

---

## 0.5. Grill Phase (optional)

Run after structural pre-check, before Mode Selection. Orchestrator inline — no delegation.

Ask the user:

```
Run grill review?
Surfaces gaps in decisions one question at a time. (y/n)
```

**n → proceed to Stage 1.**

**y → execute the following:**

1. Read artifact contents.
2. Determine question focus by artifact type:
   - **PRD**: problem definition specificity, missing AC coverage, ambiguous non-goal boundaries, MVP scope rationale
   - **TRD**: rationale for technology choices, missing edge cases, external dependency risks, testing strategy fit
   - **Feature Breakdown**: dependency completeness, session sizing rationale, missing features
3. Extract a list of decision points and assumptions (internal only — not shown to user).
4. Ask one question at a time:
   - If answerable from the codebase → search via Explore and cite findings in the recommended answer.
   - Otherwise → provide a recommended answer only.
   - Format: question + `(Recommended: <answer>. Reason: <one-line rationale>)`
5. If the user's answer differs from the artifact → propose artifact update (apply after Stage 1).
6. All decision points resolved → proceed to Stage 1.

---

## 1. Mode Selection

Ask the user before proceeding:

```
Review mode:
  1) Plannotator visual review (default)
  2) Inline text review
  3) Skip

> Enter number
```

---

## 2. Review Execution

**Mode 1 — Plannotator:**
1. Check `plannotator` command availability.
2. If available: run `plannotator` on the artifact file.
3. If unavailable or launch fails:
   ```
   [WARN] Plannotator CLI unavailable — falling back to inline text review.
   Continue? (Y/n)
   ```
   - `n` → stay; let user choose retry or skip
   - `Y` (default) → fall back to inline text

**Mode 2 — Inline:** display artifact contents and prompt for feedback inline.

**Mode 3 — Skip:** proceed without review.

---

## 3. User Approval

- Wait for explicit approval.
- If revision requested: re-invoke the artifact-generating agent. Do NOT advance step.
- Repeat until approved.

---

## 4. Codex Cross-Review

Run automatically after user approval. No additional prompt needed.

**Invocation priority (try in order):**
1. `codex-plugin-cc`: `/codex:rescue "<codex-focus>: <artifact-path>"`
2. Codex CLI: `codex exec -c model_reasoning_effort="low" --read <artifact-path> "<codex-focus>"`
3. `code-reviewer` agent (model: sonnet) — if Codex unavailable; record fallback reason in `_state.json` history.

### Severity-Based Discussion

Classify each finding before presenting:

| Severity | Definition | Handling |
|----------|-----------|---------|
| **Critical** | Missing requirement, broken dependency, incorrect constraint | Must discuss with user — block advancement until resolved |
| **Major** | Suboptimal design, missing edge case, ambiguous spec | Recommend; user decides |
| **Advisory** | Style, naming, minor improvement | List in summary only; no discussion needed |

Present findings grouped by severity. Lead with Criticals, then Majors. Advisories can be listed as a bullet summary at the end.

### Re-Approval Gate

| Applied changes | Re-approval required? |
|----------------|----------------------|
| Critical finding(s) incorporated | Yes — re-confirm user approval |
| Major finding(s) only | No — advance without re-approval |
| Advisory only or no changes | No |
