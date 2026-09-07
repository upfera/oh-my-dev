#!/bin/bash
set -e

echo "Installing fd..."

sudo apt update
sudo apt install -y curl wget jq ca-certificates

cd /tmp

URL=$(curl -s https://api.github.com/repos/sharkdp/fd/releases/latest \
  | jq -r '.assets[] | select(.name | test("amd64\\.deb$")) | .browser_download_url' \
  | head -n 1)

echo "Downloading: $URL"

FILE=$(basename "$URL")

wget -O "$FILE" "$URL"

sudo dpkg -i "$FILE"
sudo apt -f install -y

echo "fd installed successfully"