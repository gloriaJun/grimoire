# Review Protocol

Standard review workflow for planning artifacts: PRD, TRD, and feature breakdown.
Loaded inline by plan.md and design.md at review time.

The calling step file specifies the **artifact**.

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

**Architecture (architecture.md):**
```
[ ] Tech Stack section exists (TODO items explicitly marked)
[ ] Features checklist exists (minimum 1 feature)
[ ] UI project: Screen List + Navigation Flow present
[ ] Open Questions section exists (may be empty)
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
   - **Architecture**: rationale for technology choices, missing edge cases, TODO items that should be resolved, testing strategy fit, feature dependency completeness
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

User approval ends the review — no additional automated review pass runs on planning artifacts.
Code produced at build time is reviewed separately (`steps/build/cross-review.md`).
