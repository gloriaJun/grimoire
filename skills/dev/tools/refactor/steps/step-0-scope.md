# Step 0: Scope Collection + Mode Detection

Goal: Determine what code to refactor and which analysis mode(s) to apply
before any deep analysis begins.

## 0a. Check Existing Context

Scan the current conversation for:
- File paths or directory references
- Code blocks or snippets
- Specific complaints ("이 함수가 너무 길어", "중복이 많아", "any가 너무 많아")
- Referenced components, modules, or features

If sufficient context exists (target files + user intent are clear), skip to 0c.

## 0b. Request Missing Information

If the conversation lacks a clear refactoring target, ask:

```
What would you like to refactor?

1. Specific file(s) or function(s) — provide path or name
2. A feature or module — describe which part of the codebase
3. General review — point me to a directory to scan
```

Accept any input format. If the user names a feature rather than a file, use
Glob/Grep to locate the relevant files before proceeding.

## 0c. Auto-Detect Mode

Match user input against mode signals:

| Signal keywords | Mode | Load file |
|----------------|------|-----------|
| 클린 아키텍처, 레이어, 의존성, 분리, 구조 | **architecture** | modes/architecture.md |
| 타입, any, TypeScript, 인터페이스, 제네릭 | **types** | modes/types.md |
| 중복, 공통화, 재사용, DRY, 반복 | **deduplication** | modes/deduplication.md |
| 이름, 네이밍, 관심사, 가독성, 함수 분리 | **naming** | modes/naming.md |
| 성능, 렌더링, 메모리, 번들, 느려, 최적화 | **performance** | modes/performance.md |
| No specific signal or general refactor request | **auto** | All modes (Step 1 runs full checklist) |

Multiple modes can be active simultaneously if the user's request spans categories.

## 0d. Present Scope Summary

Show the detected scope and get user confirmation:

```
## Refactor Scope
- **Target**: <file(s), function(s), or directory>
- **Mode**: <detected mode(s)>
- **Goal**: <inferred user intent>

Proceed with this scope? (Y / adjust)
```

Allow the user to:
- Add or remove files from scope
- Change the mode
- Narrow or broaden the goal

**Confirm with user before proceeding to Step 1.**
