"use strict";

const fs = require("fs");
const path = require("path");

// Directories that are never meaningful source in an SFDX project
const SKIP_DIRS = new Set([
  "node_modules",
  "__tests__",
  ".git",
  ".sfdx",
  ".sf"
]);

/**
 * Read and parse sfdx-project.json from projectRoot.
 * Throws with a clear message if the file is missing or malformed.
 */
function readSfdxProject(projectRoot) {
  const sfdxPath = path.join(projectRoot, "sfdx-project.json");
  if (!fs.existsSync(sfdxPath)) {
    throw new Error(
      `No sfdx-project.json found in ${projectRoot}.\n` +
        "Run this tool from the root of an SFDX project."
    );
  }
  try {
    return JSON.parse(fs.readFileSync(sfdxPath, "utf8"));
  } catch (e) {
    throw new Error(`Could not parse sfdx-project.json: ${e.message}`);
  }
}

/**
 * Return the absolute paths of all packageDirectory source roots
 * declared in sfdx-project.json, filtering out any that don't exist on disk.
 */
function getSourceDirs(projectRoot) {
  const project = readSfdxProject(projectRoot);
  const packageDirs = project.packageDirectories ?? [];
  if (packageDirs.length === 0) {
    throw new Error("sfdx-project.json has no packageDirectories entries.");
  }
  return packageDirs
    .map((pkg) => path.resolve(projectRoot, pkg.path))
    .filter((dir) => fs.existsSync(dir));
}

/** Low-level recursive file finder (used internally). */
function findFiles(dir, predicate, results = []) {
  let entries;
  try {
    entries = fs.readdirSync(dir, { withFileTypes: true });
  } catch {
    return results;
  }

  for (const entry of entries) {
    if (entry.isDirectory()) {
      if (!SKIP_DIRS.has(entry.name) && !entry.name.startsWith(".")) {
        findFiles(path.join(dir, entry.name), predicate, results);
      }
    } else if (predicate(path.join(dir, entry.name))) {
      results.push(path.join(dir, entry.name));
    }
  }

  return results;
}

/**
 * Find files matching predicate, scoped to the packageDirectories
 * declared in sfdx-project.json at projectRoot.
 */
function findSfdxFiles(projectRoot, predicate) {
  const sourceDirs = getSourceDirs(projectRoot);
  const results = [];
  for (const dir of sourceDirs) {
    findFiles(dir, predicate, results);
  }
  return results;
}

module.exports = { readSfdxProject, getSourceDirs, findSfdxFiles };
