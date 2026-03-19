#!/bin/bash
# Terraform external data source: verify required host commands exist.
# Runs during terraform plan/apply so missing dependencies fail fast.
set -euo pipefail

# Consume stdin (Terraform always sends a JSON query object)
cat >/dev/null

missing=()
for cmd in sshpass ssh rsync; do
  if ! command -v "$cmd" >/dev/null 2>&1; then
    missing+=("$cmd")
  fi
done

if [ "${#missing[@]}" -ne 0 ]; then
  >&2 echo "ERROR: Missing required executable(s): ${missing[*]}"
  >&2 echo "Please install them before running terraform plan/apply."
  exit 1
fi

echo '{"ok":"true"}'