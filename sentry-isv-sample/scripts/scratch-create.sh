#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
VERSION_ID_FILE="$SCRIPT_DIR/../../sentry-isv-adoption/.last-package-version-id"

if [[ ! -f "$VERSION_ID_FILE" ]]; then
  echo "Error: no package version ID found at $VERSION_ID_FILE" >&2
  echo "Run: turbo run package:create --filter=sentry-isv-adoption" >&2
  exit 1
fi

NEW_ID="$(cat "$VERSION_ID_FILE")"
ORG_ALIAS="$(date +%Y%m%d-%H%M)"

echo "Creating scratch org '$ORG_ALIAS'..."
sf org create scratch \
  --definition-file config/project-scratch-def.json \
  --alias "$ORG_ALIAS" \
  --set-default \
  --duration-days 7

echo "Installing package $NEW_ID into org '$ORG_ALIAS'..."
sf package install \
  --package "$NEW_ID" \
  --target-org "$ORG_ALIAS" \
  --wait 20 \
  --no-prompt

echo "Deploying subscriber metadata (validation rules, custom stages)..."
sf project deploy start \
  --target-org "$ORG_ALIAS" \
  --wait 10

echo "Seeding crash-scenario data..."
sf apex run \
  --file "$SCRIPT_DIR/seed-data.apex" \
  --target-org "$ORG_ALIAS"

echo ""
echo "Running crash scenarios..."
"$SCRIPT_DIR/crash-scenarios.sh" "$ORG_ALIAS"
