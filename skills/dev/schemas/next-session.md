# next-session.md Schema

Human-readable session handoff document for the build step.
Stored in the devlog task subdirectory alongside `_state.json`.

**Scope**: build step only. Not created for other steps.

## Format

```markdown
---
updated: YYYY-MM-DD
---

# Next Session — <taskName>

## 재개 현황
- 레포: <repo-name>
- 브랜치: <branch>
- Devlog: <task-dir path>
- 진행: <N>/<total> features 완료
- 다음 피처: <next pending feature name, or "모두 완료">

## 세션 재개 방법
`/dev build` 실행 (피처 상태는 _state.json에서 자동 복구됨)

<!-- worktree 사용 중이면: -->
cd <worktreePath>
`/dev build`

## 구현 결정사항 & 아키텍처 노트
<!-- build 진행 중 알게 된 판단들: 아키텍처 결정, 트레이드오프, 비자명한 설계 이유 -->
<!-- 예: - F-01: tsup outExtension `.mjs` 회피 위해 `() => ({ js: '.js' })` 명시 -->

## 현재 코드베이스 주요 파일
<!-- 핵심 파일과 역할 — entry.md 복구 시 빠른 컨텍스트 제공용 -->
| 파일 | 역할 |
|------|------|

## 블로커 / 다음 세션 전 확인사항
<!-- 미해결 이슈, 의존성, 확인 필요한 항목 -->
<!-- 없으면 섹션 생략 가능 -->
```

## Rules

- `updated:` 는 피처 완료 시마다 갱신한다 (오늘 날짜).
- `branch` / `worktreePath` 는 frontmatter에 두지 않는다 → `_state.json`에서 관리.
- **"재개 현황"** 섹션은 **항상 존재**하고, 피처 완료 시마다 최신값으로 덮어쓴다.
  `/dev handoff` 도구가 이 섹션을 단독으로 읽어 재개 프롬프트를 생성한다.
- 완료된/잔여 Feature 테이블은 작성하지 않는다 → `_state.json.features[]`가 정식 출처.
- 섹션은 필요한 것만 포함한다 (빈 섹션은 생략). 단, "재개 현황"은 예외로 항상 포함.

## When to Create

build.md의 Session Handoff에서 첫 피처 완료 시 생성한다.
파일이 이미 존재하면 해당 섹션만 업데이트한다.

## What NOT to Include

| 항목 | 이유 |
|------|------|
| 완료된/잔여 Feature 테이블 | `_state.json.features[]`와 중복 |
| `branch:` frontmatter | `_state.json.branch`로 이관 |
| `worktree:` frontmatter | `_state.json.worktreePath`로 이관 |
| `repo:` frontmatter | `_state.json.taskName`에서 유추 가능 |
| Feature 진행률 | "재개 현황" 섹션에 텍스트로 요약 — 테이블 형태 불필요 |
