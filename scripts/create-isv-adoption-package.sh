#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
MONOREPO_ROOT="$SCRIPT_DIR/.."
PROJECT_ROOT="$MONOREPO_ROOT/sentry-isv-adoption"
SFDX_PROJECT="$PROJECT_ROOT/sfdx-project.json"

if ! command -v sf &>/dev/null; then
  echo "Error: 'sf' (Salesforce CLI) is not installed or not in PATH." >&2
  exit 1
fi
if ! command -v jq &>/dev/null; then
  echo "Error: 'jq' is not installed or not in PATH." >&2
  exit 1
fi

echo "Reading package alias from sfdx-project.json..."
PACKAGE_ALIAS="$(jq -r '.packageDirectories[] | select(has("package")) | .package' "$SFDX_PROJECT")"
if [[ -z "$PACKAGE_ALIAS" ]]; then
  echo "Error: no packageDirectories entry with a 'package' field found in $SFDX_PROJECT" >&2
  exit 1
fi
echo "  Package alias: $PACKAGE_ALIAS"

echo "Running 'sf package version create' (this may take a few minutes)..."
cd "$PROJECT_ROOT"
SF_OUTPUT="$(sf package version create \
  --package "$PACKAGE_ALIAS" \
  --code-coverage \
  --installation-key-bypass \
  --json \
  --wait 20)" || {
  echo "Error: 'sf package version create' failed:" >&2
  echo "$SF_OUTPUT" >&2
  exit 1
}

NEW_ID="$(echo "$SF_OUTPUT" | jq -r '.result.SubscriberPackageVersionId // empty')"
if [[ -z "$NEW_ID" ]]; then
  echo "Error: could not extract subscriberPackageVersionId from sf output:" >&2
  echo "$SF_OUTPUT" >&2
  exit 1
fi
echo "  New subscriberPackageVersionId: $NEW_ID"

ORG_ALIAS="$(date +%Y%m%d)"
SAMPLE_ROOT="$MONOREPO_ROOT/sentry-isv-sample"

echo "Creating scratch org '$ORG_ALIAS'..."
cd "$SAMPLE_ROOT"
sf org create scratch \
  --definition-file config/project-scratch-def.json \
  --alias "$ORG_ALIAS" \
  --set-default \
  --duration-days 7

echo "Installing package $NEW_ID into org '$ORG_ALIAS'..."
sf package install \
  --package "$NEW_ID" \
  --target-org "$ORG_ALIAS" \
  --wait 20

echo "Done. Scratch org alias: $ORG_ALIAS"