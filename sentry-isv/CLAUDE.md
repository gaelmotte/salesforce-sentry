# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What This Project Is

`sentry-isv` is a **not-yet-built** distribution of the salesforce-sentry SDK targeting ISVs (Independent Software Vendors) — companies that build managed packages on Salesforce AppExchange and want to embed Sentry error monitoring inside their own product.

This is distinct from:

- `sentry-enduser/` — the `sentrysdk`-namespaced managed package that end customers install
- `sentry-enduser-adoption/` + `codemods/` — tooling to instrument an existing customer org

The ISV case is different because the ISV cannot assume the `sentrysdk` managed package is present in their subscriber's org. They need to ship the SDK as part of their own package, under their own namespace.

## The Distribution Model

The intended artifact is an **NPM package** that an ISV developer installs into their SFDX project. It should provide:

1. **Source metadata to copy/vendor** — the Apex classes, platform event, and LWC mixin from `sentry-core/`, stripped of the `sentrysdk` namespace so the ISV can include them under their own namespace.
2. **Setup tooling** — a CLI command (similar to `codemods/` `setup`) that generates the config class, metadata record, and remote site setting wired to the ISV's DSN.
3. **Adopt tooling** — a CLI command (similar to `codemods/` `adopt`) that instruments Apex and LWC entry points, but references the ISV's namespace for `Sentry.captureException()` rather than `sentrysdk.Sentry.captureException()`.

## Resolved Design Decisions

### 1. Namespace handling — `--namespace` flag on the `vendor` command

`sentry-core/` is nearly namespace-agnostic. There are exactly three `sentrysdk` references that need substitution:

- `Sentry.cls` — `iconName='resource:sentrysdk__SentryLogo:logo'` on `@InvocableMethod` (annotation limitation, no clean fix yet)
- `Sentry.cls` — `configurationEditor='sentrysdk-capture-flow-fault-property-editor'` (same)
- `SentryMechanismDMLExceptionStrategyTest.cls:51` — `'sentrysdk__Stored_By_Sentry__c'` field reference (a bug — should not use the namespace in tests; fix in `sentry-core`)

The `vendor` CLI command will accept `--namespace <ns>` and do a find-replace of `sentrysdk` → `<ns>` across copied files. The two annotation references are known limitations to fix in `sentry-core` over time.

### `vendor` also applies CMT protection transforms

`sentry-core` ships `Sentry_Config__mdt` as `visibility: Public` and `DSN__c` as `fieldManageability: SubscriberControlled` — correct for the end-user case where subscribers configure their own DSN. For ISVs these must be different, but `sentry-core` must not be changed (it would break `sentry-enduser`). The `vendor` command therefore applies these transforms when copying:

| File                                   | Change                                                                                                                   |
| -------------------------------------- | ------------------------------------------------------------------------------------------------------------------------ |
| `Sentry_Config__mdt.object-meta.xml`   | `<visibility>Public</visibility>` → `<visibility>Protected</visibility>`                                                 |
| `fields/DSN__c.field-meta.xml`         | `<fieldManageability>SubscriberControlled</fieldManageability>` → `<fieldManageability>Upgradeable</fieldManageability>` |
| Generated config record `.md-meta.xml` | Inject `<protected>true</protected>`                                                                                     |

All other field manageability values should also be reviewed and set to `Upgradeable` at vendor time (not `SubscriberControlled`).

### `vendor` also strips `global` access modifiers

Every class, interface, method, and member in `sentry-core` is `global` — required so subscriber Apex can call across the namespace boundary into the `sentrysdk` managed package. For ISVs, the vendored code lives in their own package namespace alongside their own Apex, so `public` is sufficient. `global` would unnecessarily expose SDK internals to the ISV's subscribers.

The `vendor` command performs a `global` → `public` substitution across all copied `.cls` files.

