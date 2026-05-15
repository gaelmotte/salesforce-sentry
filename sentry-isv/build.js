#!/usr/bin/env node
const fs = require("fs");
const path = require("path");

const SRC = path.resolve(__dirname, "../sentry-core/core/main");
const DEST = path.resolve(__dirname, "sentry-isv/core");

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

  // Strip global access modifier — not needed when vendored into the same package
  if (filePath.endsWith(".cls") || filePath.endsWith(".trigger")) {
    content = content.replace(/\bglobal\b/g, "public");
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

  // CMT field manageability: Upgradeable lets ISV rotate values via push upgrade
  if (
    normalized.includes("/Sentry_Config__mdt/fields/") &&
    filePath.endsWith(".field-meta.xml")
  ) {
    content = content.replace(/SubscriberControlled/g, "Upgradeable");
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

if (fs.existsSync(DEST)) {
  fs.rmSync(DEST, { recursive: true });
}
copyDir(SRC, DEST);
console.log(`core/ regenerated → ${path.relative(process.cwd(), DEST)}`);
