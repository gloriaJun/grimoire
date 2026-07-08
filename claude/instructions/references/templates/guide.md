# Guide Template

Applies to procedural guide documents (how-to, onboarding, migration guides).

## Skeleton

```markdown
# {goal-bearing title: "X → Y 전환", "X 설정"}

{the outcome this guide delivers. 1 line}
대상: {assumed reader/environment. 1 line}. 소요 시간: {N분}.

## 사전 조건

{required tools/permissions/state. bullets, with a verification command alongside each item}

## 절차

{step table: | 단계 | 명령/작업 | 결과 |. mermaid flowchart if there are branches}

## 확인

{completion check: the command to run and its expected output. 1-3 lines}

## 문제 발생 시

{1-2 common failures: symptom → action, 1 line each. remove the section if none}
```
