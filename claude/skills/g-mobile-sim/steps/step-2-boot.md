# Step 2: Boot

## 1. Reuse before booting

State file schema: `references/paths.md`. Column 1 is the platform, 2 the id,
4 the reverse port.

```bash
awk -F'\t' -v p=ios '$1 == p { print }' "${TMPDIR:-/tmp}/g-mobile-sim-state.tsv" 2>/dev/null || true
```

No file or no output means nothing is owned yet: go to section 2. A row for the
chosen platform means this skill already booted that device: reuse it by running
the section 3 command with that row's id or AVD name, which returns `READY`
without duplicating the row and re-establishes the tunnel when a port is passed.
Boot a different device only when the goal needs the other platform, or needs
`line=yes` and that row is not such a device.

## 2. List candidates

```bash
scripts/list-devices.sh
```

Columns: `platform / id / name / os / state / line`. Zero rows means neither
Xcode nor the Android SDK is usable here: report that and stop, no retry.

Both state values are lowercase: `booted` or `shutdown`. Present at most 8
candidates for the chosen platform, ordered `line=yes` first, then
`state=booted`, then newest OS. `line=unknown` means undetermined (a shutdown
AVD, or a missing or unreadable simulator directory), never "absent". Let the
user pick one.

## 3. Boot

```bash
scripts/boot.sh ios <udid>
scripts/boot.sh android <avd> [reverse_port]
```

| Output | Meaning | Action |
|---|---|---|
| `READY` | booted and recorded as owned | continue to section 4 |
| `ALREADY_BOOTED_EXTERNAL` | someone else started it, not recorded | tell the user it stays unowned and this skill will not shut it down; ask whether to use it as is or pick another device |
| `BOOT_FAIL` | reason in the second field | report the reason verbatim, retry 0 times, stop |

The script blocks while polling: Android cold boot takes 30-60 s, iOS 10-30 s.

## 4. Hand off

Report the device id plus the tool set that actually works:

- Android: the mcp-mobile tools, passing the serial from the `READY` line as
  `device`.
- iOS: only `xcrun simctl openurl <udid> <url>` and
  `xcrun simctl io <udid> screenshot <path>`. Read `references/paths.md` before
  attempting anything else on iOS.

Run the verification with those tools, then read `steps/step-3-teardown.md`.
