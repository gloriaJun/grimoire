# Code Review Guidelines

Applies when the user requests a review of their own code
("코드 리뷰해줘", "내 코드 리뷰", "review my code").

Does NOT apply to reviewing someone else's code or an existing PR:
follow the PR-review flow the current repository defines instead.

## Process

1. Ask once: "simplify를 먼저 실행할까요? (Y/n)". If yes, run the `simplify`
   skill (when available in the environment) and wait for it to finish.
2. Determine the target: the working-tree diff (`git diff HEAD`), or the files
   the user named. Empty diff and no named files → report "리뷰 대상 없음" and stop.
3. Review covering, in order: bugs, security, performance, readability, and one
   adversarial pass ("with what input or state does this break?").
4. Write the findings to a scratchpad file `code-review.md`, one section per
   finding: file:line, severity (high/medium/low), what breaks, concrete fix.
   Zero findings → skip plannotator, state "발견 없음" in chat, and stop.
5. Post the high-severity findings inline in chat, then run
   `plannotator review --git` so the user can walk the diff in the browser
   with the findings file at hand.
6. Apply the feedback plannotator returns when it exits. No feedback → report
   "피드백 없음" and stop. If the `plannotator` command is missing, print the
   full findings file in chat instead and stop.
