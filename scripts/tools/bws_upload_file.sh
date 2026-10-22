#!/usr/bin/env bash
# Upload one file to Bitwarden Secrets Manager.
# Usage: bws_upload_file.sh <file> <project-id> [secret-key]
set -uo pipefail

if [[ $# -lt 2 || $# -gt 3 ]]; then
  echo "Usage: $0 <file> <project-id> [secret-key]" >&2
  exit 2
fi

file=$1
project_id=$2
key=${3:-$(basename -- "$file")}

if [[ ! -f "$file" || ! -r "$file" ]]; then
  echo "ERROR: File is missing or unreadable: $file" >&2
  exit 1
fi
if [[ -z "${BWS_ACCESS_TOKEN:-}" ]]; then
  echo "ERROR: BWS_ACCESS_TOKEN is not set." >&2
  echo "Set it securely in your shell, then rerun this script." >&2
  exit 1
fi
if ! command -v bws >/dev/null 2>&1; then
  echo "ERROR: bws CLI is not installed." >&2
  exit 1
fi

# bws 2.x takes VALUE as a positional argument. The -- delimiter is
# important for PEM files whose content starts with dashes.
value=$(<"$file") || {
  echo "ERROR: Could not read $file" >&2
  exit 1
}

if bws secret create --output none -- "$key" "$value" "$project_id"; then
  printf 'Uploaded %s as secret "%s".\n' "$file" "$key"
else
  rc=$?
  echo "ERROR: Upload failed for secret \"$key\" (bws exit $rc)." >&2
  unset value
  exit "$rc"
fi
unset value
