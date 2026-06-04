# Prerequisites

This will guide you through the standard setup of the SDK and its usage.

> If you want a deeper dive into what information is sent to Sentry when an issue is encountered, have a look at the [Configuration](configuration.md) guide.

## Sentry Project

You already have a Sentry project and have its DSN close at hand.

## Salesforce Edition

You are on Salesforce Enterprise Edition or higher. (Platform Events, required for the async transport, are not available on lower editions.)

## Node.js and npx

The `@salesforce-sentry/enduser-cli` package handles setup and instrumentation. You'll need Node.js 18+ to run it via `npx`. If you prefer to configure everything manually, Node.js is not required — see [Installation](install.md) for both options.

## Yourself

You are comfortable with Salesforce development: writing Apex classes and working with Custom Metadata Types.

## Performance & governor limits

The SDK is designed to be non-blocking. Errors are published as a Platform Event within your transaction (a lightweight DML operation), and all HTTP callouts to the Sentry API happen asynchronously in a separate Queueable context. Capturing an exception adds one Platform Event publish to your transaction — no synchronous HTTP callouts, no significant governor limit impact.
