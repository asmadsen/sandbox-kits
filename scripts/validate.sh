#!/usr/bin/env bash
set -euo pipefail

root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
failed=0

for dir in "$root"/kits/*/; do
  [ -f "${dir}$(basename "$dir").yaml" ] || continue
  echo "==> $(basename "$dir")"
  if ! sbx kit validate "$dir"; then
    failed=1
  fi
done

exit "$failed"
