# Retro Note Format

Template, writing rules, and field guide for `retro.md`. Loaded by `tools/retro/SKILL.md`.

## Template

```markdown
---
date: YYYY-MM-DD
task: <task-name>
scope: <scope>
audience: personal
tags: []
keywords: []
summary: "<한 줄 요약>"
effort: S | M | L
related: []
follow_up: []
---

## 한 일
- **목표:** (이 작업에서 해결하려던 것 — 작업명을 몰라도 읽히게)
- 스택 / 도구:

## 잘된 점

## 아쉬운 점

## 다음에 바꿀 것
<행동·습관·프로세스 변화 — "다음엔 X 하겠다">

## 배운 것 (기술)
<기술 사실·패턴 — "X 상황에서는 Y 방법을 쓴다" 형태로 일반화>

## 트러블슈팅 (있으면)
### [문제 제목]
- **증상:**
- **원인:** (불명확하면 Unknown으로 명시)
- **해결:**

## 참고 자료

## 링크
```

## Writing Rules (personal knowledge records)

- Plain, everyday language that reads clearly six months later; spell out jargon
  and feature IDs.
- No AI-report style (feature tables, completion percentages) — full sentences on
  what was done and why.

## Field Guide

- `tags`: required — 1–3 topic tags
- `keywords`: optional — searchable specifics (error messages, package names, symptoms)
- `summary`: required — one sentence: what was retrospected, core lesson
- `effort`: optional — S (< 2h), M (2–8h), L (> 8h)
- `follow_up`: optional — remaining tech debt, things to dig into
- `다음에 바꿀 것` vs `배운 것`: behavior/habit change vs technical fact
- `한 일 > 목표`: required — a reader who doesn't know the task must get the
  background in one sentence (Every Page is Page One).

## Team Mode (`audience: team`) Extras

- `한 일 > 목표`: 2–3 sentences for readers with zero context
- `배운 것`: add why the situation arises
- `트러블슈팅 > 원인`: no `Unknown` — confirmed facts only (drop the item if unclear)
- `참고 자료`: required learning material for readers
