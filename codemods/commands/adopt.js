"use strict";

const path = require("path");
const fs = require("fs");
const { collectLWCTransforms } = require("../transforms/lwc");
const { collectApexTransforms } = require("../transforms/apex");
const { showDiffAndPrompt } = require("../utils/interactive");
const { getSourceDirs } = require("../utils/files");
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

  const [lwcTransforms, apexTransforms] = await Promise.all([
    collectLWCTransforms(projectRoot),
    collectApexTransforms(projectRoot)
  ]);

  const all = [...lwcTransforms, ...apexTransforms];

  if (all.length === 0) {
    console.log(pc.green("✓ Nothing to transform."));
    return;
  }

  console.log(
    `Found ${pc.yellow(String(lwcTransforms.length))} LWC file(s) and ` +
      `${pc.yellow(String(apexTransforms.length))} Apex file(s) to transform.\n`
  );

  let applyAll = false;
  let applied = 0;
  let skipped = 0;

  for (const transform of all) {
    if (applyAll) {
      fs.writeFileSync(transform.path, transform.newContent, "utf8");
      applied++;
      continue;
    }

    const decision = await showDiffAndPrompt(transform);

    if (decision === "yes" || decision === "all") {
      fs.writeFileSync(transform.path, transform.newContent, "utf8");
      applied++;
      if (decision === "all") applyAll = true;
    } else if (decision === "quit") {
      skipped += all.length - applied - 1;
      break;
    } else {
      skipped++;
    }
  }

  console.log(
    `\n${pc.green(`✓ Applied: ${applied}`)}  ${pc.dim(`Skipped: ${skipped}`)}\n`
  );
}

module.exports = { adopt };
