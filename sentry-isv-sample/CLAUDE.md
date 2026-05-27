# CLAUDE.md

This file provides guidance to Claude Code when working with code in this repository.

## What This Project Is

`sentry-isv-sample` is a sample **end-user org** for an ISV managed package that has vendored the Sentry SDK. It simulates what a subscriber's org looks like after installing an ISV package that embeds Sentry error monitoring.

This is **not** the ISV package itself — it is the org of a customer who installed that package.

The subscriber has no awareness of Sentry. Error capture is entirely autonomous inside the ISV managed package — the subscriber never references the SDK, configures a DSN, or extends any config class. Their org just uses the ISV package's features normally.

### The ISV package

- Namespace: `sentrysdk` (reused from the enduser package for simplicity — does not affect structure)
- Package version ID: `04tQy000000VdoHIAS`
- The ISV package business logic lives in `sentry-isv-adoption/` and is instrumented with `Sentry.captureException()` at all entry points
- The Sentry SDK is vendored inside this package — the subscriber's org has no direct dependency on it

The package is pre-installed in scratch orgs via `config/project-scratch-def.json`.

## What `force-app` Contains

`force-app` holds subscriber-side metadata that causes crashes in the ISV package's instrumented business logic. The goal is to verify that the SDK correctly captures exceptions when vendored inside a managed package.

The subscriber code has no Sentry calls, no config class, no DSN. It just customizes their org normally (validation rules, etc.), and the ISV package's embedded SDK captures the resulting errors autonomously.

**Important constraints on what subscriber metadata can actually cause captures:**

- **VRs on SDK-owned objects** (`Sentry_Payload__c`, `Sentry_Rate_Limits__c`): do not add these — they make the SDK silently fail, not capture errors.
- **Permission sets restricting Contact/Opportunity fields**: Apex does not enforce FLS unless `WITH SECURITY_ENFORCED` is used explicitly. The ISV package code uses neither, so field-level restrictions cause no crashes.
- **Email deliverability off**: `Messaging.sendEmail()` does not throw — it silently drops emails. Not a capture scenario.

## Crash Scenarios

### 1. VR on Contact — DmlException in `ContactRestService`

`ContactRestService.createContact()` inserts a Contact from a JSON payload. If the subscriber adds a validation rule requiring `FirstName` or `Email`, a POST request with a missing field throws a `DmlException` inside the instrumented try/catch → `Sentry.captureException()`.

**What this tests:** SDK captures DML exceptions from instrumented REST entry points.

### 2. VR on Account — DmlException in `AccountController`

`AccountController.updateAccountStatus()` does a partial update (`Description` only) on an Account. A subscriber VR requiring a field that is blank on the record (e.g. `Industry` required) causes the update to fail → `DmlException` inside the instrumented try/catch → `Sentry.captureException()`.

**What this tests:** SDK captures DML exceptions from instrumented AuraEnabled methods.

### 3. Unknown Opportunity Stage — cross-context capture in `NightlyBatchJob`

`NightlyBatchJob.execute()` sets `StageName = 'Stalled'` on stale Opportunities. `'Stalled'` is not in the `OpportunityTriggerHandler` stage probability map → trigger throws `IllegalArgumentException` → captured by the trigger's try/catch → re-thrown → batch catches the resulting `DmlException` → captured again.

**No subscriber metadata required** — this is a built-in crash in the adoption code.

**What this tests:** SDK captures exceptions across async execution contexts (batch → trigger); the same error chain produces two distinct captures (root cause in trigger, DML consequence in batch).

### 4. Bad Contact ID — QueryException in `ContactRestService`

`ContactRestService.getContact()` and `deleteContact()` query a single Contact by ID. Passing a non-existent ID causes `QueryException: List has no rows for assignment` inside the instrumented try/catch → `Sentry.captureException()`.

**No subscriber metadata required** — triggered by a bad REST request.

**What this tests:** SDK captures SOQL exceptions from instrumented REST entry points.

## Scratch Org Setup

```bash
sf org create scratch --definition-file config/project-scratch-def.json --alias isv-sample --duration-days 7
sf project deploy start --target-org isv-sample
```

The ISV package is installed automatically from `packageVersions` in the scratch org def.

## Key Difference from `sentry-enduser-sample`

|                                  | `sentry-enduser-sample`                     | `sentry-isv-sample`                                     |
| -------------------------------- | ------------------------------------------- | ------------------------------------------------------- |
| Package source                   | `sentry-enduser` managed package            | ISV managed package (vendored SDK)                      |
| SDK reference in subscriber code | `sentrysdk.Sentry.*`                        | None — SDK is internal to the ISV package               |
| Config class                     | Subscriber extends `sentrysdk.SentryConfig` | None — ISV owns the config                              |
| DSN ownership                    | Subscriber sets their own DSN               | ISV controls the DSN — entirely invisible to subscriber |
