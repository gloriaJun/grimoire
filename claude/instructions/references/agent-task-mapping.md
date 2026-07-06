# Agent Task-to-Model Mapping

Optimal model per task type with fallback chains. Loaded on demand from agent-guidelines.md.

## Mapping Table

| Task Type | Primary | Fallback | Rationale |
|-----------|---------|----------|-----------|
| **Deep reasoning** | | | |
| Architecture direction | Opus (advisor) | Sonnet | direction only; Sonnet executes |
| PRD/TRD writing | Sonnet | - | Sonnet writes, reflecting Opus direction |
| Multi-step debugging | Sonnet | - | needs sustained context |
| **Code tasks** | | | |
| Code cross-review | Codex | Sonnet | Sonnet fallback when Codex unavailable |
| Codebase exploration / pattern search | Codex | Sonnet (Explore) | Sonnet fallback when Codex unavailable |
| Test code generation | Codex | Sonnet | Sonnet fallback when Codex unavailable |
| Mechanical refactoring | Codex | Sonnet | Sonnet fallback when Codex unavailable |
| **Document tasks** | | | |
| Light doc edits (typos, format, small sections) | Haiku | Sonnet | fast and cheap |
| Template-based doc generation | Haiku | Sonnet | fixed-structure fill-in work |
| Format conversion (markdown restructure, TOC) | Haiku | Sonnet | pure text transformation |
| General doc generation (README, changelog) | Codex | Haiku → Sonnet | two-stage fallback |
| Design doc cross-review | Codex | Sonnet | Sonnet fallback when Codex unavailable |
| **Utility tasks** | | | |
| Web search / info gathering | Haiku | Sonnet (Explore) | simple lookup and summary |
| Summarization | Haiku | Sonnet | compressing existing content |

## Fallback Trigger Conditions

| Condition | Action |
|-----------|--------|
| Codex unavailable (CLI missing, Bash restricted, tokens exhausted) | fall back to Sonnet |
| Haiku output quality insufficient | escalate to Sonnet |
| Opus advisor declined by user | Sonnet proceeds on its own judgment |
| Codex response quality insufficient | retry once, then switch to Sonnet |

## Haiku Usage Rules

Invoke Haiku via the Agent tool with `model: haiku`.
It needs no Bash permission, so it serves as the fallback when Codex is unavailable.

**Good fit**: clearly structured tasks that need no deep reasoning
**Poor fit**: cross-review, architecture design, complex code analysis
**Invocation**: `Agent tool: model: haiku, subagent_type: general-purpose`
