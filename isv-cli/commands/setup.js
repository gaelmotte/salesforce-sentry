"use strict";

// TODO: interactive wizard — generates into the ISV's default source directory:
//   - Apex config class extending SentryConfig (no namespace prefix)
//   - Its .cls-meta.xml
//   - Sentry_Config.Default.md-meta.xml with DSN and <protected>true</protected>
//   - Sentry.remoteSite-meta.xml
//
// Key differences from enduser-cli setup:
//   - <protected>true</protected> on the CMT record
//   - No sentrysdk. prefix on generated class (vendored SDK is in same package)
//   - No SentryDebugLogsIntegration option
//   - SentryISVContextIntegration enabled by default

async function setup(projectArg) {
  throw new Error("setup: not yet implemented");
}

module.exports = { setup };
