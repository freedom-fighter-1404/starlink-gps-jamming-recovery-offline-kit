#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

IDENTITY="starlink-gps-jamming-recovery-offline-kit"
NAMESPACE="starlink-gps-jamming-recovery-offline-kit-release"

DEFAULT_SIGNING_KEY="${HOME}/.config/starlink-gps-jamming-recovery-offline-kit/release_ed25519"
LEGACY_SIGNING_KEY="${HOME}/.config/starlink-iran-toolkit-offline/release_ed25519"
SIGNING_KEY="${SIGNING_KEY:-$DEFAULT_SIGNING_KEY}"

usage() {
  cat <<EOF
Sign a release artifact (ZIP) with:
  - SHA-256
  - OpenSSH signatures (sshsig), when ssh-keygen supports it

Usage:
  SIGNING_KEY=/path/to/release_ed25519 ./scripts/release_sign.sh /path/to/release.zip

Outputs (next to the ZIP):
  - <zip>.sha256
  - <zip>.sshsig

Public verification material (tracked in this repo):
  - release_keys/release_ed25519.pub
  - release_keys/allowed_signers
  - release_keys/FINGERPRINT.txt

Notes:
  - Do NOT commit your private signing key.
  - Always publish/confirm the fingerprint out-of-band.
EOF
}

sha256_file() {
  local file="$1"
  local base
  base="$(basename "${file}")"
  if command -v shasum >/dev/null 2>&1; then
    local h
    h="$(shasum -a 256 "${file}" | awk '{print $1}')"
    printf "%s  %s\n" "${h}" "${base}"
    return 0
  fi
  if command -v sha256sum >/dev/null 2>&1; then
    local h
    h="$(sha256sum "${file}" | awk '{print $1}')"
    printf "%s  %s\n" "${h}" "${base}"
    return 0
  fi
  echo "ERROR: need shasum or sha256sum to compute SHA-256." >&2
  return 1
}

write_release_keys() {
  local pub="$1"
  mkdir -p "${ROOT_DIR}/release_keys"
  cp -f "${pub}" "${ROOT_DIR}/release_keys/release_ed25519.pub"
  printf "%s %s\n" "${IDENTITY}" "$(cat "${pub}")" > "${ROOT_DIR}/release_keys/allowed_signers"
  {
    echo "Release signing public key fingerprint (SHA256):"
    ssh-keygen -l -f "${pub}" | awk '{print $2}'
    echo
    echo "Verify on your machine:"
    echo "ssh-keygen -l -f release_keys/release_ed25519.pub"
    echo
    echo "Important:"
    echo "- Always confirm this fingerprint from at least two independent channels."
    echo "- Do not trust a public key that arrived only inside an unverified ZIP file."
  } > "${ROOT_DIR}/release_keys/FINGERPRINT.txt"
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

  if [[ ! -f "${SIGNING_KEY}" && -f "${LEGACY_SIGNING_KEY}" ]]; then
    SIGNING_KEY="${LEGACY_SIGNING_KEY}"
  fi

  if [[ ! -f "${SIGNING_KEY}" || ! -f "${SIGNING_KEY}.pub" ]]; then
    echo "ERROR: signing key not found: ${SIGNING_KEY}" >&2
    echo "Generate one with:" >&2
    echo "  mkdir -p \"$(dirname "${DEFAULT_SIGNING_KEY}")\"" >&2
    echo "  ssh-keygen -t ed25519 -N '' -f \"${DEFAULT_SIGNING_KEY}\"" >&2
    exit 1
  fi

  echo "Updating public key material in repo (release_keys/)..."
  write_release_keys "${SIGNING_KEY}.pub"

  echo "Writing SHA-256..."
  sha256_file "${file}" > "${file}.sha256"
  cat "${file}.sha256"
  echo

  echo "Signing (OpenSSH sshsig) with namespace: ${NAMESPACE}"
  sig_out=""
  if sig_out="$(ssh-keygen -Y sign -f "${SIGNING_KEY}" -n "${NAMESPACE}" "${file}" 2>&1)"; then
    if [[ "${sig_out}" != "" ]]; then
      printf "%s\n" "${sig_out}"
    fi
    if [[ -f "${file}.sig" ]]; then
      mv -f "${file}.sig" "${file}.sshsig"
    fi
    echo "Wrote signature: ${file}.sshsig"
    echo
    echo "Verify with:"
    echo "  ssh-keygen -Y verify -f \"${ROOT_DIR}/release_keys/allowed_signers\" -I \"${IDENTITY}\" -n \"${NAMESPACE}\" -s \"${file}.sshsig\" < \"${file}\""
    return 0
  fi

  # If sshsig isn't supported, fall back to SHA-256 only.
  printf "%s\n" "${sig_out}" >&2
  if printf "%s\n" "${sig_out}" | grep -qiE "illegal option|unknown option"; then
    echo "WARNING: ssh-keygen does not support sshsig (-Y); signature skipped." >&2
    return 0
  fi

  echo "ERROR: sshsig signing failed." >&2
  return 1
}

main "$@"