Note: `SentryConfig` is `global virtual` in `sentry-core` so subscriber orgs can subclass it. After vendoring it becomes `public virtual`. The ISV writes their own config class (in their package) that extends it — `public virtual` is enough, and the ISV should not expose subclassing to their own subscribers.

### 2. Platform event portability — clean, no action needed

`Sentry_Event__e`, `Sentry_Config__mdt`, `Sentry_Payload__c`, and `Sentry_Rate_Limits__c` are all fully self-contained in `sentry-core/core/main/model/objects/`. Vendoring copies them as-is.

### 3. Config metadata type — protected CMT + push upgrades for DSN rotation

The ISV embeds a `Sentry_Config__mdt` record with their DSN at build time. To protect it from subscriber visibility and enable ISV-side rotation:

- Set type `<visibility>Protected</visibility>` in the object XML — subscriber Apex/SOQL/UI cannot access the type at all
- Set `<protected>true</protected>` on the record
- Set field manageability to `Upgradeable` on `DSN__c` — ISV can change the value in a new package version; subscribers are locked out

To rotate the DSN: update the record in the ISV dev org → cut a new package version → push upgrade via AppExchange Partner Console (or `PackagePushRequest` API). Subscribers receive it automatically.

**Critical:** All three settings must be configured before the first Managed-Released upload — they cannot be changed after.

### 4. `SentryDebugLogsIntegration` — excluded

This integration lives in `sentry-enduser/`, requires Tooling API callouts, and is the main feature exclusive to the managed package offering. It is out of scope for `sentry-isv`.

## Monorepo Layout (planned)

```
sentry-core/              ← source of truth for SDK Apex (no namespace)
sentry-enduser/           ← managed package (sentrysdk namespace)
sentry-isv/               ← npm: @salesforce-sentry/sentry-isv — transformed Apex metadata for ISV usage
isv-cli/                  ← npm: @salesforce-sentry/isv-cli — CLI that reads sentry-isv and places files
enduser-cli/              ← renamed from codemods/ — npm: @salesforce-sentry/enduser-cli
```

### Role split: `sentry-isv` vs `isv-cli`

**`@salesforce-sentry/sentry-isv`** (this package) is an SFDX project whose structure mirrors `sentry-enduser/sentry-enduser/`:

```
sentry-isv/
  sfdx-project.json
  core/                  ← transformed from sentry-core — committed, regenerated by build script
    main/
      sdk/classes/       ← global→public, sentrysdk→{{NAMESPACE}}
      model/objects/     ← CMT Protected visibility, Upgradeable field manageability
      integrations/
      ...
  isv/                   ← hand-authored ISV-specific metadata (committed directly, mostly empty in v1)
    main/
      ...
  package.json           ← build script: regenerates core/ from ../sentry-core/
```

`core/` files are committed (reviewable in git, diffable when `sentry-core` changes) but are derived artifacts — regenerated by running the build script. `isv/` is hand-authored, analogous to `sentry-enduser/sentry-enduser/main/`.

The npm package ships both directories as a versioned SFDX source tree.

**`@salesforce-sentry/isv-cli`** depends on `sentry-isv`, reads its files, substitutes `{{NAMESPACE}}` with the ISV's actual namespace (from their `sfdx-project.json` or `--namespace` flag), and writes the result into the ISV's SFDX project directory. It also owns `setup`, `adopt`, and `validate` commands.

This split means `sentry-isv` versions track the Apex SDK, and `isv-cli` versions track CLI tooling — they can evolve independently.

### Rename: `codemods/` → `enduser-cli/`

The existing `codemods/` directory and its npm package (`@salesforce-sentry/codemods`) will be renamed to `enduser-cli/` / `@salesforce-sentry/enduser-cli`. Breaking change to the public CLI name — coordinate with docs and install instructions.

### Shared logic between `enduser-cli` and `isv-cli`

