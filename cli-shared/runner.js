"use strict";

const path = require("path");
const { execSync } = require("child_process");
const { findProjectFiles, readSfdxProject } = require("./utils/sfdx");
const { readState, writeState } = require("./state");
const registry = require("./migrations");

/**
 * @typedef {{ capturePrefix?: string, sentryImportPath?: string, excludeDir?: string }} RunnerOptions
 * @typedef {{ path: string, label: string, oldContent: string, newContent: string, migrationVersion: string }} PendingTransform
 * @typedef {{ filePath: string, message: string, severity: 'warn'|'error' }} Violation
 */

function requireSfdxProject(projectRoot) {
  try {
    readSfdxProject(projectRoot);
  } catch {
    throw new Error(
      `sfdx-project.json not found in ${projectRoot}.\n` +
        "Run this command from the root of an SFDX project."
    );
  }
}

/**
 * Requires a clean git working tree before running destructive transforms.
 * Skips the check if the directory is not a git repository.
 * @param {string} projectRoot
 */
function requireCleanGit(projectRoot) {
  let status;
  try {
    status = execSync("git status --porcelain -- .", {
      cwd: projectRoot,
      encoding: "utf8",
      stdio: ["pipe", "pipe", "pipe"]
    });
  } catch {
    return; // not a git repo — skip the check
  }
  if (status.trim()) {
    throw new Error(
      "Working tree is not clean. Commit or stash your changes before running the adoption codemod.\n\n" +
        status.trim()
    );
  }
}

function migrationIndex(version) {
  return registry.findIndex((m) => m.version === version);
}

/**
 * Collect all transforms that still need to be applied across all registered migrations.
 * Files already recorded in the state file at the current migration version are skipped,
 * enabling partial runs to be resumed.
 * Requires a clean git working tree before collecting.
 * @param {string} projectRoot
 * @param {RunnerOptions} [options]
 * @returns {Promise<PendingTransform[]>}
 */
async function collectPendingTransforms(projectRoot, options = {}) {
  requireSfdxProject(projectRoot);
  requireCleanGit(projectRoot);

  const state = readState(projectRoot);
  const allFiles = findProjectFiles(projectRoot, () => true);

  const transforms = [];

  for (const migration of registry) {
    const mIdx = migrationIndex(migration.version);

    const pendingFiles = allFiles.filter((f) => {
      const rel = path.relative(projectRoot, f);
      const entry = state.files[rel];
      if (!entry) return true;
      const entryIdx = migrationIndex(entry.migration);
      return entryIdx < mIdx;
    });

    if (pendingFiles.length === 0) continue;

    const migrationTransforms = await migration.transform(
      pendingFiles,
      options
    );
    for (const t of migrationTransforms) {
      transforms.push({ ...t, migrationVersion: migration.version });
    }
  }

  return transforms;
}

/**
 * Record that a file has been successfully instrumented by a migration.
 * Writes to the state file immediately so partial runs are resumable.
 * @param {string} projectRoot
 * @param {string} filePath - absolute path to the instrumented file
 * @param {string} migrationVersion - e.g. "v0.1"
 */
function saveFileState(projectRoot, filePath, migrationVersion) {
  const state = readState(projectRoot);
  const rel = path.relative(projectRoot, filePath);
  state.files[rel] = {
    migration: migrationVersion,
    instrumentedAt: new Date().toISOString()
  };
  state.lastAppliedMigration = migrationVersion;
  writeState(projectRoot, state);
}

/**
 * Run each migration's validate() function across all project files.
 * Read-only — never writes to disk.
 * @param {string} projectRoot
 * @param {RunnerOptions} [options]
 * @returns {Promise<Violation[]>}
 */
async function runValidations(projectRoot, options = {}) {
  requireSfdxProject(projectRoot);
  const allFiles = findProjectFiles(projectRoot, () => true);

  const violations = [];
  for (const migration of registry) {
    const migrationViolations = await migration.validate(allFiles, options);
    violations.push(...migrationViolations);
  }

  return violations;
}

/**
 * Write the state file if it does not already exist.
 * Calling adopt on a project with nothing to transform should still leave a
 * .sentry-adoption.json so future incremental runs can track progress.
 * @param {string} projectRoot
 */
function ensureStateFile(projectRoot) {
  const state = readState(projectRoot);
  writeState(projectRoot, state);
}

module.exports = {
  collectPendingTransforms,
  saveFileState,
  runValidations,
  ensureStateFile
};
