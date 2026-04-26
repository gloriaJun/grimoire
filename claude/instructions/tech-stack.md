# Tech Stack Preferences

## Package Manager
- pnpm preferred for all projects

## Node.js Version Manager

- mise를 기본 Node.js 버전 관리 도구로 사용한다
- 전역 설정(`~/.config/mise/config.toml`)에 `legacy_version_file = true` 활성화
  → mise가 `.nvmrc`를 자동 인식

### 프로젝트 적용 규칙

| 상황 | 처리 방식 |
|------|-----------|
| `.nvmrc` 없음 | 프로젝트 루트에 `.mise.toml` 생성 |
| `.nvmrc` 있음 | `.mise.toml`로 전환하고 `.nvmrc` 삭제 |

### `.mise.toml` 형식

```toml
[tools]
node = "22"   # 메이저 버전 고정 (mise가 최신 패치 자동 선택)
```

## JavaScript / TypeScript

Defaults for JS/TS projects:
- **Language**: Prefer TypeScript. If starting in JS, plan a migration path.
- **Linting**: ESLint (configure at project init)
- **Formatting**: Prettier (integrate with ESLint, use `.prettierrc` or `prettier.config.ts`)
- Project-specific ESLint rule sets and Prettier config may override these in each repo's CLAUDE.md

## JS/TS File Conventions

Single-responsibility principle at the file level:

- **No mixing constants and functions**: A file whose role is to export immutable values must not define functions (transformation logic, utilities)
- **Split by role, even within the same domain**: e.g. `auth-constants.ts` + `auth-utils.ts`
- This applies regardless of filename (`constants.ts`, `config.ts`, `tokens.ts`, etc.) — if the file's purpose is "a collection of immutable values", no function mixing allowed

When file-level conventions grow to 5+ rules, extract to `instructions/js-ts-conventions.md`.

## General
- Specific frameworks and libraries are defined per project in each repo's CLAUDE.md
- This file covers cross-project preferences only
