"use strict";

const { collectApexTransforms } = require("./apex");
const { collectLWCTransforms } = require("./lwc");

/**
 * v0.1 — Initial Sentry instrumentation of Apex entry points and LWC components.
 *
 * Apex: wraps @AuraEnabled, @InvocableMethod, @RemoteAction, @HttpGet/Post/Put/Delete/Patch,
 *       Schedulable.execute, Queueable.execute, and Database.Batchable methods in try/catch.
 *       Wraps trigger bodies in try/catch.
 *
 * LWC: adds SentryMixin (internal) or SentryBoundaryMixin (exposed) to components.
 */

/**
 * @typedef {{ capturePrefix?: string, sentryImportPath?: string, excludeDir?: string }} MigrationOptions
 * @typedef {{ path: string, label: string, oldContent: string, newContent: string }} Transform
 * @typedef {{ filePath: string, message: string, severity: 'warn'|'error' }} Violation
 */

/**
 * Collect transforms for uninstrumented files.
 * Each returned transform has the same shape used by showDiffAndPrompt.
 * @param {string[]} filePaths - absolute paths from the runner
 * @param {MigrationOptions} [options]
 * @returns {Promise<Transform[]>}
 */
async function transform(filePaths, options = {}) {
  const lwc = collectLWCTransforms(filePaths, options);
  const apex = collectApexTransforms(filePaths, options);
  return [...lwc, ...apex];
}

/**
 * Validate that all entry points in the given file paths are instrumented.
 * Read-only — never writes. Returns one violation per uninstrumented file.
 * @param {string[]} filePaths - absolute paths to check
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

module.exports = { transform, validate };
