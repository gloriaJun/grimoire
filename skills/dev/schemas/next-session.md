# next-session.md — RETIRED

This schema has been retired. The responsibilities previously handled by `next-session.md` are now split:

- **Session resume state** (재개 현황): managed exclusively by `_state.json`
- **Human-readable view** (Obsidian): `history.md` → `## Current Snapshot` (auto-generated from `_state.json`)
- **Architecture decisions & blockers**: `history.md` → `## Decision Log` (append-only)

See `schemas/history.md` for the replacement schema.
