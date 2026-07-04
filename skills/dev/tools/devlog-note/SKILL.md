# devlog-note — Quick Devlog Note Writing

Write a note to the active devlog without running the full dev planning workflow.
Triggered by: `/dev devlog-note`, "devlogs에 기록/정리해줘", "오늘 작업 기록해줘",
"작업 노트 써줘", "devlog에 남겨줘", "이거 기록해줘", etc.

---

## Step 1: Task Resolution

Resolve which devlog task to write to.

1. Resolve current repo name (main repo root — worktree-safe):
   ```bash
   REPO_ROOT=$(dirname "$(git rev-parse --path-format=absolute --git-common-dir 2>/dev/null)")
   [ -d "$REPO_ROOT" ] || REPO_ROOT=$(git rev-parse --show-toplevel 2>/dev/null || pwd)
   basename "$REPO_ROOT"
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
   - **0 active tasks found**: offer a standalone vault note instead of forcing a task:
     ```
     현재 레포에 진행 중인 작업이 없습니다.
       1. 단독 노트로 기록 (vault 04_Notes) — 기본
       2. 새 작업 시작
       n. 취소
     ```
     - `1` or Enter → resolve scope from cwd (GitHubWork → `work`, GitHubPrivate → `life`,
       else ask). Write `~/Documents/obsidian-vault/04_Notes/<scope>/YYYY-MM-DD-<slug>/note.md`
       with frontmatter (`created`, `tags`, `summary`, `scope`) and the content from Step 2.
       Plain-language rule applies (write so it reads clearly six months later;
       spell out jargon). After writing, self-check silently: required frontmatter
       present, any `[[wikilink]]` target exists — fix immediately.
       Skip Steps 3–4, confirm per Step 5.
     - `2` → proceed to `steps/entry.md`
     - `n` → stop

   **Fallback**: if MEMORY.md has no entries, scan `<memory-root>` for orphaned `YYYY-MM-DD-*/state.md` and re-register.

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
| `decision` | architecture decision, design rationale, trade-off choice | `history.md` → `결정·블로커 기록` |
| `blocker` | blocked issue, item needing confirmation | `history.md` → `결정·블로커 기록` |
| `troubleshooting` | bug cause, error resolution, debugging finding | `history.md` → `결정·블로커 기록` |
| `progress` | progress update, completed item | `notes.md` |
| `note` | general memo, idea, reference | `notes.md` |

If ambiguous, default to `note`.

---

## Step 4: Write

### For `decision`, `blocker`, `troubleshooting`: append to `history.md` `결정·블로커 기록`

If `history.md` does not exist in the task directory, create it following `schemas/history.md` initial template.

Append a `결정·블로커 기록` entry in this format:
```
### [<current-step from memory file>] YYYY-MM-DD — <title derived from content>
_type: <decision|blocker|troubleshooting> · status: <open (blocker) or resolved (decision/troubleshooting)>_

<content>
```

Then regenerate the `history.md` `현재 상태` block from the memory file (open blockers list will auto-update).

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
