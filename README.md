# salesforce-sentry

Sentry SDK for the Salesforce Platform.
Due to the absence of global hooks to catch unhandled exception, it still requires some plumbing.
I hope this makes your life easier though.

This is an attempt at convincing my colleagues mixing low-code and pro-code features of Salesforce does not necessarily mean losing in termes of debuging possibilities.
I am convinced the less code we write, the less surface for a bug to be implemented.
Furthermore, for both a customer or ISV, it is quite hard to get a sense of what is happening on the customer's org.
This should help us get some more clarity.

## Expected Features from a Sentry SDK

Here is the list of the features we can expect from a Sentry SDK : https://develop.sentry.dev/sdk/features/

- Background Sending : ✅ The event is first published to pubsub and processed asynchronously
- Uncaught Exception Handler :
  - ❌ Salesforce does not provide any kind of hook for that. Heck tere even are exception no one ca catch. However, i aim to provide examples on how to captures exceptions from any runtimecontext https://developer.salesforce.com/docs/atlas.en-us.apexref.meta/apexref/apex_enum_System_Quiddity.htm
  - ⏳ It is however possible to poll EventLogFiles (requires salesforce shield or Event Moniroting addon). Much less details can be retrieved this way, but can help with uncatchable exceptions (limits for instance) and provide help on where to add `Sentry.captureException()` calls where possible
- Scopes : 🟠 You'll need to push them yourself.
- Automatic Context Data : ✅ User and permissions are automatically sent (PII retrieval is enabled by integration)
- Breadcrumbs : ✅ Manual breadcrumb should work.
- Event Sampling : ⏳ not implemented yet
- Rate Limiting : ⏳ not implemented yet
- In-App frames : ✅ callback available
- Surrounding Source in Stack Trace : ✅ ( ⚠️ untested with managed packages yet. ISVs, i fear even if code requesting `ApexClass` sobject is from the same namespace, `Body` might well be null)
- Local Variables : No way to do that. Though; it may be done for Flow Variables marked for Input or output. Does it have value to you ? Scrubbing PII may be super hard. There actually is a way by setting propper levels and catching it in eventProcessor https://help.salesforce.com/s/articleView?id=sf.code_setting_debug_log_levels.htm&type=5 STACK_FRAME_VARIABLE_LIST
- Desymbolication : not applicable
- Retrieve Last Event ID : ⏳ not implemented yet
- User Feedback : ⏳ not implemented yet
- Attachments : ⏳ not implemented yet
- Screenshots : ❓ would it help devs to have a look at a broken LWC component within sentry ?
- Before-Send Hook : ⏳ not implemented yet
- Before-Breadcrumb Hook : ⏳ not implemented yet
- Buffer to Disk : ✅ (no retrial yet though)
- Start-Up Crash Detection : not applicable
- HTTP Proxy : Not Applicable
- HTTP Client Integrations : ✅ (end-user only integration)
- Log context : ✅ (end-user only integration)

## Features that i wish to add

- Add Finest trace flags on classes mentionned as `inApp` in Frames to limit size of debugLog files
- Attach log to sentry event so devs can use Replay Debugger to understand what went wrong (Needs to be gated as there probably are PII in there)
- Polling for unhandled exceptions in EventLogFile https://developer.salesforce.com/docs/atlas.en-us.object_reference.meta/object_reference/sforce_api_objects_eventlogfile_apexunexpectedexception.htm It will not allow for on the fly capture, but could help identify if a class throws in a context that is NOT caught
- LWC SentryBoundary Mixin
- Flow Action SentryCaptureFlowException

## Options

To setup Sentry, you must expose a `public class <WHATEVER> implements ISentryConfig` and only one.

- isEnabled
- getDSN
- getIntegrations
  - SentryStacktraceIntegration : Handles stacktrace formatting so Sentry can ingest it
    - frameContextLines : number of lines for pre and post context code lines
    - inAppCallback : a callback to identify if a frame is from your app
    - mechanismExceptionStrategies : List of Strategies on how to handle a given exception type to retrieve contextual data
  - SentryUserIntegration : captures details about the user, including permissions
    - captureUserPII: allows capturing PII about the user
  - SentryDebugLogsIntegration (end-user only) : parses debuglog to produce breadcrumbs.
  - TODO, implement global config flag config https://docs.sentry.io/platforms/python/guides/logging/configuration/options/#send-default-pii

## Package Directories

Each of these are an SFDX project within this repo. You might want to open several vscode instances to make sure salesforce extensions work as expected

### core

This is the core SDK. It should not be used as standalone. If you do, i'd love to know why :)
See the two other package directories, that provide features specific to the two use cases of ISV projects and Salesforce customer org.
It is imported as a symlink in the other projects

### sentry-isv

TODO

I know hardcoding is bad practive, yet for ISV projects, i guess customer customization of the `SentryConfig` does not quite make sense.
Configuration is (almost) limited to hardcoded config.
We have no way to remotely update the Sentry DSN anyway (bar some callout shenanigans)

Ideally, i would like to discribute this over NPM, for it does not make sense for an ISV project to depend on another package (complex installs) nor do i want you to copy over the code (losing all possibility for dependency updates)

### sentry enduser

This includes many more metadata to help a customer Setup Sentry :

- Lightning app to setup the sdk
- Tab for payloads sent to sentry for review
  This needs to be packaged as a managed package. But the 0% test coverage yet makes me think it is not quite for now XD

### Sentry enduser sample

This is sample on how a Salesforce customer might use the enduser version of the SDK
For now, it imports the enduser sdk with a symlink, but as soon as it is packaged, this should be changed

## Setup for dev

### NPM deps

for each sfdx project
`npm install .`

### Git submodules

the SDK depends on custom deserialization classes.
These are made available as a git submodule
`git submodule update --init --recursive`

### Start working

open each sfdx project in a separate vscode instance
create a scratch org for each

### leads on how to make it more dev freadly

- move to lerna to manage dev setup ?

## Design

To make sure we are able to process events even if transaction is rolled back, `Sentry.captureException()` does the following :

- capture runtime contexts (such as the user and eventual breadcrumbs)
- publishes an internal Pubsub Event.
- A platform event trigger then processes and enriches with data or complex logic since we are not on the critical path anymore
- sends it to Sentry ingest endpoint and stores the result

I tried to stick to the https://develop.sentry.dev/sdk/unified-api/ spec as much as i could.

## Acknowledgements

Thanks @jmather for giving me a base idea on how to implement this.
https://github.com/jmather/SentryForSalesforce

Thanks people from Sentry discord server :)
