#!/usr/bin/env python3
"""Probe depends/packages/*.mk download URLs before running make.

Usage:
  ./contrib/check-depends-urls.py              # base + Qt (Linux GUI build)
  ./contrib/check-depends-urls.py --no-gui     # base packages only
  ./contrib/check-depends-urls.py --wallet --upnp --darwin
  ./contrib/check-depends-urls.py --checksum   # download and verify sha256
  ./contrib/check-depends-urls.py --all        # every package .mk
"""

from __future__ import annotations

import argparse
import hashlib
import re
import ssl
import sys
import urllib.error
import urllib.request
from pathlib import Path
from typing import Dict, List, NamedTuple, Optional, Set, Tuple

ROOT = Path(__file__).resolve().parents[1]
PACKAGES_DIR = ROOT / "depends" / "packages"

BASE_PACKAGES = [
    "boost",
    "openssl",
    "libevent",
    "zeromq",
    "gmp",
    "cmake",
    "bls-dash",
    "backtrace",
    "native_b2",
]
GUI_EXTRA = [
    "native_protobuf",
    "protobuf",
    "qrencode",
    "zlib",
    "qt",
    "expat",
    "dbus",
    "libxcb",
    "xcb_proto",
    "libXau",
    "xproto",
    "freetype",
    "fontconfig",
]
WALLET_EXTRA = ["bdb"]
UPNP_EXTRA = ["miniupnpc"]
DARWIN_NATIVE = [
    "native_biplist",
    "native_ds_store",
    "native_mac_alias",
    "native_cctools",
    "native_cdrkit",
    "native_libdmg-hfsplus",
]

EXTRA_SOURCE_SPECS = {
    "qt": [
        ("download_path", "qttranslations_file_name", "qttranslations_sha256_hash", "qttranslations"),
        ("download_path", "qttools_file_name", "qttools_sha256_hash", "qttools"),
    ],
    "bls-dash": [
        ("relic_download_path", "relic_download_file", "relic_sha256_hash", "relic"),
    ],
    "native_cctools": [
        ("clang_download_path", "clang_download_file", "clang_sha256_hash", "clang"),
    ],
}


class Source(NamedTuple):
    package: str
    url: str
    sha256: Optional[str]
    label: str


def parse_packages() -> Dict[str, Dict[str, str]]:
    ctx: Dict[str, Dict[str, str]] = {}
    for mk in sorted(PACKAGES_DIR.glob("*.mk")):
        if mk.name == "packages.mk":
            continue
        pkg = mk.stem
        fields: Dict[str, str] = {}
        for line in mk.read_text().splitlines():
            if line.startswith("package="):
                pkg = line.split("=", 1)[1].strip()
            m = re.match(r"^\$\(package\)_(\w+)\s*=\s*(.*)$", line.strip())
            if m:
                fields[m.group(1)] = m.group(2).strip()
        ctx[pkg] = fields
    return ctx


def _split_var(var: str, packages: Set[str]) -> Optional[Tuple[str, str]]:
    for pkg in sorted(packages, key=len, reverse=True):
        prefix = pkg + "_"
        if var.startswith(prefix):
            return pkg, var[len(prefix) :]
    return None


def eval_field(
    pkg: str,
    key: str,
    ctx: Dict[str, Dict[str, str]],
    stack: Set[Tuple[str, str]],
) -> str:
    if (pkg, key) in stack:
        return ""
    fields = ctx.get(pkg)
    if not fields or key not in fields:
        return ""
    raw = fields[key]
    stack = set(stack)
    stack.add((pkg, key))
    return eval_expr(raw, pkg, ctx, stack)


