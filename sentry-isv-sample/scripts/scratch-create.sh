#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SFDX_PROJECT="$SCRIPT_DIR/../../sentry-isv-adoption/sfdx-project.json"
NEW_ID="$(node -p "
  const p = require('$SFDX_PROJECT');
  const versioned = Object.entries(p.packageAliases).filter(([k]) => k.includes('@'));
  versioned[versioned.length - 1][1];
")"
echo "Using package version: $NEW_ID"
ORG_ALIAS="isvsample$(date +%Y%m%d%H%M)"

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
