# Upgrading & Codemods

When a new SDK version ships, upgrading means re-vendoring — pulling the updated source into your project and integrating the changes before cutting a new package version.

## Upgrade process

**1. Update the CLI**

```bash
npm install -g @salesforce-sentry/isv-cli@latest
```

Or pin a specific version in your `package.json` devDependencies and run `npm install`:

```json
{
  "devDependencies": {
    "@salesforce-sentry/isv-cli": "^1.x.x"
  }
}
```

**2. Check the changelog**

Read the [ISV Changelog](./changelog) before re-vendoring. It lists breaking changes, new integrations, and any manual steps required for that version.

**3. Re-run vendor**

```bash
npx @salesforce-sentry/isv-cli vendor
```

This overwrites `force-app/sentry/` with the updated SDK source. Review the diff carefully before committing.

**4. Run adopt**

```bash
npx @salesforce-sentry/isv-cli adopt
```

This applies codemods to update your instrumentation for the new SDK version. Coverage is currently incomplete — review the diff and consult the changelog for any changes requiring manual intervention.

Migration codemods (handling API changes between SDK versions) are on the roadmap.

**5. Test and repackage**

Deploy to a scratch org, validate with `isv-cli validate`, then cut a new version of your managed package.

## A note on managed package constraints

Salesforce does not allow certain metadata types to be removed from a managed package once released — custom objects, fields, and some other components are permanent after customers have installed them.

The `vendor` command is being updated to handle this correctly: retaining undeletable metadata across upgrades and flagging deprecated components rather than removing them. Until this is confirmed stable, **review the diff after every re-vendor** and do not delete anything from `force-app/sentry/` without verifying it is safe to remove from your package.
