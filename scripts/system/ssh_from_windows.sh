#!/usr/bin/env bash
set -euo pipefail

mkdir -p "$HOME/.ssh"
chmod 700 "$HOME/.ssh"

# Copy files
if ! command -v powershell.exe >/dev/null 2>&1 || ! command -v wslpath >/dev/null 2>&1; then
    echo "Windows interop (powershell.exe and wslpath) is unavailable; nothing copied." >&2
    exit 0
fi
windows_home=$(wslpath "$(powershell.exe -NoProfile -Command '$env:USERPROFILE' | tr -d '\r')")

if [ -d "$windows_home/.ssh" ]; then
    for file in "$windows_home"/.ssh/*; do
        [[ -f "$file" ]] || continue
        target="$HOME/.ssh/$(basename "$file")"
        if [[ -e "$target" ]]; then
            echo "Keeping existing $target"
        else
            cp -- "$file" "$target"
        fi
    done
else
    echo "No .ssh directory found in Windows home"
fi

# Setup priviledges:
chmod 700 "$HOME/.ssh"
find "$HOME/.ssh" -maxdepth 1 -type f -name '*.pub' -exec chmod 644 {} +

for possiblekey in "$HOME"/.ssh/id_* "$HOME"/.ssh/vps*; do
    [[ -f "$possiblekey" ]] || continue
    if grep -q PRIVATE "$possiblekey"; then
        chmod 600 "$possiblekey"
    fi
done

