"use strict";

const fs = require("fs");
const path = require("path");
const {
  findProjectFiles: findSfdxFiles
} = require("@salesforce-sentry/cli-shared/utils/sfdx");

function findMatchingBrace(content, openPos) {
  let depth = 0;
  let i = openPos;

  while (i < content.length) {
    const ch = content[i];

    if (ch === "/" && content[i + 1] === "/") {
      const nl = content.indexOf("\n", i + 2);
      if (nl === -1) return -1;
      i = nl + 1;
      continue;
    }

    if (ch === "/" && content[i + 1] === "*") {
      const end = content.indexOf("*/", i + 2);
      if (end === -1) return -1;
      i = end + 2;
      continue;
    }

    if (ch === "'") {
      i++;
      while (i < content.length) {
        if (content[i] === "'") {
          if (content[i + 1] === "'") {
            i += 2;
            continue;
          }
          i++;
          break;
        }
        i++;
      }
      continue;
    }

    if (ch === "{") depth++;
    else if (ch === "}") {
      depth--;
      if (depth === 0) return i;
    }

    i++;
  }

  return -1;
}

function detectIndentUnit(content) {
  for (const line of content.split("\n")) {
    if (!line.trim()) continue;
    if (/^\t/.test(line)) return "\t";
    const m = line.match(/^( +)/);
    if (m) return m[1].length <= 2 ? "  " : "    ";
  }
  return "    ";
}

function buildWrappedBlock(
  content,
  bracePos,
  bodyEnd,
  catchStatements,
  indentUnit
) {
  const body = content.slice(bracePos + 1, bodyEnd);

  const lines = body.split("\n");
  const firstNonEmpty = lines.find((l) => l.trim());
  if (!firstNonEmpty) return null;

  const baseIndent = firstNonEmpty.match(/^(\s*)/)[1];

  const closingLineStart = content.lastIndexOf("\n", bodyEnd - 1) + 1;
  const closingIndent = content.slice(closingLineStart, bodyEnd);

  const reindented = lines
    .map((l) => (l.trim() ? indentUnit + l : ""))
    .join("\n");

  const catchLines = catchStatements
    .map((s) => `${baseIndent}${indentUnit}${s}`)
    .join("\n");

  return (
    `{\n${baseIndent}try {` +
    reindented +
    `\n${baseIndent}} catch (Exception e) {\n` +
    catchLines +
    `\n${baseIndent}}\n${closingIndent}}`
  );
}

function applyTransforms(content, transforms, indentUnit) {
  const sorted = [...transforms].sort((a, b) => b.bodyStart - a.bodyStart);
  let result = content;

  for (const t of sorted) {
    const replacement = buildWrappedBlock(
      result,
      t.bodyStart,
      t.bodyEnd,
      t.catchStatements,
      indentUnit
    );
    if (!replacement) continue;
    result =
      result.slice(0, t.bodyStart) + replacement + result.slice(t.bodyEnd + 1);
  }

  return result;
}

function findAnnotatedMethods(content, annotationName, catchStatements) {
  const results = [];
  const re = new RegExp(`@${annotationName}\\b`, "gi");
  let match;

  while ((match = re.exec(content)) !== null) {
    let pos = match.index + match[0].length;

    while (pos < content.length && /[ \t\r\n]/.test(content[pos])) pos++;
    if (content[pos] === "(") {
      let d = 1;
      pos++;
      while (pos < content.length && d > 0) {
        if (content[pos] === "(") d++;
        else if (content[pos] === ")") d--;
        pos++;
      }
    }

    const bracePos = content.indexOf("{", pos);
    if (bracePos === -1) continue;

    const between = content.slice(pos, bracePos);
    if (!between.includes("(") || !between.includes(")")) continue;
    if (/\bclass\b|\binterface\b/i.test(between)) continue;

    const bodyEnd = findMatchingBrace(content, bracePos);
    if (bodyEnd === -1) continue;

    const body = content.slice(bracePos + 1, bodyEnd);
    if (body.includes("captureException")) continue;
    if (body.trim().startsWith("try ") || body.trim().startsWith("try{"))
      continue;

    results.push({ bodyStart: bracePos, bodyEnd, catchStatements });
  }

  return results;
}

