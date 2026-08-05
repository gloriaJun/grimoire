# Paths and Limits

## Interaction matrix

| Path | Boot | Open URL | Screenshot | Tap / type / swipe | Element tree |
|---|---|---|---|---|---|
| Android emulator + mcp-mobile | `boot.sh android` | yes | yes | yes | yes |
| iOS simulator + simctl | `boot.sh ios` | yes | yes | no | no |
| iOS simulator + mcp-mobile | - | needs WDA | needs WDA | needs WDA | needs WDA |
| Browser device emulation | none | yes | yes | yes | DOM only |

Android needs no extra dependency because adb exposes input injection and
uiautomator dumps. The iOS simulator has no public equivalent, so mcp-mobile
drives it through a WebDriverAgent instance on port 8100 and fails with
"WebDriverAgent is not running on simulator" until one runs. simctl is a
device-management layer and has no UI-input command at all.

## simctl commands used with this skill

```bash
xcrun simctl list devices available
xcrun simctl boot <UDID>; open -a Simulator
xcrun simctl openurl <UDID> <url>
xcrun simctl io <UDID> screenshot <path>
xcrun simctl shutdown <UDID>
```

## WebDriverAgent (UNVERIFIED)

appium, idb, and go-ios are all absent on this machine. Candidate setups are
the Appium xcuitest driver, or building facebook/WebDriverAgent with
`xcodebuild -scheme WebDriverAgentRunner test`. Neither has been run here, so
never present them as a working procedure. Success check:
`curl http://localhost:8100/status` returns JSON, after which mcp-mobile lists
the simulator as usable. Verified alternative: use Android for any
interaction-heavy scenario.

## State file

`${TMPDIR:-/tmp}/g-mobile-sim-state.tsv`, tab-separated, one row per device
this skill booted, appended by `boot.sh` and rewritten by `teardown.sh`:

| Column | Value |
|---|---|
| 1 platform | `ios` or `android` |
| 2 id | simulator UDID, or emulator serial such as `emulator-5554` |
| 3 name | simulator name, or AVD name |
| 4 reverse_port | Android reverse port, `-` when unset |
| 5 booted_at | `YYYY-MM-DDTHH:MM:SS` local time |

This file is the ownership boundary. A running device with no row here was
started by someone else: `boot.sh` refuses to adopt it
(`ALREADY_BOOTED_EXTERNAL`) and `teardown.sh` only reports it
(`KEPT_EXTERNAL`).

## LINE app detection

- iOS, no boot needed: `LINE.app` under
  `~/Library/Developer/CoreSimulator/Devices/<UDID>/data/Containers/Bundle/Application/*/`.
  A device directory that is missing, unreadable, or not traversable yields
  `unknown`, not `no`.
- Android: `adb -s <serial> shell pm list packages jp.naver.line.android`
  needs a running device, so `list-devices.sh` prints `unknown` for shutdown
  AVDs and resolves it after boot.

## Host dev server

- iOS simulator shares the host network namespace, so
  `http://localhost:<port>` works unchanged.
- Android emulator does not. Pass the port to `boot.sh android <avd> <port>`,
  which runs `adb -s <serial> reverse tcp:<port> tcp:<port>`. `10.0.2.2` is the
  host alias when reverse is unavailable.

## Timings and exit contracts

- Android cold boot to `sys.boot_completed=1`: 30-60 s. `boot.sh` polls 5 s x 40
  and then fails with `BOOT_FAIL`.
- iOS boot to Booted state: 10-30 s. `boot.sh` polls 2 s x 30.
- `adb emu kill` needs a few seconds before `adb devices` clears, so
  `teardown.sh` sleeps 8 s before verifying.
- Script output is tab-separated and greppable. Full token list: `READY`,
  `ALREADY_BOOTED_EXTERNAL`, `BOOT_FAIL`, `DOWN_OK`, `DOWN_FAIL`, `PRUNED`,
  `KEPT_EXTERNAL`, `NOTHING_TO_DO`, `DOWN_ALL`, `TEARDOWN_ERROR`.
- `list-devices.sh` state column is lowercase (`booted`, `shutdown`) on both
  platforms, unlike raw simctl output.
- A device that refuses to stop keeps its state row on both teardown paths, so
  `down` can retry it.
- Guards that fail fast instead of burning the poll budget: unknown iOS UDID,
  unknown AVD name, an emulator process that exits before its device appears,
  and a device that is already running.
