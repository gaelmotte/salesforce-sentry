# Flow Fault Integration

Adds Flow interview context to events captured from Flow fault paths.

When `Sentry.captureFlowFault()` is called from a Flow's fault connector, this integration attaches the interview GUID, the name of the faulting element, and the Flow definition ID to the Sentry event — making it possible to correlate the Sentry event with a specific Flow interview in the Salesforce debug logs.

## Usage

```apex
new sentrysdk.SentryFlowFaultIntegration()
```

No parameters.

## Related

See [Use in Flows](flows.md) for how to wire up the fault connector in your Flow.