function findSignatureMethods(content, interfaceRe, methodRe, catchStatements) {
  if (!interfaceRe.test(content)) return [];

  const results = [];
  const re = new RegExp(
    methodRe.source,
    methodRe.flags.includes("g") ? methodRe.flags : methodRe.flags + "g"
  );
  let match;

  while ((match = re.exec(content)) !== null) {
    const afterSig = match.index + match[0].length;
    const bracePos = content.indexOf("{", afterSig);
    if (bracePos === -1) continue;

    if (content.slice(afterSig, bracePos).includes("{")) continue;

    const bodyEnd = findMatchingBrace(content, bracePos);
    if (bodyEnd === -1) continue;

    const body = content.slice(bracePos + 1, bodyEnd);
    if (body.includes("captureException")) continue;
    if (body.trim().startsWith("try ") || body.trim().startsWith("try{"))
      continue;

    results.push({ bodyStart: bracePos, bodyEnd, catchStatements });
  }

  return results;
}

// ISV: no namespace prefix — vendored SDK lives in the same package
const GENERIC_CATCH = ["Sentry.captureException(e);", "throw e;"];
const AURA_CATCH = [
  "Sentry.captureException(e);",
  "throw new AuraHandledException(e.getMessage());"
];

const ANNOTATION_PATTERNS = [
  { annotation: "AuraEnabled", catchStatements: AURA_CATCH },
  { annotation: "InvocableMethod", catchStatements: GENERIC_CATCH },
  { annotation: "RemoteAction", catchStatements: GENERIC_CATCH },
  { annotation: "HttpGet", catchStatements: GENERIC_CATCH },
  { annotation: "HttpPost", catchStatements: GENERIC_CATCH },
  { annotation: "HttpPut", catchStatements: GENERIC_CATCH },
  { annotation: "HttpDelete", catchStatements: GENERIC_CATCH },
  { annotation: "HttpPatch", catchStatements: GENERIC_CATCH }
];

const INTERFACE_PATTERNS = [
  {
    interfaceRe: /implements\s+[^{]*\bSchedulable\b/i,
    methodRe: /\bvoid\s+execute\s*\(\s*SchedulableContext/gi,
    catchStatements: GENERIC_CATCH
  },
  {
    interfaceRe: /implements\s+[^{]*\bQueueable\b/i,
    methodRe: /\bvoid\s+execute\s*\(\s*QueueableContext/gi,
    catchStatements: GENERIC_CATCH
  },
  {
    interfaceRe: /implements\s+[^{]*Database\.Batchable/i,
    methodRe: /\b(?:start|execute|finish)\s*\(\s*Database\.BatchableContext/gi,
    catchStatements: GENERIC_CATCH
  }
];

function dedup(transforms) {
  const seen = new Set();
  return transforms.filter(({ bodyStart }) => {
    if (seen.has(bodyStart)) return false;
    seen.add(bodyStart);
    return true;
  });
}

async function collectApexTransforms(projectRoot) {
  const triggers = findSfdxFiles(projectRoot, (f) => f.endsWith(".trigger"));
  const classes = findSfdxFiles(projectRoot, (f) => f.endsWith(".cls"));
  const transforms = [];

  for (const triggerFile of triggers) {
    const content = fs.readFileSync(triggerFile, "utf8");

    const bracePos = content.indexOf("{");
    if (bracePos === -1) continue;
    const bodyEnd = findMatchingBrace(content, bracePos);
    if (bodyEnd === -1) continue;

    const body = content.slice(bracePos + 1, bodyEnd);
    if (body.includes("captureException")) continue;

    const indentUnit = detectIndentUnit(content);
    const replacement = buildWrappedBlock(
      content,
      bracePos,
      bodyEnd,
      GENERIC_CATCH,
      indentUnit
    );
    if (!replacement) continue;

    const newContent =
      content.slice(0, bracePos) + replacement + content.slice(bodyEnd + 1);
    transforms.push({
      path: triggerFile,
      label: `Apex Trigger  →  try/catch  (${path.basename(triggerFile)})`,
      oldContent: content,
      newContent
    });
  }

  for (const clsFile of classes) {
    const content = fs.readFileSync(clsFile, "utf8");
    const found = [];

    for (const { annotation, catchStatements } of ANNOTATION_PATTERNS) {
      found.push(...findAnnotatedMethods(content, annotation, catchStatements));
    }

    for (const {
      interfaceRe,
      methodRe,
      catchStatements
    } of INTERFACE_PATTERNS) {
      found.push(
        ...findSignatureMethods(content, interfaceRe, methodRe, catchStatements)
      );
    }

    const unique = dedup(found);
    if (unique.length === 0) continue;

    const indentUnit = detectIndentUnit(content);
    const newContent = applyTransforms(content, unique, indentUnit);

    transforms.push({
      path: clsFile,
      label: `Apex Class  →  ${
        unique.length
      } method(s) wrapped  (${path.basename(clsFile)})`,
      oldContent: content,
      newContent
    });
  }

  return transforms;
}

module.exports = { collectApexTransforms };
