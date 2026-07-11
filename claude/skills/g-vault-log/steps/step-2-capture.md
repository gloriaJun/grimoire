# Step 2: Capture to inbox

For session records with no project doc: one-off troubleshooting, design
discussions, learnings worth keeping.

## A. Path

- `$PWD` under `$HOME/Documents/GitHubWork` -> `$VAULT/inbox/work/`
- anything else -> `$VAULT/inbox/`
- Filename: `<kebab-slug>.md` derived from the note's topic (English,
  lowercase). Name taken -> try `<kebab-slug>-2.md` and increment up to
  `-9`; all taken -> ask the user for a name.

## B. Note

```markdown
---
created: YYYY-MM-DD
source: claude
tags: [<1-3 lowercase tags>]
---

# <제목>

## 배경
<왜 이 기록이 생겼나 - 세션 맥락 1-3문장>

## 내용
<결정/트러블슈팅/배운 것 - 증거(명령, 결과, 링크) 포함>

## 후속
<남은 일 - 없으면 "없음">
```

Content in Korean; commands, code, and error text stay English verbatim.
Only evidenced content; a section with nothing to say gets the explicit
none-marker shown in the skeleton, never invented text.

## C. Finish

Report the created path, and remind the user in one line that inbox notes
are theirs to triage (graduate to projects/wiki or delete, per the vault's
RULE.md). Never commit in the vault.
