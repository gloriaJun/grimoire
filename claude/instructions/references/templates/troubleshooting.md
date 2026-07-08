# Troubleshooting Record Template

Applies to problem-resolution records (retros, issue write-ups, resolved items in a devlog).
The full process already lives in PRs, commits, and tickets, so do not re-document it.

## Skeleton

```markdown
# {symptom-bearing title}

- 증상: {what failed and how. 1 line}
- 원인: {root cause. 1 line}
- 수정: {the applied fix. 1 line}
- 교훈: {reusable generalization. 1 line. remove the row if none}
- 참조: {PR/commit/ticket links}
```

## Forbidden

- Call-chain traces, log dumps, rejected-alternative comparisons, step-by-step verification logs.
- Detailed narration is allowed only in unresolved/follow-up items.
- If the document's TL;DR already summarizes the resolution, do not create a separate detailed "해결된 이슈" (resolved issues) section.
