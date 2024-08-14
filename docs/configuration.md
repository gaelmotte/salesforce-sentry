# Advanced Configuration

You already have seen in [Getting Started](getStarted.md) how part of the configuration is made through a custom metadata.

In the following, you will see how to create a configuration class for finer settings.

## Create a configuration class

Using your usual dev workflow, crate a new class for the Sentry SDK config.

It must read like this :

TODO : update after packaging

```apex
public with sharing class MySentryConfig extends SentryConfig {
  public virtual override List<ISentryIntegration> getIntegrations() {
    return new List<ISentryIntegration>{
      new SentryUserIntegration(true, true), // capture user PII, which is not default
      new SentryDebugLogsIntegration(), // all de defaults
      new SentryStacktraceIntegration(), // all the defaults,
      new SentryFlowFaultIntegration(),
      new SentryLWCErrorIntegration()
    };
  }
}
```

What you should pay attention to :

- The classname : Name it anyway you like, but keep it somewhere because it will be used in the custom metadata
- `extends SentryConfig`: Your class must extend this.
- List of integrations with their parameters.

## Integrations you say ?

Yes, Integrations represent a group of actions to enrich an event.

Some are built into the product and are listed in the next page.
You may develop your own to scrub certain data away, or filter what events are sent to sentry.
