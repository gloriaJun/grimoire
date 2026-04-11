# User Prompt Patterns

Standard UX patterns for requesting user input during the task-process workflow.
All step files should follow these patterns for consistency.

---

## Single Choice (1 answer needed)

Present numbered options. Accept either a number or a free-text response.

```
<context sentence>:
1. <option A>
2. <option B>
3. <option C>

> 번호 입력 또는 자유 응답
```

**Rules:**
- Always include a number for each option
- If the user replies with a number, map to the corresponding option
- If the user replies with free text, interpret intent and confirm if ambiguous
- Max 5 options. If more exist, group or filter first.

**Example:**
```
TRD 리뷰 방식을 선택해주세요:
1. Plannotator 시각적 리뷰
2. 텍스트 기반 인라인 리뷰
3. 건너뛰기
```

---

## Multiple Inputs (2+ answers needed)

Use AskUserQuestion with structured fields when collecting multiple inputs at once.

```
다음 항목을 확인해주세요:
- 구현 에이전트: Claude / Codex
- 리뷰 범위: 전체 / 변경 파일만
- 프론트엔드 리뷰 필요: Y / N
```

**Rules:**
- Each field on its own line with clear options
- Provide defaults where possible (mark with bold or parentheses)
- Accept partial answers — only re-ask for missing fields

---

## Confirmation (Y/N)

For binary decisions, use a direct confirmation prompt.

```
PRD가 완성되었습니다. 다음 단계(설계)로 진행할까요? (Y/n)
```

**Rules:**
- Default action is capitalized: `(Y/n)` means default is Yes
- Accept: y, yes, 네, ㅇ, enter → Yes
- Accept: n, no, 아니오, ㄴ → No
- Any other response: re-confirm with the user

---

## Fallback Warning (Plannotator unavailable)

Use this when review mode is Plannotator but CLI is unavailable or launch fails.

```
[WARN] Plannotator CLI가 설치되어 있지 않거나 실행할 수 없어 텍스트 리뷰 모드로 전환이 필요합니다.
- 현재 모드: Plannotator
- 전환 모드: Inline text review

텍스트 리뷰로 계속 진행할까요? (Y/n)
```

**Rules:**
- Always show the `[WARN]` prefix as a visual indicator
- Ask confirmation before fallback (default yes)
- If user says no, stay in the current step and offer retry/skip

---

## Revision Loop

When the user requests changes after a review.

```
수정할 내용을 알려주세요. 완료되면 "확인" 또는 "done"을 입력해주세요.
```

**Rules:**
- Stay in revision loop until explicit completion signal
- After each revision, re-present the updated artifact
- Max 3 iterations before suggesting a step back to re-evaluate
