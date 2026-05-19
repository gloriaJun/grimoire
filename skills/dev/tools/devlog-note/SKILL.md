# devlog-note — Quick Devlog Note Writing

Write a note to the active devlog without running the full dev planning workflow.
Triggered by: `/dev devlog-note`, "devlogs에 기록/정리해줘", "오늘 작업 기록해줘",
"작업 노트 써줘", "devlog에 남겨줘", "이거 기록해줘", etc.

---

## Step 1: Task Resolution

Resolve which devlog task to write to.

1. Run Devlog Path Detection (from SKILL.md):
   - `cwd` contains `GitHubWork` → `~/Documents/GitHubWork/_claude/devlogs/`
   - `cwd` contains `GitHubPrivate` → `~/Documents/GitHubPrivate/_claude/devlogs/`
   - Neither → ask the user

2. Resolve current repo name:
   ```bash
   basename $(git rev-parse --show-toplevel 2>/dev/null || pwd)
   ```

3. Pass 1 — filter folders by repo name substring:
   - Find active tasks (`currentStep NOT IN completedSteps` in `_state.json`)

4. Match results:
   - **1 active task found**: auto-select, announce: "📝 <task-dir> 에 기록합니다"
   - **Multiple active tasks**: show selection menu
     ```
     기록할 태스크를 선택하세요:
       1. 2026-05-19-<repo>-task-a   (build — feature-03 진행 중)
       2. 2026-05-10-<repo>-task-b   (breakdown)
     > Enter number
     ```
   - **0 active tasks found**: "현재 레포의 active devlog가 없습니다. 새 태스크를 시작하시겠습니까? (Y/n)"
     - Y → proceed to `steps/entry.md`
     - n → stop

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
| `decision` | 아키텍처 결정, 설계 이유, 트레이드오프 선택 | `next-session.md` → 구현 결정사항 섹션 |
| `blocker` | 블로커, 막힌 이슈, 확인 필요 사항 | `next-session.md` → 블로커 섹션 |
| `progress` | 진행 상황 업데이트, 완료 항목 | `notes.md` |
| `note` | 일반 메모, 아이디어, 참고 사항 | `notes.md` |

If ambiguous, default to `note`.

---

## Step 4: Write

### Always: append to `_state.json.history`

```json
{
  "step": "<currentStep from _state.json>",
  "action": "manual-note",
  "content": "<first 100 chars of the note>",
  "timestamp": "<ISO8601>"
}
```

### For `decision` and `blocker`: update `next-session.md`

If `next-session.md` does not exist in the task directory, create it following `schemas/next-session.md`.

- `decision` → append a bullet to "구현 결정사항 & 아키텍처 노트" section:
  ```
  - [manual] <content>
  ```
- `blocker` → append a bullet to "블로커 / 다음 세션 전 확인사항" section:
  ```
  - [manual] <content>
  ```
- Update `updated:` frontmatter to today's date.

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
   저장: <file(s) written, e.g. "notes.md" or "next-session.md (결정사항)">
```
