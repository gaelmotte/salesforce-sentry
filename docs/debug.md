# Debug Logs Integration

_(enduser package only)_

Retrieves the most recent Apex debug log for the current user and parses it into breadcrumbs on the Sentry event. This gives you a chronological trace of what happened in the Apex execution leading up to the error.

Because logs only exist when trace flags are active, the integration can optionally enable them automatically when an error is caught.

## Usage

```apex
new sentrysdk.SentryDebugLogsIntegration()
new sentrysdk.SentryDebugLogsIntegration(true)                          // auto-enable trace flags
new sentrysdk.SentryDebugLogsIntegration(true, 'My_Named_Credential')   // custom named credential
```

## Parameters

| Position |  Type   |               Default               | Effect                                                                                            |
| :------: | :-----: | :---------------------------------: | :------------------------------------------------------------------------------------------------ |
|    1     | Boolean |               `false`               | Automatically enable `FINEST`-level trace flags for the user for 24 hours when an error is caught |
|    2     | String  | `Sentry_SDK_Tooling_Api_Credential` | API name of the Named Credential used to call the Tooling API                                     |

## Setting up the Named Credential

The integration calls the Salesforce Tooling API to retrieve `ApexLog` records. It authenticates via a Named Credential of type **Named Principal** using the **Salesforce (OAuth)** authentication provider.

1. In Setup, go to **Named Credentials → New**.
2. Set the **Label** and **Name** to `Sentry_SDK_Tooling_Api_Credential` (or your custom name).
3. Set **URL** to your org's My Domain URL (e.g. `https://myorg.my.salesforce.com`).
4. Set **Identity Type** to `Named Principal` and **Authentication Protocol** to `OAuth 2.0`.
5. Configure the Auth Provider to use the Salesforce connected app with the `api` and `refresh_token` scopes.
