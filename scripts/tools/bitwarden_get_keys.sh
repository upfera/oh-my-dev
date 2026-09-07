#!/bin/bash

set -euo pipefail

export BW_SESSION
BW_SESSION=$(bw unlock --raw)

bw sync --session "$BW_SESSION"

SSH_DIR="$HOME/.ssh"
mkdir -p "$SSH_DIR"
chmod 700 "$SSH_DIR"

# Ensure BW session exists
if [ -z "${BW_SESSION:-}" ]; then
  echo "❌ BW_SESSION is not set. Run: bw unlock"
  exit 1
fi

echo "🔐 Fetching SSH keys from Bitwarden..."

bw list items --session "$BW_SESSION" | jq -c '
  .[] | select(.sshKey != null and .sshKey.privateKey != null)
' | while read -r item; do

  NAME=$(echo "$item" | jq -r '.name')
  SAFE_NAME=$(echo "$NAME" | tr ' ' '_' | tr -cd '[:alnum:]_-')

  PRIV_KEY=$(echo "$item" | jq -r '.sshKey.privateKey')
  PUB_KEY=$(echo "$item" | jq -r '.sshKey.publicKey')

  KEY_PATH="$SSH_DIR/$SAFE_NAME"

  if [ -f "$KEY_PATH" ]; then
    echo "⚠️ Skipping existing key: $KEY_PATH"
    continue
  fi

  echo "➡️ Writing key: $KEY_PATH"

  echo "$PRIV_KEY" > "$KEY_PATH"
  chmod 600 "$KEY_PATH"

  if [ "$PUB_KEY" != "null" ] && [ -n "$PUB_KEY" ]; then
    echo "$PUB_KEY" > "$KEY_PATH.pub"
    chmod 644 "$KEY_PATH.pub"
  fi

done

echo "✅ Done. Keys saved to $SSH_DIR"