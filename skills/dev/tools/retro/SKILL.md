---
name: retro
description: >
  Tool loaded by /dev skill via Read(). Triggered by /dev retro.
  Not a standalone skill — invoked only from dev/SKILL.md.
---

# Retro — 회고 + 배운 점 노트

완료된 작업의 회고(잘된 점·아쉬운 점·다음에 바꿀 것)와 기술적으로 배운 점을 **하나의 노트**로
묶어 Obsidian vault에 발행한다. devlog가 있든 없든 동작한다.

> 이전의 `retro`/`til` 두 단계를 하나로 합친 명령이다. 작업 내부 정리는 `/dev complete`가
> `<task>-log.md`로 끝내고, 이 명령은 그 내용을 vault에 정리해 남기는 역할만 한다.

---

## 진입 확인

**현재 레포 이름** (main repo root 기준 — worktree에서도 메인을 가리킴):
```bash
REPO_ROOT=$(dirname "$(git rev-parse --path-format=absolute --git-common-dir 2>/dev/null)")
[ -d "$REPO_ROOT" ] || REPO_ROOT=$(git rev-parse --show-toplevel 2>/dev/null || pwd)
basename "$REPO_ROOT"
```

**후보 작업 탐색** — MEMORY.md의 `## Completed Dev Tasks`와 `## Active Dev Tasks`에서 현재 레포(`repo`)로 필터:
- **완료 작업**: 포인터가 `<task>-log.md`를 가리키는 항목 (가장 흔한 경우)
- **진행 중 작업**: `state.md`의 `current-step`이 `complete` 직전까지 온 항목

후보가 여러 개면 목록을 보여주고 사용자가 고르게 한다.

**모드 결정:**
- **완료 모드** (`<task>-log.md` 존재): 로그 파일을 읽어 `## 결과`·`## 과정에서 고민한 것`·`## 배운 것`을 입력으로 쓴다.
- **진행 중 모드** (`state.md`만 있고 아직 complete 전): 경고만 하고 막지는 않는다. `state.md`·`history.md`에서 컨텍스트를 모은다.
- **단독 모드** (후보 없음): 사용자에게 직접 묻는다.

진행에 앞서 한 번 확인: "**<task-name>** 회고 노트를 작성할까요? (y/n)"
- `n` → 중단. "건너뜀. 나중에 `/dev retro`로 언제든 작성할 수 있습니다."
- `y` → 진행

---

## 컨텍스트 수집

- **완료 모드**: `<task>-log.md`의 요약·결과·고민·배운 점.
- **진행 중 모드**: `state.md`의 `task-name`·`## Artifacts`, `history.md`의 결정·블로커 기록.
- **단독 모드**: 작업 이름과 한 일을 사용자에게 묻는다.

---

## 실행

vault에 노트 하나(`retro.md`)를 쓴다.

1. 출력 경로 결정:
   - `~/Documents/obsidian-vault/04_Notes/<scope>/YYYY-MM-DD-<task-name>/retro.md`
   - 폴더가 없으면 만든다.
2. `scope`는 cwd로 판단:
   | cwd 포함 | scope |
   |---|---|
   | `GitHubWork` | `work` |
   | `GitHubPrivate` | `life` |
   | 둘 다 아님 | 사용자에게 질문 |
3. **용도(audience) 선택** — 한 번 묻는다:
   ```
   이 노트의 용도를 선택하세요:
     1. 개인 메모 (기본) — 내가 나중에 참고
     2. 팀 공유 — 팀원이 읽을 기술 문서
   ```
   - `1` 또는 Enter → `audience: personal`
   - `2` → `audience: team`
