#!/usr/bin/env bash
# Boot one device and record it in the state file.
# usage: boot.sh ios <udid>
#        boot.sh android <avd> [reverse_port]
# stdout: READY <TAB> platform <TAB> id [<TAB> avd]
#         ALREADY_BOOTED_EXTERNAL <TAB> platform <TAB> id   (never recorded)
# stderr: BOOT_FAIL <TAB> reason   (exit 1)
set -uo pipefail

STATE="${TMPDIR:-/tmp}/g-mobile-sim-state.tsv"
ANDROID_EMULATOR="${ANDROID_EMULATOR:-$HOME/Library/Android/sdk/emulator/emulator}"
platform="${1:-}"
target="${2:-}"
port="${3:-}"

die() {
  printf 'BOOT_FAIL\t%s\n' "$1" >&2
  exit 1
}

record() {
  in_state "$2" && return 0
  printf '%s\t%s\t%s\t%s\t%s\n' \
    "$1" "$2" "$3" "${4:--}" "$(date +%Y-%m-%dT%H:%M:%S)" >>"$STATE"
}

in_state() {
  awk -F'\t' -v id="$1" '$2 == id { found = 1 } END { exit !found }' "$STATE" 2>/dev/null
}

# Only "device" state counts: offline and unauthorized emulators are not usable.
emulator_serials() {
  adb devices 2>/dev/null | awk '/^emulator-/ && $2 == "device" {print $1}' | sort
}

avd_of() {
  adb -s "$1" emu avd name 2>/dev/null | head -1 | tr -d '\r'
}

ios_device_name() {
  xcrun simctl list devices 2>/dev/null |
    sed -nE "s/^[[:space:]]*(.+) \($1\) \(.+\)[[:space:]]*$/\1/p" | head -1
}

ios_is_booted() {
  xcrun simctl list devices booted 2>/dev/null | grep -q "$1"
}

# A device already running is adopted only if this skill booted it before.
# An owned Android device still gets the requested tunnel; an external one is
# left untouched.
report_running() {
  if in_state "$2"; then
    if [[ $1 == android && -n $port ]]; then
      adb -s "$2" reverse "tcp:$port" "tcp:$port" >/dev/null 2>&1 ||
        die "adb reverse failed on port $port"
    fi
    printf 'READY\t%s\t%s\n' "$1" "$2"
  else
    printf 'ALREADY_BOOTED_EXTERNAL\t%s\t%s\n' "$1" "$2"
  fi
}

boot_ios() {
  command -v xcrun >/dev/null 2>&1 || die "xcrun not found"
  local name
  name=$(ios_device_name "$target")
  [[ -n $name ]] || die "unknown ios udid: $target"
  if ios_is_booted "$target"; then
    report_running ios "$target"
    return 0
  fi
  xcrun simctl boot "$target" >/dev/null 2>&1
  open -a Simulator >/dev/null 2>&1 || die "Simulator app failed to open"
  for _ in $(seq 1 30); do
    if ios_is_booted "$target"; then
      record ios "$target" "$name" ""
      printf 'READY\tios\t%s\n' "$target"
      return 0
    fi
    sleep 2
  done
  die "ios boot timeout after 60s: $target"
}

running_serial_of_avd() {
  local serial
  while read -r serial; do
    [[ -n $serial ]] || continue
    if [[ $(avd_of "$serial") == "$1" ]]; then
      printf '%s\n' "$serial"
      return 0
    fi
  done < <(emulator_serials)
  return 1
}

boot_android() {
  command -v adb >/dev/null 2>&1 || die "adb not found"
  [[ -x $ANDROID_EMULATOR ]] || die "emulator binary not found: $ANDROID_EMULATOR"
  "$ANDROID_EMULATOR" -list-avds 2>/dev/null | grep -qxF "$target" ||
    die "unknown avd: $target"
  local existing before after serial child
  if existing=$(running_serial_of_avd "$target"); then
    report_running android "$existing"
    return 0
  fi
  before=$(emulator_serials)
  nohup "$ANDROID_EMULATOR" -avd "$target" >/dev/null 2>&1 &
  child=$!
  for _ in $(seq 1 40); do
    sleep 5
    after=$(emulator_serials)
    serial=$(comm -13 <(printf '%s\n' "$before") <(printf '%s\n' "$after") |
      grep -v '^$' | head -1)
    if [[ -z $serial ]]; then
      kill -0 "$child" 2>/dev/null ||
        die "emulator process exited before the device appeared: $target"
      continue
    fi
    [[ $(adb -s "$serial" shell getprop sys.boot_completed 2>/dev/null | tr -d '\r') == 1 ]] || continue
    if [[ -n $port ]]; then
      adb -s "$serial" reverse "tcp:$port" "tcp:$port" >/dev/null 2>&1 ||
        die "adb reverse failed on port $port"
    fi
    record android "$serial" "$target" "$port"
    printf 'READY\tandroid\t%s\t%s\n' "$serial" "$target"
    return 0
  done
  die "android boot timeout after 200s: $target"
}

case "$platform" in
ios)
  [[ -n $target ]] || die "usage: boot.sh ios <udid>"
  boot_ios
  ;;
android)
  [[ -n $target ]] || die "usage: boot.sh android <avd> [reverse_port]"
  boot_android
  ;;
*)
  die "usage: boot.sh ios <udid> | boot.sh android <avd> [reverse_port]"
  ;;
esac
