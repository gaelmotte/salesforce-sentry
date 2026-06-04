# Troubleshooting & FAQ

## CLI & Setup

**`vendor` fails with a namespace error**

The CLI reads your namespace from `sfdx-project.json`. Make sure the `namespace` field is set before running `vendor`:

```json
{
  "namespace": "mynamespace",
  ...
}
```

If the field is missing or empty, the CLI cannot perform namespace substitution on the vendored metadata.

**`force-app/sentry/` already exists**

Re-running `vendor` overwrites the directory. This is intentional during upgrades — review the diff afterwards. Do not modify vendored files directly; use your config class and integrations for customization.

**Not sure if everything is wired up correctly**

Run:

```bash
npx @salesforce-sentry/isv-cli validate
```

This checks that the metadata record, Remote Site Setting, and config class are correctly configured.

---

## Runtime

**Errors are not appearing in Sentry**

Work through this checklist:

- Run `validate` to rule out configuration issues
- Check the Remote Site Setting — the URL must match the host of your DSN exactly (e.g. `https://o123456.ingest.sentry.io`)
- Check the `Sentry_Config__mdt` record — confirm the DSN and ApexClass fields are populated
- Check that the Platform Event trigger deployed successfully — look for `SentryEventTrigger` in Setup → Apex Triggers
- Check Apex debug logs for errors originating from `SentryEventTrigger` or `SentryTransport`

**I can't tell which customer org an error came from**

Make sure `SentryISVContextIntegration` is the first integration in your config class. It tags every event with the customer org ID, making events filterable in Sentry. See [SentryISVContextIntegration](./isv-context).

---

## Packaging

**Can I remove a vendored component from my package?**

Not always. Salesforce does not allow certain metadata types to be removed from a managed package once released. If you're unsure whether a component is safe to remove, leave it in place. The `vendor` command will handle deprecated component flagging in a future release. When in doubt, check the [ISV Changelog](./changelog) before removing anything from `force-app/sentry/`.

**Will the vendored SDK conflict with the end-user managed package if both are installed in the same org?**

No. The vendored SDK lives in your package's namespace; the end-user SDK lives in the `sentrysdk` namespace. They are fully independent at runtime.
