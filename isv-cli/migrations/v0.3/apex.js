"use strict";

const fs = require("fs");
const path = require("path");

/**
 * Replace System.debug( calls with Sentry.log( while skipping strings and comments.
 * Returns null if no replaceable calls are found.
 * @param {string} content
 * @param {string} capturePrefix - e.g. "Sentry"
 * @returns {string|null}
 */
function replaceSystemDebug(content, capturePrefix) {
  const target = "System.debug(";
  const replacement = `${capturePrefix}.log(`;

  if (!content.includes(target)) return null;

  const chunks = [];
  let i = 0;
  let changed = false;

  while (i < content.length) {
    // Line comment
    if (content[i] === "/" && content[i + 1] === "/") {
      const nl = content.indexOf("\n", i + 2);
      if (nl === -1) {
        chunks.push(content.slice(i));
        break;
      }
      chunks.push(content.slice(i, nl + 1));
      i = nl + 1;
      continue;
    }

    // Block comment
    if (content[i] === "/" && content[i + 1] === "*") {
      const end = content.indexOf("*/", i + 2);
      if (end === -1) {
        chunks.push(content.slice(i));
        break;
      }
      chunks.push(content.slice(i, end + 2));
      i = end + 2;
      continue;
    }

    // Single-quoted string (Apex uses '' as the escape sequence)
    if (content[i] === "'") {
      let j = i + 1;
      while (j < content.length) {
        if (content[j] === "'") {
          if (content[j + 1] === "'") {
            j += 2;
            continue;
          }
          j++;
          break;
        }
        j++;
      }
      chunks.push(content.slice(i, j));
      i = j;
      continue;
    }

    // Match System.debug(
    if (content.slice(i, i + target.length) === target) {
      chunks.push(replacement);
      i += target.length;
      changed = true;
      continue;
    }

    chunks.push(content[i]);
    i++;
  }

  return changed ? chunks.join("") : null;
}

/**
 * Collect Apex transforms that replace System.debug() with Sentry.log().
 * @param {string[]} filePaths
 * @param {{ capturePrefix?: string, excludeDir?: string }} [options]
 * @returns {{ path: string, label: string, oldContent: string, newContent: string }[]}
 */
function collectSystemDebugTransforms(filePaths, options = {}) {
  const { capturePrefix = "Sentry", excludeDir, pendingContent } = options;

  const apexFiles = filePaths.filter(
    (f) =>
      (f.endsWith(".cls") || f.endsWith(".trigger")) &&
      (!excludeDir || !f.startsWith(excludeDir + path.sep))
  );

  const results = [];

  for (const file of apexFiles) {
    const diskContent = fs.readFileSync(file, "utf8");
    const source = pendingContent?.get(file) ?? diskContent;
    const newContent = replaceSystemDebug(source, capturePrefix);
    if (!newContent) continue;

    results.push({
      path: file,
      label: `Apex  System.debug()  →  ${capturePrefix}.log()  (${path.basename(
        file
      )})`,
      oldContent: source,
      newContent
    });
  }

  return results;
}

module.exports = { collectSystemDebugTransforms, replaceSystemDebug };
