# Agent Guidelines

Common rules for all agent dispatches — applies to skills and general conversations alike.

## Model Hierarchy

4-tier 모델 계층으로 역할을 분리한다.

| Tier | Model | Role | 원칙 |
|------|-------|------|------|
| 1 | Opus | Strategic Advisor | 판단/방향만 제시, 실행 금지 |
| 2 | Sonnet | Main Orchestrator + Executor | 조율, 라우팅, 실제 작업 수행 |
| 3 | Haiku | Lightweight Worker | 문서 편집, 요약, 포맷 변환 |
| 3 | Codex | Code-centric Worker | 리뷰, 탐색, 테스트, 리팩토링 |

Fallback 체인: Codex → Sonnet, Haiku → Sonnet, Opus declined → Sonnet

### Sonnet as Default

모든 에이전트의 기본 모델은 **sonnet**이다.
CLI 메인 세션도 Sonnet을 권장한다.

### Opus Advisor Pattern

Opus는 **direction만 제공하는 advisor**이다. 문서 작성, 코드 작성, 리뷰 등 실행은 절대 하지 않는다.

**호출 조건** (모두 충족 시에만):
- 3+ 컴포넌트가 얽힌 아키텍처 결정
- Sonnet이 최소 2개 선택지를 이미 분석 완료
- 선택지 간 trade-off가 명확히 상충
- 결정이 장기적 아키텍처 영향을 미침

**프로세스:**
1. Sonnet이 먼저 선택지를 분석하고, 판단이 어려운 구체적 이유를 설명
2. 사용자에게 Opus advisor 호출 승인 요청 (Y/n)
   - "Opus가 방향만 제시, Sonnet이 실행합니다"
3. 승인 시: Opus에게 Direction Brief만 요청 (상세 형식은 `references/opus-advisor-pattern.md`)
4. 거절 시: Sonnet이 자체 판단으로 진행

**Opus가 절대 하지 않는 것:**
- TRD/PRD 문서 작성
- 코드 작성 또는 리뷰
- 긴 분석 보고서 생성

### Specifying Model

| Agent type | How to set |
|-----------|-----------|
| Global (`.claude/agents/`) | `model: sonnet` or `model: opus` in YAML frontmatter |
| Skill-local | `model` parameter in the Agent tool call |
| Ad-hoc (no agent definition) | Always pass `model: sonnet` in the Agent tool call |

## Autonomous Agent Dispatch

When a task would benefit from agent delegation (parallel research, codebase exploration,
isolated sub-tasks), dispatch agents proactively without waiting for user instruction.

**Rules:**
- Always use `model: sonnet` unless opus advisor is justified and approved
- Follow the same parallel execution limits (max 3 per wave)
- Inform the user what agents are being dispatched and why

## Codex Delegation

When delegating work to Codex CLI, follow `@instructions/codex-delegation.md`
for work sizing, sub-task splitting, and incomplete result handling.

### Delegation Priority for Parallel Work

When running parallel agents, prefer delegating to Codex first for eligible tasks
to reduce Claude seat token consumption. Codex uses OpenAI API (separate billing).

**Codex-first tasks** (delegate to Codex when running in parallel):
- Code review (cross-review pattern)
- Codebase exploration and pattern search
- Test code generation
- Mechanical refactoring (rename, move, boilerplate)
- Documentation generation (README, changelog — requires codebase access)
- Design doc cross-review (PRD/TRD Codex validation)

**Claude-only tasks** (keep on Claude agents):
- Architecture design requiring deep reasoning
- Initial PRD/TRD authoring (deep reasoning required)
- Multi-step debugging with nuanced judgment
- Skill/agent authoring (Claude ecosystem context required)
- Tasks requiring Claude-specific tool access (MCP, hooks)

### Parallel Mix Strategy

When dispatching 2-3 parallel agents, apply this priority:

| Parallel count | Strategy |
|---------------|----------|
| 2 agents | Codex-eligible 1개 → Codex, 나머지 → Claude/Haiku |
| 3 agents | Codex-eligible 최대화, Haiku-eligible 차선, 나머지 Claude |

