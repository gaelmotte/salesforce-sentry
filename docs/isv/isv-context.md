# SentryISVContextIntegration

This integration is the most important one in ISV mode. Because all customer errors flow into your single Sentry project, you need a way to know which org an error came from.

`SentryISVContextIntegration` attaches the customer's org ID to every event as a tag, making it filterable and searchable in Sentry.

```apex
new SentryISVContextIntegration()
```

It takes no parameters and should always be included as the first integration in your config class.

::: tip
In Sentry, use the org ID tag to filter issues by customer, set up customer-specific alert rules, or identify which customers are affected by a given error.
:::

::: info
Additional fields attached by this integration are being finalized — this page will be updated when confirmed.
:::
