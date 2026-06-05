#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
MONOREPO_ROOT="$SCRIPT_DIR/.."
PREADOPTION="$MONOREPO_ROOT/sentry-isv-preadoption"
ADOPTION="$MONOREPO_ROOT/sentry-isv-adoption"
ISV_CLI="$MONOREPO_ROOT/isv-cli/index.js"

if ! command -v sf &>/dev/null; then
  echo "Error: 'sf' (Salesforce CLI) is not installed or not in PATH." >&2
  exit 1
fi
if ! command -v jq &>/dev/null; then
  echo "Error: 'jq' is not installed or not in PATH." >&2
  exit 1
fi
if ! command -v node &>/dev/null; then
  echo "Error: 'node' is not installed or not in PATH." >&2
  exit 1
fi
if ! command -v rsync &>/dev/null; then
  echo "Error: 'rsync' is not installed or not in PATH." >&2
  exit 1
fi

echo "==> [1/6] vendor: copying SDK into sentry-isv-preadoption..."
node "$ISV_CLI" vendor "$PREADOPTION"

echo "==> [2/6] adopt: instrumenting Apex and LWC entry points..."
node "$ISV_CLI" adopt "$PREADOPTION"

echo "==> [3/6] setup: generating config class and metadata (interactive)..."
node "$ISV_CLI" setup "$PREADOPTION"

echo "==> [4/6] sync: copying instrumented output to sentry-isv-adoption..."
rsync -a --delete "$PREADOPTION/force-app/main/"  "$ADOPTION/instrumented/main/"
rsync -a --delete "$PREADOPTION/force-app/sentry/" "$ADOPTION/instrumented/sentry/"

echo "==> [5/6] package: building adoption package and updating sentry-isv-sample scratch-def..."
"$SCRIPT_DIR/create-isv-adoption-package.sh"

echo "==> [6/6] reset: restoring sentry-isv-preadoption to clean state..."
git -C "$MONOREPO_ROOT" restore sentry-isv-preadoption/force-app/main/
git -C "$MONOREPO_ROOT" clean -fd sentry-isv-preadoption/force-app/main/
rm -rf "$PREADOPTION/force-app/sentry/"

echo "Done. sentry-isv-adoption/instrumented/ is up to date and the package version is created."
