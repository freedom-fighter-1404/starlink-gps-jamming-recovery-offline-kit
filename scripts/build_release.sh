#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

PROJECT="starlink-gps-jamming-recovery-offline-kit"

TAG="${TAG:-}"
if [[ "${TAG}" == "" ]]; then
  if command -v git >/dev/null 2>&1 && git -C "${ROOT_DIR}" rev-parse --is-inside-work-tree >/dev/null 2>&1; then
    TAG="$(git -C "${ROOT_DIR}" describe --tags --abbrev=0 2>/dev/null || true)"
  fi
fi
if [[ "${TAG}" == "" ]]; then
  TAG="v0.0.0-dev"
fi

OUT_DIR="${1:-${ROOT_DIR}/dist}"
mkdir -p "${OUT_DIR}"

build_one() {
  local suffix="$1"
  local platforms="$2"
  local out="${OUT_DIR}/${PROJECT}_${TAG}_${suffix}.zip"
  echo "Building deterministic ZIP:"
  echo "  platforms: ${platforms}"
  echo "  out:       ${out}"
  python3 "${ROOT_DIR}/scripts/build_release_zip.py" \
    --src "${ROOT_DIR}" \
    --out "${out}" \
    --grpcurl-platforms "${platforms}"
  "${ROOT_DIR}/scripts/release_sign.sh" "${out}"
  echo
}

echo "Output directory: ${OUT_DIR}"
echo "Tag/version:      ${TAG}"
echo

build_one "windows" "windows-x86_64"
build_one "macos" "macos-arm64,macos-x86_64"
build_one "linux" "linux-arm64,linux-x86_64"
build_one "all-platforms" "all"

echo "Copying verification material next to the ZIPs:"
rm -rf "${OUT_DIR}/release_keys" || true
cp -R "${ROOT_DIR}/release_keys" "${OUT_DIR}/release_keys"
cp "${ROOT_DIR}/docs/VERIFY.md" "${OUT_DIR}/VERIFY_RELEASE_EN.md"
cp "${ROOT_DIR}/docs/VERIFY_FA.md" "${OUT_DIR}/VERIFY_RELEASE_FA.md"

echo
echo "Done."
ls -la "${OUT_DIR}" | sed -n '1,200p'
