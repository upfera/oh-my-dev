#!/usr/bin/env bash
# Upload every regular file directly inside a directory to one BWS project.
# Secret names are the files' basenames.
# Usage: bws_upload_dir.sh <directory> <project-id>
set -uo pipefail

if [[ $# -ne 2 ]]; then
  echo "Usage: $0 <directory> <project-id>" >&2
  exit 2
fi

dir=$1
project_id=$2
if [[ ! -d "$dir" || ! -r "$dir" ]]; then
  echo "ERROR: Directory is missing or unreadable: $dir" >&2
  exit 1
fi
if [[ -z "${BWS_ACCESS_TOKEN:-}" ]]; then
  echo "ERROR: BWS_ACCESS_TOKEN is not set." >&2
  exit 1
fi
if ! command -v bws >/dev/null 2>&1; then
  echo "ERROR: bws CLI is not installed." >&2
  exit 1
fi

shopt -s nullglob dotglob
files=("$dir"/*)
shopt -u dotglob
if [[ ${#files[@]} -eq 0 ]]; then
  echo "No files found in $dir."
  exit 0
fi

ok=0
failed=0
for file in "${files[@]}"; do
  [[ -f "$file" ]] || continue
  key=$(basename -- "$file")
  echo "Uploading: $key"
  if "$(dirname -- "$0")/bws_upload_file.sh" "$file" "$project_id" "$key"; then
    ((ok+=1))
  else
    ((failed+=1))
    echo "ERROR: Failed to upload $key; continuing with remaining files." >&2
  fi
done

printf '\nUpload summary: %d succeeded, %d failed.\n' "$ok" "$failed"
(( failed == 0 ))
