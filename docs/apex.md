# Usage in Apex

Wrap any code that may throw with a try/catch and call `Sentry.captureException()`. The error is reported to Sentry and you can re-throw to preserve normal error handling.

## Basic example

```apex
try {
    someService.doWork();
} catch (Exception e) {
    Sentry.captureException(e);
    throw e;
}
```

## Realistic example — a trigger handler

```apex
public with sharing class AccountTriggerHandler {
  public static void afterInsert(List<Account> newAccounts) {
    try {
      ExternalSyncService.sync(newAccounts);
    } catch (Exception e) {
      // Report to Sentry, then fail gracefully so other trigger handlers can continue
      Sentry.captureException(e);
    }
  }
}
```

## Adding user context

If you want the Sentry event to include the current user's identity, enable the `SentryUserIntegration` in your [configuration](configuration.md). No extra code is required at the call site — the integration runs automatically on every captured event.

## Sampling

You can control what percentage of events are forwarded to Sentry via the `Sampling` field on the `Sentry Config` custom metadata record (0–100). This is useful for high-volume orgs where you want representative coverage without overwhelming your Sentry quota.