This is a soft guideline — if all tasks require Claude-specific capabilities,
use Claude agents for all.

## Task-to-Model Mapping

작업 유형별 최적 모델과 fallback 체인을 정의한다.

### Mapping Table

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

### Fallback Trigger Conditions

| Condition | Action |
|-----------|--------|
| Codex unavailable (CLI 미설치, Bash 제한, 토큰 소진) | Sonnet으로 fallback |
| Haiku output quality insufficient | Sonnet으로 escalate |
| Opus advisor declined by user | Sonnet이 자체 판단으로 진행 |
| Codex 응답 품질 불충분 | 1회 재시도 후 Sonnet으로 전환 |

### Haiku Usage Rules

Haiku는 Agent tool의 `model: haiku`로 호출한다.
Bash 권한이 불필요하므로 Codex를 사용할 수 없는 환경에서 fallback으로 활용한다.

**적합한 작업**: 구조가 명확하고 심층 추론이 불필요한 작업
**부적합한 작업**: cross-review, 아키텍처 설계, 복잡한 코드 분석
**호출 방식**: `Agent tool: model: haiku, subagent_type: general-purpose`

## Parallel Execution Limit

Each parallel agent runs in a separate context window and is billed independently.
Apply a hard cap to prevent cost spikes and context fragmentation.

### Hard Cap: 3 Parallel Agents

Never dispatch more than **3 agents simultaneously** in a single parallel batch.

| Agents needed | Strategy |
|---------------|----------|
| 1-3 | Dispatch all in parallel |
| 4-6 | Split into waves: wave 1 (max 3) -> wait -> wave 2 (remainder) |
| 7+ | Reconsider design -- split into sub-tasks or reduce scope |

### When Parallelism Is Justified

Parallelize only when all of these hold:
1. Each agent's task is fully self-contained (no inter-agent data dependencies)
2. Combined wait time savings justify the cost multiplier
3. Total count stays within the 3-agent cap per wave

### Batching Pattern (for 4+ agents)

When more than 3 agents are needed, use wave-based sequential dispatch:

1. Wave 1: dispatch up to 3 agents -> wait for all to complete
2. Wave 2: dispatch next batch (up to 3) -> wait for all to complete
3. Aggregate: combine results from all waves

Document each wave boundary in mermaid diagrams as a distinct sync node.

## Action Markers

Agent 위임이 포함된 응답에서 사용자가 진행 상황을 쉽게 인지할 수 있도록
액션 유형별 이모지 마커를 사용한다.

이 이모지는 장식이 아닌 **액션 유형 식별 마커**로서 사용한다.
일반 대화에서의 이모지 사용 규칙과는 별개이다.

### 적용 조건

Agent tool 호출이 포함된 응답에만 적용한다.
Agent 위임 없이 직접 응답하는 경우에는 일반 텍스트로 응답한다.

### Agent 블록

Agent 위임 시 markdown heading으로 구분한다:

`## 🤖 Agent: {task name} ({model})`

### 액션 유형 매핑

| Emoji | Label | 용도 |
|-------|-------|------|
| 🤖 | Agent | 고수준 태스크/서브태스크 |
| 🔍 | Search | 파일, 코드, 데이터 검색 |
| 🧠 | Analysis | 추론, 비교, 해석 |
| ⚙️ | Tool | 명령 실행 (bash, API 등) |
| 📄 | Read | 파일/콘텐츠 읽기 |
| ✍️ | Write | 파일 생성/수정 |
| ✅ | Result | 최종 출력/결론 |
| ⚠️ | Warning | 잠재적 이슈/불확실성 |
| ❌ | Error | 에러/실패 |
| 💬 | Question | 사용자에게 질문 |

### 포맷 규칙

- Agent 블록: `## 🤖 Agent: {task name} ({model})`
- 일반 액션: `{emoji} {Label}: {대상/설명}` (Label과 설명이 중복되지 않도록 간결하게)
- 관련 액션은 가장 가까운 Agent 블록 아래에 그룹핑
