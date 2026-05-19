# history.md Schema

Human-readable lifecycle document for the full dev workflow.
Stored in the devlog task subdirectory alongside `_state.json`.

**Scope**: created at task initialization; spans idea → complete.

---

## Two-Section Structure

```markdown
<!-- ═══════════════════════════════════════════════════════════
     AUTO-GENERATED from _state.json — DO NOT EDIT THIS SECTION
     Regenerated on every step transition and feature completion
     ═══════════════════════════════════════════════════════════ -->

## Current Snapshot

[generated content — see "Current Snapshot Format" below]

<!-- ═══════════════════════════════════════════════════════════
     END AUTO-GENERATED — append Decision Log entries below
     ═══════════════════════════════════════════════════════════ -->

---

## Decision Log

[append-only entries — see "Decision Log Format" below]
```

---

## Current Snapshot Format

Regenerate this section in full from `_state.json` on every step transition and feature completion.
Replace the entire block between the two comment markers.

```markdown
## Current Snapshot

_Updated: YYYY-MM-DD_

| | |
|---|---|
| **Task** | <taskName> |
| **Step** | <currentStep> |
| **Branch** | <branch or "—"> |
| **Devlog** | <absolute path to task directory> |

<Progress line — only include when in build step or later>
**Progress**: <done-count>/<total-count> features done · Next: <next pending feature name or "모두 완료">

<Feature table — only include when features[] is non-empty>
| # | Feature | Status | Executor |
|---|---------|--------|----------|
| F-01 | <name> | ✅ done | claude |
| F-02 | <name> | ⏳ pending | — |

<Artifacts line — only include non-null artifact paths>
**Artifacts**: [PRD](<prd-path>) · [TRD](<trd-path>) · [features.md](<features-path>)

<Open blockers — only include if Decision Log has entries with status: open>
**Open blockers**: <titles of open Decision Log entries, comma-separated>
```

### Current Snapshot Rules

- The comment markers (`<!-- AUTO-GENERATED ... -->` and `<!-- END AUTO-GENERATED ... -->`) must be preserved exactly — they are parsing anchors.
- Replace the entire block between markers on each update; never do partial updates.
- Omit empty sections (progress line, feature table, artifacts line, open blockers) when they have no content.
- Branch shows `"—"` if `_state.json.branch` is null.
- Feature status icons: `✅ done`, `🔄 in-progress`, `👀 review`, `⏳ pending`.
- Executor shows `"—"` if not yet assigned.

---

## Decision Log Format

Append-only. Each entry follows this format:

```markdown
### [<step>] YYYY-MM-DD — <title>
_type: <decision|blocker|troubleshooting> · status: <open|resolved>_

<prose content: what was decided/encountered and why>
```

### Entry Types

| type | When to use |
|------|-------------|
| `decision` | Architecture choice, technology selection, non-obvious trade-off; also used for review approvals (PRD/TRD/features) |
| `blocker` | Unresolved dependency, external decision needed, blocked on information |
| `troubleshooting` | Bug root cause, error resolution, debugging finding worth preserving; also used for stagnation events (tests fail ×2) |

### Review Approval Entries

When a PRD, TRD, or feature breakdown is reviewed and approved, append a Decision Log entry:

```markdown
### [plan] YYYY-MM-DD — PRD approved
_type: decision · status: resolved_

Reviewed via <plannotator|text>. Approved by user.
```

Replace `plan` with the current step (`design` for TRD, `breakdown` for features).

### Stagnation Entries

When a stagnation escape is triggered (tests fail ×2), append a Decision Log entry:

```markdown
### [build] YYYY-MM-DD — F-XX stagnation: <feature name>
_type: troubleshooting · status: open_

Tests failed after 2 iterations. Resolution chosen: <option description>.
<outcome or pending action>
```

Update `status: resolved` when the stagnation is resolved.

### Status

| status | Meaning |
|--------|---------|
| `open` | Not yet resolved — surfaces in Current Snapshot's "Open blockers" |
| `resolved` | Resolved within this task — candidate for TIL archiving |

### Decision Log Rules

- Only append, never edit or delete entries (except via `/dev til` archive flow).
- If a blocker is resolved: add a follow-up entry `### [<step>] YYYY-MM-DD — <title> (resolved)` with `status: resolved` and a brief note. Do not edit the original entry.
- The step field should match the step at the time of writing (e.g., `build`, `design`).

---

## When to Create

Created at task initialization (New Task Initialization in `steps/entry.md`).
Create with the comment markers and empty sections only — no content until first step completes.

```markdown
<!-- ═══════════════════════════════════════════════════════════
     AUTO-GENERATED from _state.json — DO NOT EDIT THIS SECTION
     Regenerated on every step transition and feature completion
     ═══════════════════════════════════════════════════════════ -->

## Current Snapshot

_Updated: YYYY-MM-DD_

| | |
|---|---|
| **Task** | <taskName> |
| **Step** | <currentStep> |
| **Branch** | — |
| **Devlog** | <devlogs-root>/<task-dir>/ |

<!-- ═══════════════════════════════════════════════════════════
     END AUTO-GENERATED — append Decision Log entries below
     ═══════════════════════════════════════════════════════════ -->

---

## Decision Log
```

---

## Pruning Policy

- `/dev complete` → **do not prune**. Completed-task decisions are the most valuable entries.
- `/dev til` → review Decision Log:
  - `status: resolved` entries that map to TIL learnings: archive to `<task-dir>/archived/history-<date>.md`
  - `status: open` entries: surface as `follow_up` items in the TIL note
  - Entries without clear TIL value: leave in place
- Automatic deletion is **never allowed**.
