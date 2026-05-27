"use strict";

const fs = require("fs");
const path = require("path");
const jscodeshift = require("jscodeshift");
const { readMetaXml } = require("../../utils/meta-xml");

const j = jscodeshift.withParser("babel");

function containsLightningElement(node) {
  if (!node) return false;
  if (node.type === "Identifier" && node.name === "LightningElement")
    return true;
  if (node.type === "CallExpression") {
    return node.arguments.some(containsLightningElement);
  }
  return false;
}

/**
 * Transform a single LWC JS source string.
 * Returns null if already instrumented, unparseable, or has no LightningElement superclass.
 * @param {string} source
 * @param {boolean} isExposed
 * @param {string} sentryImportPath - e.g. "sentrysdk/sentryMixin" or "c/sentryMixin"
 * @returns {string|null}
 */
function transformLWCSource(
  source,
  isExposed,
  sentryImportPath = "sentrysdk/sentryMixin"
) {
  if (/\bextends\s+Sentry(?:Boundary)?Mixin\(/.test(source)) return null;

  let root;
  try {
    root = j(source);
  } catch {
    return null;
  }

  const mixinName = isExposed ? "SentryBoundaryMixin" : "SentryMixin";

  let targetClass = null;
  const check = (nodePath) => {
    if (
      nodePath.node.superClass &&
      containsLightningElement(nodePath.node.superClass)
    ) {
      targetClass = nodePath;
    }
  };
  root.find(j.ClassDeclaration).forEach(check);
  if (!targetClass) root.find(j.ClassExpression).forEach(check);
  if (!targetClass) return null;

  const componentName =
    targetClass.node.id?.name ?? path.basename(path.dirname(source));

  targetClass.node.superClass = j.callExpression(j.identifier(mixinName), [
    targetClass.node.superClass,
    j.stringLiteral(componentName)
  ]);

  const sentryImport = j.importDeclaration(
    [
      j.importSpecifier(j.identifier(mixinName)),
      j.importSpecifier(j.identifier("Sentry"))
    ],
    j.stringLiteral(sentryImportPath)
  );

  const importPaths = root.find(j.ImportDeclaration).paths();
  if (importPaths.length > 0) {
    importPaths[importPaths.length - 1].insertAfter(sentryImport);
  } else {
    root.find(j.Program).get("body", 0).insertBefore(sentryImport);
  }

  return root.toSource({ quote: "double" });
}

/**
 * Collect LWC transforms for the given candidate file paths.
 * Skips files that are already instrumented, have no meta.xml, or parse errors.
 * @param {string[]} filePaths - absolute paths to consider
 * @param {{ sentryImportPath?: string, excludeDir?: string }} [options]
 * @returns {{ path: string, label: string, oldContent: string, newContent: string }[]}
 */
function collectLWCTransforms(filePaths, options = {}) {
  const { sentryImportPath = "sentrysdk/sentryMixin", excludeDir } = options;

  const jsFiles = filePaths.filter(
    (f) =>
      f.endsWith(".js") &&
      f.includes("/lwc/") &&
      (!excludeDir || !f.startsWith(excludeDir + path.sep))
  );

  const results = [];

  for (const jsFile of jsFiles) {
    const dir = path.dirname(jsFile);
    const componentName = path.basename(dir);
    const metaFile = path.join(dir, `${componentName}.js-meta.xml`);
    if (!fs.existsSync(metaFile)) continue;

    const source = fs.readFileSync(jsFile, "utf8");
    if (/\bextends\s+Sentry(?:Boundary)?Mixin\(/.test(source)) continue;

    const meta = readMetaXml(metaFile);
    const isExposed =
      meta?.LightningComponentBundle?.isExposed === true ||
      meta?.LightningComponentBundle?.isExposed === "true";

    const newContent = transformLWCSource(source, isExposed, sentryImportPath);
    if (!newContent || newContent === source) continue;

    const mixinName = isExposed ? "SentryBoundaryMixin" : "SentryMixin";
    results.push({
      path: jsFile,
      label: `LWC  →  ${mixinName}  (${componentName})`,
      oldContent: source,
      newContent
    });
  }

  return results;
}

module.exports = { collectLWCTransforms, transformLWCSource };
