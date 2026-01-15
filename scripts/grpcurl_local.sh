#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

if [[ "${GRPCURL:-}" != "" ]]; then
  if [[ -x "${GRPCURL}" ]]; then
    exec "${GRPCURL}" "$@"
  fi
  echo "ERROR: GRPCURL is set but not executable: ${GRPCURL}" >&2
  exit 1
fi

OS="$(uname -s 2>/dev/null || true)"
ARCH="$(uname -m 2>/dev/null || true)"

platform=""
case "${OS}" in
  Darwin) platform="macos" ;;
  Linux) platform="linux" ;;
  *)
    platform=""
    ;;
esac

arch=""
case "${ARCH}" in
  x86_64|amd64) arch="x86_64" ;;
  arm64|aarch64) arch="arm64" ;;
  *)
    arch=""
    ;;
esac

if [[ "${platform}" != "" && "${arch}" != "" ]]; then
  bundled="${ROOT_DIR}/bin/grpcurl/${platform}-${arch}/grpcurl"
  if [[ -x "${bundled}" ]]; then
    exec "${bundled}" "$@"
  fi
fi

if command -v grpcurl >/dev/null 2>&1; then
  exec grpcurl "$@"
fi

echo "ERROR: grpcurl not found." >&2
echo "Expected bundled binary at bin/grpcurl/<platform>-<arch>/grpcurl or a system grpcurl in PATH." >&2
echo "Detected: OS='${OS}', ARCH='${ARCH}'" >&2
exit 1

