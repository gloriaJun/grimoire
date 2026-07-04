# Complete: Task Wrap-up

Run when all features are done. Consolidates scattered work records into a single
`<task>-log.md` and cleans up process files (state / history / brainstorm).
PRD and architecture are kept as reference documents.

## Process

### 1. Refresh reference docs

Give PRD and architecture.md a final pass so they reflect what actually changed
during build (both are preserved, so leave them current).

### 2. Create `<task>-log.md`

Create `<task-name>-log.md` in the task folder using the fixed format below.

**Writing rules (personal knowledge records):**
- Write in plain, everyday language that still reads clearly six months from now.
  Spell out jargon and feature IDs (F-01 etc.).
- Prefer sentences over tables — what was done and **why** must survive.
- Link at least one related vault note with `[[wikilink]]` (omit if none exists).

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
- 구현한 것: <만든 기능을 쉬운 말로 풀어서>
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

> `## 과정에서 고민한 것` absorbs the old history.md decision/blocker log;
> `## 배운 것` absorbs the old "Wonder & Reflect" retro. One pass here, no extra steps.

### 3. Process file cleanup (go-ahead gate)

**Never ask to delete right after writing the log.** The user needs time to review
the output first.

Start the deletion confirmation only on an explicit go-ahead signal from the user —
"다음 작업 진행해줘", "검토 끝났어", "정리해줘" and similar. Until then, leave process
files in place and move on to step 4 (summary report).

On the go-ahead signal, confirm once before deleting:

```
작업 기록을 <task>-log.md 하나로 합쳤습니다.
아래 과정 파일을 삭제할까요? (PRD·architecture·wireframe은 보존합니다)

  - state.md
  - history.md
  - brainstorm.md

> Y 삭제 / n 보존
```

- Y: delete the 3 files. Keep PRD, architecture, wireframe, and `<task>-log.md`.
- n: keep everything and continue.

Ask the same one-time confirmation for any other temp files in the task folder.
If the session ends without a go-ahead signal, the next session's `/dev status`
surfaces the un-cleaned files.

### 4. Summary report

Report briefly on screen: what was built (features), files changed,
follow-ups (if any).

### 5. insight (optional)

Run only when the user wants grimoire config improvement suggestions. Its purpose
differs from a retro (tool/instruction improvements, not a work retrospective).
Fine to skip.

- To run: Read `~/.claude/skills/insight/SKILL.md`
- Dispatch via `Agent(subagent_type: "Explore")` — pass the insight instructions plus
  task context (task-name, what was built, key decisions, artifact paths).
  The agent reads grimoire files directly.

---

## Session Handoff

### State update

MEMORY.md:
- Move the pointer from `## Active Dev Tasks` to `## Completed Dev Tasks`
- Point it at `<task>-log.md` instead of `state.md`:
  ```
  - [<task-name>](YYYY-MM-DD-<task-name>/<task-name>-log.md) — <repo> / 완료 YYYY-MM-DD
  ```

state.md is deleted, so no memory file remains to update. Later status checks
(`/dev status`) read completion info from the `<task>-log.md` frontmatter.

### Completion message

```
✅ 작업 완료 — <task-name>

작업 기록: <task>-log.md (결과 · 고민 · 배운 점)
보존 문서: PRD · architecture(· wireframe)

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
다음에 할 수 있는 것:
  /dev retro  — 회고 + 배운 점을 Obsidian 노트로 발행
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```
