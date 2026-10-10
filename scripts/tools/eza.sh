#!/bin/bash
set -euo pipefail

TEMP_DIR=$(mktemp -d)
trap 'rm -rf -- "$TEMP_DIR"' EXIT

curl -fsSL --proto '=https' --proto-redir '=https' -o "$TEMP_DIR/deb.asc" https://raw.githubusercontent.com/eza-community/eza/main/deb.asc
gpg --dearmor --output "$TEMP_DIR/gierens.gpg" "$TEMP_DIR/deb.asc"
sudo install -D -m 644 "$TEMP_DIR/gierens.gpg" /etc/apt/keyrings/gierens.gpg
printf '%s\n' 'deb [signed-by=/etc/apt/keyrings/gierens.gpg] https://deb.gierens.de stable main' | sudo tee /etc/apt/sources.list.d/gierens.list
sudo chmod 644 /etc/apt/keyrings/gierens.gpg /etc/apt/sources.list.d/gierens.list
sudo apt update
sudo apt install -y eza

cat ./dot_files/.eza_aliases >> ~/.zsh_aliases
cat ./dot_files/.eza_aliases >> ~/.bash_aliases
