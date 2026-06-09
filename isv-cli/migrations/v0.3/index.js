"use strict";

const { collectSystemDebugTransforms } = require("./apex");

/**
 * v0.3 — Optional: replace System.debug() calls with Sentry.log() in Apex files.
 *
 * Idempotent: re-runs on files whose content has changed since last adoption,
 * picking up new System.debug() calls added after initial instrumentation.
 */

async function transform(filePaths, options = {}) {
  return collectSystemDebugTransforms(filePaths, options);
}

async function validate(filePaths, options = {}) {
  const pending = await transform(filePaths, options);
  return pending.map((t) => ({
    filePath: t.path,
    message: t.label,
    severity: "warn"
  }));
}

module.exports = {
  transform,
  validate,
  idempotent: true,
  optional: true,
  optionDescription:
    "Migrate System.debug() calls to Sentry.log()? (drop-in replacement — breadcrumbs + debug log)"
};
