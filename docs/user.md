# User Integration

Captures the current user's identity and, optionally, their permission sets and PII.

The Organization ID and User ID are always included — they allow Sentry to count how many distinct users are affected by a given issue.

## Usage

```apex
new sentrysdk.SentryUserIntegration()              // identity only (default)
new sentrysdk.SentryUserIntegration(true, false)   // + permission sets, no PII
new sentrysdk.SentryUserIntegration(true, true)    // + permission sets + PII
```

## Parameters

| Position |  Type   | Default | Effect                                                                   |
| :------: | :-----: | :-----: | :----------------------------------------------------------------------- |
|    1     | Boolean | `true`  | Include the user's assigned Profile and Permission Sets                  |
|    2     | Boolean | `false` | Include PII: first name, last name, email, language, country, `isActive` |
