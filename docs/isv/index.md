# Sentry SDK for ISVs

If you're building a managed package and want to embed Sentry error tracking for your customers, ISV support is on the roadmap.

The planned approach is an npm package that wraps the SDK for use in your own packaging pipeline, so you can bundle Sentry reporting without requiring customers to install a separate managed package.

## Current workaround

You can include the `sentry-core` source directly in your own package today. The core SDK has no external dependencies and is designed to be namespace-safe. Have a look at the [source on GitHub](https://github.com/gaelmotte/salesforce-sentry/) to evaluate whether this fits your use case.

## Help prioritize this

If ISV support matters to you, [open a GitHub issue](https://github.com/gaelmotte/salesforce-sentry/issues) — it helps gauge demand and shapes the roadmap.
