#!/usr/bin/env bash
# Upload files directly inside a directory to one BWS project.
# Secret names always use the GH_ prefix.
# GitHub App PEM files such as:
#   upfera-code-review-agent.2026-10-14.private-key.pem
# become:
#   GH_CODE_REVIEW_AGENT_PRIVATE_KEY
# Other files become GH_<NORMALIZED_BASENAME>.
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

script_dir=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)
upload_file="$script_dir/bws_upload_file.sh"
if [[ ! -x "$upload_file" ]]; then
  echo "ERROR: Upload helper is missing or not executable: $upload_file" >&2
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
seen_keys=()

for file in "${files[@]}"; do
  [[ -f "$file" ]] || continue

  filename=$(basename -- "$file")

  # Convert dated GitHub App PEM filenames to stable, human-readable secret names.
  if [[ "$filename" =~ ^upfera-(.+)\.[0-9]{4}-[0-9]{2}-[0-9]{2}\.private-key\.pem$ ]]; then
    app_name=${BASH_REMATCH[1]}
    normalized=$(printf '%s' "$app_name" | tr '[:lower:]-' '[:upper:]_')
    key="GH_${normalized}_PRIVATE_KEY"
  else
    # Generic fallback: normalize the filename and ensure it has no extension suffix.
    stem=${filename%.*}
    normalized=$(printf '%s' "$stem" | tr '[:lower:]-' '[:upper:]_')
    normalized=$(printf '%s' "$normalized" | sed -E 's/[^A-Z0-9_]+/_/g; s/^_+//; s/_+$//; s/_+/_/g')
    key="GH_${normalized}"
  fi

  if [[ ! "$key" =~ ^GH_[A-Z0-9_]+$ ]]; then
    echo "ERROR: Cannot derive a valid secret name from $filename (derived: $key)." >&2
    ((failed+=1))
    continue
  fi

  for seen in "${seen_keys[@]}"; do
    if [[ "$seen" == "$key" ]]; then
      echo "ERROR: Multiple files map to secret $key; skipping $filename to avoid ambiguity." >&2
      ((failed+=1))
      continue 2
    fi
  done
  seen_keys+=("$key")

  echo "Uploading: $filename -> $key"
  if "$upload_file" "$file" "$project_id" "$key"; then
    ((ok+=1))
  else
    ((failed+=1))
    echo "ERROR: Failed to upload $filename; continuing with remaining files." >&2
  fi
done

printf '\nUpload summary: %d succeeded, %d failed.\n' "$ok" "$failed"
(( failed == 0 ))
