# UserIntegration

It enriches events with user details.

## Parameters

| position |  type   | default | effect                                                                                  |
| :------: | :-----: | :-----: | :-------------------------------------------------------------------------------------- |
|    1     | Boolean |  true   | Enrich with assigned Profile and Permission sets                                        |
|    2     | Boolean |  false  | Enrich with User PII (Firstname, Lastname, Email, isActive, languageLocaleKey, country) |

Note, The Organization ID and User Id are always sent to allow sentry to count how many users are impacted by a given issue.
