"use strict";

// TODO: checks:
//   - namespace set in sfdx-project.json
//   - vendor has been run (sentry/ directory present in default source dir)
//   - Sentry_Config__mdt record exists, is enabled, has valid DSN
//   - Remote site setting matches DSN host
//   - Config class exists
//   - No uninstrumented Apex/LWC entry points remain

async function validate(projectArg) {
  throw new Error("validate: not yet implemented");
}

module.exports = { validate };
