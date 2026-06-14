# history.md Schema

Human-readable lifecycle document for the full dev workflow.
Stored in the task subdirectory alongside `state.md`.

**Scope**: created at task initialization; spans idea → complete.
At `/dev complete`, this file is consolidated into `<task>-log.md` and deleted (see `steps/complete.md`).

---

## Two-Section Structure

```markdown
<!-- ═══════════════════════════════════════════════════════════
     AUTO-GENERATED from memory file — DO NOT EDIT THIS SECTION
     Regenerated on every step transition and feature completion
     ═══════════════════════════════════════════════════════════ -->

## 현재 상태

[generated content — see "현재 상태 Format" below]

<!-- ═══════════════════════════════════════════════════════════
     END AUTO-GENERATED — append 결정·블로커 기록 entries below
     ═══════════════════════════════════════════════════════════ -->

---

## 결정·블로커 기록

[append-only entries — see "결정·블로커 기록 Format" below]
```

---

## 현재 상태 Format

Regenerate this section in full from the memory file on every step transition and feature completion.
Replace the entire block between the two comment markers.

```markdown
## 현재 상태

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

<Artifacts line — only include artifact paths present in memory file ## Artifacts>
**Artifacts**: [PRD](<prd-path>) · [Architecture](<architecture-path>) · [Wireframe](<wireframe-path>)

<Open blockers — only include if 결정·블로커 기록 has entries with status: open>
**Open blockers**: <titles of open 결정·블로커 기록 entries, comma-separated>
```

### 현재 상태 Rules

- The comment markers (`<!-- AUTO-GENERATED ... -->` and `<!-- END AUTO-GENERATED ... -->`) must be preserved exactly — they are parsing anchors.
- Replace the entire block between markers on each update; never do partial updates.
- Omit empty sections (progress line, feature table, artifacts line, open blockers) when they have no content.
- Branch shows `"—"` if memory file `## Build Context` has no branch set.
- Feature status icons: `✅ done`, `🔄 in-progress`, `👀 review`, `⏳ pending`.
- Executor shows `"—"` if not yet assigned.

---

## 결정·블로커 기록 Format

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

When a PRD, TRD, or feature breakdown is reviewed and approved, append a 결정·블로커 기록 entry:

```markdown
### [plan] YYYY-MM-DD — PRD approved
_type: decision · status: resolved_

Reviewed via <plannotator|text>. Approved by user.
```

Replace `plan` with the current step (`design` for architecture review).

### Stagnation Entries

When a "테스트 막힘 탈출" is triggered (tests fail ×2), append a 결정·블로커 기록 entry:

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
| `open` | Not yet resolved — surfaces in the 현재 상태 block's "Open blockers" |
| `resolved` | Resolved within this task |

### 결정·블로커 기록 Rules

- Append-only while the task is active: never edit or delete entries.
- If a blocker is resolved: add a follow-up entry `### [<step>] YYYY-MM-DD — <title> (resolved)` with `status: resolved` and a brief note. Do not edit the original entry.
- The step field should match the step at the time of writing (e.g., `build`, `design`).

---

## When to Create

Created at task initialization alongside the memory file (New Task Initialization in `steps/entry.md`).
Create with the comment markers and empty sections only — no content until first step completes.

```markdown
<!-- ═══════════════════════════════════════════════════════════
     AUTO-GENERATED from memory file — DO NOT EDIT THIS SECTION
     Regenerated on every step transition and feature completion
     ═══════════════════════════════════════════════════════════ -->

## 현재 상태

_Updated: YYYY-MM-DD_

| | |
|---|---|
| **Task** | <taskName> |
| **Step** | <currentStep> |
| **Branch** | — |
| **Task Dir** | <task-dir>/ |

<!-- ═══════════════════════════════════════════════════════════
     END AUTO-GENERATED — append 결정·블로커 기록 entries below
     ═══════════════════════════════════════════════════════════ -->

---

## 결정·블로커 기록
```

---

## Lifecycle End

- While the task is active, this file is never pruned — every decision and blocker stays.
- At `/dev complete`, the 결정·블로커 기록 is summarized into `<task>-log.md` (`## 과정에서 고민한 것`)
  and this file is deleted as part of consolidation. There is no separate archive step.
