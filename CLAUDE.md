# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What This Project Is

salesforce-sentry is a Sentry SDK for the Salesforce Platform, enabling error tracking across Apex, Flow, and Lightning Web Components (LWC). It works around Salesforce's lack of global hooks for unhandled exceptions by capturing errors at call sites and routing them to Sentry via platform events.

## Commands

### First-time setup

```bash
npm install       # install all deps and wire workspace symlinks between local packages
npm run build     # seed all derived directories in topological order:
                  #   sentry-core:build  → core/deps/apex-json-serialization/
                  #   sentry-isv:build   → sentry-isv/core/ (copied from sentry-core source)
                  #   sentry-enduser:build → sentry-enduser/core/ (copied from sentry-core)
```

### Active development

```bash
npm run dev       # start watch scripts for sentry-core and sentry-enduser in parallel
                  # sentry-enduser watcher only starts after sentry-core:build completes
```

Changes to `cli-shared`, `isv-cli`, or `enduser-cli` are immediately visible to consumers — no rebuild needed (workspace symlinks). Changes to `sentry-core` Apex/LWC are picked up automatically by the sentry-enduser watcher; for sentry-isv you need a manual rebuild:

```bash
npm run build -- --filter=@salesforce-sentry/sentry-isv
```

### Testing

```bash
npm run test                          # run all LWC Jest tests across all packages (via turbo)
npm run test -- --filter=sentry-core  # single package

npm run test:unit:watch               # watch mode (run from within a specific package)
npm run test:unit:coverage            # coverage report (run from within a specific package)
```

Apex tests require a live Salesforce org:

```bash
sf apex run test --test-level RunLocalTests
sf apex run test --class-names MyTestClass
```

### Linting and formatting

```bash
npm run lint              # ESLint on Aura/LWC across all packages
npm run prettier          # format all source files
npm run prettier:verify   # verify formatting
```

### Deploying to a Salesforce org

```bash
source .env               # sets SENTRY_REMOTE_SITE and SENTRY_DSN
sf project deploy start
```

### Docs

```bash
npm run docs:dev          # VitePress dev server
npm run docs:build        # build docs
```

### Releasing npm packages

Bump versions first (in dependency order: cli-shared and sentry-isv before the CLIs), then:

```bash
npm run release           # publishes all npm packages in topological order via turbo:
                          #   1. @salesforce-sentry/cli-shared
                          #   2. @salesforce-sentry/sentry-isv
                          #   3. @salesforce-sentry/isv-cli, @salesforce-sentry/enduser-cli
```

## Monorepo Structure

| Directory                  | Purpose                                                                                  |
| -------------------------- | ---------------------------------------------------------------------------------------- |
| `sentry-core/`             | Base SDK — Apex classes, LWC mixin, platform event, metadata                             |
| `sentry-enduser/`          | Managed package (namespace `sentrysdk`) — setup UI, DebugLogs integration                |
| `sentry-enduser-adoption/` | Sample enduser adoption project                                                          |
| `sentry-enduser-sample/`   | Sample customer org implementation                                                       |
| `sentry-isv/`              | npm package — transformed SDK source for ISV vendoring (`@salesforce-sentry/sentry-isv`) |
| `sentry-isv-preadoption/`  | ISV working directory — vendor SDK + instrument Apex/LWC here before packaging           |
| `sentry-isv-adoption/`     | ISV managed package — holds the instrumented output (`instrumented/`) that gets built    |
| `sentry-isv-sample/`       | Sample ISV customer org (scratch org scratch-def used by the adoption pipeline)          |
| `isv-cli/`                 | npm — CLI driving the ISV adoption pipeline (`vendor`, `setup`, `adopt` commands)        |
| `enduser-cli/`             | npm — CLI driving the enduser adoption pipeline                                          |
| `cli-shared/`              | npm — shared utilities and codemods used by both CLIs                                    |
| `scripts/`                 | Shell scripts automating the ISV packaging pipeline                                      |
| `docs/`                    | VitePress documentation site                                                             |

All packages are npm workspace members. Build orchestration uses Turborepo (`turbo.json`). Published packages are scoped under `@salesforce-sentry/`.

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
2. **adopt** — `isv-cli adopt sentry-isv-preadoption` instruments Apex and LWC entry points in-place
3. **setup** — `isv-cli setup sentry-isv-preadoption` interactively generates the config class and metadata (prompts for DSN, namespace, etc.)
4. **sync** — `rsync` copies the instrumented output from `sentry-isv-preadoption/force-app/` into `sentry-isv-adoption/instrumented/`
5. **package + scratch org** — `turbo run scratch:create --filter=sentry-isv-sample` runs `sf package version create` in `sentry-isv-adoption`, then creates a scratch org in `sentry-isv-sample` and installs the new version
6. **reset** — `git restore` + `git clean` bring `sentry-isv-preadoption/force-app/main/` back to the checked-in state and delete `force-app/sentry/`

Steps 1–4 and 6 are stateful/interactive and stay in the shell script. Step 5 is orchestrated by turbo, which guarantees `package:create` completes before `scratch:create` starts.

### Partial runs

```bash
# Re-package and create scratch org when instrumented/ is already up to date:
turbo run scratch:create --filter=sentry-isv-sample

# Vendor and adopt only (no setup, no packaging):
npm run vendor --workspace=sentry-isv-preadoption
npm run adopt  --workspace=sentry-isv-preadoption
```

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
