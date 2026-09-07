#!/usr/bin/env bash
set -euo pipefail

WIN_DIR="/mnt/c/Source/Dev"
DISK_FILE="$WIN_DIR/code.img"
MOUNT_POINT="/home/tomasz/code"
DISK_SIZE="20G"

echo "[1/4] Preparing folders..."
mkdir -p "$WIN_DIR"
mkdir -p "$MOUNT_POINT"

echo "[2/4] Creating disk (if missing)..."
if [ ! -f "$DISK_FILE" ]; then
    truncate -s "$DISK_SIZE" "$DISK_FILE"
    mkfs.ext4 -F "$DISK_FILE"
fi

echo "[3/4] Mounting..."
if ! mountpoint -q "$MOUNT_POINT"; then
    sudo mount -o loop "$DISK_FILE" "$MOUNT_POINT"
    sudo chown -R $USER:$USER "$MOUNT_POINT"
fi

echo "[4/4] Adding auto-mount to zshrc..."

ZSHRC="$HOME/.zshrc"
MARKER="# >>> code-img-auto-mount >>>"

if ! grep -q "$MARKER" "$ZSHRC"; then
cat <<EOF >> "$ZSHRC"

$MARKER
DISK_FILE="$DISK_FILE"
MOUNT_POINT="$MOUNT_POINT"

if [ -f "\$DISK_FILE" ]; then
    if ! mountpoint -q "\$MOUNT_POINT"; then
        sudo mount -o loop "\$DISK_FILE" "\$MOUNT_POINT"
        sudo chown -R \$USER:\$USER "\$MOUNT_POINT"
    fi
fi
# <<< code-img-auto-mount <<<
EOF
fi

echo ""
echo "✅ DONE"
echo "👉 Disk: $DISK_FILE"
echo "👉 Mount: $MOUNT_POINT"
echo "👉 Auto-mount enabled"