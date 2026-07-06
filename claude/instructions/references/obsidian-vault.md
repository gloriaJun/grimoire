# Obsidian Vault Reference Map

Vault: ~/Documents/obsidian-vault/

## Folder Routing

| Area      | Path               | Content                          | Read when                                      |
|-----------|--------------------|----------------------------------|------------------------------------------------|
| Ideas     | 02_Ideas/work/     | ideas under development          | brainstorming, need prior-idea context         |
| Logs      | 03_Logs/work/      | meeting notes, work journal      | need past decisions or history                 |
| Notes     | 04_Notes/work/     | structured, refined notes        | need a reference on a specific topic           |
| Knowledge | 10_Knowledge/work/ | tips, snippets, debugging guides | searching technical precedents, prior material |
| Prompts   | 90_System/prompts/ | AI prompt templates              | writing or improving prompts/skills            |

## Read Procedure (context-minimal)

1. **Scan**: run `find <folder> -name "*.md" -maxdepth 2` → list filenames
2. **Filter**: pick the 1-3 most relevant files by filename/path
3. **Read**: read only the selected files with the Read tool
4. No relevant files → skip the vault reference and continue the task

## Rules

- Never read a whole folder — always scan, then select
- When quoting vault content, cite the vault path (so the user can locate the note)
- 01_Raw holds fleeting/inbox memos — low reference priority (check only when needed)
- Obsidian dashboard query patterns: see `.claude/references/dashboard-query.md` (vault-local)
