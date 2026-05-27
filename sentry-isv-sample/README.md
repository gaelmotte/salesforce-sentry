# sentry-isv-sample

Sample subscriber org for an ISV managed package that embeds the Salesforce Sentry SDK.

## What This Is

This project simulates a customer org that has installed an ISV package with Sentry error monitoring built in. The ISV has vendored the Sentry SDK inside their managed package — the subscriber (this org) gets error tracking automatically, without installing or configuring Sentry themselves.

The `force-app` directory contains subscriber-side metadata — Apex classes, Flows, and LWC components — that intentionally trigger crashes and exceptions inside the ISV package, demonstrating how the embedded SDK captures and routes errors to Sentry.

## Prerequisites

- Salesforce CLI (`sf`)
- Access to a Dev Hub org

## Scratch Org Setup

```bash
sf org create scratch \
  --definition-file config/project-scratch-def.json \
  --alias isv-sample \
  --duration-days 7

sf project deploy start --target-org isv-sample
```

The ISV managed package (`04tQy000000VdoHIAS`, namespace `sentrysdk`) is installed automatically into the scratch org from `config/project-scratch-def.json`.

## What the Scenarios Demonstrate

- **Apex exceptions** — caught exceptions reported via `sentrysdk.Sentry.captureException(e)`
- **Flow faults** — fault paths connected to the ISV package's `Capture Flow Fault` invocable action
- **LWC errors** — Lightning component errors surfaced through the SDK's LWC mixin

All errors are sent to the ISV's Sentry project (DSN is configured inside the managed package — the subscriber has no visibility into it).

## Related Projects

| Directory            | Description                                                                 |
| -------------------- | --------------------------------------------------------------------------- |
| `sentry-isv/`        | The npm package containing the vendored SDK source (builds the ISV package) |
| `isv-cli/`           | CLI tooling for ISVs to vendor, set up, and adopt the SDK                   |
| `sentry-isv-sample/` | This project — sample subscriber org                                        |