4. **Action Items 초안 확인** (완료/진행 중 모드, 입력 컨텍스트가 있을 때):
   - `<task>-log.md`의 `## 배운 것`/`## 과정에서 고민한 것`(또는 history.md 결정·블로커 기록)에서 후보 3~5개 도출
   - 사용자에게 제시:
     ```
     Action Items 초안:
     - [ ] ...
     - [ ] ...

     수정·추가할 항목이 있으면 알려주세요. 없으면 그대로 진행합니다.
     ```
   - 응답을 반영해 확정. 단독 모드이거나 입력 컨텍스트가 없으면 건너뜀.
5. 아래 템플릿으로 `retro.md`를 쓴다:

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

작성 규칙 (개인 지식 관리용 기록):
- 6개월 뒤 다시 읽어도 이해되도록 **일상 언어**로 쓴다. 전문 용어·기능 ID는 풀어 쓴다.
- AI 보고서체(기능 표·완료율 나열) 금지 — "무엇을 왜 그렇게 했는지"를 문장으로 남긴다.

필드 가이드:
- `tags`: 필수 — 주제 태그 1~3개
- `keywords`: 선택 — 검색용 구체 용어(에러 메시지·패키지명·증상)
- `summary`: 필수 — 무엇을 회고했고 핵심 교훈은 무엇인지 한 문장
- `effort`: 선택 — S (< 2h), M (2–8h), L (> 8h)
- `follow_up`: 선택 — 남은 기술 부채·추가로 파볼 항목
- `다음에 바꿀 것` vs `배운 것`: 전자는 행동/습관 변화, 후자는 기술 사실
- `한 일 > 목표`: 필수. 작업명을 모르는 독자도 배경을 한 문장으로 이해할 수 있게 (Every Page is Page One 원칙).

**팀 공유 모드(`audience: team`) 보강:**
- `한 일 > 목표`: 배경 지식 없는 독자가 이해하도록 2~3문장으로 상세히
- `배운 것`: "왜 그 상황이 생기는지" 배경 설명 추가
- `트러블슈팅 > 원인`: `Unknown` 금지 — 확인된 사실만 (불명확하면 해당 항목 삭제)
- `참고 자료`: 독자 학습용 자료 필수 (개인 모드에서는 선택)

노트를 쓴 뒤 `related:`와 `참고 자료`를 채운다:

1. `shared/vault-context.md`를 Read하고 다음으로 실행:
   - **keywords**: `keywords` 필드 값(있으면), 없으면 `tags` + `task-name` 용어
   - **search_focus**: `references`, `error-history`, `past-mistakes`
   - **scope_hint**: `scope`와 동일
2. 상위 매칭 파일(최대 3개):
   - `04_Notes` 파일 → `related:`에 `"[[path/to/file]]"`로 추가
   - `10_Knowledge` 파일 → `참고 자료`에 `[[path/to/file]] — <frontmatter 요약>`로 추가
3. 매칭 없으면 그대로 둔다.

---

## 상태 갱신

- **완료 모드**: `state.md`는 이미 삭제됐다. `<task>-log.md`의 `## 참고 문서` 아래에
  `- 회고: 04_Notes/<scope>/YYYY-MM-DD-<task-name>/retro.md` 한 줄을 추가한다.
  MEMORY.md 완료 포인터는 그대로 둔다.
- **진행 중 모드**: `state.md`의 `## Artifacts`에 `retro: <경로>`를 추가하고 `updated`를 오늘로 갱신.

## 03_Logs 아카이브 제안 (완료 모드만)

`~/Documents/obsidian-vault/03_Logs/<scope>/`에 이 작업과 같은 이름의 폴더가 있으면 묻는다:

```
📦 03_Logs에 완료된 작업 폴더가 남아 있습니다: <folder>
20_Archive로 이동할까요? (Y/n)
```

- Y: `20_Archive/`로 폴더 이동 (mv). 완료 작업 로그가 활성 목록에 쌓이는 것을 방지한다.
- n: 그대로 둔다.

---

## 완료

```
✅ 회고 노트 저장 완료 — <task-name>

📄 <retro-path>
```

작업 라이프사이클이 모두 끝났습니다. 다음 단계는 없습니다.
