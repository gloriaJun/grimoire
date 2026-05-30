---
name: dev
description: >
  Unified development workflow skill. Triggered by /dev or sub-commands:
  /dev idea, /dev plan, /dev design, /dev build, /dev complete,
  /dev test, /dev refactor, /dev review, /dev troubleshoot,
  /dev retro, /dev til, /dev help, /dev status.
  Also triggers on: code refactoring requests ("리팩토링 해줘", "코드 정리해줘",
  "클린 아키텍처 적용해줘", "중복 코드 정리해줘", "타입 추가해줘", "코드 냄새 제거해줘",
  "성능 개선해줘", "refactor this", "clean up this code"),
  error analysis and debugging ("에러 고쳐줘", "에러 원인 분석해줘", "버그 원인이 뭐야",
  "오류가 왜 나지", "왜 에러가 나지", "이 에러 뭔지", "에러 원인을 분석해줘",
  "어디서 실패하는 거야", "스택트레이스 분석해줘", "디버깅 해줘",
  error logs, stack traces, Sentry alerts, GitHub Actions failure output).
  Performance issues trigger only when accompanied by log/metric artifacts
  ("느리다", "타임아웃", "latency" + log or trace data).
  Devlog write/note ("devlogs에 정리해줘", "devlog에 기록해줘", "오늘 작업 기록해줘",
  "작업 내용 정리해줘", "이거 기록해줘", "devlog에 남겨줘", "작업 노트 써줘").
  Session resume/status ("작업 이어하자", "이어서 진행하자", "작업 현황 보여줘", "devlog 상태 보여줘").
  Code review/modification ("이 부분 검토해줘", "이 코드 리뷰해줘", "이 코드 봐줘",
  "코드 개선 제안해줘", "이 부분 수정 제안해줘", "review this", "check this code").
  Manages task state via Claude Code memory files for cross-session persistence.
  Manual planning steps (idea/plan/design/build/complete) require explicit invocation.
---

# dev — Unified Development Workflow

Single entry point for the full development lifecycle: ideation → planning → implementation → documentation.
Each sub-command maps to a step file. State persists across sessions via memory files (`schemas/memory.md`).

---

## Role

Claude acts as a **technical project manager** in this workflow:

- **Planning phases** (idea → design): drives artifact creation to a level of detail sufficient for single-session feature implementation. Asks for clarification rather than assuming.
- **Build phase**: produces mini-design per feature, delegates implementation to feature-executor or Codex; owns state tracking and cross-session continuity.
- **Quality bar**: PRD and architecture.md must be self-contained enough that a developer with no prior context could implement from them.

---

## Argument Pre-processing

Before routing, check if arguments were passed after `/dev`.

**Pattern detection** (in order):

| Pattern | Detection | Action |
|---------|-----------|--------|
| URL (`http://`, `https://`) | starts with `http` | Extract as artifact URL; proceed to entry.md with artifact context |
| File path (`/`, `~/`, `./`) | path-like string | Extract as artifact path; proceed to entry.md with artifact context |
| Descriptor phrase (`결과물`, `디자인`, `스펙`, `문서`, `산출물`) | keyword match | Treat arguments as artifact context; proceed to entry.md |
| Known sub-command (`idea`, `plan`, etc.) | exact match | Route normally to step file |
| No arguments | — | Proceed to entry.md (default) |

When an artifact context is detected, pass it to entry.md's "External Artifact Registration" flow rather than treating it as a sub-command.

---

## Flow Diagram

```mermaid
stateDiagram-v2
    [*] --> Router: /dev [sub-command]

    Router --> ActiveCheck: no sub-command
    Router --> DirectTool: refactor / troubleshoot / retro / til / review / devlog-note triggers
    Router --> StepFile: explicit sub-command

    ActiveCheck --> ResumeTask: active task found
    ActiveCheck --> EntryMenu: no active task
    EntryMenu --> StepFile

    ResumeTask --> StepFile

    state "Step Files" as StepFile {
        idea --> plan
        plan --> design
        design --> build
        build --> complete
    }

    state "Tool Files" as DirectTool {
        refactor_tool: tools/refactor
        troubleshoot_tool: tools/troubleshoot
        test_tool: tools/test
        retro_tool: tools/retro
        til_tool: tools/til
        review_tool: tools/review
        setup_tool: tools/setup
        devlog_note_tool: tools/devlog-note
    }

    StepFile --> Handoff: step complete
    Handoff --> [*]: new session
```

