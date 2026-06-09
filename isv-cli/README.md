# @salesforce-sentry/isv-cli

CLI for ISVs (Independent Software Vendors) to embed the [Salesforce Sentry](https://github.com/gaelmotte/salesforce-sentry) SDK inside their own managed package. Unlike the end-user managed package (`sentrysdk`), the ISV approach vendors the SDK source directly into the ISV's SFDX project under the ISV's own namespace.

## Prerequisites

Your SFDX project must have a `namespace` set in `sfdx-project.json`:

```json
{
  "namespace": "myisv",
  "packageDirectories": [{ "path": "force-app", "default": true }]
}
```

## Usage

Run from your SFDX project root. All commands accept an optional path argument; defaults to the current working directory.

```bash
npx @salesforce-sentry/isv-cli <command> [project-path]
```

## Commands

### `vendor`

Copies the Sentry SDK source into your project with `{{NAMESPACE}}` substituted for your actual namespace. Writes files to a `sentry/` subdirectory inside your default source directory.

```bash
npx @salesforce-sentry/isv-cli vendor
```

On re-run, shows a colored diff per changed file and prompts before overwriting. Safe to re-run when upgrading `@salesforce-sentry/sentry-isv`.

### `setup`

Interactive wizard that generates the files needed to configure the SDK:

- An Apex config class extending `SentryConfig` (no namespace prefix — SDK is in the same package)
- Its `.cls-meta.xml`
- `Sentry_Config.Default.md-meta.xml` — custom metadata record with `<protected>true</protected>` so subscriber orgs cannot see the DSN
- `Sentry.remoteSite-meta.xml` — remote site setting for the Sentry ingest host

```bash
npx @salesforce-sentry/isv-cli setup
```

Requires `vendor` to have been run first.

You will be prompted for:

- **DSN** — your Sentry project DSN (`https://<key>@<host>/<projectId>`)
- **Apex class name** — defaults to `SentryISVConfig`
- **Sampling rate** — 0–100, defaults to 100
- **Integrations** — multiselect; `SentryISVContextIntegration` is on by default (sets release from package version, environment from org type, and subscriber org as a tag)

> **Important:** Set `<protected>true</protected>` and `fieldManageability: Upgradeable` on the CMT record **before** your first Managed-Released upload — these cannot be changed after release. `setup` handles this automatically.

### `adopt`

Scans your SFDX project and instruments LWC components and Apex entry points with Sentry error capture. Shows a diff for each file and prompts before applying.

```bash
npx @salesforce-sentry/isv-cli adopt
```

**LWC components:**

- Exposed components (`isExposed: true`) → wrapped with `SentryBoundaryMixin`
- Other components → wrapped with `SentryMixin`
- Import path: `c/sentryMixin` (vendored component, same package)

**Apex entry points instrumented:**

- `@AuraEnabled` methods → try/catch with `Sentry.captureException(e)` + `AuraHandledException`
- `@InvocableMethod`, `@RemoteAction`, `@HttpGet/Post/Put/Delete/Patch` → try/catch with `Sentry.captureException(e)` + rethrow
- `Schedulable.execute`, `Queueable.execute`, `Database.Batchable` start/execute/finish → same

No namespace prefix on `Sentry` calls — the SDK is vendored into the same package.

**Optional migration (prompted):**

`adopt` also offers to replace `System.debug()` calls with `Sentry.log()` across all `.cls` and `.trigger` files. `Sentry.log()` is a drop-in replacement that captures the message as a breadcrumb on the current scope instead of (or alongside) writing to the debug log. Breadcrumbs are attached to the next error event sent to Sentry, giving you the log trail leading up to the exception. The migration is idempotent and skips strings and comments.

### `validate`

Checks that the SDK is correctly wired up:

```bash
npx @salesforce-sentry/isv-cli validate
```

Verifies:

- `sfdx-project.json` exists
- Namespace is set
- `vendor` has been run (`sentry/` directory present)
- Exactly one `Sentry_Config` metadata record is enabled
- CMT record has `<protected>true</protected>` _(critical before managed release)_
- DSN is set and valid
- Remote site setting matches the DSN host
- Apex config class exists on disk
- No uninstrumented LWC or Apex entry points remain

## DSN rotation

To rotate the DSN after your managed package is released:

1. Update `Sentry_Config.Default.md-meta.xml` in your dev org
2. Update `Sentry.remoteSite-meta.xml` if the ingest host changed
3. Cut a new package version and push upgrade via AppExchange Partner Console
