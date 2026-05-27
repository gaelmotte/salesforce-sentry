"use strict";

const path = require("path");
const fs = require("fs");
const pc = require("picocolors");
const { XMLParser } = require("fast-xml-parser");
const {
  readSfdxProject,
  getDefaultSourceDir,
  findProjectFiles: findSfdxFiles
} = require("@salesforce-sentry/cli-shared/utils/sfdx");
const { parseDSN } = require("@salesforce-sentry/cli-shared/utils/dsn");
const { collectLWCTransforms } = require("../transforms/lwc");
const { collectApexTransforms } = require("../transforms/apex");

const xmlParser = new XMLParser({
  ignoreAttributes: false,
  parseTagValue: true
});

function pass(msg) {
  console.log(`  ${pc.green("✓")} ${msg}`);
}
function fail(msg) {
  console.log(`  ${pc.red("✗")} ${msg}`);
}
function warn(msg) {
  console.log(`  ${pc.yellow("!")} ${msg}`);
}

async function validate(projectArg) {
  const projectRoot = projectArg ? path.resolve(projectArg) : process.cwd();

  let allPassed = true;
  function check(passed, passMsg, failMsg) {
    if (passed) {
      pass(passMsg);
    } else {
      fail(failMsg);
      allPassed = false;
    }
    return passed;
  }

  console.log(pc.bold("\nSalesforce Sentry ISV — Validate\n"));

  // 1. SFDX project
  let sfdxProject, defaultSourceDir;
  try {
    sfdxProject = readSfdxProject(projectRoot);
    defaultSourceDir = getDefaultSourceDir(projectRoot);
    pass("sfdx-project.json found");
  } catch {
    fail("sfdx-project.json not found or invalid");
    console.log(pc.red("\n  Cannot continue without a valid SFDX project.\n"));
    return;
  }

  // 2. Namespace
  check(
    !!sfdxProject.namespace,
    `Namespace set: ${sfdxProject.namespace}`,
    'No namespace in sfdx-project.json — set "namespace" before vendoring'
  );

  // 3. Vendor has been run
  const sentryDir = path.join(defaultSourceDir, "sentry");
  if (
    !check(
      fs.existsSync(sentryDir),
      "Vendored SDK found (sentry/)",
      "Vendored SDK not found — run `sentry-isv vendor` first"
    )
  ) {
    console.log(pc.red("\n  Some checks failed — see above.\n"));
    return;
  }

  // 4. Sentry_Config metadata record
  const mdFiles = findSfdxFiles(projectRoot, (f) =>
    /Sentry_Config[^/]*\.md-meta\.xml$/.test(f)
  );

  if (
    !check(
      mdFiles.length > 0,
      `Found ${mdFiles.length} Sentry_Config metadata record(s)`,
      "No Sentry_Config metadata record found — run `sentry-isv setup`"
    )
  ) {
    console.log(pc.red("\n  Some checks failed — see above.\n"));
    return;
  }

  // Parse enabled records — ISV field names have no namespace prefix
  const enabledRecords = [];
  let configDSN = null;
  let configClassName = null;
  let configProtected = false;

  for (const f of mdFiles) {
    try {
      const xml = xmlParser.parse(fs.readFileSync(f, "utf8"));
      const rawValues = xml?.CustomMetadata?.values;
      const valuesArr = Array.isArray(rawValues) ? rawValues : [rawValues];
      let enabled = false;
      let dsn = null;
      let cls = null;
      const rawVal = (v) =>
        v?.value != null && typeof v.value === "object"
          ? v.value["#text"]
          : v.value;
      for (const v of valuesArr) {
        if (!v) continue;
        if (v.field === "Enabled__c" && rawVal(v) === true) enabled = true;
        if (v.field === "DSN__c") dsn = String(rawVal(v) ?? "");
        if (v.field === "ApexClass__c") cls = String(rawVal(v) ?? "");
      }
      if (enabled) {
        enabledRecords.push(f);
        configDSN = dsn;
        configClassName = cls;
        configProtected = xml?.CustomMetadata?.protected === true;
      }
    } catch {
      /* skip unparseable file */
    }
  }

  check(
    enabledRecords.length === 1,
    "Exactly one Sentry_Config record is enabled",
    enabledRecords.length === 0
      ? "No Sentry_Config record has Enabled__c = true"
      : `${enabledRecords.length} Sentry_Config records are enabled — only one should be active`
  );

  // 5. Protected flag — critical for ISV: must be true before managed release
  check(
    configProtected,
    "Sentry_Config record is protected (subscriber orgs cannot see it)",
    "Sentry_Config record is not protected — set <protected>true</protected> before your first managed release"
  );

  // 6. DSN validity
  if (configDSN) {
    const parsed = parseDSN(configDSN);
    const dsnOk = check(
      parsed.valid,
      `DSN is set and valid (project: ${parsed.projectId ?? "?"})`,
      `DSN is set but invalid: ${configDSN}`
    );

    if (dsnOk) {
      // 7. Remote site setting
      const rsFiles = findSfdxFiles(projectRoot, (f) =>
        f.endsWith(".remoteSite-meta.xml")
      );
      let remoteSiteOk = false;
      for (const f of rsFiles) {
        try {
          const xml = xmlParser.parse(fs.readFileSync(f, "utf8"));
          const url = String(xml?.RemoteSiteSetting?.url ?? "").replace(
            /\/$/,
            ""
          );
          if (url === parsed.remoteUrl || parsed.remoteUrl.startsWith(url)) {
            remoteSiteOk = true;
            break;
          }
        } catch {
          /* skip */
        }
      }
      check(
        remoteSiteOk,
        `Remote site setting matches DSN host (${parsed.host})`,
        `No remote site setting found for ${parsed.host} — run \`sentry-isv setup\` or add it manually`
      );
    }
  } else {
    fail("DSN__c is not set in the enabled Sentry_Config record");
    allPassed = false;
  }

  // 8. Apex config class
  if (configClassName) {
    const clsFiles = findSfdxFiles(projectRoot, (f) =>
      f.endsWith(`/${configClassName}.cls`)
    );
    check(
      clsFiles.length > 0,
      `Apex config class found: ${configClassName}.cls`,
      `Apex config class not found: ${configClassName}.cls — run \`sentry-isv setup\``
    );
  } else {
    fail("ApexClass__c not set in the enabled Sentry_Config record");
    allPassed = false;
  }

  // 9. Pending instrumentation
  process.stdout.write("\n");
  process.stdout.write(pc.dim("  Scanning for uninstrumented files…"));
  const excludeDir = path.join(defaultSourceDir, "sentry");
  const [lwc, apex] = await Promise.all([
    collectLWCTransforms(projectRoot, { excludeDir }),
    collectApexTransforms(projectRoot, { excludeDir })
  ]);
  process.stdout.write("\r" + " ".repeat(50) + "\r");

  const pending = lwc.length + apex.length;
  if (pending === 0) {
    pass("All LWC and Apex entry points are instrumented");
  } else {
    warn(
      `${pending} file(s) still need instrumentation — run \`sentry-isv adopt\``
    );
  }

  console.log(
    allPassed
      ? pc.green("\n  All checks passed.\n")
      : pc.red("\n  Some checks failed — see above.\n")
  );
}

module.exports = { validate };
