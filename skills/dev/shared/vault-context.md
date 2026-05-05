# Vault Context Lookup

Shared utility for dev skill stages. Run before main work to surface related vault content.
Uses the same grep-first → frontmatter-score → top-N-read strategy as the obsidian query skill.

---

## Input

| Parameter | Values | Description |
|-----------|--------|-------------|
| `keywords` | string[] | Extracted from task name, description, or error message |
| `search_focus` | `duplicate` \| `past-mistakes` \| `error-history` \| `references` | Controls which folders to search |
| `scope_hint` | `work` \| `life` \| nil | Narrows search to scoped folders if set |

---

## Search Folders by Focus

| Focus | Primary Folders | Notes |
|-------|----------------|-------|
| `duplicate` | `02_Ideas`, `03_Logs` | Detect overlapping plans or in-progress tasks |
| `past-mistakes` | `04_Notes/retrospect`, `04_Notes/process`, `04_Notes/til` | Surface lessons from past retro/TIL |
| `error-history` | `04_Notes` (all) | Match `keywords:` frontmatter field first |
| `references` | `10_Knowledge` | Curated reference material for design/build |

Vault root: `~/Documents/obsidian-vault/`

If `scope_hint` is set, filter by `scope: <scope_hint>` frontmatter after scoring.

---

## Token Budget

Follow this sequence strictly. Never jump to a later step if an earlier one yields no results.

### Phase 1 — Grep (0 file reads)

```bash
grep -ril "<keyword>" ~/Documents/obsidian-vault/<target-folder>/
```

Run per keyword. Collect file paths. Count keyword hits per file. Deduplicate.
Keep top 20 by hit count.

### Phase 2 — Frontmatter Score (30 lines × top 20 = max 600 lines)

For each of the top 20 candidates, read first 30 lines only.

Scoring:
- +3: keyword found in `title`
- +2: keyword found in `summary`
- +2: keyword found in `tags`
- +2: keyword found in `keywords` field (TIL files — error-history focus)
- +1: `status: reference` (curated, prefer)
- -1: `status: archived` (deprioritize)

Total score: `(hit_count × 2) + frontmatter_score`. Sort descending. Keep top 3.

### Phase 3 — Deep Read (top 3 × 200 lines = max 600 lines)

Read the top 3 files. Max 200 lines each.
Extract: title, key findings, relevant section headings.

---

## Output

### Results found

```
📚 Vault Context
─────────────────────────────────────────────
[중복 주의] 유사 작업 발견:
  • 2026-04-28 OpenChat Release Ops (03_Logs) — scope: work
  • 2026-04-07 Sentry Alert Skill (03_Logs) — scope: work

[과거 실수] 관련 회고/TIL:
  • retro: Sentry 알림 스킬 재발 방지 — 배포 전 알림 조건 검증 누락
  • til: n8n webhook 파싱 오류 — keywords: webhook, payload, 400

[참고 자료] 관련 지식:
  • 10_Knowledge/dev/debugging-tips.md — Chrome DevTools 성능 분석
─────────────────────────────────────────────
```

Show only sections that have results. Omit empty sections entirely.

### No results

Output nothing. Proceed silently to the next step.

---

## Automation Suggestion

After output, check: if `duplicate` focus returned **2 or more** similar tasks:

```
⚡ 자동화 기회: 유사한 작업이 반복되고 있습니다 — 스킬 또는 스크립트 자동화를 검토해보세요.
```

Trigger this message only once per session, only when the threshold is met.

---

## Caller Instructions

Each calling step passes:
1. Keywords (extract from task name/description/error — 2–5 terms)
2. One or more focus values
3. scope_hint if known from devlog or cwd

After output (or silent pass), proceed with the step's main logic.
Do NOT block or ask the user about vault results — present them as context only.
