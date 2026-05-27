#!/usr/bin/env node
"use strict";

const pc = require("picocolors");
const { vendor } = require("./commands/vendor");
const { setup } = require("./commands/setup");
const { adopt } = require("./commands/adopt");
const { validate } = require("./commands/validate");

const USAGE = `
${pc.bold("Salesforce Sentry ISV CLI")}

  ${pc.cyan("Usage:")} sentry-isv <command> [project-path]

  ${pc.bold("Commands:")}
    ${pc.cyan(
      "vendor"
    )}    Copy SDK source into the ISV project with namespace substitution
    ${pc.cyan("setup")}     Generate config class and required metadata files
    ${pc.cyan(
      "adopt"
    )}     Instrument LWC and Apex entry points with Sentry error capture
    ${pc.cyan("validate")}  Check that Sentry is correctly wired up

  project-path defaults to the current working directory.
`;

async function main() {
  const [, , cmd, projectArg] = process.argv;

  switch (cmd) {
    case "vendor":
      return vendor(projectArg);
    case "setup":
      return setup(projectArg);
    case "adopt":
      return adopt(projectArg);
    case "validate":
      return validate(projectArg);
    default:
      console.log(USAGE);
      process.exit(cmd ? 1 : 0);
  }
}

main().catch((err) => {
  console.error(pc.red(err.message));
  process.exit(1);
});
