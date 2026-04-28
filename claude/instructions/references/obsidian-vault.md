# Obsidian Vault Reference Map

Vault: ~/Documents/obsidian-vault/

## Folder Routing

| Area      | Path               | Content                     | Read when                                    |
|-----------|--------------------|-----------------------------|----------------------------------------------|
| Ideas     | 02_Ideas/work/     | 개발 중인 아이디어 노트      | 브레인스토밍, 기존 아이디어 맥락 필요         |
| Logs      | 03_Logs/work/      | 회의록, 업무 일지            | 과거 결정/이력 맥락 필요                      |
| Notes     | 04_Notes/work/     | 정리된 구조화 노트           | 특정 주제 레퍼런스 필요                       |
| Knowledge | 10_Knowledge/work/ | 팁, 스니펫, 디버깅 가이드    | 기술적 선례 검색, 기존 자료 참조              |
| Prompts   | 90_System/prompts/ | AI 프롬프트 템플릿           | 프롬프트/스킬 작성 또는 개선 시               |

## Read Procedure (context-minimal)

1. **스캔**: `find <folder> -name "*.md" -maxdepth 2` 실행 → 파일명 목록 확인
2. **필터**: 파일명·경로에서 관련성 높은 파일 1–3개 선택
3. **Read**: 선택한 파일만 Read tool로 읽기
4. 관련 파일 없으면 → vault 참조 생략, 작업 계속

## Rules

- 폴더 전체를 읽지 않는다 — 반드시 스캔 후 선별
- 읽은 내용 인용 시 vault 경로 명시 (사용자가 노트를 찾을 수 있도록)
- 01_Raw는 fleeting/inbox 메모이므로 참조 우선순위 낮음 (필요 시만 확인)
- Obsidian 대시보드 쿼리 패턴: .claude/references/dashboard-query.md 참조
