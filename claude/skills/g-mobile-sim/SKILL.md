---
name: g-mobile-sim
description: >
  Boot a local iOS simulator or Android emulator for hands-on mobile
  verification, hand interaction over to the mcp-mobile MCP server, then shut
  down only what it booted. Trigger: /g-mobile-sim, or a request to check
  something on a simulator or emulator. Sub-commands: down, help.
---

# g-mobile-sim Skill

Owns the device layer only: route, pick, boot, hand off, tear down.
Interaction (tap, type, screenshot) belongs to the external tools below.

## Workflow

```mermaid
flowchart TD
    A(["/g-mobile-sim [arg]"]) --> B{"arg?"}
    B -- "down" --> T1["Step 3: teardown"]
    B -- "down --all" --> T2["Step 3: approval gate, then --all"]
    B -- "help or unrecognized" --> Z0(["Print sub-command table, stop"])
    B -- "none or goal text" --> R["Step 1: route"]
    R -- "layout only" --> BE[["playwright MCP viewport emulation"]]
    R -- "no usable path" --> Z1(["Report blocker, no boot"])
    R -- "path fixed" --> S2["Step 2: boot"]
    S2 -- "BOOT_FAIL" --> Z2(["Report reason, no retry"])
    S2 -- "READY" --> H(["Hand off device id"])
    H --> MCP[["mcp-mobile tools"]]
    H --> SIM[["simctl openurl / io screenshot"]]
    MCP --> D{"check done?"}
    SIM --> D
    D -- "yes" --> T1
    D -- "not yet" --> Z3(["Keep booted, name down command + state path"])
```

## Step Router

Read only the step file for the current branch. Each step names the next one.

| Branch | Load file |
|---|---|
| route (default entry) | `steps/step-1-route.md` |
| boot | `steps/step-2-boot.md` |
| teardown (`down`, `down --all`, end of flow) | `steps/step-3-teardown.md` |

## Sub-commands

| Sub-command | Action |
|---|---|
| (none) | Default: route, then boot |
| `down` | Shut down state-file devices only |
| `down --all` | Also shut down external devices, after the step-3 gate |
| `help` | Print this table |

`help` or an unrecognized sub-command: print this table and stop. A bare
invocation runs the default flow, which asks for the goal in step 1.

## Hard Rules

- Never shut down a device absent from
  `${TMPDIR:-/tmp}/g-mobile-sim-state.tsv`. The only exception is
  `down --all`, gated by explicit approval in step 3.
- Teardown is part of the flow, not a favour: ask once when the check is done.
- Boot at most one device per path; reuse a matching state row.
- Device ids, AVD names, and LINE presence are read at runtime. Never hardcode.
- The uppercase tokens the scripts print are the contract. Each step file lists
  the ones it handles; never invent others.
- Capability matrix, WebDriverAgent status, state-file schema, token list,
  timings: `references/paths.md`.
