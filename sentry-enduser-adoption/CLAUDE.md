# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What This Project Is

`sentry-enduser-adoption` is a sample Salesforce org that mimics a real customer implementation. It exists as the **target project** for the `codemods/` CLI tool (at the monorepo root), which automatically instruments Apex and LWC code with Sentry error capture. The code here is intentionally incomplete — it demonstrates the before-state that codemods should transform.

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

# Run the CLI against this project (from this directory)
npx @salesforce-sentry/enduser-cli adopt
```

Apex tests run via SFDX CLI against a live org:

```bash
sf apex run test --test-level RunLocalTests
```

## Architecture

### Purpose

This repo serves dual purposes:

1. **End-to-end test fixture** — the uninstrumented files show what real customer code looks like before adoption
2. **Showcase** — demonstrates every Sentry adoption pattern across Apex entry point types

### Codemod integration

The `../codemods/` CLI targets this directory. When run with `adopt`, it:

- Wraps `@AuraEnabled`, `@InvocableMethod`, `@HttpGet/Post/Put/Delete/Patch`, `@RemoteAction` methods in try/catch with `sentrysdk.Sentry.captureException(e)`
- Wraps `Schedulable.execute`, `Queueable.execute`, `Database.Batchable` start/execute/finish methods
- Wraps entire trigger bodies in try/catch
- Skips methods that already contain `captureException` or whose body starts with `try`
- Adds `SentryMixin` (internal components) or `SentryBoundaryMixin` (exposed components) to LWC classes, based on `isExposed` in the `.js-meta.xml`

`@AuraEnabled` methods get `AuraHandledException` re-throws; all others get plain `throw e`.

### Salesforce entry points in scope

| File                         | Type                                      | Codemod target                                      |
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

### Sentry SDK reference

The managed package namespace is `sentrysdk`. The `Sentry.captureException(e)` call is always prefixed as `sentrysdk.Sentry.captureException(e)` in generated code. SDK configuration lives in `SentryConfig__mdt` custom metadata (not present in this repo — it is deployed from `sentry-core/` or `sentry-enduser/`).
