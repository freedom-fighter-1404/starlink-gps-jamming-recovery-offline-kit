#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "${ROOT_DIR}"

if ! command -v git >/dev/null 2>&1; then
  echo "ERROR: git is required to list tracked files." >&2
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
  echo "ERROR: need shasum or sha256sum to compute SHA-256." >&2
  exit 1
fi

tmp="$(mktemp)"
trap 'rm -f "${tmp}"' EXIT

# We intentionally exclude:
# - CHECKSUMS.sha256 (this output file)
# - bundled grpcurl binaries (verified via checksums/BUNDLED_FILES_SHA256.txt)
git ls-files -z \
  | tr '\0' '\n' \
  | grep -vE '^CHECKSUMS\\.sha256$' \
  | grep -vE '^bin/grpcurl/' \
  | sort \
  | while IFS= read -r file; do
      # Safety: never include the checksum file itself (avoids self-referential mismatch).
      if [[ "${file}" == "CHECKSUMS.sha256" ]]; then
        continue
      fi

      h="$("${sum_cmd}" "${sum_args[@]}" "${file}" | awk '{print $1}')"
      printf "%s  ./%s\n" "${h}" "${file}"
    done > "${tmp}"

mv -f "${tmp}" CHECKSUMS.sha256
echo "Wrote CHECKSUMS.sha256"
