"use strict";

const fs = require("fs");
const path = require("path");

const STATE_FILE = ".sentry-adoption.json";

/**
 * @typedef {{ schemaVersion: number, lastAppliedMigration: string|null, files: Record<string, { migration: string, instrumentedAt: string }> }} AdoptionState
 */

/**
 * Read the adoption state file from a project root.
 * Returns a default empty state if the file does not exist or cannot be parsed.
 * @param {string} projectRoot
 * @returns {AdoptionState}
 */
function readState(projectRoot) {
  const statePath = path.join(projectRoot, STATE_FILE);
  try {
    return JSON.parse(fs.readFileSync(statePath, "utf8"));
  } catch {
    return { schemaVersion: 1, lastAppliedMigration: null, files: {} };
  }
}

/**
 * Write the adoption state file, creating or overwriting it atomically.
 * @param {string} projectRoot
 * @param {AdoptionState} state
 */
function writeState(projectRoot, state) {
  const statePath = path.join(projectRoot, STATE_FILE);
  fs.writeFileSync(statePath, JSON.stringify(state, null, 2) + "\n", "utf8");
}

module.exports = { STATE_FILE, readState, writeState };
