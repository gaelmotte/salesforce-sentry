# @salesforce-sentry/enduser-cli

CLI to adopt the [Salesforce Sentry](https://github.com/gaelmotte/salesforce-sentry) SDK in an SFDX project. Requires the `sentrysdk` managed package installed in your org.

## Usage

```bash
npx @salesforce-sentry/enduser-cli <command> [project-path]
```

All commands accept an optional path to the SFDX project root. Defaults to the current working directory.

## Commands

### `setup`

Interactive wizard that generates the files needed to wire up the SDK:

- An Apex config class extending `sentrysdk.SentryConfig`
- Its `.cls-meta.xml`
- A `sentrysdk__Sentry_Config.Default.md-meta.xml` custom metadata record
- A `Sentry.remoteSite-meta.xml` remote site setting

```bash
npx @salesforce-sentry/enduser-cli setup [project-path]
```

You will be prompted for:

- **DSN** — your Sentry project DSN (`https://<key>@<host>/<projectId>`)
- **Apex class name** — defaults to `MySentryConfig`
- **Sampling rate** — 0–100, defaults to 100
- **Integrations** — multiselect from all available integrations

Generated files are written to the `default` package directory from `sfdx-project.json`. Deploy them with `sf project deploy start`.

### `adopt`

Scans your SFDX project and instruments LWC components and Apex entry points with Sentry error capture. Shows a diff for each file and prompts before applying.

```bash
npx @salesforce-sentry/enduser-cli adopt [project-path]
```

**LWC components:**

- Exposed components (`isExposed: true`) → wrapped with `SentryBoundaryMixin`
- Other components → wrapped with `SentryMixin`

**Apex entry points instrumented:**

- `@AuraEnabled` methods → try/catch with `sentrysdk.Sentry.captureException(e)` + `AuraHandledException`
- `@InvocableMethod`, `@RemoteAction`, `@HttpGet/Post/Put/Delete/Patch` → try/catch with `sentrysdk.Sentry.captureException(e)` + rethrow
- `Schedulable.execute`, `Queueable.execute`, `Database.Batchable` start/execute/finish → same

Already-instrumented files are skipped automatically.

### `validate`

Checks that the SDK is correctly wired up in the project:

```bash
npx @salesforce-sentry/enduser-cli validate [project-path]
```

Verifies:

- `sfdx-project.json` exists
- Exactly one `Sentry_Config` metadata record is enabled
- DSN is set and valid
- Remote site setting matches the DSN host
- Apex config class exists on disk
- No uninstrumented LWC or Apex entry points remain
