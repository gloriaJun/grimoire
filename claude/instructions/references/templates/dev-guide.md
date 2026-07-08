# Development Guide Template

Applies to development guides for repository contributors (CONTRIBUTING, development rule docs).
This is a collection of rules and commands referenced repeatedly. For linear procedures performed once, use `guide.md`.

## Skeleton

```markdown
# {project name} 개발 가이드

{target audience and scope of this document. 1 line}

## 개발 환경

{required tools/versions as bullets + setup commands as a code block}

## 명령어

{table: | 작업 | 명령 |. order: build, test, lint, run}

## 코드 컨벤션

{repository-specific rules only. exclude what the linter/formatter enforces. bullets}

## 브랜치·PR 규칙

{branch naming, commit format, PR requirements. bullets}

## 테스트

{how to run in 1 line + writing rules (location, naming, coverage criteria). bullets}
```
