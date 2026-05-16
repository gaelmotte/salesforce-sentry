# @salesforce-sentry/sentry-isv

Transformed Salesforce Sentry SDK source for ISV managed packages. This package contains ready-to-vendor SFDX metadata that an ISV embeds in their own managed package under their own namespace.

**You do not use this package directly.** The [`@salesforce-sentry/isv-cli`](https://www.npmjs.com/package/@salesforce-sentry/isv-cli) `vendor` command reads it, substitutes your namespace for the `{{NAMESPACE}}` placeholder, and writes the result into your SFDX project.

## What's inside

```
sentry-isv/
  core/       ← Generated from sentry-core. global→public, sentrysdk→{{NAMESPACE}},
              |  CMT visibility→Protected, field manageability→Upgradeable
  isv/        ← Hand-authored ISV-specific integrations
              |  SentryISVContextIntegration — sets release, environment, subscriber org tag
```

`core/` mirrors `sentry-core/core/main/` with the following transformations applied:

| What                                                  | Transform                                          |
| ----------------------------------------------------- | -------------------------------------------------- |
| `*.cls`, `*.trigger`                                  | `global` → `public`, `sentrysdk` → `{{NAMESPACE}}` |
| `Sentry_Config__mdt.object-meta.xml`                  | `Public` → `Protected` visibility                  |
| `fields/*.field-meta.xml` under `Sentry_Config__mdt/` | `SubscriberControlled` → `Upgradeable`             |
| All other files                                       | `sentrysdk` → `{{NAMESPACE}}` catch-all            |

## Regenerating `core/`

`core/` is a derived artifact. Regenerate it after pulling changes from `sentry-core`:

```bash
npm run build
```

The build script copies from `../sentry-core/core/main/` and `node_modules/@guimini/apex-json-serialization/`, applies all transforms, and prunes the previous output first.

## Usage (via isv-cli)

```bash
# In your ISV SFDX project root (namespace must be set in sfdx-project.json)
npx @salesforce-sentry/isv-cli vendor
npx @salesforce-sentry/isv-cli setup
npx @salesforce-sentry/isv-cli adopt
npx @salesforce-sentry/isv-cli validate
```
