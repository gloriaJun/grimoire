# Complete: 작업 마무리

모든 기능이 끝났을 때 실행한다. 흩어진 작업 기록을 **하나의 `<task>-log.md`로 압축**하고,
과정 파일(state·history·brainstorm)을 정리한다. PRD·architecture는 참고 문서로 남긴다.

## Process

### 1. 참고 문서 최신화

PRD와 architecture.md를 빌드 중 바뀐 내용에 맞춰 마지막으로 손본다 (이 둘은 보존 대상이므로 최신 상태로 둔다).

### 2. `<task>-log.md` 생성

작업 폴더에 `<task-name>-log.md`를 만든다. 아래 고정 포맷을 따른다:

```markdown
---
created: <state.md의 created>
completed: YYYY-MM-DD
type: memory/project
task-name: <task-name>
repo: <repo>
status: completed
tags:
  - claude-memory
  - project
  - dev-workflow
---

# <task-name> 작업 로그

## 한 줄 요약
<무엇을 만들었고 결과가 어땠는지 한 문장>

## 결과
- 구현한 것: <## Features 표의 기능 목록 + 상태>
- 변경된 주요 파일: <핵심 파일 몇 개>
- 커밋 / PR: <해시·링크 (있으면)>

## 과정에서 고민한 것
<history.md 결정·블로커 기록에서 추린 결정·트러블슈팅 + 아직 남은 의문>
- PRD/architecture의 미해결 항목(Open Questions·TBD) 최대 3개
- 결정·블로커 기록 중 status: open 항목
- 빌드에서 검증되지 않은 가정

## 배운 것
<다음 작업에 도움이 될 점 — 위임 없이 인라인으로 정리>
- 기능 크기 추정이 실제 공수와 맞았는가
- mini-design 합격 기준(AC) 중 테스트하기 어려웠던 항목
- 빌드 중 새로 드러났지만 mini-design에 없던 요구사항
- 다음에는 무엇을 바꿀까

## 참고 문서
- PRD-<task>.md
- architecture.md
- wireframe.html  (있으면)
```

> `## 과정에서 고민한 것`은 기존 history.md의 결정·블로커 기록을, `## 배운 것`은 기존
> "Wonder & Reflect" 회고를 흡수한 자리다. 따로 단계를 두지 않고 여기서 한 번에 정리한다.

### 3. 과정 파일 정리 (go-ahead 게이트)

**`<task>-log.md`를 쓴 직후에는 삭제를 묻지 않는다.** 사용자가 산출물을 검토할 시간이 필요하다.

삭제 확인은 사용자의 명시적 진행 신호가 있을 때만 시작한다 — "다음 작업 진행해줘",
"검토 끝났어", "정리해줘" 등. 신호 전까지는 과정 파일을 그대로 두고 4단계(요약 보고)로 넘어간다.

진행 신호를 받으면 **삭제 전 1회 확인**:

```
작업 기록을 <task>-log.md 하나로 합쳤습니다.
아래 과정 파일을 삭제할까요? (PRD·architecture·wireframe은 보존합니다)

  - state.md
  - history.md
  - brainstorm.md

> Y 삭제 / n 보존
```

- Y: 위 3개 삭제. PRD·architecture·wireframe·`<task>-log.md`는 남긴다.
- n: 그대로 두고 다음 단계 진행.

작업 폴더에 위 외의 임시 파일이 더 있으면 같은 확인 절차로 삭제 여부를 묻는다.
같은 세션에서 진행 신호 없이 작업이 끝나면, 다음 세션의 `/dev status`가 미정리 파일을 안내한다.

### 4. 요약 보고

화면에 간단히 보고한다:
- 만든 것 (기능 목록)
- 바뀐 파일
- 후속으로 할 일 (있으면)

### 5. insight (선택)

grimoire 설정 개선 제안을 받고 싶을 때만 실행한다. 회고와 목적이 다르다(작업 회고가 아니라
도구·지침 개선 제안). 건너뛰어도 된다.

- 실행 시: `~/.claude/skills/insight/SKILL.md`를 Read로 로드
- `Agent(subagent_type: "Explore")`로 디스패치 — 프롬프트에 insight 지침 + 작업 컨텍스트
  (`task-name`, 만든 것 요약, 핵심 결정, 산출물 경로) 전달. 에이전트는 grimoire 파일을 직접 읽는다.

---

## Session Handoff

### 상태 갱신

MEMORY.md:
- 포인터를 `## Active Dev Tasks` → `## Completed Dev Tasks`로 이동
- 포인터 대상을 `state.md`가 아닌 `<task>-log.md`로 변경:
  ```
  - [<task-name>](YYYY-MM-DD-<task-name>/<task-name>-log.md) — <repo> / 완료 YYYY-MM-DD
  ```

state.md를 삭제했으므로 더 이상 갱신할 메모리 파일이 없다. 이후 현황 조회(`/dev status`)는
`<task>-log.md` frontmatter에서 완료 정보를 읽는다.

### 완료 메시지

```
✅ 작업 완료 — <task-name>

작업 기록: <task>-log.md (결과 · 고민 · 배운 점)
보존 문서: PRD · architecture(· wireframe)

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
다음에 할 수 있는 것:
  /dev retro  — 회고 + 배운 점을 Obsidian 노트로 발행
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```
