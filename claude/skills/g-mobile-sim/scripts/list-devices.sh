#!/usr/bin/env bash
# List bootable local mobile devices, one TSV row each:
#   platform <TAB> id <TAB> name <TAB> os <TAB> state <TAB> line
# A platform whose toolchain is missing is skipped silently.
set -uo pipefail

ANDROID_EMULATOR="${ANDROID_EMULATOR:-$HOME/Library/Android/sdk/emulator/emulator}"
SIM_DEVICES_DIR="$HOME/Library/Developer/CoreSimulator/Devices"
LINE_PKG="jp.naver.line.android"

ios_has_line() {
  local device="$SIM_DEVICES_DIR/$1"
  # A missing or unreadable device directory means undetermined, not absent.
  [[ -d $device && -r $device && -x $device ]] || {
    echo unknown
    return 0
  }
  if compgen -G "$device/data/Containers/Bundle/Application/*/LINE.app" >/dev/null 2>&1; then
    echo yes
  else
    echo no
  fi
}

list_ios() {
  command -v xcrun >/dev/null 2>&1 || return 0
  local row runtime="" name udid state
  while IFS= read -r row; do
    if [[ $row =~ ^--[[:space:]](.+)[[:space:]]--$ ]]; then
      runtime="${BASH_REMATCH[1]}"
      continue
    fi
    [[ $runtime == iOS* ]] || continue
    [[ $row =~ ^[[:space:]]+(.+)[[:space:]]\(([0-9A-Fa-f-]{36})\)[[:space:]]\((.+)\)[[:space:]]*$ ]] || continue
    name="${BASH_REMATCH[1]}"
    udid="${BASH_REMATCH[2]}"
    # simctl says "Booted"/"Shutdown"; the state column is lowercase everywhere.
    state=$(printf '%s' "${BASH_REMATCH[3]}" | tr '[:upper:]' '[:lower:]')
    printf 'ios\t%s\t%s\t%s\t%s\t%s\n' \
      "$udid" "$name" "$runtime" "$state" "$(ios_has_line "$udid")"
  done < <(xcrun simctl list devices available 2>/dev/null)
}

list_android() {
  command -v adb >/dev/null 2>&1 || return 0
  local serial avd os line running=""
  while read -r serial; do
    [[ -n $serial ]] || continue
    avd=$(adb -s "$serial" emu avd name 2>/dev/null | head -1 | tr -d '\r')
    [[ -n $avd ]] || avd="$serial"
    os=$(adb -s "$serial" shell getprop ro.build.version.release 2>/dev/null | tr -d '\r')
    if adb -s "$serial" shell pm list packages "$LINE_PKG" 2>/dev/null | grep -q "$LINE_PKG"; then
      line=yes
    else
      line=no
    fi
    running+="$avd"$'\n'
    printf 'android\t%s\t%s\t%s\tbooted\t%s\n' "$serial" "$avd" "${os:--}" "$line"
  done < <(adb devices 2>/dev/null | awk '/^emulator-/ && $2 == "device" {print $1}')

  [[ -x $ANDROID_EMULATOR ]] || return 0
  while read -r avd; do
    [[ -n $avd ]] || continue
    grep -qxF "$avd" <<<"$running" && continue
    printf 'android\t%s\t%s\t-\tshutdown\tunknown\n' "$avd" "$avd"
  done < <("$ANDROID_EMULATOR" -list-avds 2>/dev/null)
}

list_ios
list_android
