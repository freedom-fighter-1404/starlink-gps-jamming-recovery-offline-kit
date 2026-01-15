#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
GRPCURL="${ROOT_DIR}/scripts/grpcurl_local.sh"

DISH_IP="${DISH_IP:-192.168.100.1}"
GRPC_PORT="${GRPC_PORT:-9200}"
TARGET="${DISH_IP}:${GRPC_PORT}"
HANDLE_METHOD="SpaceX.API.Device.Device/Handle"

GRPC_CONNECT_TIMEOUT="${GRPC_CONNECT_TIMEOUT:-5}"
GRPC_MAX_TIME="${GRPC_MAX_TIME:-15}"

PROTOSET_DEFAULT="${ROOT_DIR}/proto/starlink.protoset"
STARLINK_PROTOSET="${STARLINK_PROTOSET:-${PROTOSET_DEFAULT}}"

DEFAULT_INTERVAL_SECONDS=300

usage() {
  cat <<'EOF'
Starlink GPS anti-jamming helper (offline)

Usage:
  ./scripts/starlink_gps.sh disable
  ./scripts/starlink_gps.sh enable
  ./scripts/starlink_gps.sh status
  ./scripts/starlink_gps.sh probe
  ./scripts/starlink_gps.sh daemon [seconds]
  ./scripts/starlink_gps.sh menu

Environment overrides:
  DISH_IP      (default: 192.168.100.1)
  GRPC_PORT    (default: 9200)
  GRPC_CONNECT_TIMEOUT (default: 5)
  GRPC_MAX_TIME        (default: 15)
  STARLINK_PROTOSET    (default: proto/starlink.protoset)

Notes:
  - This only talks to the local dish on your LAN.
  - This kit includes an offline gRPC schema so it can work even when reflection is disabled.
EOF
}

grpcurl_plaintext() {
  local schema_args=()
  if [[ -f "${STARLINK_PROTOSET}" ]]; then
    schema_args=(-protoset "${STARLINK_PROTOSET}")
  fi
  "${GRPCURL}" -plaintext \
    -connect-timeout "${GRPC_CONNECT_TIMEOUT}" \
    -max-time "${GRPC_MAX_TIME}" \
    "${schema_args[@]}" \
    "$@"
}

filter_lines_ci() {
  local pattern="$1"
  if command -v rg >/dev/null 2>&1; then
    rg -i "${pattern}"
  else
    grep -Ei "${pattern}"
  fi
}

send_handle_json() {
  local json="$1"
  grpcurl_plaintext -d "${json}" "${TARGET}" "${HANDLE_METHOD}"
}

cmd_disable() {
  echo "Sending: dish_inhibit_gps (disable GPS, use constellation positioning when supported)"
  echo "Target: ${TARGET}"
  echo
  if out="$(send_handle_json '{"dishInhibitGps":{"inhibitGps":true}}' 2>&1)"; then
    if [[ "${out}" != "" ]]; then
      printf "%s\n" "${out}"
    fi
  else
    printf "%s\n" "${out}"
    echo
    echo "FAILED."
    echo "Common causes:"
    echo "  - Not connected to Starlink Wi‑Fi / local LAN"
    echo "  - Older firmware (no dish_inhibit_gps)"
    echo
    echo "Next steps:"
    echo "  - Run: ./scripts/starlink_gps.sh probe"
    echo "  - If the Starlink app has the toggle, enable: \"Use Starlink positioning exclusively\""
    echo "  - See: docs/OLDER_FIRMWARE.md"
    return 1
  fi
  echo
  echo "Done."
}

cmd_enable() {
  echo "Sending: dish_inhibit_gps (enable GPS)"
  echo "Target: ${TARGET}"
  echo
  if out="$(send_handle_json '{"dishInhibitGps":{"inhibitGps":false}}' 2>&1)"; then
    if [[ "${out}" != "" ]]; then
      printf "%s\n" "${out}"
    fi
  else
    printf "%s\n" "${out}"
    echo
    echo "FAILED. Run: ./scripts/starlink_gps.sh probe"
    return 1
  fi
  echo
  echo "Done."
}

cmd_status() {
  echo "Requesting dish status (look for gps/inhibit fields in output)"
  echo "Target: ${TARGET}"
  echo
  out="$(send_handle_json '{"getStatus":{}}' 2>&1 || true)"
  printf "%s\n" "${out}"
  echo
  echo "---- highlights (gps|inhibit|position|location|gnss|constellation) ----"
  printf "%s\n" "${out}" | filter_lines_ci "gps|inhibit|position|location|gnss|constellation" || true
}

