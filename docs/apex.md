# Usage in Apex

Wrap any code that may throw with a try/catch and call `Sentry.captureException()`. The error is reported to Sentry and you can re-throw to preserve normal error handling.

## Automated instrumentation (CLI)

The `adopt` command instruments your Apex entry points automatically:

```bash
npx @salesforce-sentry/enduser-cli adopt
```

It wraps the following with a try/catch that calls `Sentry.captureException()`:

- `@AuraEnabled` methods — rethrows as `AuraHandledException`
- `@InvocableMethod`, `@RemoteAction`, `@HttpGet/Post/Put/Delete/Patch` — rethrows
- `Schedulable.execute`, `Queueable.execute`, `Database.Batchable` start/execute/finish — rethrows

It shows a diff for each file and prompts before applying. Already-instrumented files are skipped.

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
