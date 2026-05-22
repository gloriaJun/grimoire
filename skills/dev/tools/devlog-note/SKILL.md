# devlog-note — Quick Devlog Note Writing

Write a note to the active devlog without running the full dev planning workflow.
Triggered by: `/dev devlog-note`, "devlogs에 기록/정리해줘", "오늘 작업 기록해줘",
"작업 노트 써줘", "devlog에 남겨줘", "이거 기록해줘", etc.

---

## Step 1: Task Resolution

Resolve which devlog task to write to.

1. Resolve current repo name:
   ```bash
   basename $(git rev-parse --show-toplevel 2>/dev/null || pwd)
   ```

2. Read MEMORY.md `## Active Dev Tasks` (already in context).
   For each listed memory file: read frontmatter `repo` to filter by current repo.

3. Match results:
   - **1 active task found**: auto-select, announce: "📝 <task-name> 에 기록합니다"
   - **Multiple active tasks**: show selection menu
     ```
     기록할 태스크를 선택하세요:
       1. <task-name>   (build — F-03 진행 중)
       2. <task-name>   (design)
     > Enter number
     ```
   - **0 active tasks found**: "현재 레포의 active 태스크가 없습니다. 새 태스크를 시작하시겠습니까? (Y/n)"
     - Y → proceed to `steps/entry.md`
     - n → stop

   **Fallback**: if MEMORY.md has no entries, scan devlog folder for `_state.json` (legacy — see `schemas/state.md`).

---

## Step 2: Content Gathering

Determine what to record.

- If the user provided explicit content in their message → use it directly
- If the current conversation contains recent work context → summarize and confirm:
  ```
  다음 내용을 기록할까요?
  "<summarized content>"
  (Y/n, 또는 직접 입력)
  ```
- If no content available → ask: "어떤 내용을 기록할까요?"

---

## Step 3: Category Detection

Classify the content (can be multiple):

| Category | Indicators | Write to |
|----------|-----------|----------|
| `decision` | 아키텍처 결정, 설계 이유, 트레이드오프 선택 | `history.md` → Decision Log |
| `blocker` | 블로커, 막힌 이슈, 확인 필요 사항 | `history.md` → Decision Log |
| `troubleshooting` | 버그 원인, 오류 해결, 디버깅 발견 | `history.md` → Decision Log |
| `progress` | 진행 상황 업데이트, 완료 항목 | `notes.md` |
| `note` | 일반 메모, 아이디어, 참고 사항 | `notes.md` |

If ambiguous, default to `note`.

---

## Step 4: Write

### For `decision`, `blocker`, `troubleshooting`: append to `history.md` Decision Log

If `history.md` does not exist in the task directory, create it following `schemas/history.md` initial template.

Append a Decision Log entry in this format:
```
### [<current-step from memory file>] YYYY-MM-DD — <title derived from content>
_type: <decision|blocker|troubleshooting> · status: <open (blocker) or resolved (decision/troubleshooting)>_

<content>
```

Then regenerate `history.md` Current Snapshot from the memory file (open blockers list will auto-update).

### For `progress` and `note`: append to `notes.md`

If `notes.md` does not exist in the task directory, create it with a header:
```markdown
# Notes — <taskName>
```

Append under today's date heading:
```markdown
## YYYY-MM-DD

- [progress|note] <content>
```

If today's heading already exists, append to it without creating a duplicate.

---

## Step 5: Confirm

Output a single confirmation line:

```
✅ 기록 완료
   태스크: <task-dir>
   저장: <file(s) written, e.g. "notes.md" or "history.md (결정사항)">
```
