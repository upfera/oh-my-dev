#!/bin/bash
set -euo pipefail

INSTALLER=$(mktemp)
trap 'rm -f -- "$INSTALLER"' EXIT
curl -fsSL --proto '=https' --proto-redir '=https' -o "$INSTALLER" https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh
sh "$INSTALLER"

echo -e '\neval "$(zoxide init zsh)"' >> ~/.zshrc
