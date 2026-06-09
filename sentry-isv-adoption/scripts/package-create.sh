#!/usr/bin/env bash
set -euo pipefail

PACKAGE_ALIAS="$(node -p "require('./sfdx-project.json').packageDirectories.find(d => d.package).package")"
echo "Creating package version for: $PACKAGE_ALIAS"

SF_OUTPUT="$(sf package version create \
  --package "$PACKAGE_ALIAS" \
  --code-coverage \
  --installation-key-bypass \
  --json \
  --wait 20)"

NEW_ID="$(echo "$SF_OUTPUT" | node -p "JSON.parse(require('fs').readFileSync(0,'utf8')).result.SubscriberPackageVersionId")"

if [[ -z "$NEW_ID" ]]; then
  echo "Error: could not extract SubscriberPackageVersionId from sf output:" >&2
  echo "$SF_OUTPUT" >&2
  exit 1
fi

echo "$NEW_ID" > .last-package-version-id
echo "Package version created: $NEW_ID"
