# Note Entry Formats

Authoritative folder and frontmatter rules live in the vault's RULE.md;
this file fixes only the entry shapes g-vault-log writes. Entry content is
Korean; commands, code, and error text stay English verbatim.

## Decision entry (section `## 결정 기록`, newest at top)

```markdown
### YYYY-MM-DD <한 줄 제목>
- 결정: <무엇을>
- 이유: <왜>
- 기각한 대안: <있으면 - 없으면 이 줄 생략>
```

## Work-log entry (section `## 작업 로그`, newest at top)

```markdown
### YYYY-MM-DD <한 줄 제목>
- 한 일: <무엇을 했나>
- 증거: <명령 + 결과 요약, 커밋 해시, PR 링크>
- 남은 것: <없으면 "없음">
```

## Troubleshooting entry (also in `## 작업 로그`)

```markdown
### YYYY-MM-DD [TS] <증상 한 줄>
- 증상: <에러/현상 - 원문 인용>
- 원인: <확인된 원인 - 추정이면 "추정" 명시>
- 해결: <적용한 수정 + 검증 결과>
```

## Status block (between the g-dev markers, fully regenerated each write)

```markdown
<current-step> (기준일 YYYY-MM-DD)

| id | task | 상태 |
|---|---|---|
| t01 | <title> | done |
```

## Rules

- Entries are only ever added, newest at the top of the section; existing
  entries are NEVER edited. A reversal gets a new entry referencing the old
  entry's date.
- One entry per handoff; never split a single handoff into multiple
  entries.
- Every evidence line names something checkable: a command, a hash, a
  path, or a URL.
- Concurrent-edit discipline: re-read the doc immediately before each
  edit; the status block is replaced only between its markers; entries are
  inserted with a partial Edit anchored on the section heading; rewriting
  the whole doc file is forbidden.
