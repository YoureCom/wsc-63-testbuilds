#!/usr/bin/env bash
# Keeps the newest 7 test builds plus the newest build of each of the last 4 ISO weeks; deletes the rest.
set -euo pipefail
declare -A week_seen; keep=0
gh release list --limit 200 --json tagName,createdAt --jq 'sort_by(.createdAt)|reverse|.[]|select(.tagName|startswith("6.3-alpha-"))|[.tagName,.createdAt]|@tsv' |
while IFS=$'\t' read -r tag created; do
  keep=$((keep+1)); week="$(date -u -d "$created" +%G-%V)"
  if [ "$keep" -le 7 ]; then week_seen[$week]=1; continue; fi
  if [ -z "${week_seen[$week]:-}" ] && [ "${#week_seen[@]}" -lt 11 ]; then week_seen[$week]=1; continue; fi
  gh release delete "$tag" --cleanup-tag --yes
done
