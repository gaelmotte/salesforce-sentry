#!/usr/bin/env bash
# Triggers all four crash scenarios and confirms Sentry capture for each.
# Usage: ./scripts/crash-scenarios.sh [<org-alias>]
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TARGET_ORG="${1:-}"
SF_ARGS=()
[[ -n "$TARGET_ORG" ]] && SF_ARGS+=(--target-org "$TARGET_ORG")

sep() { echo; printf '%.0s─' {1..60}; echo; }

# ── Credentials ───────────────────────────────────────────────
echo "Fetching org credentials..."
read -r INSTANCE_URL ACCESS_TOKEN < <(
  sf org display "${SF_ARGS[@]}" --json | node -e "
    const chunks = [];
    process.stdin.on('data', d => chunks.push(d));
    process.stdin.on('end', () => {
      const r = JSON.parse(Buffer.concat(chunks).toString()).result;
      process.stdout.write(r.instanceUrl + ' ' + r.accessToken);
    });
  "
)
REST_BASE="$INSTANCE_URL/services/apexrest/sentrysdk"
echo "Org: $INSTANCE_URL"

# ── Helpers ────────────────────────────────────────────────────
rest_call() {
  local method="$1" path="$2" body="${3:-}"
  local args=(-s -w "\n%{http_code}" -X "$method"
              -H "Authorization: Bearer $ACCESS_TOKEN"
              -H "Content-Type: application/json")
  [[ -n "$body" ]] && args+=(-d "$body")
  local raw
  raw=$(curl "${args[@]}" "$REST_BASE$path")
  local http_status body_text
  http_status=$(echo "$raw" | tail -1)
  body_text=$(echo "$raw" | head -n -1)
  echo "  HTTP $http_status — $body_text"
}

# ── Scenario 1 — VR on Contact ─────────────────────────────────
sep
echo "Scenario 1 — VR on Contact"
echo "  ContactRestService.createContact() — POST without 'email'"
echo "  Expect: DmlException (RequireEmail VR) → Sentry capture"
rest_call POST /contacts '{"firstName":"John","lastName":"Doe"}'

# ── Scenario 2 — VR on Account ────────────────────────────────
sep
echo "Scenario 2 — VR on Account"
echo "  AccountController.updateAccountStatus() on Acme Corp (no Industry)"
echo "  Expect: DmlException (RequireIndustry VR) → Sentry capture"
sf apex run "${SF_ARGS[@]}" --file "$SCRIPT_DIR/crash-account-vr.apex"

# ── Scenario 3 — NightlyBatchJob → unknown stage 'Stalled' ────
sep
echo "Scenario 3 — NightlyBatchJob → unknown stage 'Stalled'"
echo "  Batch marks stale opps as 'Stalled' → OpportunityTrigger throws"
echo "  Expect: IllegalArgumentException → two Sentry captures (trigger + batch)"
sf apex run "${SF_ARGS[@]}" --file "$SCRIPT_DIR/trigger-batch.apex"

# ── Scenario 4 — Bad Contact ID ───────────────────────────────
sep
echo "Scenario 4 — Bad Contact ID"
echo "  ContactRestService.getContact() — GET with non-existent ID"
echo "  Expect: QueryException (List has no rows) → Sentry capture"
rest_call GET /contacts/000000000000000

sep
echo "Done. Check Sentry for captured events."
