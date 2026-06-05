"use strict";

/**
 * Ordered migration registry for the end-user adoption CLI.
 */
const migrations = [
  {
    version: "v0.1",
    ...require("@salesforce-sentry/cli-shared/migrations/v0.1")
  },
  {
    version: "v0.2",
    ...require("@salesforce-sentry/cli-shared/migrations/v0.2")
  }
];

module.exports = migrations;
