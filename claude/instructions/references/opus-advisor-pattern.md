# Opus Advisor Pattern

Opus는 Strategic Advisor로서 **판단과 방향 제시만** 수행한다.
문서 작성, 코드 작성, 리뷰 등 실행 작업은 절대 Opus에게 위임하지 않는다.

## Direction Brief 형식

Opus가 반환하는 표준 출력 형식:

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

## 호출 판단 체크리스트

다음 조건이 **모두** 충족될 때만 Opus advisor를 제안한다:

- [ ] 3개 이상 컴포넌트가 얽힌 아키텍처 결정
- [ ] Sonnet이 최소 2개 선택지를 이미 분석 완료
- [ ] 선택지 간 trade-off가 명확히 상충 (하나가 압도적이지 않음)
- [ ] 결정이 장기적 아키텍처 영향을 미침

하나라도 미충족이면 Sonnet이 직접 판단한다.

## 호출 프로세스

### 1. 사용자 동의

```
이 아키텍처 결정에 Opus의 판단이 필요합니다.
- 판단 대상: [구체적 결정 설명]
- Opus는 방향만 제시하고, 실제 작업은 Sonnet이 수행합니다.
Opus 호출을 승인하시겠습니까? (Y/n)
```

### 2. Opus 프롬프트 구성

Opus에게 전달하는 프롬프트에 포함할 내용:

| 항목 | 포함 | 제외 |
|------|------|------|
| 요구사항 요약 | O | 전체 PRD 원문 |
| Sonnet이 분석한 선택지 | O | 미분석 선택지 |
| 각 선택지 장단점 | O | 부차적 세부사항 |
| 구체적 판단 질문 | O | 열린 질문 ("어떻게 할까요?") |
| Direction Brief 형식 요청 | O | 문서/코드 작성 요청 |

프롬프트 말미에 반드시 명시:
> "Direction Brief 형식으로만 응답해주세요. 문서나 코드를 작성하지 마세요."

### 3. Direction Brief 수신 후

1. Direction에서 핵심 결정과 실행 지침 추출
2. Sonnet이 direction 기반으로 실제 작업 수행 (TRD 작성, 설계 등)
3. 산출물에 "Architecture direction by Opus advisor" 표기

## Anti-patterns

| Anti-pattern | 올바른 접근 |
|-------------|------------|
| Opus에게 TRD 전체 작성 요청 | Opus는 방향만, Sonnet이 TRD 작성 |
| Opus에게 코드 리뷰 위임 | Codex 또는 Sonnet이 리뷰 |
| 선택지 분석 없이 Opus 호출 | Sonnet이 먼저 2+ 선택지 분석 후 호출 |
| 단일 컴포넌트 설계에 Opus 사용 | Sonnet이 직접 판단 |
| "어떻게 설계할까요?" 식 열린 질문 | "A vs B 중 어떤 방향이 적합한가?" 식 구체적 질문 |
| Opus의 direction을 무시하고 재호출 | 사용자와 상의 후 방향 조정 |
