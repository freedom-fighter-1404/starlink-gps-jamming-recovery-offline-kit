#!/usr/bin/env python3
import argparse
import os
import stat
import zipfile
from pathlib import Path
from typing import List, Optional, Set


EXCLUDE_DIRS = {".git", "dist"}
EXCLUDE_NAMES = {".DS_Store"}


def is_excluded(rel_posix: str, grpcurl_platforms: Optional[Set[str]]) -> bool:
    if rel_posix == "":
        return True
    parts = rel_posix.split("/")
    if any(part in EXCLUDE_DIRS for part in parts):
        return True
    if parts[-1] in EXCLUDE_NAMES:
        return True
    if parts[-1].endswith((".pyc", ".pyo", ".swp", ".tmp")):
        return True
    if "/__pycache__/" in f"/{rel_posix}/":
        return True

    if grpcurl_platforms is not None and rel_posix.startswith("bin/grpcurl/"):
        # Keep only selected grpcurl directories (e.g. windows-x86_64, macos-arm64).
        # Path looks like: bin/grpcurl/<platform>/<file>
        p = rel_posix.split("/")
        if len(p) >= 3:
            platform = p[2]
            if platform not in grpcurl_platforms:
                return True
    return False


def zipinfo_for(path: Path, arcname: str, fixed_date_time) -> zipfile.ZipInfo:
    info = zipfile.ZipInfo(filename=arcname, date_time=fixed_date_time)
    st = path.stat()
    mode = st.st_mode
    perm = 0o755 if (mode & (stat.S_IXUSR | stat.S_IXGRP | stat.S_IXOTH)) else 0o644
    info.external_attr = ((stat.S_IFREG | perm) & 0xFFFF) << 16
    info.compress_type = zipfile.ZIP_DEFLATED
    info.create_system = 3
    return info


def build_zip(src: Path, out_zip: Path, grpcurl_platforms: Optional[Set[str]]) -> None:
    src = src.resolve()
    out_zip.parent.mkdir(parents=True, exist_ok=True)

    fixed_date_time = (1980, 1, 1, 0, 0, 0)
    files: List[str] = []

    for root, dirs, filenames in os.walk(src):
        root_path = Path(root)
        rel_root = root_path.relative_to(src).as_posix()

        dirs[:] = sorted(
            d for d in dirs if not is_excluded(f"{rel_root}/{d}" if rel_root else d, grpcurl_platforms)
        )
        for name in sorted(filenames):
            rel = f"{rel_root}/{name}" if rel_root else name
            rel_posix = Path(rel).as_posix()
            if is_excluded(rel_posix, grpcurl_platforms):
                continue
            files.append(rel_posix)

    with zipfile.ZipFile(out_zip, "w", compression=zipfile.ZIP_DEFLATED, compresslevel=9) as zf:
        for rel_posix in files:
            path = src / rel_posix
            info = zipinfo_for(path, rel_posix, fixed_date_time)
            with path.open("rb") as f, zf.open(info, "w") as dest:
                while True:
                    chunk = f.read(1024 * 1024)
                    if not chunk:
                        break
                    dest.write(chunk)


def parse_platforms(value: str) -> Optional[Set[str]]:
    v = value.strip()
    if v.lower() == "all":
        return None
    items = [p.strip() for p in v.split(",") if p.strip()]
    if not items:
        raise ValueError("grpcurl platforms list is empty")
    return set(items)


def main() -> int:
    parser = argparse.ArgumentParser(
        description="Build deterministic offline-kit ZIPs (fixed timestamps; excludes .git, dist)."
    )
    parser.add_argument("--src", required=True, help="Source directory to zip")
    parser.add_argument("--out", required=True, help="Output zip path")
    parser.add_argument(
        "--grpcurl-platforms",
        default="all",
        help="Comma-separated grpcurl subdirs to include (e.g. windows-x86_64,macos-arm64) or 'all'",
    )
    args = parser.parse_args()

    src = Path(args.src)
    out_zip = Path(args.out)
    grpcurl_platforms = parse_platforms(args.grpcurl_platforms)
    build_zip(src, out_zip, grpcurl_platforms)
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
