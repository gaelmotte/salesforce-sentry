#!/usr/bin/env bash
set -euo pipefail

PACKAGE_ALIAS="$(node -p "require('./sfdx-project.json').packageDirectories.find(d => d.package).package")"
echo "Creating package version for: $PACKAGE_ALIAS"

SF_OUTPUT="$(sf package version create \
  --package "$PACKAGE_ALIAS" \
  --code-coverage \
  --installation-key-bypass \
  --json \
  --wait 20 2>&1)" || true

NEW_ID="$(echo "$SF_OUTPUT" | node -e "
  let d = '';
  process.stdin.on('data', c => d += c);
  process.stdin.on('end', () => {
    const json = d.slice(d.indexOf('{'));
    const result = JSON.parse(json);
    if (result.status !== 0) {
      process.stderr.write('sf error: ' + (result.message || JSON.stringify(result)) + '\n');
      process.exit(1);
    }
    process.stdout.write(result.result.SubscriberPackageVersionId);
  });
")"

echo "Package version created: $NEW_ID"
