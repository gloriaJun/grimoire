# Build: Stagnation Escape

Triggered when tests fail after 2 implementation iterations.

## Escape Menu

```
테스트가 2회 시도 후에도 통과되지 않습니다.

복구 방법을 선택하세요:
  1. 범위 축소   — non-essential AC 제외 후 재구현
  2. 실행기 전환 — Claude ↔ Codex 전환
  3. 피처 분할   — F-Xa(기반) + F-Xb(막힌 부분)으로 분할; F-Xb 연기
  4. 테스트 연기 — "pending" 마킹 후 /dev complete 전 처리
  5. 에스컬레이션 — 진단 메모와 함께 사용자에게 위임

> 번호 입력
```

## Option Handling

| Option | Action |
|--------|--------|
| 1 | Scope reduction: remove non-essential AC, return to feature-executor for re-implementation |
| 2 | Switch executor: toggle Claude ↔ Codex; update `features[i].executor` in `_state.json` |
| 3 | Split feature: add F-Xa (base) + F-Xb (blocked) to `features.md` and `_state.json.features`; defer F-Xb |
| 4 | Defer tests: add `> ⚠️ 테스트 연기됨` warning to feature spec; append stagnation entry to `history.md` Decision Log (see `schemas/history.md` Stagnation Entries) |
| 5 | Escalate: write diagnostic note; surface to user for direct resolution |

After handling: return to the calling flow's "proceed to cross-review" step.
