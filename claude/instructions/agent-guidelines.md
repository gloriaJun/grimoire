# Agent Guidelines

Common rules for all agent dispatches - skills and general conversations alike.

## Model Hierarchy

4-tier로 역할 분리. 기본 모델은 Sonnet (CLAUDE.md 참조).
Fallback: Codex→Sonnet, Haiku→Sonnet, Opus declined→Sonnet.

| Tier | Model | Role | 원칙 |
|------|-------|------|------|
| 1 | Opus | Strategic Advisor | 판단/방향만, 실행 금지 |
| 2 | Sonnet | Orchestrator + Executor | 조율, 라우팅, 실제 작업 |
| 3 | Haiku | Lightweight Worker | 문서 편집, 요약, 포맷 변환 |
| 3 | Codex | Code-centric Worker | 리뷰, 탐색, 테스트, 리팩토링 (위임 시 `--effort low`) |

**Opus Advisor**: direction만 제공, 실행 금지. 호출 조건(3+ 컴포넌트 아키텍처 결정,
Sonnet이 2+ 선택지 분석 완료, trade-off 상충, 장기 영향)을 모두 충족할 때만 사용자 승인 후 호출.
상세 프로세스·Direction Brief 형식·anti-pattern → `references/opus-advisor-pattern.md`.

작업 유형별 모델 매핑, fallback 조건, Haiku 사용 규칙 → `references/agent-task-mapping.md`.

## Specifying Model

| Agent type | How to set |
|-----------|-----------|
| Global (`.claude/agents/`) | `model:` in YAML frontmatter |
| Skill-local / Ad-hoc | `model` param in Agent tool call (ad-hoc는 항상 `model: sonnet`) |

## Agent Dispatch

에이전트 위임이 유리한 작업(병렬 리서치, 코드베이스 탐색, 격리된 서브태스크)은
사용자 지시를 기다리지 않고 능동적으로 dispatch한다. 무엇을·왜 위임하는지 알린다.

**자율/확인 경계**: 격리된 탐색·분석·리서치는 자율 dispatch. 외부에 영향을 주는
액션(GitHub·Jira·메시지 발송, 파일 수정)은 CLAUDE.md의 확인 규칙을 따른다.

**병렬 판단**: 독립적 서브태스크가 2개 이상이고 (1) 상호 출력 비의존,
(2) 독립 컨텍스트 실행 가능하면 단일 메시지에 묶어 병렬 dispatch.
패턴 예: 탐색+탐색, 분석+분석, Codex(리뷰/탐색)+Claude(설계/작성).

## Codex Delegation

병렬 실행 시 Codex-eligible 작업(코드 리뷰, 탐색, 테스트 생성, 기계적 리팩토링, 문서 생성)은
Codex 우선 위임해 Claude seat 토큰을 아낀다(Codex는 OpenAI API 별도 과금).
아키텍처 설계·초기 PRD/TRD·복잡한 디버깅·스킬 저작은 Claude 유지.

작업 사이징, 서브태스크 분할, 프롬프트 품질, 미완료 결과 처리 → `@instructions/codex-delegation.md`.

## Parallel Execution Limit

한 번의 병렬 배치에 **최대 3개** 에이전트. 각 에이전트는 별도 컨텍스트·별도 과금.

| 필요 수 | 전략 |
|---------|------|
| 1-3 | 전부 병렬 dispatch |
| 4-6 | wave 분할: wave 1 (최대 3) → 대기 → wave 2 |
| 7+ | 설계 재고 - 서브태스크 분할 또는 범위 축소 |

## Action Markers

Agent tool 호출이 포함된 응답에서만 사용(위임 없는 직접 응답은 일반 텍스트).
이모지는 장식이 아닌 액션 유형 식별 마커.

- Agent 블록: `## 🤖 Agent: {task name} ({model})`
- 일반 액션: `{emoji} {Label}: {대상}` - 🔍 Search, 🧠 Analysis, ⚙️ Tool, 📄 Read,
  ✍️ Write, ✅ Result, ⚠️ Warning, ❌ Error, 💬 Question
- 관련 액션은 가장 가까운 Agent 블록 아래 그룹핑
