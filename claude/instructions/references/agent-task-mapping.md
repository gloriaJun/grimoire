# Agent Task-to-Model Mapping

작업 유형별 최적 모델과 fallback 체인. agent-guidelines.md에서 on-demand 로드.

## Mapping Table

| Task Type | Primary | Fallback | Rationale |
|-----------|---------|----------|-----------|
| **Deep reasoning** | | | |
| 아키텍처 방향 판단 | Opus (advisor) | Sonnet | 방향만 제시, 실행은 Sonnet |
| PRD/TRD 작성 | Sonnet | - | Opus direction 반영하여 Sonnet이 작성 |
| 다단계 디버깅 | Sonnet | - | 맥락 유지 필요 |
| **Code tasks** | | | |
| Code cross-review | Codex | Sonnet | Codex 불가 시 Sonnet fallback |
| 코드베이스 탐색/패턴 검색 | Codex | Sonnet (Explore) | Codex 불가 시 Sonnet fallback |
| 테스트 코드 생성 | Codex | Sonnet | Codex 불가 시 Sonnet fallback |
| 기계적 리팩토링 | Codex | Sonnet | Codex 불가 시 Sonnet fallback |
| **Document tasks** | | | |
| 문서 경미한 편집 (오타, 포맷, 절 추가) | Haiku | Sonnet | 빠르고 저렴 |
| 템플릿 기반 문서 생성 | Haiku | Sonnet | 구조가 정해진 채우기 작업 |
| 포맷 변환 (마크다운 구조 변경, TOC 생성) | Haiku | Sonnet | 순수 텍스트 변환 |
| 일반 문서 생성 (README, changelog) | Codex | Haiku → Sonnet | 2단 fallback |
| 설계 문서 cross-review | Codex | Sonnet | Codex 불가 시 Sonnet fallback |
| **Utility tasks** | | | |
| 웹 검색/정보 수집 | Haiku | Sonnet (Explore) | 단순 조회, 요약 |
| 요약/정리 | Haiku | Sonnet | 기존 내용 압축 |

## Fallback Trigger Conditions

| Condition | Action |
|-----------|--------|
| Codex unavailable (CLI 미설치, Bash 제한, 토큰 소진) | Sonnet으로 fallback |
| Haiku output quality insufficient | Sonnet으로 escalate |
| Opus advisor declined by user | Sonnet이 자체 판단으로 진행 |
| Codex 응답 품질 불충분 | 1회 재시도 후 Sonnet으로 전환 |

## Haiku Usage Rules

Haiku는 Agent tool의 `model: haiku`로 호출한다.
Bash 권한이 불필요하므로 Codex를 사용할 수 없는 환경에서 fallback으로 활용한다.

**적합한 작업**: 구조가 명확하고 심층 추론이 불필요한 작업
**부적합한 작업**: cross-review, 아키텍처 설계, 복잡한 코드 분석
**호출 방식**: `Agent tool: model: haiku, subagent_type: general-purpose`
