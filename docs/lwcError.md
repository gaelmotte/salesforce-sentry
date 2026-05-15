# LWC Error Integration

Adds the LWC component stack to events captured from Lightning Web Components.

When a component using `SentryMixin` or `SentryBoundaryMixin` catches an error, the browser error event includes a component stack trace. This integration attaches it to the Sentry event so you can see which component in the tree triggered the error.

## Usage

```apex
new sentrysdk.SentryLWCErrorIntegration()
```

No parameters.

## Related

See [Use in LWC](lwc.md) for how to instrument your components with `SentryMixin` and `SentryBoundaryMixin`.
