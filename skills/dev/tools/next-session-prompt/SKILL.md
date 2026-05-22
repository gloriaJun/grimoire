# next-session-prompt — Next Session Resume Prompt Generator

Generate a self-contained prompt to paste at the start of the next session.
Triggered by: `/dev handoff`, "다음 세션 프롬프트 생성해줘", "세션 인계 프롬프트",
"이어서 할 프롬프트 만들어줘", "다음 작업 프롬프트", "handoff prompt", etc.

**Single source of truth**: reads `history.md` (Current Snapshot + Decision Log).
Does NOT modify any files (read-only operation).

---

## Step 1: Task Resolution

1. Resolve current repo name:
   ```bash
   basename $(git rev-parse --show-toplevel 2>/dev/null || pwd)
   ```

2. Read MEMORY.md `## Active Dev Tasks` (already in context).
   For each listed memory file: read frontmatter `repo` to filter by current repo.

3. Match results:
   - **1 active task found**: auto-select
   - **Multiple active tasks**: show selection menu
     ```
     핸드오프 프롬프트를 생성할 태스크를 선택하세요:
       1. <task-name>   (build — 3/5 done)
       2. <task-name>   (design)
     > Enter number
     ```
   - **0 active tasks**: "현재 레포의 active 태스크가 없습니다" → stop

   **Fallback**: if MEMORY.md has no entries, scan devlog folder for `_state.json` (legacy — see `schemas/state.md`).

---

## Step 2: Read `history.md`

Check if `history.md` exists in the selected task directory:

- **Exists**: read and extract both sections
- **Does not exist**: inform the user and stop
  ```
  ⚠️  history.md가 아직 없습니다.
  /dev handoff는 첫 번째 step이 완료된 후 사용할 수 있습니다.
  먼저 /dev build 등 workflow step을 실행하세요.
  ```

Extract from `history.md`:
- **Current Snapshot section** (between the two comment markers): task name, branch, step, progress, next feature
- **Decision Log section**: filter entries where `status: open` → active blockers; last 1-2 `status: resolved` entries → recent decisions

---

## Step 3: Output Resume Prompt

Assemble and output the following as a fenced code block (`\`\`\``):

```
/dev build 이어서 진행해줘.

레포: <task from Current Snapshot>  |  브랜치: <branch>  |  Devlog: <devlog path>
현재 단계: build — <N>/<total> features 완료
다음 피처: <next pending feature name>
[다음 피처 없으면 생략 — 모두 완료 상태]
```

If recent Decision Log entries (status: resolved) exist:
```

최근 결정사항:
<bullet list: title + one-line summary>
```

If open blocker entries exist:
```

블로커:
<bullet list: title + content summary>
```

After the code block, add on a separate line:
```
이 내용을 다음 세션 시작 시 그대로 붙여넣으세요.
```
