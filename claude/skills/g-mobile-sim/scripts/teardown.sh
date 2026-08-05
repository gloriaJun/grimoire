#!/usr/bin/env bash
# Shut down the devices this skill booted, or every device with --all.
# usage: teardown.sh [--all]
# stdout: DOWN_OK / DOWN_FAIL / PRUNED / KEPT_EXTERNAL / NOTHING_TO_DO /
#         DOWN_ALL / TEARDOWN_ERROR
set -uo pipefail

STATE="${TMPDIR:-/tmp}/g-mobile-sim-state.tsv"

booted_ios_udids() {
  xcrun simctl list devices booted 2>/dev/null |
    sed -nE 's/^.*\(([0-9A-Fa-f-]{36})\) \(Booted\).*$/\1/p'
}

# Only "device" state counts: offline entries would fake a DOWN_FAIL.
booted_android_serials() {
  adb devices 2>/dev/null | awk '/^emulator-/ && $2 == "device" {print $1}'
}

ios_is_booted() { booted_ios_udids | grep -qx "$1"; }
android_is_booted() { booted_android_serials | grep -qx "$1"; }

in_state() {
  awk -F'\t' -v id="$1" '$2 == id { found = 1 } END { exit !found }' "$STATE" 2>/dev/null
}

quit_simulator_if_idle() {
  [[ -z $(booted_ios_udids) ]] || return 0
  osascript -e 'quit app "Simulator"' >/dev/null 2>&1
}

report_external() {
  local id ids=""
  while read -r id; do
    [[ -n $id ]] || continue
    in_state "$id" && continue
    ids+="$id "
  done < <(booted_ios_udids)
  [[ -z ${ids// /} ]] || printf 'KEPT_EXTERNAL\tios\t%s\n' "${ids% }"
  ids=""
  while read -r id; do
    [[ -n $id ]] || continue
    in_state "$id" && continue
    ids+="$id "
  done < <(booted_android_serials)
  [[ -z ${ids// /} ]] || printf 'KEPT_EXTERNAL\tandroid\t%s\n' "${ids% }"
}

state_rows() {
  awk -F'\t' 'NF > 1 { n++ } END { print n + 0 }' "$STATE" 2>/dev/null
}

# Keep ownership of anything that refused to stop, so `down` can retry it.
keep_alive_rows() {
  local kept plat id name port ts
  kept=$(mktemp) || return 0
  while IFS=$'\t' read -r plat id name port ts; do
    [[ -n ${plat:-} ]] || continue
    if { [[ $plat == ios ]] && ios_is_booted "$id"; } ||
      { [[ $plat == android ]] && android_is_booted "$id"; }; then
      printf '%s\t%s\t%s\t%s\t%s\n' "$plat" "$id" "$name" "$port" "$ts" >>"$kept"
    fi
  done <"$STATE"
  mv "$kept" "$STATE"
}

kill_all() {
  xcrun simctl shutdown all >/dev/null 2>&1
  osascript -e 'quit app "Simulator"' >/dev/null 2>&1
  local serial
  while read -r serial; do
    [[ -n $serial ]] && adb -s "$serial" emu kill >/dev/null 2>&1
  done < <(booted_android_serials)
  sleep 8
  printf 'DOWN_ALL\tios_booted=%s\tandroid_booted=%s\n' \
    "$(booted_ios_udids | grep -c .)" "$(booted_android_serials | grep -c .)"
  keep_alive_rows
}

down_state() {
  report_external
  [[ $(state_rows) -gt 0 ]] || {
    printf 'NOTHING_TO_DO\tno owned device in the state file\n'
    return 0
  }
  local pending failed plat id name port ts
  pending=$(mktemp) || {
    printf 'TEARDOWN_ERROR\tmktemp failed, state file untouched\n'
    return 1
  }
  failed=$(mktemp) || {
    rm -f "$pending"
    printf 'TEARDOWN_ERROR\tmktemp failed, state file untouched\n'
    return 1
  }
  while IFS=$'\t' read -r plat id name port ts; do
    [[ -n ${plat:-} ]] || continue
    case "$plat" in
    ios)
      if ! ios_is_booted "$id"; then
        printf 'PRUNED\tios\t%s\n' "$name"
        continue
      fi
      xcrun simctl shutdown "$id" >/dev/null 2>&1
      ;;
    android)
      if ! android_is_booted "$id"; then
        printf 'PRUNED\tandroid\t%s\n' "$name"
        continue
      fi
      [[ $port == "-" || -z $port ]] ||
        adb -s "$id" reverse --remove-all >/dev/null 2>&1
      adb -s "$id" emu kill >/dev/null 2>&1
      ;;
    esac
    printf '%s\t%s\t%s\t%s\t%s\n' "$plat" "$id" "$name" "$port" "$ts" >>"$pending"
  done <"$STATE"

  sleep 8
  while IFS=$'\t' read -r plat id name port ts; do
    [[ -n ${plat:-} ]] || continue
    if { [[ $plat == ios ]] && ios_is_booted "$id"; } ||
      { [[ $plat == android ]] && android_is_booted "$id"; }; then
      printf 'DOWN_FAIL\t%s\t%s\n' "$plat" "$name"
      printf '%s\t%s\t%s\t%s\t%s\n' "$plat" "$id" "$name" "$port" "$ts" >>"$failed"
    else
      printf 'DOWN_OK\t%s\t%s\n' "$plat" "$name"
    fi
  done <"$pending"
  # Replace the state file only once the outcome is known, so an interrupted
  # run never loses ownership of a device that is still alive.
  mv "$failed" "$STATE"
  rm -f "$pending"
  quit_simulator_if_idle
}

case "${1:-}" in
--all) kill_all ;;
'') down_state ;;
*)
  printf 'usage: teardown.sh [--all]\n' >&2
  exit 1
  ;;
esac
