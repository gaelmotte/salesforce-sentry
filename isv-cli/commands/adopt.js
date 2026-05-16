"use strict";

// TODO: same entry-point detection as enduser-cli adopt.
// Difference: generated calls use Sentry.captureException(e) with no namespace
// prefix — vendored SDK lives in the same package. LWC mixin imports also
// point to the vendored component path (c/sentryMixin, not sentrysdk/sentryMixin).

async function adopt(projectArg) {
  throw new Error("adopt: not yet implemented");
}

module.exports = { adopt };
