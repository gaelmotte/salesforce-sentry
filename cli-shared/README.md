# @salesforce-sentry/cli-shared

Internal shared utilities for the salesforce-sentry CLI tools. Used by [`@salesforce-sentry/enduser-cli`](https://www.npmjs.com/package/@salesforce-sentry/enduser-cli) and [`@salesforce-sentry/isv-cli`](https://www.npmjs.com/package/@salesforce-sentry/isv-cli).

Not intended for direct use.

## Utilities

### `utils/sfdx.js`

SFDX project helpers:

- `readSfdxProject(projectRoot)` — parses `sfdx-project.json`
- `getSourceDirs(projectRoot)` — returns all package directory paths
- `getDefaultSourceDir(projectRoot)` — returns the default package directory path
- `findProjectFiles(projectRoot, predicate)` — walks all source dirs, returns files matching predicate

### `utils/dsn.js`

Sentry DSN parsing and validation:

- `parseDSN(dsn)` — returns `{ valid, publicKey, host, projectId, remoteUrl }`
- `validateDSN(dsn)` — returns an error string or `null`

### `utils/interactive.js`

Terminal diff and prompt UX:

- `colorDiff(patch)` — colorizes a unified diff string (green additions, red removals)
- `showDiffAndPrompt(transform)` — prints a colored diff and prompts yes / no / all / quit

### `utils/meta-xml.js`

- `readMetaXml(filePath)` — parses a Salesforce `.xml-meta.xml` file and returns the parsed object
