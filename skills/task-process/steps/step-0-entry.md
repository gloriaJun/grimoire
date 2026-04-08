# Step 0: Entry Point Selection

Ask the user to select their starting point (follow `references/user-prompt-patterns.md` Single Choice pattern):

```
시작점을 선택해주세요:
1. 아이디어가 있어요 — 아직 막연한 컨셉 (Step 1)
2. 요구사항을 정리하고 싶어요 — 대략적인 요구사항 있음 (Step 2)
3. PRD / 기획 문서가 있어요 — 외부 문서 보유 (Step 3)
4. 설계가 끝났어요 — PRD + TRD 완료 (Step 4)
5. 바로 구현할게요 — 범위가 명확함 (Step 5)

> 번호 입력 또는 자유 응답
```

| # | Choice | What you have | Starts at |
|---|--------|--------------|-----------|
| 1 | "I have an idea" | Vague concept | Step 1 (idea-explorer) |
| 2 | "I want to define requirements" | Rough requirements | Step 2 (requirements-analyst) |
| 3 | "I have a PRD / planning doc" | External PRD | Step 3 (system-architect) |
| 4 | "Design is done" | PRD + TRD | Step 4 (feature breakdown) |
| 5 | "Just implement" | Clear scope | Step 5 (feature-executor) |

## External Document Handling

If the user has an external document (planning doc, PRD, etc.):
- Ask for the file path
- Copy or link it into the task subdirectory
- Register it in `_state.json` artifacts
- Use it as input for the appropriate agent

## State Update

After user confirms selection:
1. Set `entryPoint` in `_state.json`
2. Set `currentStep` to the selected step number
3. Append to `completedSteps`: `[0]`
4. Log to `history`

**Confirm selection with user before proceeding.**
