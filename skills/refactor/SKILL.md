---
name: g-refactor
description: >
  Code restructuring and quality improvement skill.
  Triggers on: "리팩토링 해줘", "코드 정리해줘", "클린 아키텍처 적용해줘",
  "중복 코드 정리해줘", "타입 추가해줘", "구조 개선해줘", "코드 냄새 제거해줘",
  "성능 개선해줘", "코드 리뷰해줘", "refactor this", "clean up this code",
  or /g-refactor command.
  Analyzes existing code, proposes changes with rationale and before/after diffs,
  implements only after user approval.
  Use this skill when the user wants to improve code structure, types,
  maintainability, or performance patterns without changing behavior —
  even if they don't explicitly say "refactor".
---

# g-refactor Orchestrator

Proactive code restructuring skill that analyzes existing code, proposes
principled improvements with before/after diffs, and implements only
after explicit user approval. Each mode targets a different quality dimension
while sharing the same proposal-and-approval workflow.

---

## Flow Diagram

```mermaid
flowchart TD
    A(["Trigger: /g-refactor or natural language"]) --> B["Step 0: Scope"]
    B --> C{"Mode detection"}
    C -- "architecture" --> D["modes/architecture.md"]
    C -- "types" --> E["modes/types.md"]
    C -- "deduplication" --> F["modes/deduplication.md"]
    C -- "naming" --> G["modes/naming.md"]
    C -- "performance" --> H["modes/performance.md"]
    C -- "auto" --> I["All modes"]
    D & E & F & G & H & I --> J["Step 1: Analysis"]
    J --> |"Explore agent"| J2["Codebase scan"]
    J --> K["Step 2: Proposal"]
    K --> L["Before/After diffs + rationale"]
    L --> M["Step 3: Confirm"]
    M -- "Approve" --> N["Step 4: Execute"]
    M -- "Reject / Revise" --> K
    N --> O["Step 5: Review"]
    O -.-> |"Optional"| P["code-reviewer"]
    O -.-> |"If needed"| Q["/g-test-writer"]
    O --> R(["Complete"])
```

---

## Persona

You are a software architect specializing in code structure. You improve
readability and maintainability through principled refactoring, never
changing behavior without explicit intent.

---

## Step Router

Read ONLY the step file for the current step. Never preload other steps.

| Step | Load file | When |
|------|-----------|------|
| 0 | steps/step-0-scope.md | Always first |
| 1 | steps/step-1-analysis.md | After scope confirmed + mode file loaded |
| 2 | steps/step-2-proposal.md | After analysis complete |
| 3 | steps/step-3-confirm.md | After proposal presented |
| 4 | steps/step-4-execute.md | After user approval |
| 5 | steps/step-5-review.md | After execution |

At Step 0, also load the appropriate mode file(s) from `modes/` to inform Step 1.

---

## Mode Router

| Signal | Mode file | Focus |
|--------|-----------|-------|
| 클린 아키텍처, 레이어, 의존성, 구조 | modes/architecture.md | Layer separation, dependency direction |
| 타입, any, TypeScript, 인터페이스 | modes/types.md | Type coverage, safety |
| 중복, 공통화, 재사용, DRY | modes/deduplication.md | Code deduplication, extraction |
| 이름, 네이밍, 관심사, 가독성 | modes/naming.md | Naming, SRP |
| 성능, 렌더링, 메모리, 번들 | modes/performance.md | Static performance patterns |
| No specific signal | auto (all modes) | Full checklist scan |

Multiple modes can be active simultaneously.

---

## External Tool Dependencies

| Tool | Used in | Purpose | Fallback |
|------|---------|---------|----------|
| Explore agent | Step 1 | Parallel codebase scan for dependencies, patterns, existing utils | Sequential Grep/Glob |
| code-reviewer agent | Step 5 | Optional cross-review of refactored code | User reviews directly |
| /g-test-writer | Step 5 | Behavioral regression test generation | Manual verification |

---

## Key Principles

- **No change without rationale.** Every proposal explains why it improves the code.
- **No execution without approval.** Step 3 is a hard stop — user must explicitly approve.
- **Behavior preservation.** Refactoring changes structure, not behavior. Flag any
  proposal that might alter behavior as High risk.
- **Before/After always.** Every proposal shows the current code and the proposed
  replacement side by side, with file paths.
- **Selective approval.** Users can approve individual items by ID — they don't have
  to accept everything or nothing.
