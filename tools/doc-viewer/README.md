# doc-viewer

영문 instruction·skill 정의 파일을 한국어 번역과 함께 보여주는 정적 뷰어.

- 정의 파일은 정책상 영어로만 작성, 한국어 가독성은 이 뷰어가 담당
- 영어 원문이 유일한 기준(source of truth), 번역은 표시 전용 sidecar JSON
- 빌드 결과는 의존성 없는 단일 `dist/index.html`

- [실행 방법](#실행-방법)
- [번역 갱신 워크플로우](#번역-갱신-워크플로우)
- [설정](#설정)
- [기능 요약](#기능-요약)
- [산출물과 gitignore](#산출물과-gitignore)

## 실행 방법

```bash
cd tools/doc-viewer
pnpm install     # 최초 1회
pnpm build       # dist/index.html 생성
node serve.mjs   # http://localhost:4173
```

포트는 `PORT=5000 node serve.mjs`처럼 환경 변수로 바꾼다.
리포지토리 루트 `.claude/launch.json`에 `doc-viewer` 항목이 있어,
Claude Code preview 도구가 이 서버를 직접 띄울 수 있다.

## 번역 갱신 워크플로우

```mermaid
flowchart LR
  A["원문 .md 수정"] --> B["pnpm build skeleton [rootName]"]
  B --> C["빈 ko 채우기 (Claude agent 위임)"]
  C --> D["pnpm build"]
```

`pnpm build skeleton [rootName]`은 `translations/<root>/<relpath>.json`을
다시 생성한다. src 블록이 그대로인 세그먼트는 기존 `ko`를 유지하므로,
새로 생기거나 바뀐 블록만 채우면 된다. `rootName`을 주면 해당 루트만 갱신.

sidecar 형식:

```json
{ "segments": [ { "src": "<원문 markdown 블록>", "ko": "<한국어 markdown>" } ] }
```

stale 감지: 빌드 시 sidecar의 src 전체를 현재 원문과 공백 무시로 비교한다.
불일치하면 해당 문서 상단에 stale 경고 배너가 뜬다. skeleton 재생성 뒤
`ko`가 빈 세그먼트는 재번역 전까지 영어 원문만 보인다.
sidecar가 아예 없는 파일은 트리에 `EN` 배지가 붙고 원문만 렌더링.

## 설정

`doc-viewer.config.json`으로 여러 문서 루트를 등록한다.

```json
{
  "roots": [
    { "name": "grimoire", "path": "../../claude" },
    { "name": "my-claude-skills", "path": "~/Documents/GithubWork/my-claude-skills" }
  ],
  "ignore": ["node_modules", ".git", "dist", ".claude-plugin"]
}
```

- `roots`: `{name, path}` 목록. `~/` 확장 지원, 상대 경로는 이 디렉터리 기준
- `ignore`: 스캔에서 제외할 디렉터리 이름 목록
- 루트 추가: `roots`에 항목 추가 → `pnpm build skeleton <name>`으로 sidecar 생성

## 기능 요약

- 접이식 파일 트리: 루트는 펼침, 하위 디렉터리는 접힘이 기본값
- 블록·리스트 항목 단위 한국어 인터리브: 각 항목 바로 아래 번역 표시
- 헤딩은 번역 생략 (영어 그대로 표시)
- uncommitted git diff 패널: 변경 파일은 트리에서 파일명이 amber로 표시,
  본문 상단에 접이식 diff 제공
- hash 라우팅: `#<root>/<relpath>` 형태로 문서별 URL 공유 가능

## 산출물과 gitignore

`node_modules/`, `dist/`, `translations/`는 커밋하지 않는다.
`dist/`는 빌드 산출물이고, `translations/`는 표시 전용 파생 데이터다.
skeleton은 원문에서 언제든 재생성하고 `ko`는 Claude 세션이 다시 채우면 되므로,
영어 원문만 있으면 전체를 복원할 수 있다.
