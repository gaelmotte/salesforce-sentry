"use strict";

const fs = require("fs");
const path = require("path");

const SKIP_DIRS = new Set([
  "node_modules",
  "__tests__",
  ".git",
  ".sfdx",
  ".sf"
]);

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

function getDefaultSourceDir(projectRoot) {
  const project = readSfdxProject(projectRoot);
  const entry =
    project.packageDirectories?.find((d) => d.default) ??
    project.packageDirectories?.[0];
  if (!entry) {
    throw new Error("No packageDirectories found in sfdx-project.json");
  }
  return path.resolve(projectRoot, entry.path);
}

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

function findProjectFiles(projectRoot, predicate) {
  const results = [];
  for (const dir of getSourceDirs(projectRoot)) {
    findFiles(dir, predicate, results);
  }
  return results;
}

module.exports = {
  readSfdxProject,
  getSourceDirs,
  getDefaultSourceDir,
  findProjectFiles
};
