# Code Review Guidelines

Applies when the user requests a review of their own written code.
("코드 리뷰해줘", "내 코드 리뷰", "review my code" 등)

Does NOT apply to:
- `/l-pr review` or PR number provided → use `l-pr review` skill instead
- Reviewing someone else's code or a PR

## Process

1. Ask: "simplify를 먼저 실행할까요? (Y/n)"
2. If yes: invoke the `simplify` skill and wait for completion before proceeding
3. Perform code review covering: bugs, security, performance, readability, adversarial perspective
4. Render review results as a self-contained HTML file, save to `/tmp/`, and open in the browser
