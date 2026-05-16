# Advanced Configuration

The SDK is configured through an Apex class that extends `sentrysdk.SentryConfig`. This class is referenced by name in the `Sentry_Config` custom metadata record, letting you change behaviour without redeploying the package.

A default class (`SentryEnduserDefaultConfig`) is included with the managed package and works out of the box. Create your own class when you need to customise integrations, filter events, or scrub sensitive data.

## Creating a config class

```apex
public with sharing class MySentryConfig extends sentrysdk.SentryConfig {
  public override List<sentrysdk.ISentryIntegration> getIntegrations() {
    return new List<sentrysdk.ISentryIntegration>{
      new sentrysdk.SentryUserIntegration(),
      new sentrysdk.SentryStacktraceIntegration(),
      new sentrysdk.SentryFlowFaultIntegration(),
      new sentrysdk.SentryLWCErrorIntegration()
    };
  }
}
```

Set the **ApexClass** field on the `Sentry_Config` metadata record to the class name (`MySentryConfig` above). Only one record should have `Enabled__c = true` at a time.

The `setup` CLI command generates this class and the metadata record for you:

```bash
npx @salesforce-sentry/enduser-cli setup
```

## Integrations

Integrations run during Phase 1 (in your transaction) and enrich the event with contextual data before it is serialised to the Platform Event payload. Each integration is an implementation of `sentrysdk.ISentryIntegration`.

| Integration                                | What it adds                                                                               |
| ------------------------------------------ | ------------------------------------------------------------------------------------------ |
| [SentryUserIntegration](user.md)           | User identity, permission sets, and optional PII                                           |
| [SentryStacktraceIntegration](stack.md)    | Structured stack frames with source context, custom in-app filtering, exception strategies |
| [SentryFlowFaultIntegration](flowFault.md) | Flow interview GUID, faulting element, and Flow definition ID                              |
| [SentryLWCErrorIntegration](lwcError.md)   | LWC component stack from the browser error event                                           |
| [SentryDebugLogsIntegration](debug.md)     | Apex debug log parsed as breadcrumbs _(enduser package only)_                              |

### Custom integrations

Implement `sentrysdk.ISentryIntegration` to add your own enrichment. The `applyToScope` method receives the current scope and can add tags, extras, breadcrumbs, or custom event processors.

```apex
public class MyOrgContextIntegration implements sentrysdk.ISentryIntegration {
  public void applyToScope(sentrysdk.SentryScope scope) {
    scope.setTag('region', MyOrgSettings__c.getInstance().Region__c);
    scope.setExtra('featureFlags', MyFeatureFlags.getActive());
  }
}
```

---

## Filtering and scrubbing events

### Before-send callback

Return an `ISentryBeforeSendCallback` to inspect or modify every event just before it is serialised. Return `null` from `process()` to discard the event entirely.

```apex
public override sentrysdk.ISentryBeforeSendCallback getBeforeSendCallback() {
  return new MySendCallback();
}

private class MySendCallback implements sentrysdk.ISentryBeforeSendCallback {
  public sentrysdk.SentryEvent process(sentrysdk.SentryEvent event) {
    // Drop events tagged as coming from sandboxes
    if ('sandbox'.equals(event.tags?.get('environment'))) {
      return null;
    }
    // Scrub a sensitive tag before sending
    event.tags?.remove('internalAccountId');
    return event;
  }
}
```

### Before-breadcrumb callback

Return an `ISentryBeforeBreadcrumbCallback` to filter or modify breadcrumbs before they are attached to an event. Return `null` from `process()` to drop the breadcrumb.

```apex
public override sentrysdk.ISentryBeforeBreadcrumbCallback getBeforeBreadcrumbCallback() {
  return new MyBreadcrumbCallback();
}

private class MyBreadcrumbCallback implements sentrysdk.ISentryBeforeBreadcrumbCallback {
  public sentrysdk.SentryBreadcrumb process(sentrysdk.SentryBreadcrumb breadcrumb) {
    // Drop debug-level breadcrumbs to reduce noise
    if ('debug'.equals(breadcrumb.level)) {
      return null;
    }
    return breadcrumb;
  }
}
```
