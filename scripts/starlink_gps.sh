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

Notes:
  - This only talks to the local dish on your LAN.
  - Works best when the dish supports server reflection on port 9200.
EOF
}

grpcurl_plaintext() {
  "${GRPCURL}" -plaintext \
    -connect-timeout "${GRPC_CONNECT_TIMEOUT}" \
    -max-time "${GRPC_MAX_TIME}" \
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
  if out="$(send_handle_json '{"dish_inhibit_gps":{"inhibit_gps":true}}' 2>&1)"; then
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
    echo "  - Reflection unavailable (try Probe)"
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
  if out="$(send_handle_json '{"dish_inhibit_gps":{"inhibit_gps":false}}' 2>&1)"; then
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
  out="$(send_handle_json '{"get_status":{}}' 2>&1 || true)"
  printf "%s\n" "${out}"
  echo
  echo "---- highlights (gps|inhibit|position|location|gnss|constellation) ----"
  printf "%s\n" "${out}" | filter_lines_ci "gps|inhibit|position|location|gnss|constellation" || true
}

cmd_probe() {
  echo "Probe: verifying reflection + listing GPS-related request fields"
  echo "Target: ${TARGET}"
  echo

  echo "[1/3] List services:"
  svc_out="$(grpcurl_plaintext "${TARGET}" list 2>&1 || true)"
  printf "%s\n" "${svc_out}"
  echo

  echo "[2/3] Describe request message (SpaceX.API.Device.Request) and filter GPS-ish lines:"
  req_out="$(grpcurl_plaintext "${TARGET}" describe SpaceX.API.Device.Request 2>&1 || true)"

  if printf "%s\n" "${svc_out}" | grep -qiE "Failed to dial target host|transport: error while dialing|connect:|connection refused|no route to host|context deadline exceeded"; then
    echo "✗ Probe failed: could not connect to ${TARGET}."
    echo "  Make sure you are connected to Starlink Wi‑Fi / local LAN, and retry."
    return 1
  fi

  if printf "%s\n" "${req_out}" | grep -qiE "does not support the reflection API|server reflection|reflection"; then
    if printf "%s\n" "${req_out}" | grep -qiE "does not support the reflection API"; then
      echo "✗ Probe failed: the dish does not expose the reflection API to grpcurl."
      echo "  Try the Starlink app toggle if available, or see docs for older firmware."
      return 1
    fi
  fi

  if printf "%s\n" "${req_out}" | grep -qiE "Failed to dial target host|transport: error while dialing|connect:|connection refused|no route to host|context deadline exceeded"; then
    echo "✗ Probe failed: could not connect to ${TARGET}."
    echo "  Make sure you are connected to Starlink Wi‑Fi / local LAN, and retry."
    return 1
  fi

  highlights="$(printf "%s\n" "${req_out}" | filter_lines_ci "gps|inhibit|position|location|gnss|constellation" || true)"
  if [[ "${highlights}" == "" ]]; then
    echo "(no GPS-related fields printed; full output may explain why)"
    printf "%s\n" "${req_out}"
  else
    printf "%s\n" "${highlights}"
  fi
  echo

  echo "[3/3] Quick check: does 'dish_inhibit_gps' appear in the request definition?"
  if printf "%s\n" "${req_out}" | grep -q "dish_inhibit_gps"; then
    echo "✓ Found dish_inhibit_gps in SpaceX.API.Device.Request"
  else
    echo "✗ dish_inhibit_gps not found (older firmware or reflection unavailable)."
    echo "  Try the Starlink app toggle if available, or use physical/antenna fallbacks in docs."
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
    if out="$(send_handle_json '{"dish_inhibit_gps":{"inhibit_gps":true}}' 2>&1)"; then
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
