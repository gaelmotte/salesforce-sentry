# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What This Project Is

salesforce-sentry is a Sentry SDK for the Salesforce Platform, enabling error tracking across Apex, Flow, and Lightning Web Components (LWC). It works around Salesforce's lack of global hooks for unhandled exceptions by capturing errors at call sites and routing them to Sentry via platform events.

## Commands

```bash
# LWC/JavaScript
npm run lint                  # ESLint on Aura/LWC
npm run test                  # Run LWC Jest tests
npm run test:unit:watch       # Watch mode
npm run test:unit:coverage    # Coverage report
npm run prettier              # Format code
npm run prettier:verify       # Verify formatting

# Docs
npm run docs:dev              # VitePress dev server
npm run docs:build            # Build docs
```

Apex tests are run via SFDX CLI against a Salesforce org:

```bash
sf apex run test --test-level RunLocalTests
sf apex run test --class-names MyTestClass   # Single test class
```

Deploy to a Salesforce org:

```bash
source .env  # sets SENTRY_REMOTE_SITE and SENTRY_DSN
sf project deploy start
```

## Monorepo Structure

| Directory                 | Purpose                                                                               |
| ------------------------- | ------------------------------------------------------------------------------------- |
| `sentry-core/`            | Base SDK — Apex classes, LWC mixin, platform event, metadata                          |
| `sentry-enduser/`         | Managed package (namespace `sentrysdk`) — setup UI, DebugLogs integration             |
| `sentry-enduser-sample/`  | Sample customer org implementation                                                    |
| `sentry-isv-preadoption/` | ISV working directory — vendor SDK + instrument Apex/LWC here before packaging        |
| `sentry-isv-adoption/`    | ISV managed package — holds the instrumented output (`instrumented/`) that gets built |
| `sentry-isv-sample/`      | Sample ISV customer org (scratch org scratch-def used by the adoption pipeline)       |
| `isv-cli/`                | CLI tool driving the ISV adoption pipeline (`vendor`, `setup`, `adopt` commands)      |
| `scripts/`                | Shell scripts automating the ISV packaging pipeline                                   |
| `docs/`                   | VitePress documentation site                                                          |

## ISV Adoption Pipeline

ISVs embed the SDK in their own managed package rather than installing it as a dependency. The pipeline has two phases: **preadoption** (instrument the ISV source) and **adoption** (build and publish the package).

### Directories

- `sentry-isv-preadoption/force-app/main/` — ISV's own Apex/LWC source (checked in, never committed after mutation)
- `sentry-isv-preadoption/force-app/sentry/` — SDK vendored in by the CLI (gitignored, ephemeral)
- `sentry-isv-adoption/instrumented/` — output of the pipeline; what gets packaged (committed)

### Full pipeline — one command

```bash
./scripts/release-isv-adoption.sh
```

This script runs 6 steps end-to-end:

1. **vendor** — `isv-cli vendor sentry-isv-preadoption` copies the SDK source into `sentry-isv-preadoption/force-app/sentry/`
2. **setup** — `isv-cli setup sentry-isv-preadoption` interactively generates the config class and metadata (prompts for DSN, namespace, etc.)
3. **adopt** — `isv-cli adopt sentry-isv-preadoption` instruments Apex and LWC entry points in-place
4. **sync** — `rsync` copies the instrumented output from `sentry-isv-preadoption/force-app/` into `sentry-isv-adoption/instrumented/`
5. **package** — `./scripts/create-isv-adoption-package.sh` runs `sf package version create` for `sentry-isv-adoption` and updates the subscriber package version ID in `sentry-isv-sample/config/project-scratch-def.json`
6. **reset** — `git restore` + `git clean` bring `sentry-isv-preadoption/force-app/main/` back to the checked-in state and delete `force-app/sentry/`

### Partial run — package only

```bash
./scripts/create-isv-adoption-package.sh
```

Use this when `sentry-isv-adoption/instrumented/` is already up to date and you only need to cut a new package version (e.g. after a metadata-only change).

## Architecture

### Event Flow

Errors flow through two phases separated by a Salesforce platform event:

**Phase 1 — Capture (synchronous, in-transaction)**

1. Caller invokes `Sentry.captureException()`, `Sentry.captureFlowFault()`, or `Sentry.captureLWCError()`
2. `SentryHub` manages the current scope and delegates to `SentryClient`
3. `SentryClient` applies scope transforms, runs integrations, serializes to JSON, and publishes to the `Sentry_Event__e` platform event — non-blocking

**Phase 2 — Transport (asynchronous, out-of-transaction)**

1. `SentryEventTrigger` fires on the platform event
2. `SentryHub.transportEvents()` deserializes the payload
3. `SentryTransport` enriches the event (Tooling API callouts, debug log parsing)
4. `QueueableTransportEvent` sends the HTTP callout to the Sentry API

This two-phase design exists because Salesforce disallows HTTP callouts from the same transaction as DML. The platform event boundary is the escape hatch.

### Key Classes (`sentry-core/core/main/`)

| Class                                     | Role                                                               |
| ----------------------------------------- | ------------------------------------------------------------------ |
| `sdk/classes/Sentry.cls`                  | Public API entry point                                             |
| `sdk/classes/SentryHub.cls`               | Manages scope stack and client lifecycle                           |
| `sdk/classes/SentryClient.cls`            | Processes events, applies integrations, publishes platform event   |
| `sdk/classes/SentryTransport.cls`         | Async HTTP transport to Sentry API                                 |
| `sdk/classes/SentryScope.cls`             | Holds contextual data (user, tags, breadcrumbs) attached to events |
| `sdk/classes/SentryConfig.cls`            | Config interface and factory                                       |
| `model/classes/SentryEvent.cls`           | Full Sentry event payload structure                                |
| `sdk/triggers/SentryEventTrigger.trigger` | Platform event trigger — entry point for Phase 2                   |

### Integrations

Integrations are classes that enrich events before they are sent. They run during Phase 1 (in `SentryClient`) except `SentryDebugLogsIntegration` which runs in Phase 2 (requires callout).

| Integration                                 | What it does                                            |
| ------------------------------------------- | ------------------------------------------------------- |
| `SentryStacktraceIntegration`               | Parses Apex stack traces into structured frames         |
| `SentryUserIntegration`                     | Captures user identity and permission sets              |
| `SentryFlowFaultIntegration`                | Adds Flow interview context                             |
| `SentryLWCErrorIntegration`                 | Adds LWC component stack                                |
| `SentryDebugLogsIntegration` (enduser only) | Parses Apex debug logs into breadcrumbs via Tooling API |

### LWC

`sentry-core/core/main/default/lwc/sentryMixin/sentryMixin.js` is an error boundary mixin that LWC components extend to automatically capture errors via `Sentry.captureLWCError()`.

### Salesforce Metadata

- `Sentry_Event__e` — Platform event used to cross the async boundary
- `Sentry_Config__mdt` — Custom metadata type for SDK configuration
- `Sentry_Payload__c` — Custom object for persisting payloads (optional)
- Remote site setting needed for `SENTRY_REMOTE_SITE` (the Sentry ingest URL)

## Package Configuration

- SFDX API version: 58.0
- Managed package namespace: `sentrysdk`
- Package ID: `0HoQy0000000IMjKAM`
- Environment variables required for deployment: `SENTRY_REMOTE_SITE`, `SENTRY_DSN` (defined in `.env`, template at `.env.dist`)
