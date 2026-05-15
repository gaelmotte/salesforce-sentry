# How it works

The SDK is built around two phases separated by a Salesforce Platform Event. Understanding this split explains both the performance characteristics and what information appears in each Sentry event.

## The two-phase design

Salesforce prohibits HTTP callouts from the same transaction that performs DML. Sending an event to Sentry requires an HTTP callout. The Platform Event is the escape hatch: it lets the SDK capture data synchronously during your transaction, then hand off the outbound call to a separate async context.

**Phase 1 — Capture (your transaction)**

```
  Apex / Flow / LWC
       │
       │  Sentry.captureException()
       ▼
  SentryHub ──► SentryClient
                     │
                     │  apply integrations
                     │  serialize to JSON
                     ▼
              Sentry_Event__e
              (publish immediate)
                     │
                     ▼
           platform event delivered
           ──────────────────────────► Phase 2
           your transaction continues
```

**Phase 2 — Transport (separate async transaction)**

```
  SentryEventTrigger
       │  fires on Sentry_Event__e
       ▼
  SentryHub.transportEvents()
       │
       │  deserialize payload
       ▼
  SentryTransport
       │
       │  enrich: Tooling API callouts,
       │  debug log parsing
       ▼
  QueueableTransportEvent
       │
       │  HTTP callout → Sentry API
       ▼
  event stored in Sentry
```

## No limit impact on capture

Capture calls (`Sentry.captureException()`, `Sentry.captureFlowFault()`, `Sentry.captureLWCError()`) publish a **publish-immediate Platform Event**. This is a special event type in Salesforce that:

- Is **not subject to the 150 DML statement limit** — publishing it does not count as a DML operation
- Is delivered even if the transaction is rolled back (e.g. a failed save operation)
- Has its own governor limit: 1,000 publish-immediate events per transaction, which is well above any realistic instrumentation density

This means adding Sentry capture calls to your critical paths has no governor limit cost on your transaction.

## What is captured when

Not all event data is available at capture time. Some fields require callouts or queries that can only happen asynchronously.

### Captured immediately (Phase 1 — in your transaction)

| Data                                         | Source                                       |
| -------------------------------------------- | -------------------------------------------- |
| Exception type, message, and raw stack trace | The `Exception` object itself                |
| User identity (Id, name, profile)            | `UserInfo` — available synchronously         |
| User permission sets                         | SOQL on `PermissionSetAssignment`            |
| Tags, extras, and breadcrumbs                | Whatever you set on the current scope        |
| Flow interview context                       | Input parameters of `SentryCaptureFlowFault` |
| LWC component stack                          | Error event payload from the component       |

### Enriched at send time (Phase 2 — async transport)

| Data                                                 | Source                                             |
| ---------------------------------------------------- | -------------------------------------------------- |
| Structured stack frames with pre/post source context | Tooling API `ApexClass` body query                 |
| Apex debug log as breadcrumbs                        | Tooling API `ApexLog` query (enduser package only) |

The Tooling API callouts in Phase 2 are what require the async context — they cannot be made inside a transaction that has performed DML.

## Prior art

The idea of routing Salesforce exceptions to Sentry via an async event boundary was first explored by [@jmather](https://github.com/jmather) in [SentryForSalesforce](https://github.com/jmather/SentryForSalesforce) — an unmanaged Apex package that pioneered the same core pattern: publish an event from the capture site, process it asynchronously via a `@Future` method, then call out to the Sentry API. This SDK builds on that foundation with a managed package, Platform Events, richer context (stack traces, user identity, debug logs), and LWC and Flow coverage.
