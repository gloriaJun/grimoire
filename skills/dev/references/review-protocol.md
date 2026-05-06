# Review Protocol

Standard review workflow for planning artifacts: PRD, TRD, and feature breakdown.
Loaded inline by plan.md, design.md, and breakdown.md at review time.

The calling step file specifies the **artifact** and **Codex focus**.

---

## 0. Stage 0: 구조적 사전 체크

Mode Selection 전에 실행. orchestrator inline — 위임 없음.
아티팩트 유형에 맞는 항목을 평가한다.

**PRD:**
```
[ ] 문제/배경 서술 존재
[ ] 모든 기능 요구사항에 AC(수락 기준) 존재
[ ] Non-goals 섹션 존재 (비어 있어도 명시되면 통과)
[ ] MVP 범위 경계 정의
[ ] 미해결 항목에 TBD:[담당자 또는 "미정"] 표기
```

**TRD:**
```
[ ] 테스팅 전략 테이블 존재 (framework / configFile / command)
[ ] 핵심 아키텍처 결정에 ≥2 대안 기록 (또는 "단일 선택지 이유" 명시)
[ ] 외부 의존성에 fallback 또는 "없음" 명시
```

**Feature Breakdown:**
```
[ ] 모든 피처에 Testing Approach 섹션 존재
[ ] 모든 피처에 AC 1개 이상 존재
[ ] 의존성 있는 피처가 선행 피처보다 뒤에 정렬
```

미체크 항목 → 즉시 인라인 수정 후 Mode Selection으로 진행.
전체 체크 → 즉시 Mode Selection으로 진행.

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
