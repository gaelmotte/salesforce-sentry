"use strict";

const fs = require("fs");
const path = require("path");
const jscodeshift = require("jscodeshift");
const { readMetaXml } = require("../utils/meta-xml");
const { findSfdxFiles } = require("../utils/files");

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

function transformLWCSource(source, isExposed) {
  if (/\bextends\s+Sentry(?:Boundary)?Mixin\(/.test(source)) return null;

  let root;
  try {
    root = j(source);
  } catch {
    return null;
  }

  const mixinName = isExposed ? "SentryBoundaryMixin" : "SentryMixin";

  // Find the class whose superClass involves LightningElement
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

  // Use the class identifier name for the componentName string arg
  const componentName =
    targetClass.node.id?.name ?? path.basename(path.dirname(source));

  // Wrap existing superClass: SentryXxxMixin(originalSuperClass, "ClassName")
  targetClass.node.superClass = j.callExpression(j.identifier(mixinName), [
    targetClass.node.superClass,
    j.stringLiteral(componentName)
  ]);

  // Add the import after the last existing import declaration
  const sentryImport = j.importDeclaration(
    [
      j.importSpecifier(j.identifier(mixinName)),
      j.importSpecifier(j.identifier("Sentry"))
    ],
    j.stringLiteral("sentrysdk/sentryMixin")
  );

  const importPaths = root.find(j.ImportDeclaration).paths();
  if (importPaths.length > 0) {
    importPaths[importPaths.length - 1].insertAfter(sentryImport);
  } else {
    root.find(j.Program).get("body", 0).insertBefore(sentryImport);
  }

  return root.toSource({ quote: "double" });
}

async function collectLWCTransforms(projectRoot) {
  const jsFiles = findSfdxFiles(
    projectRoot,
    (f) => f.endsWith(".js") && f.includes("/lwc/")
  );
  const transforms = [];

  for (const jsFile of jsFiles) {
    const dir = path.dirname(jsFile);
    const componentName = path.basename(dir);
    const metaFile = path.join(dir, `${componentName}.js-meta.xml`);
    if (!fs.existsSync(metaFile)) continue;

    const source = fs.readFileSync(jsFile, "utf8");
    // Skip if already instrumented — catches both managed pkg path and local c/sentryMixin
    if (/\bextends\s+Sentry(?:Boundary)?Mixin\(/.test(source)) continue;

    const meta = readMetaXml(metaFile);
    const isExposed =
      meta?.LightningComponentBundle?.isExposed === true ||
      meta?.LightningComponentBundle?.isExposed === "true";

    const newContent = transformLWCSource(source, isExposed);
    if (!newContent || newContent === source) continue;

    const mixinName = isExposed ? "SentryBoundaryMixin" : "SentryMixin";
    transforms.push({
      path: jsFile,
      label: `LWC  →  ${mixinName}  (${componentName})`,
      oldContent: source,
      newContent
    });
  }

  return transforms;
}

module.exports = { collectLWCTransforms };
