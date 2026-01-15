#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "${ROOT_DIR}"

if [[ ! -f "CHECKSUMS.sha256" ]]; then
  echo "ERROR: CHECKSUMS.sha256 not found in: ${ROOT_DIR}" >&2
  echo "If you downloaded a release ZIP, it may be incomplete or corrupted." >&2
  exit 1
fi

sum_cmd=""
sum_args=()

if command -v shasum >/dev/null 2>&1; then
  sum_cmd="shasum"
  sum_args=(-a 256)
elif command -v sha256sum >/dev/null 2>&1; then
  sum_cmd="sha256sum"
  sum_args=()
else
  echo "ERROR: No SHA-256 checksum tool found in PATH." >&2
  exit 1
fi

echo "== Verifying scripts/docs (CHECKSUMS.sha256) =="
"${sum_cmd}" "${sum_args[@]}" -c "CHECKSUMS.sha256"
echo

echo "== Verifying bundled grpcurl binaries (checksums/BUNDLED_FILES_SHA256.txt) =="
(cd "bin" && "${sum_cmd}" "${sum_args[@]}" -c "../checksums/BUNDLED_FILES_SHA256.txt")
echo

echo "OK: Integrity checks passed."
