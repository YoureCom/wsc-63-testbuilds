#!/usr/bin/env bash
# Builds WCFSetup.tar.gz + install.php from a WoltLab/WCF checkout.
# Usage: build.sh <WCF checkout> <output dir>
# Requires `npm ci` in <checkout>/extra beforehand (skip the JS build with SKIP_JS=1).
set -euo pipefail
SRC="$(cd "$1" && pwd)"; OUT="$2"; mkdir -p "$OUT"; OUT="$(cd "$OUT" && pwd)"
PKG="$(mktemp -d)"; trap 'rm -rf "$PKG" "$SRC/wcfsetup/install/packages/com.woltlab.wcf.tar"' EXIT

# 1) JS bundles
if [ "${SKIP_JS:-0}" != "1" ]; then (cd "$SRC/extra" && node _buildCore.js); fi

# 2) Core package com.woltlab.wcf.tar
cp -r "$SRC/com.woltlab.wcf/." "$PKG/"
tar -cf "$PKG/files.tar"        -C "$SRC/wcfsetup/install/files" --exclude=./acp/templates .
tar -cf "$PKG/acptemplates.tar" -C "$SRC/wcfsetup/install/files/acp/templates" .
tar -cf "$PKG/templates.tar"    -C "$SRC/com.woltlab.wcf/templates" .
rm -rf "$PKG/templates"
mkdir -p "$PKG/language" "$PKG/acp/database"
cp "$SRC"/wcfsetup/install/lang/*.xml "$PKG/language/"
cp "$SRC/wcfsetup/setup/db/install_com.woltlab.wcf.php" "$PKG/acp/database/"
mkdir -p "$SRC/wcfsetup/install/packages"
tar -cf "$SRC/wcfsetup/install/packages/com.woltlab.wcf.tar" -C "$PKG" .

# 3) WCFSetup.tar.gz (install/ + setup/) and install.php
tar -czf "$OUT/WCFSetup.tar.gz" -C "$SRC/wcfsetup" install setup
cp "$SRC/wcfsetup/install.php" "$SRC/wcfsetup/test.php" "$OUT/"
( cd "$OUT" && sha256sum WCFSetup.tar.gz install.php test.php > SHA256SUMS )
ls -la "$OUT"