---

## Sub-command Router

Parse the first word after `/dev`. Load ONLY the matching file.

### Planning Lifecycle (memory-tracked)

| Sub-command | Step file | Description |
|-------------|-----------|-------------|
| *(none)* | `steps/entry.md` | Active task check → resume or entry menu |
| `idea` | `steps/idea.md` | Ideation → brainstorm.md |
| `plan` | `steps/plan.md` | Requirements → PRD |
| `design` | `steps/design.md` | Architecture → architecture.md + wireframe |
| `build` | `steps/build.md` | Feature implementation (mini-design + 1 feature/session) |
| `complete` | `steps/complete.md` | Wrap-up, insight, summary |
| `import` | `steps/entry.md` (Import Flow) | existing artifacts → bootstrap devlog |

### Utility Tools (task optional)

| Sub-command / Natural language trigger | Tool file |
|----------------------------------------|-----------|
| `test` | `Read("tools/test/SKILL.md")` |
| `refactor`, "리팩토링 해줘", "코드 정리해줘", etc. | `Read("tools/refactor/SKILL.md")` |
| `troubleshoot`, error logs, stack traces, "에러 고쳐줘", etc. | `Read("tools/troubleshoot/SKILL.md")` |
| `review`, "이 코드 리뷰해줘", "이 부분 검토해줘", "코드 봐줘", "review this", "check this code", etc. | `Read("tools/review/SKILL.md")` |
| `retro` | `Read("tools/retro/SKILL.md")` |
| `til` | `Read("tools/til/SKILL.md")` |
| `setup` | `Read("tools/setup/SKILL.md")` |
| `devlog-note`, "devlogs에 기록/정리해줘", "오늘 작업 기록해줘", "작업 노트 써줘", etc. | `Read("tools/devlog-note/SKILL.md")` |
| `status` | `steps/status.md` | scan memory root → print task status summary |
| `help` | inline | print available sub-commands |

### help Output Format

When `/dev help` is invoked, print the following directly (no file load):

```
/dev — Development workflow commands

Planning lifecycle (memory-tracked):
  idea          vague concept → brainstorm.md
  plan          requirements → PRD
  design        PRD → architecture.md + wireframe (UI projects)
  build         implement features (mini-design + 1 feature/session)
  complete      wrap-up + summary
  import        existing artifacts → bootstrap devlog

Utility tools (devlog optional):
  test          test code generation
  refactor      code cleanup / restructure
  troubleshoot  debug errors and stack traces
  review        code review workflow
  retro         retrospective → vault note
  til           TIL note → vault + devlog cleanup
  setup         configure lint, prettier, type-check, and husky
  devlog-note   write a note to the active devlog
  status        show all devlog task statuses

  help          show this message
```

---

## Natural Language Auto-routing

**Trigger acknowledgement:** At the start of every invocation (natural language or explicit sub-command), output on the first line:
```
> /dev → {tool-or-step}  [trigger: {explicit|natural-language: "<trigger phrase>"}]
```
Examples:
- `/dev build` 명시 호출: `> /dev → build  [trigger: explicit]`
- "에러 고쳐줘" 자동: `> /dev → troubleshoot  [trigger: natural-language: "에러 고쳐줘"]`
- "devlog에 기록해줘" 자동: `> /dev → devlog-note  [trigger: natural-language: "devlog에 기록해줘"]`

When triggered by natural language (not an explicit `/dev` command):

1. Analyze the trigger (in order):
   - Refactoring keywords → load `tools/refactor/SKILL.md` directly, skip entry menu
   - Error/debug signal (error keyword + action verb, stack trace, Sentry/log artifact,
     or performance keywords **with** log/metric artifact) → load `tools/troubleshoot/SKILL.md` directly, skip entry menu
   - Devlog write/note signal ("devlogs에 기록/정리/남겨줘", "작업 노트", "오늘 작업 기록", etc.)
     → load `tools/devlog-note/SKILL.md` directly, skip entry menu
   - Session resume/status signal:
     - "작업 현황 보여줘", "devlog 상태 보여줘" → load `steps/status.md`
     - "작업 이어하자", "이어서 진행하자" → proceed to `steps/entry.md` (resume flow)
   - Code review/modification signal ("이 코드 리뷰/검토해줘", "이 코드 봐줘",
     "코드 개선 제안해줘", "이 부분 수정 제안해줘", "review this code", "check this code")
     → load `tools/review/SKILL.md` directly, skip entry menu
   - Generic questions without error artifact ("왜 안돼", "왜 느리지" alone) → do NOT auto-route to troubleshoot; treat as general conversation
   - Otherwise → proceed to `steps/entry.md`

