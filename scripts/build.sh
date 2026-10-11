#!/usr/bin/env bash
# Builds WCFSetup.tar.gz + install.php from a WoltLab/WCF checkout.
# Usage: build.sh <WCF checkout> <output dir>
# Requires `npm ci` in <checkout>/extra beforehand (skip the JS build with SKIP_JS=1).
set -euo pipefail
SRC="$(cd "$1" && pwd)"; OUT="$2"; mkdir -p "$OUT"; OUT="$(cd "$OUT" && pwd)"
PKG="$(mktemp -d)"; trap 'rm -rf "$PKG" "$SRC/wcfsetup/install/packages/com.woltlab.wcf.tar"' EXIT

# Packs the content of a directory without a "./" prefix: WoltLab looks up "package.xml", not "./package.xml".
pack() { # <archive> <directory> [tar options]
  local archive="$1" dir="$2"; shift 2
  (cd "$dir" && tar -cf "$archive" "$@" -- $(ls -A))
}

# 1) JS bundles
if [ "${SKIP_JS:-0}" != "1" ]; then (cd "$SRC/extra" && node _buildCore.js); fi

# 2) Core package com.woltlab.wcf.tar
cp -r "$SRC/com.woltlab.wcf/." "$PKG/"
pack "$PKG/files.tar"        "$SRC/wcfsetup/install/files" --exclude=acp/templates
pack "$PKG/acptemplates.tar" "$SRC/wcfsetup/install/files/acp/templates"
pack "$PKG/templates.tar"    "$SRC/com.woltlab.wcf/templates"
rm -rf "$PKG/templates"
mkdir -p "$PKG/language" "$PKG/acp/database"
cp "$SRC"/wcfsetup/install/lang/*.xml "$PKG/language/"
cp "$SRC/wcfsetup/setup/db/install_com.woltlab.wcf.php" "$PKG/acp/database/"
mkdir -p "$SRC/wcfsetup/install/packages"
pack "$SRC/wcfsetup/install/packages/com.woltlab.wcf.tar" "$PKG"

# Self-check: entries must not start with "./"
if tar -tf "$SRC/wcfsetup/install/packages/com.woltlab.wcf.tar" | grep -q '^\./'; then echo "package entries have a ./ prefix" >&2; exit 1; fi
tar -tf "$SRC/wcfsetup/install/packages/com.woltlab.wcf.tar" | grep -qx 'package.xml'

# 3) WCFSetup.tar.gz (install/ + setup/) and install.php
tar -czf "$OUT/WCFSetup.tar.gz" -C "$SRC/wcfsetup" install setup
cp "$SRC/wcfsetup/install.php" "$SRC/wcfsetup/test.php" "$OUT/"

# one archive with everything the installation needs (needs `zip`, present on the CI runner)
BUNDLE="WoltLabSuite-6.3-testbuild.zip"
if command -v zip >/dev/null 2>&1; then
  (cd "$OUT" && rm -f "$BUNDLE" && zip -q -9 "$BUNDLE" install.php test.php WCFSetup.tar.gz)
else
  echo "zip not found, skipping $BUNDLE" >&2
fi
( cd "$OUT" && sha256sum WCFSetup.tar.gz install.php test.php $( [ -f "$BUNDLE" ] && echo "$BUNDLE" ) > SHA256SUMS )
ls -la "$OUT"
