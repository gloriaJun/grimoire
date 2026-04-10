# Agent Guidelines

Common rules for all agent dispatches — applies to skills and general conversations alike.

## Model Selection

Default model for all agents (global and skill-local) is **sonnet** for cost efficiency.

### Escalation to Opus

When a task requires deep reasoning that sonnet cannot reliably handle, propose opus
to the user with a yes/no choice. Always include the rationale for why opus is recommended.

**Criteria for opus recommendation:**
- Complex architecture design (multi-component trade-off analysis)
- Cross-cutting concern analysis across large codebases
- Nuanced judgment calls requiring broader context

**Process:**
1. Explain why opus is recommended for this specific task (concrete rationale, not generic)
2. Ask the user with a clear yes/no choice
3. If declined, proceed with sonnet

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
- Always use `model: sonnet` unless opus is justified and approved via the escalation process
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
- Documentation generation

**Claude-only tasks** (keep on Claude agents):
- Architecture design requiring deep reasoning
- Multi-step debugging with nuanced judgment
- Skill/agent authoring (Claude ecosystem context required)
- Tasks requiring Claude-specific tool access (MCP, hooks)

### Parallel Mix Strategy

When dispatching 2-3 parallel agents, apply this priority:

| Parallel count | Strategy |
|---------------|----------|
| 2 agents | 1 Codex + 1 Claude if one task is Codex-eligible |
| 3 agents | Maximize Codex-eligible tasks first, remainder on Claude |

This is a soft guideline — if all tasks require Claude-specific capabilities,
use Claude agents for all.

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
