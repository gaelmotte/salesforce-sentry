"use strict";

const path = require("path");
const fs = require("fs");
const pc = require("picocolors");
const { XMLParser } = require("fast-xml-parser");
const {
  readSfdxProject,
  findProjectFiles: findSfdxFiles
} = require("@salesforce-sentry/cli-shared/utils/sfdx");
const { parseDSN } = require("@salesforce-sentry/cli-shared/utils/dsn");
const runner = require("@salesforce-sentry/cli-shared/runner");

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

  console.log(pc.bold("\nSalesforce Sentry — Validate\n"));

  // 1. SFDX project
  let sfdxProject;
  try {
    sfdxProject = readSfdxProject(projectRoot);
    pass("sfdx-project.json found");
  } catch {
    fail("sfdx-project.json not found or invalid");
    console.log(pc.red("\n  Cannot continue without a valid SFDX project.\n"));
    return;
  }

  // 2. Sentry_Config metadata records
  const mdFiles = findSfdxFiles(projectRoot, (f) =>
    /Sentry_Config[^/]*\.md-meta\.xml$/.test(f)
  );

  if (
    !check(
      mdFiles.length > 0,
      `Found ${mdFiles.length} Sentry_Config metadata record(s)`,
      "No sentrysdk__Sentry_Config metadata record found — run `sentry setup`"
    )
  ) {
    console.log(pc.red("\n  Some checks failed — see above.\n"));
    return;
  }

  // Parse enabled records
  const enabledRecords = [];
  let configDSN = null;
  let configClassName = null;

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

  // 3. DSN validity
  if (configDSN) {
    const parsed = parseDSN(configDSN);
    const dsnOk = check(
      parsed.valid,
      `DSN is set and valid (project: ${parsed.projectId ?? "?"})`,
      `DSN is set but invalid: ${configDSN}`
    );

    if (dsnOk) {
      // 4. Remote site setting
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
        `No remote site setting found for ${parsed.host} — run \`sentry setup\` or add it manually`
      );
    }
  } else {
    fail("DSN__c is not set in the enabled Sentry_Config record");
    allPassed = false;
  }

  // 5. Apex config class
  if (configClassName) {
    const clsFiles = findSfdxFiles(projectRoot, (f) =>
      f.endsWith(`/${configClassName}.cls`)
    );
    check(
      clsFiles.length > 0,
      `Apex config class found: ${configClassName}.cls`,
      `Apex config class not found: ${configClassName}.cls — run \`sentry setup\``
    );
  } else {
    fail("ApexClass__c not set in the enabled Sentry_Config record");
    allPassed = false;
  }

  // 6. Pending instrumentation — delegated to the migration runner
  process.stdout.write("\n");
  process.stdout.write(pc.dim("  Scanning for uninstrumented files…"));
  const violations = await runner.runValidations(projectRoot, {
    capturePrefix: "sentrysdk.Sentry",
    sentryImportPath: "sentrysdk/sentryMixin"
  });
  process.stdout.write("\r" + " ".repeat(50) + "\r");

  if (violations.length === 0) {
    pass("All LWC and Apex entry points are instrumented");
  } else {
    violations.forEach((v) => warn(v.message));
    allPassed = false;
  }

  console.log(
    allPassed
      ? pc.green("\n  All checks passed.\n")
      : pc.red("\n  Some checks failed — see above.\n")
  );
}

module.exports = { validate };
