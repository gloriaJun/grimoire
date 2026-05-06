# Complete: Task Wrap-up

When all features are done.

## Process

1. Final update of PRD and TRD to reflect any changes made during execution.
2. If documents were saved in the task subdirectory (temporary):
   - Ask (follow Single Choice pattern):
     ```
     Temporary files found in the task subdirectory.

     What to do with them?
     1. Delete
     2. Keep
     3. Move to another location

     > Enter number or free text
     ```
   - Delete only after explicit confirmation.
3. Present summary:
   - What was built
   - Files changed
   - Follow-up items
3.5 Wonder & Reflect (inline pass 1회 — 위임 없음, 사용자 입력 불요):

   **Wonder — 무엇이 불확실한 채로 남았나?**
   - PRD의 미해결 항목 최대 3개 추출 (Open Questions 섹션 또는 TBD 표기 항목)
   - `features[i].stagnationResolution` 이벤트 목록 (구현 가정/우회 지점)
   - TRD 가정 중 빌드에서 검증되지 않은 항목

   **Reflect — 다음에는 무엇을 바꿔야 하나?**
   - 피처 사이징(breakdown)이 실제 구현 공수와 맞았는가?
   - feature spec AC 중 테스트 불가능한 항목이 있었는가?
   - 빌드 중 발견됐지만 spec에 없던 요구사항이 있었는가?

   결과를 태스크 요약의 끝에 `## Retrospective Notes` 섹션으로 추가.
   이 출력을 Step 4 insight 디스패치 컨텍스트에 포함.

4. Dispatch **insight** as a subagent (isolated context, avoids session-end context bloat):
   - Load `~/.claude/skills/insight/SKILL.md` via Read tool
   - Dispatch via `Agent(subagent_type: "Explore")` with:
     - Insight skill instructions as the prompt base
     - Task context: `taskName`, summary of what was built, key decisions, artifact paths
     - Agent reads grimoire files independently

---

## Session Handoff

### State Update

`currentStep` ← `"complete"`, append `"complete"` to `completedSteps`. Append to `history`.

Follow update mechanics from `schemas/state.md`.

### _index.md Update

- Find the row matching the current task directory in `<devlogs-root>/_index.md`
- Update step column to `complete`
- Update frontmatter `updated:` to today's date

### Completion Message

```
✅ [complete] done — task wrap-up finished

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Optional next steps:
  /dev retro  — session retrospective
  /dev til    — TIL note + devlog cleanup
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```
