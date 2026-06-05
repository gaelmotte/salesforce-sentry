#!/usr/bin/env node
const fs = require("fs");
const path = require("path");

const CORE_ROOT = path.resolve(__dirname, "sentry-isv/core");

const SRC = path.resolve(__dirname, "../sentry-core/core/main");
const DEST = path.resolve(CORE_ROOT, "main");

const DEP_SRC = path.resolve(
  __dirname,
  "node_modules/@guimini/apex-json-serialization/force-app/main"
);
const DEP_DEST = path.resolve(CORE_ROOT, "deps/apex-json-serialization");

const SKIP_NAMES = new Set([".eslintrc.json", "jsconfig.json"]);
const SKIP_PATTERNS = [/\/lwc\/[^/]+\/__tests__\//];

function shouldSkip(filePath) {
  const normalized = filePath.replace(/\\/g, "/");
  return (
    SKIP_NAMES.has(path.basename(filePath)) ||
    SKIP_PATTERNS.some((p) => p.test(normalized))
  );
}

function transform(filePath, content) {
  const normalized = filePath.replace(/\\/g, "/");

  if (filePath.endsWith(".cls") || filePath.endsWith(".trigger")) {
    // Strip global access modifier — not needed when vendored into the same package
    content = content.replace(/\bglobal\b/g, "public");
    // Activate ISV-only lines (System.debug calls suppressed in the end-user build)
    content = content.replace(/^(\s*)\/\/ ISV-ONLY: /gm, "$1");
  }

  // CMT type visibility: Protected hides records from subscriber org admins
  if (
    normalized.endsWith("Sentry_Config__mdt/Sentry_Config__mdt.object-meta.xml")
  ) {
    content = content.replace(
      "<visibility>Public</visibility>",
      "<visibility>Protected</visibility>"
    );
  }

  // CMT field manageability: DeveloperControlled — ISV rotates values via push upgrade; subscribers cannot modify
  if (
    normalized.includes("/Sentry_Config__mdt/fields/") &&
    filePath.endsWith(".field-meta.xml")
  ) {
    content = content.replace(/SubscriberControlled/g, "DeveloperControlled");
  }

  // Namespace placeholder — isv-cli vendor substitutes this with the ISV's namespace
  content = content.replace(/\bsentrysdk\b/g, "{{NAMESPACE}}");

  return content;
}

function copyDir(src, dest) {
  fs.mkdirSync(dest, { recursive: true });
  for (const entry of fs.readdirSync(src, { withFileTypes: true })) {
    const srcPath = path.join(src, entry.name);
    const destPath = path.join(dest, entry.name);
    if (shouldSkip(srcPath)) continue;
    if (entry.isDirectory()) {
      copyDir(srcPath, destPath);
    } else {
      const content = fs.readFileSync(srcPath, "utf8");
      fs.writeFileSync(destPath, transform(srcPath, content), "utf8");
    }
  }
}

if (fs.existsSync(CORE_ROOT)) {
  fs.rmSync(CORE_ROOT, { recursive: true });
}
copyDir(SRC, DEST);
copyDir(DEP_SRC, DEP_DEST);
console.log(`core/ regenerated → ${path.relative(process.cwd(), CORE_ROOT)}`);
