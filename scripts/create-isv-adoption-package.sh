#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
MONOREPO_ROOT="$SCRIPT_DIR/.."
PROJECT_ROOT="$MONOREPO_ROOT/sentry-isv-adoption"
SFDX_PROJECT="$PROJECT_ROOT/sfdx-project.json"
SCRATCH_DEF="$MONOREPO_ROOT/sentry-isv-sample/config/project-scratch-def.json"

if ! command -v sf &>/dev/null; then
  echo "Error: 'sf' (Salesforce CLI) is not installed or not in PATH." >&2
  exit 1
fi
if ! command -v jq &>/dev/null; then
  echo "Error: 'jq' is not installed or not in PATH." >&2
  exit 1
fi

if [[ ! -f "$SCRATCH_DEF" ]]; then
  echo "Error: scratch def not found at $SCRATCH_DEF" >&2
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

OLD_ID="$(jq -r '.packageVersions[0].subscriberPackageVersionId' "$SCRATCH_DEF")"
echo "Updating $SCRATCH_DEF"
echo "  $OLD_ID  →  $NEW_ID"

TMP_FILE="$(mktemp)"
jq --arg id "$NEW_ID" '.packageVersions[0].subscriberPackageVersionId = $id' "$SCRATCH_DEF" > "$TMP_FILE"
mv "$TMP_FILE" "$SCRATCH_DEF"

echo "Done."