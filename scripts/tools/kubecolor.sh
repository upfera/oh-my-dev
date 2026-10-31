#!/bin/bash
set -euo pipefail

sudo apt-get update
sudo apt-get install curl --yes

TEMP_DIR=$(mktemp -d)
trap 'rm -rf -- "$TEMP_DIR"' EXIT

VERSION=$(curl -fsSL --proto '=https' --proto-redir '=https' https://kubecolor.github.io/packages/deb/version)
ARCHITECTURE=$(dpkg --print-architecture)
curl -fsSL --proto '=https' --proto-redir '=https' -o "$TEMP_DIR/kubecolor.deb" "https://kubecolor.github.io/packages/deb/pool/main/k/kubecolor/kubecolor_${VERSION}_${ARCHITECTURE}.deb"
sudo dpkg -i "$TEMP_DIR/kubecolor.deb"
sudo apt update
