# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What This Project Is

`sentry-isv-adoption` is a sample ISV SFDX project that mimics a real managed package codebase. It exists as the **target project** for the `isv-cli/` CLI tool (at the monorepo root), which automatically vendors the Sentry SDK and instruments Apex and LWC code with Sentry error capture.

The code here is intentionally incomplete — it demonstrates the before-state that `isv-cli` should transform. The namespace is `myisv` (set in `sfdx-project.json`).

## Commands

```bash
# LWC/JavaScript
npm run lint                  # ESLint on LWC
npm run test                  # Run LWC Jest tests (via sfdx-lwc-jest)
npm run test:unit:watch       # Watch mode
npm run test:unit:coverage    # Coverage report
npm run prettier              # Format all source files
npm run prettier:verify       # Verify formatting

# Deploy to a Salesforce org
source .env
sf project deploy start

# Run isv-cli against this project (from monorepo root)
node isv-cli/index.js vendor sentry-isv-adoption/
node isv-cli/index.js setup sentry-isv-adoption/
node isv-cli/index.js adopt sentry-isv-adoption/
node isv-cli/index.js validate sentry-isv-adoption/
```

Apex tests run via SFDX CLI against a live org:

```bash
sf apex run test --test-level RunLocalTests
```

## Architecture

### Purpose

This project serves dual purposes:

1. **End-to-end test fixture** — the uninstrumented files show what real ISV code looks like before adoption
2. **Showcase** — demonstrates every Sentry adoption pattern across Apex entry point types, in an ISV context

### isv-cli integration

The `../isv-cli/` CLI targets this directory. The full workflow:

**1. `vendor`** — copies the SDK from `@salesforce-sentry/sentry-isv` into `force-app/sentry/`, substituting `{{NAMESPACE}}` → `myisv`. After vendor, `force-app/sentry/` contains:

- `core/` — all SDK Apex classes, platform event, LWC mixin (access `public`, no `sentrysdk.` prefix)
- `isv/` — `SentryISVContextIntegration` and `SentryISVEventProcessor`

**2. `setup`** — interactive wizard that generates:

- `MySentryISVConfig.cls` extending `SentryConfig` (no namespace prefix — vendored SDK is in the same package)
- `Sentry_Config.Default.md-meta.xml` with `<protected>true</protected>` and field names without namespace prefix
- `Sentry.remoteSite-meta.xml`

**3. `adopt`** — instruments entry points:

- Wraps `@AuraEnabled`, `@InvocableMethod`, `@HttpGet/Post/Put/Delete/Patch`, `@RemoteAction` methods in try/catch with `Sentry.captureException(e)` — **no `myisv.` prefix** (vendored SDK is in the same package)
- Wraps `Schedulable.execute`, `Queueable.execute`, `Database.Batchable` start/execute/finish methods
- Wraps entire trigger bodies in try/catch
- Skips methods that already contain `captureException` or whose body starts with `try`
- Adds `SentryMixin` (internal components) or `SentryBoundaryMixin` (exposed components) to LWC classes
- LWC mixin imported from `c/sentryMixin` — **not** `sentrysdk/sentryMixin` (vendored component, same package)

**4. `validate`** — checks 9 conditions: namespace set, vendor run, CMT record found, exactly one enabled, `<protected>true</protected>`, DSN valid, remote site matches, config class on disk, no uninstrumented files.

`@AuraEnabled` methods get `AuraHandledException` re-throws; all others get plain `throw e`.

### Salesforce entry points in scope

| File                         | Type                                      | isv-cli target                                      |
| ---------------------------- | ----------------------------------------- | --------------------------------------------------- |
| `AccountController.cls`      | `@AuraEnabled` methods                    | Yes — wraps bare methods, skips already-caught ones |
| `LeadProcessor.cls`          | `@InvocableMethod`                        | Yes                                                 |
| `ContactRestService.cls`     | `@HttpGet/Post/Delete`                    | Yes                                                 |
| `EmailQueueable.cls`         | `Queueable.execute`                       | Yes                                                 |
| `NightlyBatchJob.cls`        | `Database.Batchable` start/execute/finish | Yes                                                 |
| `DailyScheduler.cls`         | `Schedulable.execute`                     | Yes                                                 |
| `AccountTrigger.trigger`     | Trigger body                              | Yes                                                 |
| `OpportunityTrigger.trigger` | Trigger body                              | Yes                                                 |
| `accountDashboard` LWC       | Exposed component                         | `SentryBoundaryMixin`                               |
| `contactCard` LWC            | Internal component                        | `SentryMixin`                                       |
| `opportunityList` LWC        | Exposed, uses `NavigationMixin`           | `SentryBoundaryMixin`                               |

Handler classes (`AccountTriggerHandler`, `OpportunityTriggerHandler`) delegate to `AccountService` for shared account logic (industry normalisation, revenue tier stamping, welcome email dispatch via `EmailQueueable`).

### Key ISV differences from enduser-adoption

| Aspect               | enduser-adoption                             | isv-adoption                                          |
| -------------------- | -------------------------------------------- | ----------------------------------------------------- |
| SDK source           | `sentrysdk` managed package installed in org | Vendored into `force-app/sentry/` by `isv-cli vendor` |
| Capture call         | `sentrysdk.Sentry.captureException(e)`       | `Sentry.captureException(e)` (no prefix)              |
| LWC mixin import     | `sentrysdk/sentryMixin`                      | `c/sentryMixin`                                       |
| CMT record           | `<protected>false</protected>`               | `<protected>true</protected>`                         |
| CMT field names      | `sentrysdk__DSN__c` etc.                     | `DSN__c` etc. (same-package fields)                   |
| Namespace            | none (customer org)                          | `myisv`                                               |
| Config class extends | `sentrysdk.SentryConfig`                     | `SentryConfig`                                        |

### Sentry SDK reference

The SDK is vendored under `force-app/sentry/` after running `isv-cli vendor`. All Apex references use no namespace prefix — the SDK classes live in the same package as the ISV's own code. The `Sentry_Config__mdt` record is protected so subscriber org admins cannot see or modify the DSN.
