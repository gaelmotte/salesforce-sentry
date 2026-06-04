# Initial Setup

Setting up ISV mode is a one-time process. Run these commands from the root of your SFDX project.

## 1. Vendor the SDK

```bash
npx @salesforce-sentry/isv-cli vendor
```

This copies the full SDK source into your SFDX project — Apex classes, Platform Event metadata, trigger, Flow element configuration, and LWC components. Everything the SDK needs at runtime lives in your package after this step.

By default, files are written to the default source directory defined in your `sfdx-project.json`, under a `sentry/` subdirectory:

```
force-app/
  sentry/
    classes/
    triggers/
    objects/
    lwc/
    ...
```

To write to a different location:

```bash
npx @salesforce-sentry/isv-cli vendor --output-dir path/to/dir
```

> **Note:** The CLI does not check for an existing `force-app/sentry/` directory before writing. Re-running `vendor` will overwrite it. Do not modify vendored files directly — use your config class and integrations instead.

Namespace rewriting is handled automatically. The CLI reads your namespace from `sfdx-project.json` and substitutes it wherever the SDK metadata requires a namespace prefix.

## 2. Configure

```bash
npx @salesforce-sentry/isv-cli setup
```

This prompts for your Sentry DSN and other settings, then generates:

- An Apex config class extending `SentryConfig` in your namespace
- A `Sentry_Config__mdt` custom metadata record with your DSN and config class name
- A Remote Site Setting for your Sentry ingest host

Your DSN is hardcoded into the generated metadata — errors from all customer orgs flow to your Sentry project.

## 3. Adopt

```bash
npx @salesforce-sentry/isv-cli adopt
```

This runs codemods that instrument your existing package code — adding `Sentry.captureException()` calls to Apex catch blocks, wiring Flow fault paths to the Capture Sentry Event element, and wrapping LWC components with the appropriate mixin.

Review the changes before committing. The codemod covers common cases; you may want to add instrumentation manually in areas it didn't reach. See [Using the SDK in Your Package](./usage) for the full usage patterns.

## 4. Package

Include the `force-app/sentry/` directory in your package manifest alongside your own source. The vendored SDK ships as part of your managed package — customers install one package and configure nothing.

## 5. Validate

```bash
npx @salesforce-sentry/isv-cli validate
```

Run this at any point to verify that the metadata record, Remote Site Setting, and config class are correctly wired up.
