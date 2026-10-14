#!/usr/bin/env bash
# Download all secrets in a BWS project to files named after their secret keys.
# Existing files are not overwritten unless BWS_OVERWRITE=1.
# Usage: bws_download_dir.sh <project-id> <output-directory>
set -uo pipefail

if [[ $# -ne 2 ]]; then
  echo "Usage: $0 <project-id> <output-directory>" >&2
  exit 2
fi

project_id=$1
out_dir=$2
if [[ -z "${BWS_ACCESS_TOKEN:-}" ]]; then
  echo "ERROR: BWS_ACCESS_TOKEN is not set." >&2
  exit 1
fi
if ! command -v bws >/dev/null 2>&1 || ! command -v jq >/dev/null 2>&1; then
  echo "ERROR: Both bws and jq must be installed." >&2
  exit 1
fi

umask 077
mkdir -p -- "$out_dir" || exit 1
chmod 700 -- "$out_dir"

# Keep the JSON in memory; never print secret values to the terminal.
secrets=$(bws secret list --output json) || {
  echo "ERROR: Could not list BWS secrets." >&2
  exit 1
}

count=0
skipped=0
failed=0
while IFS= read -r row; do
  [[ -n "$row" ]] || continue
  key=$(jq -r '.key // empty' <<<"$row")
  value=$(jq -r '.value // empty' <<<"$row")
  secret_project=$(jq -r '.projectId // .project_id // .project.id // empty' <<<"$row")

  [[ "$secret_project" == "$project_id" ]] || continue
  if [[ -z "$key" ]]; then
    echo "WARNING: Skipping secret with an empty key." >&2
    ((skipped+=1))
    continue
  fi

  # Disallow path components: each secret maps to one file in output dir.
  if [[ "$key" == */* || "$key" == "." || "$key" == ".." ]]; then
    echo "WARNING: Skipping unsafe filename: $key" >&2
    ((skipped+=1))
    continue
  fi

  target="$out_dir/$key"
  if [[ -e "$target" && "${BWS_OVERWRITE:-0}" != "1" ]]; then
    echo "Skipping existing file: $target"
    ((skipped+=1))
    continue
  fi

  if printf '%s' "$value" > "$target"; then
    chmod 600 -- "$target"
    echo "Downloaded: $key"
    ((count+=1))
  else
    echo "ERROR: Could not write $target" >&2
    ((failed+=1))
  fi
done < <(jq -c '.[]' <<<"$secrets")

printf '\nDownload summary: %d downloaded, %d skipped, %d failed.\n' "$count" "$skipped" "$failed"
(( failed == 0 ))