def eval_expr(
    expr: str,
    pkg: str,
    ctx: Dict[str, Dict[str, str]],
    stack: Set[Tuple[str, str]],
) -> str:
    if not expr:
        return expr
    packages = set(ctx.keys())
    out = expr
    ver = eval_field(pkg, "version", ctx, stack)
    for _ in range(32):
        prev = out

        def repl_pkg_key(m: re.Match[str]) -> str:
            return eval_field(pkg, m.group(1), ctx, stack)

        # Before expanding bare $(package) — otherwise $($(package)_version) breaks.
        out = re.sub(r"\$\(\$\(package\)_(\w+)\)", repl_pkg_key, out)

        out = out.replace("$(subst _,.,$($(package)_version))", ver.replace("_", "."))
        out = re.sub(
            r"\$\(subst _,\.,\$\(\$\(package\)_version\)\)",
            ver.replace("_", "."),
            out,
        )
        out = re.sub(
            r"\$\(subst _,\.,([^)]+)\)",
            lambda m: m.group(1).replace("_", "."),
            out,
        )

        def repl_cross(m: re.Match[str]) -> str:
            var = m.group(1)
            split = _split_var(var, packages)
            if not split:
                return m.group(0)
            ref_pkg, ref_key = split
            return eval_field(ref_pkg, ref_key, ctx, stack)

        out = re.sub(r"\$\((\w+)\)", repl_cross, out)
        # Standalone $(package) only (not inside $($(package)_…)).
        out = re.sub(r"(?<!\$)\$\(package\)", lambda _: pkg, out)
        if out == prev:
            break
    return out


def primary_download_name(pkg: str, ctx: Dict[str, Dict[str, str]]) -> str:
    """Name used in the download URL (fetch_file arg 3)."""
    dl = eval_field(pkg, "download_file", ctx, set())
    if dl:
        return dl
    fname = eval_field(pkg, "file_name", ctx, set())
    if fname:
        return fname
    ver = eval_field(pkg, "version", ctx, set())
    return f"{pkg}-{ver}.tar.gz"


def collect_sources(pkg: str, ctx: Dict[str, Dict[str, str]]) -> List[Source]:
    rows: List[Source] = []

    def add(path_key: str, file_key: str, sha_key: str, label: str) -> None:
        base = eval_field(pkg, path_key, ctx, set())
        fname = eval_field(pkg, file_key, ctx, set())
        if not base or not fname or "$(" in base or "$(" in fname:
            return
        sha = eval_field(pkg, sha_key, ctx, set())
        sha = sha if sha and "$(" not in sha else None
        url = f"{base.rstrip('/')}/{fname.lstrip('/')}"
        rows.append(Source(pkg, url, sha, label))

    base = eval_field(pkg, "download_path", ctx, set())
    fname = primary_download_name(pkg, ctx)
    sha = eval_field(pkg, "sha256_hash", ctx, set())
    if base and fname and "$(" not in base and "$(" not in fname:
        rows.append(
            Source(
                pkg,
                f"{base.rstrip('/')}/{fname.lstrip('/')}",
                sha if sha and "$(" not in sha else None,
                "primary",
            )
        )

    for path_key, file_key, sha_key, label in EXTRA_SOURCE_SPECS.get(pkg, []):
        add(path_key, file_key, sha_key, label)

    return rows


def probe(url: str, timeout: float) -> Tuple[str, int, str]:
    req = urllib.request.Request(
        url, method="HEAD", headers={"User-Agent": "check-depends-urls/1.0"}
    )
    try:
        with urllib.request.urlopen(req, timeout=timeout) as resp:
            return "OK", resp.status, ""
    except urllib.error.HTTPError as e:
        if e.code in (403, 405):
            try:
                req2 = urllib.request.Request(
                    url,
                    headers={"User-Agent": "check-depends-urls/1.0", "Range": "bytes=0-0"},
                )
                with urllib.request.urlopen(req2, timeout=timeout) as resp2:
                    return "OK", resp2.status, ""
            except Exception as e2:
                return "FAIL", getattr(e2, "code", e.code), str(e2)
        return "FAIL", e.code, str(e)
    except urllib.error.URLError as e:
        return "FAIL", 0, str(e.reason)
    except ssl.SSLError as e:
        return "FAIL", 0, f"SSL: {e}"
    except Exception as e:
        return "FAIL", 0, str(e)


