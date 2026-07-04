# dev review

On-demand code review. Supports PR URLs and local diffs. No devlog required.

## Features

- **Auto scope detection** — staged changes → unstaged → file path → PR URL
- **Skill-first routing** — diffs go to the `code-review` skill; file-scope reviews use the `code-reviewer` agent
- **Parallel frontend review** — dispatches `frontend-reviewer` alongside when UI changes are detected
- **Plannotator support** — visual review when a PR URL is provided
- **Severity grouping** — findings presented as Blocking / Suggestions / Looks good

## Usage

```
/dev review
/dev review <PR-URL>
/dev review <file-path>
```

## How It Works

```
Scope Detection
    │
    ├── PR URL → plannotator-review skill
    ├── diff  → code-review skill
    └── file  → code-reviewer agent
            └── Frontend changes? → also dispatch frontend-reviewer (parallel)
```

### Output Format

```
## Review Results

### 🔴 Blocking
- <issue> [file:line]

### 🟡 Suggestions
- <issue> [file:line]

### ✅ Looks good
- <summary>
```

## Requirements

- `code-reviewer` agent (`~/.claude/agents/code-reviewer.md`)
- `frontend-reviewer` agent (optional, for UI change detection)
- Plannotator plugin (optional, for PR URL review)

## License

MIT
