# g-insight

Reviews completed work and suggests improvements to instructions, new skill candidates, config sharing opportunities, and agent prompt enhancements. Also invoked from `/dev complete` (optional insight step).

## Features

- **7 Analysis Categories** — Instruction candidates, skill candidates, config sharing, agent improvements, agent candidates, token efficiency, and memory updates
- **Quality Gate** — Only surfaces meaningful insights; outputs "No suggestions" when nothing actionable is found
- **3-Way User Decision** — Each suggestion can be Applied (immediate), Deferred (saved as a memory file + MEMORY.md pointer), or Skipped
- **Context-Aware** — When called from `/dev complete`, also analyzes the memory file, PRD, architecture.md, and history.md artifacts
- **Main-Context First** — Standalone runs stay in the main context for full conversation history; `/dev complete` may dispatch it as a subagent with task context

## Usage

```
/g-insight
```

Also invoked from `/dev complete` when the user opts into config improvement suggestions.

## How It Works

```
/g-insight (or invoked from /dev complete)
  → 1. Collect context (conversation history, artifacts)
  → 2. Pattern analysis across 7 categories
  → 3. Generate insights (skip if nothing meaningful)
  → 4. Present recommendations
  → 5. User decision per insight:
       ├── Apply — execute immediately
       ├── Defer — save as memory file + MEMORY.md pointer
       └── Skip — discard
```

### Analysis Categories

| Category | What it looks for |
|----------|-------------------|
| Instruction candidates | Patterns worth adding to CLAUDE.md |
| Skill candidates | Repeated workflows that could become skills |
| Config sharing | Settings reusable across projects |
| Agent improvements | Prompt refinements for existing agents |
| Agent candidates | New agent opportunities |
| Token efficiency | Ways to reduce context token usage |
| Memory updates | Outdated or missing entries in MEMORY.md |

## Requirements

- Claude Code CLI

## License

MIT
