# Agent Guidelines

Common rules for all agent dispatches - skills and general conversations alike.

## Model Hierarchy

Four tiers by role. The main session's model and effort follow settings.json and may change
per session or task (default Sonnet when unset; see CLAUDE.md).
Fallback: Codex→Sonnet, Haiku→Sonnet, Opus declined→Sonnet.

| Tier | Model | Role | Principle |
|------|-------|------|-----------|
| 1 | Opus | Strategic Advisor | judgment/direction only, no execution |
| 2 | Sonnet | Orchestrator + Executor | coordination, routing, actual work |
| 3 | Haiku | Lightweight Worker | doc edits, summaries, format conversion |
| 3 | Codex | Code-centric Worker | review, exploration, tests, refactoring (delegate with `--effort low`) |

**Opus Advisor**: direction only, never executes. Invoke only with user approval when ALL
hold: 3+ component architecture decision, Sonnet analyzed 2+ options, conflicting
trade-offs, long-term impact. Process, Direction Brief format, anti-patterns →
`references/opus-advisor-pattern.md`.

Per-task model mapping, fallback conditions, Haiku rules → `references/agent-task-mapping.md`.

## Specifying Model

| Agent type | How to set |
|-----------|-----------|
| Global (`.claude/agents/`) | `model:` in YAML frontmatter |
| Skill-local / Ad-hoc | omit `model` in the Agent tool call to inherit the session model; set it only when the task tier differs (see `references/agent-task-mapping.md`) |

## Agent Dispatch

Proactively dispatch work that benefits from delegation (parallel research, codebase
exploration, isolated subtasks) without waiting for user instruction. Say what is
delegated and why.

**Autonomy boundary**: isolated exploration/analysis/research → dispatch autonomously.
Actions with external effects (GitHub/Jira/message sending, file modifications) follow
CLAUDE.md confirmation rules.

**Parallelism**: when 2+ subtasks are (1) independent of each other's output and
(2) runnable in isolated contexts, batch them in a single message.
Patterns: explore+explore, analyze+analyze, Codex (review/explore) + Claude (design/write).

## Codex Delegation

For parallel work, delegate Codex-eligible tasks (code review, exploration, test
generation, mechanical refactoring, doc generation) to Codex first to save Claude seat
tokens (Codex bills separately via the OpenAI API). Keep architecture design, initial
PRD/TRD, complex debugging, and skill authoring on Claude.

Task sizing, subtask splitting, prompt quality, incomplete results → `references/codex-delegation.md`.

## Parallel Execution Limit

Max **3** agents per parallel batch. Each agent is a separate context and separate billing.
1-3 → all in parallel · 4-6 → waves of max 3, wait between · 7+ → rethink the design
(split subtasks or narrow scope).

## Action Markers

Use only in responses containing Agent tool calls (plain text for direct responses).
Emoji are action-type identifiers, not decoration.

- Agent block: `## 🤖 Agent: {task name} ({model})`
- General actions: `{emoji} {Label}: {target}` - 🔍 Search, 🧠 Analysis, ⚙️ Tool, 📄 Read,
  ✍️ Write, ✅ Result, ⚠️ Warning, ❌ Error, 💬 Question
- Group related actions under the nearest Agent block
