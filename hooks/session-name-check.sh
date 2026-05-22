#!/usr/bin/env bash
# UserPromptSubmit hook: inject session naming instruction if session has no name yet.
# Reads session_id from stdin JSON; checks ~/.claude/session-names/<id> file.
# Injects additionalSystemPrompt on first prompt if unnamed; silent on subsequent prompts.

INPUT=$(cat)
SESSION_ID=$(echo "$INPUT" | jq -r '.session_id // empty')

[ -z "$SESSION_ID" ] && exit 0

SESSION_DIR="$HOME/.claude/session-names"
SESSION_FILE="$SESSION_DIR/$SESSION_ID"

[ -f "$SESSION_FILE" ] && exit 0

PROMPT="⚠️ [Session Naming Required] 이 세션(ID: ${SESSION_ID})에 아직 이름이 없습니다. 사용자의 요청을 처리하기 전에 반드시 다음 순서로 행동하세요: (1) 세션 이름을 물어보세요 (예: 'auth-refactor', 'daily-debug' 등 짧은 영문 슬러그 권장). (2) 이름을 받으면: mkdir -p ${SESSION_DIR} && echo '<이름>' > ${SESSION_FILE} (3) 'skip' 또는 '없음'이면: echo 'unnamed' > ${SESSION_FILE} (4) 저장 후 원래 요청을 처리하세요."

echo "{\"hookSpecificOutput\": {\"additionalSystemPrompt\": $(printf '%s' "$PROMPT" | jq -Rs .)}}"
