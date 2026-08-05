# g-mobile-sim

Boot a local iOS simulator or Android emulator, verify something on it with the
mcp-mobile MCP tools, then shut down only what the skill booted.

## Features

- Routes a stated goal to a path that can actually do the job, before booting
  anything (layout-only checks are sent to browser emulation instead).
- Warns up front that iOS interaction needs WebDriverAgent, which is not set up
  on this machine, and offers Android or a simctl-only path.
- Lists iOS simulators and Android AVDs at runtime with a `line` column, so
  LINE-installed devices are visible for in-app webview checks.
- Tracks the devices it booted in a state file and never touches devices it did
  not start, not even one it is asked to boot again while already running.
- Teardown with per-device verification, plus `--all` as an explicit escape
  hatch.

## Usage

```
/g-mobile-sim                 # boot flow, asks for the goal if not given
/g-mobile-sim down            # shut down state-file devices only
/g-mobile-sim down --all      # also shut down externally started devices
/g-mobile-sim help
```

Scripts can be run directly:

```bash
scripts/list-devices.sh
scripts/boot.sh ios <UDID>
scripts/boot.sh android <AVD> [reverse_port]
scripts/teardown.sh [--all]
```

## How It Works

`SKILL.md` routes to one of three step files: `steps/step-1-route.md` picks the
path for the stated goal, `steps/step-2-boot.md` selects and boots a device,
`steps/step-3-teardown.md` shuts it down. `references/paths.md` holds the
capability matrix, the state-file schema, and the WebDriverAgent status.

`list-devices.sh` emits one TSV row per device
(`platform / id / name / os / state / line`), reading iOS data from
`xcrun simctl` plus the simulator bundle directories, and Android data from
`adb` plus `emulator -list-avds`. `boot.sh` boots one device, polls until it is
actually usable, optionally sets up `adb reverse`, and appends a row to
`${TMPDIR:-/tmp}/g-mobile-sim-state.tsv`. Interaction is then done with the
mcp-mobile tools against the reported device id. `teardown.sh` shuts down the
state-file rows, verifies after 8 seconds, keeps only failed rows, and reports
externally started devices as kept.

## Requirements

- Xcode with iOS runtimes for the iOS path
- Android SDK (`emulator`, `adb`) for the Android path
- mcp-mobile MCP server for interaction beyond opening URLs and screenshots.
  It is declared per repository in `.mcp.json`, so a session outside such a
  repository gets the simctl/adb-only path.
- WebDriverAgent for iOS interaction; not set up on this machine, so iOS is
  limited to opening URLs and screenshots (see `references/paths.md`).