def verify_checksum(url: str, expected: str, timeout: float) -> Tuple[bool, str]:
    h = hashlib.sha256()
    req = urllib.request.Request(url, headers={"User-Agent": "check-depends-urls/1.0"})
    try:
        with urllib.request.urlopen(req, timeout=timeout) as resp:
            while True:
                chunk = resp.read(1 << 20)
                if not chunk:
                    break
                h.update(chunk)
    except Exception as e:
        return False, str(e)
    got = h.hexdigest()
    return (got == expected, got if got == expected else f"expected {expected}, got {got}")


def package_set(args: argparse.Namespace) -> List[str]:
    if args.all:
        return sorted(
            p.stem
            for p in PACKAGES_DIR.glob("*.mk")
            if p.name != "packages.mk"
        )
    names: List[str] = list(BASE_PACKAGES)
    if args.gui:
        names.extend(GUI_EXTRA)
    if args.wallet:
        names.extend(WALLET_EXTRA)
    if args.upnp:
        names.extend(UPNP_EXTRA)
    if args.darwin:
        names.extend(DARWIN_NATIVE)
    seen: Set[str] = set()
    out: List[str] = []
    for n in names:
        if n not in seen:
            seen.add(n)
            out.append(n)
    return out


def main() -> int:
    ap = argparse.ArgumentParser(
        description=__doc__,
        formatter_class=argparse.RawDescriptionHelpFormatter,
    )
    ap.add_argument("--no-gui", action="store_true", help="skip Qt-related packages")
    ap.add_argument("--gui", action="store_true", help="include Qt stack (default)")
    ap.add_argument("--wallet", action="store_true")
    ap.add_argument("--upnp", action="store_true")
    ap.add_argument("--darwin", action="store_true")
    ap.add_argument("--all", action="store_true")
    ap.add_argument("--checksum", action="store_true")
    ap.add_argument("--timeout", type=float, default=30.0)
    args = ap.parse_args()

    if args.all:
        args.gui = False
    elif not args.no_gui and not (args.wallet or args.upnp or args.darwin):
        args.gui = True

    ctx = parse_packages()
    packages = package_set(args)
    failures = 0
    print(f"Checking {len(packages)} package(s) under {PACKAGES_DIR}\n")

    for pkg in packages:
        if pkg not in ctx:
            print(f"  ?  {pkg}: no .mk file\n")
            continue
        sources = collect_sources(pkg, ctx)
        if not sources:
            if pkg == "native_b2":
                print(f"  —  {pkg}: uses boost archive (checked via boost)\n")
            elif pkg == "protobuf":
                print(f"  —  {pkg}: uses native_protobuf archive\n")
            else:
                print(f"  ?  {pkg}: could not resolve download URL\n")
            continue
        for src in sources:
            status, code, detail = probe(src.url, args.timeout)
            if status != "OK":
                failures += 1
                print(f"  FAIL  {pkg}/{src.label}: HTTP {code}")
                print(f"       {src.url}")
                if detail:
                    print(f"       {detail}")
                print()
                continue
            if args.checksum and src.sha256:
                ok, msg = verify_checksum(src.url, src.sha256, args.timeout)
                if ok:
                    print(f"  OK    {pkg}/{src.label}: HTTP {code}, sha256 OK")
                else:
                    failures += 1
                    print(f"  FAIL  {pkg}/{src.label}: sha256 mismatch")
                    print(f"       {msg}")
                    print(f"       {src.url}")
                print()
            else:
                pin = " (sha256 pinned)" if src.sha256 else ""
                print(f"  OK    {pkg}/{src.label}: HTTP {code}{pin}")
                print(f"       {src.url}")
                print()

    print()
    if failures:
        print(f"{failures} URL(s) failed. Update depends/packages/*.mk before `make`.")
        return 1
    print("All probed URLs look reachable.")
    if not args.checksum:
        print("Tip: add --checksum to verify archives match pinned hashes (slower).")
    return 0


if __name__ == "__main__":
    sys.exit(main())
