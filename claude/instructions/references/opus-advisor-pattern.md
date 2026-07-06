# Opus Advisor Pattern

Opus acts as a Strategic Advisor: **judgment and direction only**.
Never delegate execution work (writing documents, code, or reviews) to Opus.

## Direction Brief Format

Standard output format Opus returns (user-facing, stays Korean):

```markdown
## Direction Brief

**Decision**: [선택한 접근법 한 줄 요약]

**Rationale**: [핵심 이유 2-3줄]

**Key Trade-offs Accepted**:
- [포기하는 것]: [이유]
- [얻는 것]: [이유]

**Execution Guidance**:
- [구체적 실행 지침 3-5개]
- 아키텍처 패턴, 데이터 모델링 방향 등

**Red Lines** (하지 말 것):
- [피해야 할 접근법]
```

## Invocation Checklist

Propose the Opus advisor only when **all** of the following hold:

- [ ] Architecture decision involving 3+ components
- [ ] Sonnet has already analyzed at least 2 options
- [ ] Trade-offs clearly conflict (no option dominates)
- [ ] The decision has long-term architectural impact

If any item is unmet, Sonnet decides directly.

## Invocation Process

### 1. User Approval

```
이 아키텍처 결정에 Opus의 판단이 필요합니다.
- 판단 대상: [구체적 결정 설명]
- Opus는 방향만 제시하고, 실제 작업은 Sonnet이 수행합니다.
Opus 호출을 승인하시겠습니까? (Y/n)
```

### 2. Composing the Opus Prompt

| Item | Include | Exclude |
|------|---------|---------|
| Requirements summary | O | full PRD text |
| Options Sonnet analyzed | O | unanalyzed options |
| Pros/cons per option | O | secondary details |
| A specific decision question | O | open-ended questions ("어떻게 할까요?") |
| Request for Direction Brief format | O | document/code writing requests |

Always end the prompt with:
> "Direction Brief 형식으로만 응답해주세요. 문서나 코드를 작성하지 마세요."

### 3. After Receiving the Direction Brief

1. Extract the core decision and execution guidance from the direction
2. Sonnet performs the actual work based on it (TRD writing, design, etc.)
3. Mark deliverables with "Architecture direction by Opus advisor"

## Anti-patterns

| Anti-pattern | Correct approach |
|-------------|------------------|
| Asking Opus to write a full TRD | Opus gives direction only; Sonnet writes the TRD |
| Delegating code review to Opus | Codex or Sonnet reviews |
| Calling Opus without option analysis | Sonnet analyzes 2+ options first, then calls |
| Using Opus for single-component design | Sonnet decides directly |
| Open-ended questions ("어떻게 설계할까요?") | Specific questions ("A vs B 중 어떤 방향이 적합한가?") |
| Ignoring Opus direction and re-calling | Adjust direction after consulting the user |
