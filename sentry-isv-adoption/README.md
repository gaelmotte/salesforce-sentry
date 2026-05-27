# Sentry-enduser-sample

This project aims at showcasing the usage of Salesforce-sentry package in the context of a Saleforce Customer willing to monitor issues occuring on their org.

## Install the package

Install the package from the most recent promoted version

## Deploy project

There are some replacement here
So you may :

```
source .env
sf project deploy start
```

## Uses cases where Salesforce-Sentry is set up

I'll try to show all the ways Salesforce-Sentry could help gathering knowledge to troubleshoot issues faster.
see :

- `SentryConfig.cls` on how it is set up.

### Throwing Invocable Method

This is the typical _I want to automate evrything in flows_ yet, there are some features that can only be triggered from code.
Converting a Lead is one of them. Two Flows call this invocable method, Record Triggered or Screen Flow

Issues in this `@InvocableMethod` :

- A validation rule requipres an unmapped field on opportunity.
- A debug log recheas array out of bounds

see :

- `ConvertLeadsInvocable` : code is surrounded with a big Try/Catch to `Sentry.CaptureException()`

### Execution issue in non screen Flow standard Elements

Fail to save a record
TODO

### Execution issue in non screen Flow standard Elements

Fail to save a record and prompt for User Feedback
TODO

### Callout result not valid for salesforce model

✅ Adds breadcrumbs for `Http.send()` with status

see :

- `ConvertLeadsInvocable` : there is a stupid call to limits that gos 401. No impact on execution though

### LWC component crashing, LWC component used as boundary with crashing children

LWC Mixins + AuraEnabled Apex to log the issue.
TODO

### Scheduled Apex Throwing

TODO

### Apex Triggers chains with a scope each

TODO

## Next Steps for this repo

- Implement the uses cases in both this repo and the SDK
- Tests ?
