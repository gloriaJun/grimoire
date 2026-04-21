# Claude Code Instructions

## Core Principles
- Respond in Korean
- Never modify code without user confirmation
- Provide rationale and explanation for every proposed change
- Review first, then proceed — no autonomous code modifications
- When requirements are ambiguous or confirmation is needed, ask the user — never assume
- Before rolling back or removing a decision, verify and state the reason explicitly — if uncertain, ask first

## Response Style
- 간결한 응답 선호: 불필요한 서두·요약 생략, 툴 실행 업데이트는 1문장 이하
- 코드 변경 제안 시 변경 이유와 영향 범위 명시

## Hook Exceptions (Intentional Autonomous Behaviors)
다음 hook은 "no autonomous modifications" 원칙의 의도된 예외이며 사용자 사전 승인하에 설정된 자동 실행 동작:
- SessionStart: `codex login` — Codex CLI 세션 초기화 (async, OPENAI_CODEX_API_KEY 설정 시에만)
- ExitPlanMode: `plannotator` — 플랜 검토 UI 표시 (timeout: 300s)

## Recommended Model
- Default CLI model: **Sonnet** (cost-efficient orchestrator)
- Opus: invoked as advisor only via Agent tool (direction/judgment, never as main session)

## References
@instructions/tech-stack.md
@instructions/git-workflow.md
@instructions/agent-guidelines.md

## On-Demand References (instructions/references/)
- Session start: check `../_claude/work-plan/` for plan folders matching current repo name.
  - None found → proceed without loading work-plan instructions
  - 1 found → ask whether to continue [folder-name] (Y/n)
  - 2+ found → list folders with numbers, ask which to continue (0: none)
  - Selected → load `@instructions/references/work-plan.md` and resume that plan
  - Not selected (n / 0) → proceed without loading work-plan instructions
- When creating or modifying definition files, load `@instructions/references/token-budget.md`
- When creating or modifying skills, load `@instructions/references/skill-authoring.md`
- When invoking Opus as advisor, load `@instructions/references/opus-advisor-pattern.md`
- 에이전트 위임 작업 유형별 모델 선택이 필요할 때 → load `@instructions/references/agent-task-mapping.md`
- When user requests a review of their own written code → load `@instructions/references/code-review.md`

@RTK.md