2. Skip the active devlog check for utility tools (test/refactor/troubleshoot/devlog-note/review).
   They operate on the current working files or active devlog, not on the full entry flow.

---

## External Reference Behavior

When this skill is *referenced* rather than directly invoked — e.g., "'/dev' 스킬에 맞춰 정리해줘", "devlog 형식으로 저장해줘", "이 내용을 /dev 경로에 기록해줘" — from plan mode, general conversation, or another skill:

1. **Read this skill file first.** Never act on memory of the format.
2. **Resolve the task directory** using the Task Directory Detection rules below.
3. **Create actual files** inside `<task-dir>/`. Do not reformat content inline — create the directory and individual artifact files.
4. When the user has completed artifacts, use the **Import Flow** in `steps/entry.md`.

> **Plan mode exception**: if write operations are currently blocked, record the target task directory and artifact file list in the plan file. Create the actual files after ExitPlanMode.

---

## Task Directory Detection

All task artifacts live inside the Claude Code project memory directory:

```
~/.claude/projects/<project-id>/memory/YYYY-MM-DD-<task-name>/
```

**Project-ID derivation**: absolute repo path with `/` replaced by `-` (leading `~` removed):
- `/Users/al03155147/Documents/GitHubPrivate/my-assistant-hub` → `-Users-al03155147-Documents-GitHubPrivate-my-assistant-hub`

**Current repo name** (used to match memory entries to the active project):
```bash
basename $(git rev-parse --show-toplevel 2>/dev/null || pwd)
```

---

## Session Restoration

MEMORY.md is auto-loaded at session start. When a sub-command is given:

1. Check MEMORY.md `## Active Dev Tasks` for the current repo.
2. If matching memory file found: read it, verify artifact paths, announce "Resuming **<task-name>** at step `<current-step>`", load the step file.
3. Apply step name migration if needed:
   - `"wireframe"` or `"breakdown"` → `"build"`

**Fallback** (no MEMORY.md entry found):
1. Scan `<memory-root>` for `YYYY-MM-DD-*/state.md` not yet indexed in MEMORY.md; filter by `repo` frontmatter.
2. If matches: re-add pointer to MEMORY.md and proceed.
3. If still none: scan devlog folder for `_state.json` (legacy); filter by repo name; offer migration to memory file → proceed.

**Selection table format (multiple tasks):**
```
현재 레포(<repo>) tasks:

  # | Task                          | Step    | Features  | Branch
----+-------------------------------+---------+-----------+--------
  1 | some-task                     | build   | 3/5 done  | feat/X
  2 | other-task                    | design  | —         | main

> 번호 선택 / n 새 태스크
```

---

## Step Router (Pre-condition Guards)

| currentStep | Load file | Pre-condition |
|-------------|-----------|---------------|
| `"entry"` | steps/entry.md | none |
| `"idea"` | steps/idea.md | none |
| `"plan"` | steps/plan.md | `artifacts.brainstorm` OR user input |
| `"design"` | steps/design.md | `artifacts.prd` exists |
| `"build"` | steps/build.md | `artifacts.architecture` exists |
| `"complete"` | steps/complete.md | all features in memory file Features table have status `✅ done` |

Verify pre-conditions before loading. If not met, warn and block.

---

## State Management

See `schemas/memory.md` for schema, update rules, and session restoration logic.

---

## Cross-Agent Review Protocol

See `references/review-protocol.md`.

---

## External Tool Dependencies

| Tool | Purpose | Fallback |
|------|---------|----------|
| Plannotator | Visual review of PRD/TRD/features | Inline text review |
| codex-plugin-cc | Cross-review, implementation delegation | Claude-only review |
| Codex CLI | Non-interactive task delegation | Claude agent |

Never stop the workflow because a tool is missing. Fall back gracefully.

---

## Output Format

When dispatching agents, follow `agent-guidelines.md` Action Markers:
- `## 🤖 Agent: {task} ({model})` for each agent block
- Emoji action markers for tool/read/write operations
- `— parallel N/M` suffix for parallel dispatches
