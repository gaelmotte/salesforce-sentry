# Sentry SDK for ISVs

You're building a managed package. When it throws in a customer's org, you want to know — not your customer, **you**.

The end-user SDK isn't the right fit here. It asks customers to install a separate managed package, create their own Sentry project, and manage their own configuration. That's the right model when customers want to track _their own_ errors. It's the wrong model when you want to track errors in _your_ code, deployed in their org.

ISV mode solves this by vendoring the SDK source directly into your package. Your Sentry DSN is hardcoded in your config. Your customers install your package and configure nothing. Errors from your code flow to your Sentry project, regardless of which org they occur in.

## How it differs from the end-user SDK

|                      | End-user SDK                       | ISV mode                                               |
| -------------------- | ---------------------------------- | ------------------------------------------------------ |
| Distribution         | Separate managed package           | Vendored into your package                             |
| Sentry project       | Customer's                         | Yours                                                  |
| Configuration        | Customer sets up DSN, config class | You hardcode everything                                |
| Customer involvement | Install + configure                | Install only                                           |
| Coexistence          | —                                  | Both can be installed in the same org without conflict |

## What vendoring means

Running `npx @salesforce-sentry/isv-cli vendor` copies the SDK's core Apex classes and metadata into your SFDX project. They become part of your package — versioned alongside your code, deployed through your pipeline, living in your namespace.

There is no runtime dependency on the `sentrysdk` managed package. If your customer also installs the end-user SDK separately, the two coexist without conflict.

## The trade-off

Vendoring gives you full control. It also means upgrades are manual — when a new SDK version ships, you re-run the CLI and integrate the changes. See [Upgrading](./upgrading) for what that looks like today and what's planned.