Some CLI logic is shared (SFDX project parsing, LWC/Apex AST transforms, diff/prompt UX). Target shape is a third internal package (e.g. `@salesforce-sentry/cli-shared`) that both CLIs depend on. Acceptable to duplicate with a clear seam for v1 and extract when building both in parallel causes pain.

## CLI Design Principles

### Zero-config by default — read `sfdx-project.json`

Most inputs the `vendor` command needs are already declared in the target project's `sfdx-project.json`: namespace (`"namespace"`), default package directory (`packageDirectories[].path` where `"default": true`). The command should read that file first and derive values from it rather than requiring flags.

```bash
salesforce-sentry vendor [project-path]   # namespace inferred from sfdx-project.json
salesforce-sentry vendor --namespace myisv [project-path]  # override if not yet set
```

If `sfdx-project.json` has no namespace or an empty string, the command must abort and ask the ISV to supply `--namespace`. Substituting an empty string would produce broken identifiers (e.g. `__SentryLogo`).

## Build Script (`npm run build`)

A Node.js script (`build.js`) in `sentry-isv/` that regenerates `core/` from `../sentry-core/core/main/`. Run manually before each `npm publish`. No CI yet.

### What gets copied

Everything under `sentry-core/core/main/` except:

- `default/lwc/.eslintrc.json`, `*/jsconfig.json` — dev tooling
- `default/lwc/*/__tests__/` — Jest tests (not Salesforce metadata)

Tests (`tests/*.cls`) are **included** — ISVs need Apex test coverage for their managed package.

### Transformations

| File pattern                                          | Transformation                                                           |
| ----------------------------------------------------- | ------------------------------------------------------------------------ |
| `*.cls`, `*.trigger`                                  | `global` → `public`, `sentrysdk` → `{{NAMESPACE}}`                       |
| `Sentry_Config__mdt.object-meta.xml`                  | `<visibility>Public</visibility>` → `<visibility>Protected</visibility>` |
| `fields/*.field-meta.xml` under `Sentry_Config__mdt/` | `SubscriberControlled` → `Upgradeable`                                   |
| All other files                                       | `sentrysdk` → `{{NAMESPACE}}` catch-all, otherwise copy as-is            |

Plain `fs` + string replacement — no XML parser, no AST. Output mirrors the source directory structure exactly under `sentry-isv/core/`.

## `isv-cli` Commands

### `vendor`

Reads files from the installed `@salesforce-sentry/sentry-isv` package, substitutes `{{NAMESPACE}}` with the ISV's namespace, and writes into a `sentry/` subdirectory inside the ISV's default source directory (from `sfdx-project.json`). Managed packages have a single source directory — `sentry/` is a subdirectory within it, not a separate `packageDirectories` entry.

On re-run (when `sentry-isv` bumps a version), shows a diff per file and prompts before overwriting.

### `setup`

Interactive wizard. Generates into the ISV's default source directory:

- Apex config class extending `SentryConfig` (no namespace prefix — vendored SDK is in the same package)
- Its `.cls-meta.xml`
- `Sentry_Config.Default.md-meta.xml` with the DSN and `<protected>true</protected>`
- `Sentry.remoteSite-meta.xml`

**Note on remote site wildcards:** Salesforce Remote Site Settings do not support wildcard subdomains. Sentry.io ingest hosts are per-org subdomains (`https://o<orgId>.ingest.sentry.io`), so if a DSN rotation changes the host, both the CMT record and the remote site setting must be updated in the same push upgrade package version. There is no way around this without a proxy layer.

### `adopt`

Same entry point detection as `enduser-cli adopt`. Difference: generated calls use `Sentry.captureException(e)` with no namespace prefix (SDK is vendored into the same package). LWC mixin imports also point to the vendored component path.

### `validate`

Checks: namespace set in `sfdx-project.json`, `vendor` has been run (core files present in `sentry/`), config class exists, DSN set and valid, remote site setting matches DSN host, no uninstrumented Apex/LWC entry points remain.
