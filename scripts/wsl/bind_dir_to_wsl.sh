#!/usr/bin/env bash
set -euo pipefail

sudo mkdir -p /mnt/wsl/code
sudo mount --bind ~/code /mnt/wsl/code