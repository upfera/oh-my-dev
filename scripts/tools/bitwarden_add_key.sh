#!/bin/bash

export BW_SESSION
BW_SESSION=$(bw unlock --raw)

if [ -z "$1" ]; then
  echo "Usage: $0 <path-to-ssh-key>"
  exit 1
fi

SSH_KEY_PATH="$1"

if [ ! -f "$SSH_KEY_PATH" ]; then
  echo "Error: File '$SSH_KEY_PATH' not found"
  exit 1
fi

PUB_KEY=$(ssh-keygen -y -f "$SSH_KEY_PATH")
PRIV_KEY=$(cat "$SSH_KEY_PATH")
FINGERPRINT=$(ssh-keygen -lf <(ssh-keygen -y -f "$SSH_KEY_PATH") | awk '{print $2}')

KEY_NAME=$(basename "$SSH_KEY_PATH")

bw get template item --session "$BW_SESSION" | jq \
  --arg name "$KEY_NAME" \
  --arg username "ssh-key" \
  --arg priv "$PRIV_KEY" \
  --arg pub "$PUB_KEY" \
  --arg fp "$FINGERPRINT" \
  '
  .name = $name |
  .type = 5 |
  .login.username = $username |
  .sshKey.privateKey = $priv |
  .sshKey.publicKey = $pub |
  .sshKey.keyFingerprint = $fp
  ' | bw encode | bw create item --session "$BW_SESSION"