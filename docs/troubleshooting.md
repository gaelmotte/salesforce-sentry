# Troubleshooting

Run the validation command first — it catches the most common issues automatically:

```bash
npx @salesforce-sentry/enduser-cli validate [project-path]
```

---

## Events not appearing in Sentry

**Check your DSN.** Open the enabled `Sentry_Config` custom metadata record and verify the DSN matches your Sentry project exactly (`https://<key>@o<number>.ingest.sentry.io/<projectId>`).

**Check the remote site setting.** The URL must match the host in your DSN (`https://o<number>.ingest.sentry.io`). A mismatch causes the async callout to fail silently.

**Check that exactly one record is enabled.** If `Enabled__c` is false or multiple records are active, the SDK will not initialise. Only one `Sentry_Config` record should have `Enabled__c = true`.

**Check sampling.** If `Sampling__c` is set to `0`, no events are sent. Set it to `100` to send all events during debugging.

**Check the Queueable job.** The HTTP callout happens in a `QueueableTransportEvent` job. In Setup → Apex Jobs, look for failed jobs of this type and inspect the error message.

---

## Compilation errors when deploying your config class

If you see errors like `Type is not visible` or `Method is not visible` for `sentrysdk.*` types, your org may have an older version of the managed package installed that predates the `global` visibility changes.

Reinstall the latest package version, then redeploy your config class.

---

## Platform Events not firing

Platform Events require **Salesforce Enterprise Edition or higher**. Developer Edition orgs support them for testing but scratch orgs must have the `PlatformEvents` feature enabled.

Check that `SentryEventTrigger` is active in Setup → Apex Triggers.

---

## Debug Logs integration not working

The `SentryDebugLogsIntegration` (enduser package only) requires a Named Credential pointing to the Tooling API.

- Verify the Named Credential named `Sentry_SDK_Tooling_Api_Credential` exists and its authentication works.
- If you passed a custom named credential name to the constructor, verify it matches exactly.
- The integration queries `ApexLog` records — the running user must have access to the Tooling API.

---

## Stack frames show no source context

Source lines in stack frames are retrieved via the Tooling API at send time. They will be missing if:

- The Tooling API Named Credential is not configured (see above).
- The class is part of a **managed package** — Salesforce returns a null `Body` for managed package classes, even from within the same namespace. This is a platform limitation.

---

## LWC errors not captured

- Verify the component extends `SentryMixin` or `SentryBoundaryMixin` (run `npx @salesforce-sentry/enduser-cli adopt` to instrument it).
- `SentryBoundaryMixin` catches errors from **child components**. Errors thrown in the component's own lifecycle must be caught manually with `Sentry.captureLWCError()`.

---

## Still stuck?

[Open an issue on GitHub](https://github.com/gaelmotte/salesforce-sentry/issues) and include:

- Output of `npx @salesforce-sentry/enduser-cli validate`
- The error message or symptom
- Your Salesforce edition and managed package version
