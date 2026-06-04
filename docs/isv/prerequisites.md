# Prerequisites

This guide assumes you are setting up ISV mode — vendoring the SDK into your own managed package to track errors in your code, across your customers' orgs. If you're looking to track errors in a Salesforce org you administer directly, see the [end-user setup](../getStarted) instead.

## What you'll need

**A Salesforce packaging org**
You're building a managed package. This guide assumes you have a packaging org and an SFDX project set up. Specific edition requirements depend on your package type — confirm with your Partner Agreement if unsure.

**A Sentry project and DSN**
Create a Sentry project for your managed package if you don't have one. This is the project that will receive errors from all of your customers' orgs. Keep the DSN handy — you'll need it during setup.

**Node.js and npx**
The `@salesforce-sentry/isv-cli` package runs via npx. Node.js 18+ is recommended.

**Salesforce CLI (`sf`)**
For deploying the vendored source to a scratch org or sandbox during development. You likely already have this.

## What you don't need

- Customers don't need a Sentry account
- Customers don't configure anything — no DSN, no metadata records, no Remote Site Settings
- No Named Credential is required — ISV mode does not use the Tooling API
