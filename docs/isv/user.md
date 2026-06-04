# User Integration

Attaches user identity to every event. In ISV mode, this captures the identity of the user in the customer's org who triggered the error.

```apex
new SentryUserIntegration()             // org ID and user ID only
new SentryUserIntegration(true, false)  // + profile and permission sets, no PII
new SentryUserIntegration(true, true)   // + profile and permission sets + PII (name, email, etc.)
```

| Parameter | Type    | Default | Effect                                                 |
| --------- | ------- | ------- | ------------------------------------------------------ |
| 1         | Boolean | `true`  | Include Profile and Permission Sets                    |
| 2         | Boolean | `false` | Include PII (name, email, language, country, isActive) |

::: warning
If you enable PII capture (`true, true`), ensure your privacy policy and customer agreements cover transmission of end-user data to your Sentry project.
:::
