# Status: 작업 현황 보기

진행 중·완료된 작업을 한눈에 보여준다. 활성 작업이 없어도 동작한다.

## Process

### 1. MEMORY.md 기반 스캔 (기본)

MEMORY.md는 세션 시작 시 이미 컨텍스트에 있다. 두 섹션을 읽는다:
- `## Active Dev Tasks` — 진행 중
- `## Completed Dev Tasks` — 완료 (포인터는 `<task>-log.md`)

각 포인터가 가리키는 파일의 frontmatter를 읽는다:
- 진행 중(`state.md`): `repo`, `current-step`, `task-name`, `created`, `updated`
- 완료(`<task>-log.md`): `repo`, `task-name`, `completed`

한 줄 진행 상황은 `state.md`의 `## Current Step` 첫 줄, 다음 할 일은 `## Features` 표의 첫 `⏳ pending` 기능에서 가져온다.

### 2. 누락 작업 스캔 (폴백)

MEMORY.md에 항목이 없거나 `--all` 플래그가 있을 때만 실행한다.

`<memory-root>`(= `~/.claude/projects/<project-id>/memory/`)에서 MEMORY.md에 없는 `YYYY-MM-DD-*/state.md`를 찾아 출력에 추가하고 MEMORY.md에 다시 등록한다.

### 3. 출력

진행 중인 작업은 작업당 3줄(요약/단계/다음 할 일)로 보여준다. 완료 작업은 한 줄로 모은다.

```
■ 진행 중

  <task-name>   <repo>
    요약    <state.md ## Current Step 첫 줄>
    단계    <current-step>  ·  완료 <done>/<total> 기능
    다음    <다음 ⏳ 기능 이름, 없으면 "—">
    💤 <N>일째 미진행          ← updated가 오늘 기준 7일 이상일 때만

  ...

■ 완료

  <task-name>   <repo>   완료 <completed>
  ...

진행 중이거나 완료된 작업이 없습니다.
```

규칙:
- 진행 중인 작업을 먼저, 완료 작업은 그 아래.
- 완료 작업이 없으면 `■ 완료` 블록 생략. 아무것도 없으면 마지막 한 줄 안내만 출력.
- 정체 마커: `updated` frontmatter(완료는 `completed`)가 오늘(컨텍스트의 `currentDate`) 기준 **7일 이상** 지난 진행 중 작업에 `💤 <N>일째 미진행`을 붙인다. 정체 작업을 눈에 띄게 해 재개·정리를 돕는다.
- 날짜: `created`/`completed` frontmatter, 없으면 디렉토리명의 날짜 접두사.
- 작업 이름: `task-name` frontmatter, 없으면 디렉토리명.
- `--repo` 플래그나 "이 레포" 같은 표현이 있으면 현재 레포로 필터링한다.
