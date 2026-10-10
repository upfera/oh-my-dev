#!/usr/bin/env bash
set -euo pipefail

TEMP_DIR=$(mktemp -d)
DEB="$TEMP_DIR/google-chrome-stable_current_amd64.deb"
trap 'rm -rf -- "$TEMP_DIR"' EXIT

echo "📦 Downloading Google Chrome..."
curl -fLsS --proto '=https' --proto-redir '=https' -o "$DEB" \
  https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb

echo "📦 Installing Chrome..."
sudo apt install -y "$DEB"

echo "🔤 Installing fonts..."
sudo apt install -y ttf-mscorefonts-installer

echo "🔤 Setting up fontconfig..."
mkdir -p ~/.config/fontconfig

cat > ~/.config/fontconfig/fonts.conf <<'EOF'
<?xml version="1.0"?>
<!DOCTYPE fontconfig SYSTEM "fonts.dtd">
<fontconfig>
  <alias>
    <family>sans-serif</family>
    <prefer>
      <family>Segoe UI</family>
      <family>Arial</family>
      <family>Noto Sans</family>
    </prefer>
  </alias>
</fontconfig>
EOF

echo "🔄 Rebuilding font cache..."
fc-cache -fv >/dev/null 2>&1 || true

echo "✅ Chrome installed successfully"
