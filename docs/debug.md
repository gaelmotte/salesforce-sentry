# DebugLogsIntegration

It enriches events with info extracted from the debug logs.

This only works if the user has trace flags enabled. Good news is, it can add the traceflags for 24hours when an issue is caught for the user.

## Parameters

| position |  type   |               default               | effect                                                                 |
| :------: | :-----: | :---------------------------------: | :--------------------------------------------------------------------- |
|    1     | Boolean |                false                | Should the SDK enable Trace Flags for the user when an error is caught |
|    2     | String  | `Sentry_SDK_Tooling_Api_Credential` | Name of the Named Credential to use to enable Trace Flags              |

## Additional configuration

TODO List the steps to create a self named cred for the tooling api
