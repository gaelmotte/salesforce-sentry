"use strict";

const fs = require("fs");
const path = require("path");
const jscodeshift = require("jscodeshift");

const j = jscodeshift.withParser("babel");

/**
 * Replace console.log calls with this[Sentry].log in a LWC source file.
 * Returns null if the file doesn't import sentryMixin, has no console.log calls, or fails to parse.
 * @param {string} source
 * @returns {string|null}
 */
function transformConsoleLogs(source) {
  let root;
  try {
    root = j(source);
  } catch {
    return null;
  }

  const hasSentryImport =
    root
      .find(j.ImportDeclaration)
      .filter((p) => p.node.source.value.endsWith("sentryMixin")).length > 0;
  if (!hasSentryImport) return null;

  const consoleLogs = root.find(j.CallExpression, {
    callee: {
      type: "MemberExpression",
      object: { type: "Identifier", name: "console" },
      property: { type: "Identifier", name: "log" }
    }
  });
  if (consoleLogs.length === 0) return null;

  consoleLogs.forEach((nodePath) => {
    const args = nodePath.node.arguments;
    nodePath.node.callee = j.memberExpression(
      j.memberExpression(j.thisExpression(), j.identifier("Sentry"), true),
      j.identifier("log"),
      false
    );
    if (args.length > 1) {
      nodePath.node.arguments = [
        j.callExpression(
          j.memberExpression(j.identifier("JSON"), j.identifier("stringify")),
          [j.arrayExpression(args)]
        )
      ];
    }
  });

  return root.toSource({ quote: "double" });
}

/**
 * Collect LWC transforms that replace console.log with this[Sentry].log.
 * Only applies to LWC files already instrumented with SentryMixin or SentryBoundaryMixin.
 * @param {string[]} filePaths
 * @param {{ excludeDir?: string }} [options]
 * @returns {{ path: string, label: string, oldContent: string, newContent: string }[]}
 */
function collectConsoleLogTransforms(filePaths, options = {}) {
  const { excludeDir } = options;

  const jsFiles = filePaths.filter(
    (f) =>
      f.endsWith(".js") &&
      f.includes("/lwc/") &&
      (!excludeDir || !f.startsWith(excludeDir + path.sep))
  );

  const results = [];

  for (const jsFile of jsFiles) {
    const componentName = path.basename(path.dirname(jsFile));
    const source = fs.readFileSync(jsFile, "utf8");
    const newContent = transformConsoleLogs(source);
    if (!newContent || newContent === source) continue;

    results.push({
      path: jsFile,
      label: `LWC console.log  →  this[Sentry].log  (${componentName})`,
      oldContent: source,
      newContent
    });
  }

  return results;
}

module.exports = { collectConsoleLogTransforms, transformConsoleLogs };
