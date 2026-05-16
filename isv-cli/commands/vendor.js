"use strict";

const path = require("path");
const fs = require("fs");
const pc = require("picocolors");
const { createPatch } = require("diff");
const prompts = require("prompts");
const {
  colorDiff
} = require("@salesforce-sentry/cli-shared/utils/interactive");
const { getNamespace, getDefaultSourceDir } = require("../utils/sfdx");

function sentryISVRoot() {
  try {
    return path.dirname(
      require.resolve("@salesforce-sentry/sentry-isv/package.json")
    );
  } catch {
    // monorepo dev fallback
    return path.resolve(__dirname, "../../sentry-isv");
  }
}

function substituteNamespace(content, namespace) {
  return content.replace(/\{\{NAMESPACE\}\}/g, namespace);
}

function collectOps(srcRoot, srcDir, destDir, namespace, ops) {
  for (const entry of fs.readdirSync(srcDir, { withFileTypes: true })) {
    const srcPath = path.join(srcDir, entry.name);
    const destPath = path.join(destDir, entry.name);
    const rel = path.relative(srcRoot, srcPath);
    if (entry.isDirectory()) {
      collectOps(srcRoot, srcPath, destPath, namespace, ops);
    } else {
      const raw = fs.readFileSync(srcPath, "utf8");
      const transformed = substituteNamespace(raw, namespace);
      if (fs.existsSync(destPath)) {
        const existing = fs.readFileSync(destPath, "utf8");
        if (existing === transformed) {
          ops.push({ status: "unchanged", rel, destPath, transformed });
        } else {
          const patch = createPatch(
            path.basename(destPath),
            existing,
            transformed
          );
          ops.push({ status: "changed", rel, destPath, transformed, patch });
        }
      } else {
        ops.push({ status: "new", rel, destPath, transformed });
      }
    }
  }
}

async function vendor(projectArg) {
  const projectRoot = projectArg ? path.resolve(projectArg) : process.cwd();

  let namespace, defaultSourceDir;
  try {
    namespace = getNamespace(projectRoot);
    defaultSourceDir = getDefaultSourceDir(projectRoot);
  } catch (e) {
    console.error(pc.red(e.message));
    process.exit(1);
  }

  const isvSrc = path.join(sentryISVRoot(), "sentry-isv");
  if (!fs.existsSync(isvSrc)) {
    console.error(
      pc.red(`sentry-isv source not found at ${isvSrc}.`) +
        "\n  Run `npm run build` in the sentry-isv package first."
    );
    process.exit(1);
  }

  const destRoot = path.join(defaultSourceDir, "sentry");

  console.log(pc.bold("\nSalesforce Sentry ISV — Vendor"));
  console.log(`  Namespace:   ${pc.cyan(namespace)}`);
  console.log(
    `  Destination: ${pc.cyan(path.relative(projectRoot, destRoot))}\n`
  );

  const ops = [];
  collectOps(isvSrc, isvSrc, destRoot, namespace, ops);

  const newFiles = ops.filter((o) => o.status === "new");
  const changedFiles = ops.filter((o) => o.status === "changed");
  const unchangedCount = ops.filter((o) => o.status === "unchanged").length;

  if (newFiles.length === 0 && changedFiles.length === 0) {
    console.log(pc.green("  ✓ Already up to date."));
    if (unchangedCount)
      console.log(pc.dim(`  ${unchangedCount} file(s) unchanged.`));
    return;
  }

  for (const op of newFiles) {
    console.log(`  ${pc.green("+")} ${op.rel}`);
  }

  for (const op of changedFiles) {
    console.log(`  ${pc.yellow("~")} ${op.rel}`);
    const hunks = op.patch.split("\n").slice(4).join("\n");
    console.log(colorDiff(hunks).replace(/^/gm, "    "));
  }

  if (unchangedCount) {
    console.log(pc.dim(`\n  ${unchangedCount} file(s) unchanged.`));
  }

  const { confirm } = await prompts(
    {
      type: "confirm",
      name: "confirm",
      message: "Write these files?",
      initial: true
    },
    { onCancel: () => process.exit(0) }
  );

  if (!confirm) {
    console.log(pc.dim("\nAborted."));
    return;
  }

  for (const op of [...newFiles, ...changedFiles]) {
    fs.mkdirSync(path.dirname(op.destPath), { recursive: true });
    fs.writeFileSync(op.destPath, op.transformed, "utf8");
  }

  console.log(
    pc.green(`\n  ✓ Wrote ${newFiles.length + changedFiles.length} file(s).`) +
      "\n"
  );
}

module.exports = { vendor };
