"use strict";

const path = require("path");
const fs = require("fs");
const runner = require("@salesforce-sentry/cli-shared/runner");
const {
  showDiffAndPrompt
} = require("@salesforce-sentry/cli-shared/utils/interactive");
const { getSourceDirs } = require("@salesforce-sentry/cli-shared/utils/sfdx");
const pc = require("picocolors");

async function adopt(projectArg) {
  const projectRoot = projectArg ? path.resolve(projectArg) : process.cwd();

  if (!fs.existsSync(projectRoot)) {
    console.error(pc.red(`Path not found: ${projectRoot}`));
    process.exit(1);
  }

  let sourceDirs;
  try {
    sourceDirs = getSourceDirs(projectRoot);
  } catch (e) {
    console.error(pc.red(e.message));
    process.exit(1);
  }

  console.log(pc.bold("\nSalesforce Sentry — Adoption Codemod"));
  console.log(`Project: ${pc.cyan(projectRoot)}`);
  console.log(
    `Sources: ${sourceDirs
      .map((d) => pc.dim(d.replace(projectRoot + "/", "")))
      .join(", ")}\n`
  );

  let transforms;
  try {
    transforms = await runner.collectPendingTransforms(projectRoot, {
      capturePrefix: "sentrysdk.Sentry",
      sentryImportPath: "sentrysdk/sentryMixin"
    });
  } catch (e) {
    console.error(pc.red(e.message));
    process.exit(1);
  }

  if (transforms.length === 0) {
    runner.ensureStateFile(projectRoot);
    console.log(pc.green("✓ Nothing to transform."));
    return;
  }

  const lwcCount = transforms.filter((t) => t.path.endsWith(".js")).length;
  const apexCount = transforms.length - lwcCount;
  console.log(
    `Found ${pc.yellow(String(lwcCount))} LWC file(s) and ` +
      `${pc.yellow(String(apexCount))} Apex file(s) to transform.\n`
  );

  let applyAll = false;
  let applied = 0;
  let skipped = 0;
  const skippedFiles = new Set();

  for (const transform of transforms) {
    if (skippedFiles.has(transform.path)) {
      skipped++;
      continue;
    }

    if (applyAll) {
      fs.writeFileSync(transform.path, transform.newContent, "utf8");
      runner.saveFileState(
        projectRoot,
        transform.path,
        transform.migrationVersion
      );
      applied++;
      continue;
    }

    const decision = await showDiffAndPrompt(transform);

    if (decision === "yes" || decision === "all") {
      fs.writeFileSync(transform.path, transform.newContent, "utf8");
      runner.saveFileState(
        projectRoot,
        transform.path,
        transform.migrationVersion
      );
      applied++;
      if (decision === "all") applyAll = true;
    } else if (decision === "quit") {
      skipped += transforms.length - applied - 1;
      break;
    } else {
      skipped++;
      skippedFiles.add(transform.path);
    }
  }

  console.log(
    `\n${pc.green(`✓ Applied: ${applied}`)}  ${pc.dim(`Skipped: ${skipped}`)}\n`
  );
}

module.exports = { adopt };