cmd_probe() {
  echo "Probe: connectivity + reflection check + GPS command availability"
  echo "Target: ${TARGET}"
  echo

  echo "[1/3] Connectivity check (getStatus):"
  status_out="$(send_handle_json '{"getStatus":{}}' 2>&1 || true)"
  if printf "%s\n" "${status_out}" | grep -qiE "Failed to dial target host|transport: error while dialing|connect:|connection refused|no route to host|context deadline exceeded"; then
    echo "✗ Probe failed: could not connect to ${TARGET}."
    echo "  Make sure you are connected to Starlink Wi‑Fi / local LAN, and retry."
    return 1
  fi
  printf "%s\n" "${status_out}"
  echo

  echo "[2/3] Reflection check (optional; some firmwares disable it):"
  reflect_out="$("${GRPCURL}" -plaintext -connect-timeout "${GRPC_CONNECT_TIMEOUT}" -max-time "${GRPC_MAX_TIME}" "${TARGET}" list 2>&1 || true)"
  if printf "%s\n" "${reflect_out}" | grep -qiE "does not support the reflection API"; then
    echo "ℹ Reflection is disabled on this device."
    echo "  That's OK. This kit includes an offline schema and does not require reflection."
  else
    printf "%s\n" "${reflect_out}"
  fi
  echo

  echo "[3/3] GPS command check:"
  if printf "%s\n" "${reflect_out}" | grep -qiE "does not support the reflection API"; then
    echo "Reflection is disabled, so we cannot list fields from the live schema."
    echo "Try: Disable GPS. If it fails, follow docs/OLDER_FIRMWARE.md."
  else
    req_out="$("${GRPCURL}" -plaintext -connect-timeout "${GRPC_CONNECT_TIMEOUT}" -max-time "${GRPC_MAX_TIME}" "${TARGET}" describe SpaceX.API.Device.Request 2>&1 || true)"
    if printf "%s\n" "${req_out}" | grep -q "dish_inhibit_gps"; then
      echo "✓ Found dish_inhibit_gps in SpaceX.API.Device.Request"
    else
      echo "✗ dish_inhibit_gps not found (older firmware or restricted schema)."
      echo "  Try the Starlink app toggle if available, or see docs/OLDER_FIRMWARE.md."
    fi
  fi
}

cmd_daemon() {
  local interval="${1:-${DEFAULT_INTERVAL_SECONDS}}"
  if ! [[ "${interval}" =~ ^[0-9]+$ ]]; then
    echo "ERROR: interval must be an integer seconds value." >&2
    exit 2
  fi

  echo "Daemon mode: re-sending disable command every ${interval}s"
  echo "Press Ctrl+C to stop"
  echo

  while true; do
    ts="$(date '+%Y-%m-%d %H:%M:%S' 2>/dev/null || true)"
    echo "[${ts}] disable -> ${TARGET}"
    if out="$(send_handle_json '{"dishInhibitGps":{"inhibitGps":true}}' 2>&1)"; then
      if [[ "${out}" != "" ]]; then
        printf "%s\n" "${out}"
      fi
      echo "[${ts}] OK"
    else
      printf "%s\n" "${out}"
      echo "[${ts}] FAILED"
    fi
    echo
    sleep "${interval}"
  done
}

cmd_menu() {
  while true; do
    cat <<EOF
============================================================
Starlink GPS Anti-Jamming (Offline)
Dish: ${TARGET}
============================================================
1) Disable GPS (dish_inhibit_gps=true)
2) Enable GPS  (dish_inhibit_gps=false)
3) Status      (get_status)
4) Probe       (list/describe + GPS field scan)
5) Daemon disable (re-send every 5 min)
6) Exit
EOF
    printf "Choose (1-6): "
    read -r choice || true

    case "${choice}" in
      1) cmd_disable || true ;;
      2) cmd_enable || true ;;
      3) cmd_status || true ;;
      4) cmd_probe || true ;;
      5) cmd_daemon "${DEFAULT_INTERVAL_SECONDS}" ;;
      6) exit 0 ;;
      *) echo "Invalid choice." ;;
    esac

    echo
    printf "Press Enter to continue..."
    read -r _ || true
    echo
  done
}

main() {
  local cmd="${1:-}"
  case "${cmd}" in
    disable) cmd_disable ;;
    enable) cmd_enable ;;
    status) cmd_status ;;
    probe) cmd_probe ;;
    daemon) shift; cmd_daemon "${1:-${DEFAULT_INTERVAL_SECONDS}}" ;;
    menu) cmd_menu ;;
    -h|--help|"") usage ;;
    *)
      echo "ERROR: Unknown command: ${cmd}" >&2
      usage
      exit 2
      ;;
  esac
}

main "$@"
