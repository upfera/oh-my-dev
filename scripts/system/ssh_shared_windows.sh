#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/../.." && pwd)"
for target in "$HOME/.zsh_aliases" "$HOME/.bash_aliases"; do
    touch "$target"
    while IFS= read -r line; do
        grep -qxF "$line" "$target" || printf '%s\n' "$line" >> "$target"
    done < "$ROOT_DIR/dot_files/.ssh_aliases"
done

windows_home=$(wslpath "$(powershell.exe -NoProfile -Command '$env:USERPROFILE' | tr -d '\r')")
if [[ -f "$windows_home/.gitconfig" && ! -e "$HOME/.gitconfig" ]]; then
    cp -- "$windows_home/.gitconfig" "$HOME/.gitconfig"
fi

git config --global core.sshcommand "ssh.exe"