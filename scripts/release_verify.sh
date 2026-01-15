#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

IDENTITY="starlink-gps-jamming-recovery-offline-kit"
NAMESPACE="starlink-gps-jamming-recovery-offline-kit-release"

usage() {
  cat <<EOF
Verify a release artifact using SHA-256 and OpenSSH sshsig (if available).

Usage:
  ./scripts/release_verify.sh /path/to/release.zip

Expected sidecar files (same directory as the ZIP):
  - <zip>.sha256
  - <zip>.sshsig   (optional)

Verification keys (in this repo):
  - ${ROOT_DIR}/release_keys/allowed_signers
  - ${ROOT_DIR}/release_keys/FINGERPRINT.txt
EOF
}

calc_sha256() {
  local file="$1"
  if command -v shasum >/dev/null 2>&1; then
    shasum -a 256 "${file}" | awk '{print $1}'
    return 0
  fi
  if command -v sha256sum >/dev/null 2>&1; then
    sha256sum "${file}" | awk '{print $1}'
    return 0
  fi
  echo "ERROR: need shasum or sha256sum to compute SHA-256." >&2
  return 1
}

main() {
  local file="${1:-}"
  if [[ "${file}" == "" || "${file}" == "-h" || "${file}" == "--help" ]]; then
    usage
    exit 0
  fi
  if [[ ! -f "${file}" ]]; then
    echo "ERROR: file not found: ${file}" >&2
    exit 2
  fi

  local sha_file="${file}.sha256"
  local sig_file="${file}.sshsig"

  echo "SHA-256:"
  if [[ -f "${sha_file}" ]]; then
    expected="$(awk '{print $1}' "${sha_file}" | head -n 1)"
    actual="$(calc_sha256 "${file}")"
    echo "  expected: ${expected}"
    echo "  actual:   ${actual}"
    if [[ "${expected}" != "${actual}" ]]; then
      echo "ERROR: SHA-256 mismatch." >&2
      exit 1
    fi
    echo "  OK"
  else
    echo "  (missing ${sha_file}; skipping)" >&2
  fi
  echo

  echo "Signature (OpenSSH sshsig):"
  if [[ ! -f "${sig_file}" ]]; then
    echo "  (missing ${sig_file}; skipping)" >&2
    exit 0
  fi

  verify_out=""
  if verify_out="$(ssh-keygen -Y verify \
      -f "${ROOT_DIR}/release_keys/allowed_signers" \
      -I "${IDENTITY}" \
      -n "${NAMESPACE}" \
      -s "${sig_file}" < "${file}" 2>&1)"; then
    if [[ "${verify_out}" != "" ]]; then
      printf "%s\n" "${verify_out}"
    fi
    echo "  OK"
    exit 0
  fi

  printf "%s\n" "${verify_out}" >&2
  if printf "%s\n" "${verify_out}" | grep -qiE "illegal option|unknown option"; then
    echo "  ssh-keygen does not support sshsig (-Y); skipping." >&2
    exit 0
  fi

  echo "  FAILED." >&2
  exit 1
}

main "$@"
