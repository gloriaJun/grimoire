# next-session-prompt — Next Session Resume Prompt Generator

Generate a self-contained prompt to paste at the start of the next session.
Triggered by: `/dev handoff`, "다음 세션 프롬프트 생성해줘", "세션 인계 프롬프트",
"이어서 할 프롬프트 만들어줘", "다음 작업 프롬프트", "handoff prompt", etc.

**Single source of truth**: reads only `next-session.md`.
Does NOT modify any files (read-only operation).

---

## Step 1: Task Resolution

1. Run Devlog Path Detection (from SKILL.md):
   - `cwd` contains `GitHubWork` → `~/Documents/GitHubWork/_claude/devlogs/`
   - `cwd` contains `GitHubPrivate` → `~/Documents/GitHubPrivate/_claude/devlogs/`
   - Neither → ask the user

2. Resolve current repo name:
   ```bash
   basename $(git rev-parse --show-toplevel 2>/dev/null || pwd)
   ```

3. Pass 1 — filter devlog folders by repo name substring:
   - Read `_state.json` for matched folders to identify active tasks
   - Active: `currentStep NOT IN completedSteps`

4. Match results:
   - **1 active task found**: auto-select
   - **Multiple active tasks**: show selection menu
     ```
     핸드오프 프롬프트를 생성할 태스크를 선택하세요:
       1. 2026-05-19-<repo>-task-a   (build — 3/5 done)
       2. 2026-05-10-<repo>-task-b   (breakdown)
     > Enter number
     ```
   - **0 active tasks**: "현재 레포의 active devlog가 없습니다" → stop

---

## Step 2: Read `next-session.md`

Check if `next-session.md` exists in the selected task directory:

- **Exists**: read and extract all sections
- **Does not exist**: inform the user and stop
  ```
  ⚠️  next-session.md가 아직 없습니다.
  /dev handoff는 build step이 처음 실행된 후 (첫 피처 완료 시) 사용할 수 있습니다.
  먼저 /dev build 를 실행하세요.
  ```

Extract from `next-session.md`:
- **재개 현황** section: 레포, 브랜치, Devlog 경로, 진행률, 다음 피처
- **구현 결정사항 & 아키텍처 노트** section (if present)
- **블로커 / 다음 세션 전 확인사항** section (if present)

---

## Step 3: Output Resume Prompt

Assemble and output the following as a fenced code block (`\`\`\``):

```
/dev build 이어서 진행해줘.

레포: <repo>  |  브랜치: <branch>  |  Devlog: <task-dir>
현재 단계: build — <N>/<total> features 완료
다음 피처: <next pending feature name>
[아직 없으면 생략]
```

If **구현 결정사항** section has content:
```

주요 결정사항:
<bullet list from section>
```

If **블로커** section has content:
```

블로커:
<bullet list from section>
```

After the code block, add on a separate line:
```
이 내용을 다음 세션 시작 시 그대로 붙여넣으세요.
```
