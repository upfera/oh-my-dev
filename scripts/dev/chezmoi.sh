#!/bin/bash

sh -c "$(curl -fsLS get.chezmoi.io)" -- -b ~/.local/bin

if command -v chezmoi.exe >/dev/null 2>&1; then
    mkdir -p ~/.config/chezmoi
    echo "sourceDir = \"$(wslpath -a $(chezmoi.exe source-path | tr -d '\r'))\"" > ~/.config/chezmoi/chezmoi.toml
fi
