# Status: View Task Status

Shows in-progress and completed tasks at a glance. Works even with no active tasks.

## Process

### 1. MEMORY.md-based scan (default)

MEMORY.md is already in context at session start. Read two sections:
- `## Active Dev Tasks` — in progress
- `## Completed Dev Tasks` — completed (pointer is `<task>-log.md`)

Read the frontmatter of the file each pointer targets:
- In progress (`state.md`): `repo`, `current-step`, `task-name`, `created`, `updated`
- Completed (`<task>-log.md`): `repo`, `task-name`, `completed`

Take the one-line progress summary from the first line of `state.md`'s `## Current Step`, and the next action from the first `⏳ pending` row in the `## Features` table.

### 2. Missing-task scan (fallback)

Runs only when MEMORY.md has no entries, or the `--all` flag is given.

Find `YYYY-MM-DD-*/state.md` directories under `<memory-root>` (= `~/.claude/projects/<project-id>/memory/`) that aren't listed in MEMORY.md, add them to the output, and register them back into MEMORY.md.

### 3. Output

Show in-progress tasks as 3 lines each (summary/step/next action). Roll up completed tasks into one line each.

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

Rules:
- List in-progress tasks first, completed tasks below.
- Omit the `■ 완료` block if there are no completed tasks. If there's nothing at all, print only the final one-line notice.
- Stagnation marker: attach `💤 <N>일째 미진행` to an in-progress task whose `updated` frontmatter (`completed` for finished tasks) is **7+ days** old relative to today (the context's `currentDate`). This surfaces stalled tasks so they can be resumed or cleaned up.
- Date: use `created`/`completed` frontmatter, falling back to the directory name's date prefix.
- Task name: use `task-name` frontmatter, falling back to the directory name.
- If the `--repo` flag or a phrase like "this repo" is present, filter to the current repo.
