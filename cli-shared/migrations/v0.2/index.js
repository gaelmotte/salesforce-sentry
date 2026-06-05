"use strict";

const { collectConsoleLogTransforms } = require("./lwc");

/**
 * v0.2 — Replace console.log calls with this[Sentry].log in instrumented LWC components.
 *
 * Idempotent: re-runs on files whose content has changed since last adoption,
 * picking up new console.log calls added after initial instrumentation.
 */

/**
 * @typedef {{ excludeDir?: string }} MigrationOptions
 * @typedef {{ filePath: string, message: string, severity: 'warn'|'error' }} Violation
 */

/**
 * @param {string[]} filePaths
 * @param {MigrationOptions} [options]
 */
async function transform(filePaths, options = {}) {
  return collectConsoleLogTransforms(filePaths, options);
}

/**
 * @param {string[]} filePaths
 * @param {MigrationOptions} [options]
 * @returns {Promise<Violation[]>}
 */
async function validate(filePaths, options = {}) {
  const pending = await transform(filePaths, options);
  return pending.map((t) => ({
    filePath: t.path,
    message: t.label,
    severity: "warn"
  }));
}

module.exports = { transform, validate, idempotent: true };
