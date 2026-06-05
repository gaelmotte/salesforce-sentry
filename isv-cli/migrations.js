"use strict";

/**
 * Ordered migration registry for the ISV adoption CLI.
 * v0.3 is optional — adopt.js prompts the user before including it.
 */
const migrations = [
  {
    version: "v0.1",
    ...require("@salesforce-sentry/cli-shared/migrations/v0.1")
  },
  {
    version: "v0.2",
    ...require("@salesforce-sentry/cli-shared/migrations/v0.2")
  },
  { version: "v0.3", ...require("./migrations/v0.3") }
];

module.exports = migrations;
