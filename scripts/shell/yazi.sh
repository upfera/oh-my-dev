#!/bin/bash
set -euo pipefail

TEMP_DIR=$(mktemp -d)
trap 'rm -rf -- "$TEMP_DIR"' EXIT

curl -fsSL --proto '=https' --proto-redir '=https' -o "$TEMP_DIR/yazi.zip" https://github.com/sxyazi/yazi/releases/latest/download/yazi-x86_64-unknown-linux-gnu.zip
mkdir "$TEMP_DIR/unpacked"
unzip -q "$TEMP_DIR/yazi.zip" -d "$TEMP_DIR/unpacked"
shopt -s nullglob
BINARIES=("$TEMP_DIR"/unpacked/*/{ya,yazi})
if ((${#BINARIES[@]} != 2)); then
    printf 'Unexpected yazi archive contents.\n' >&2
    exit 1
fi

sudo install -m 755 "${BINARIES[@]}" /usr/local/bin
