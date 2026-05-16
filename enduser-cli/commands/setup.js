"use strict";

const path = require("path");
const fs = require("fs");
const prompts = require("prompts");
const pc = require("picocolors");
const { readSfdxProject } = require("@salesforce-sentry/cli-shared/utils/sfdx");
const {
  parseDSN,
  validateDSN
} = require("@salesforce-sentry/cli-shared/utils/dsn");

const INTEGRATIONS = [
  {
    title:
      "SentryUserIntegration        — Captures user identity and permission sets",
    value: "SentryUserIntegration",
    selected: true
  },
  {
    title:
      "SentryStacktraceIntegration  — Parses Apex stack traces into structured frames",
    value: "SentryStacktraceIntegration",
    selected: true
  },
  {
    title:
      "SentryFlowFaultIntegration   — Adds Flow interview context to events",
    value: "SentryFlowFaultIntegration",
    selected: true
  },
  {
    title:
      "SentryLWCErrorIntegration    — Adds LWC component stack to captured errors",
    value: "SentryLWCErrorIntegration",
    selected: true
  },
  {
    title:
      "SentryDebugLogsIntegration   — Parses Apex debug logs via Tooling API (enduser package only)",
    value: "SentryDebugLogsIntegration",
    selected: false
  }
];

function buildApexClass(className, integrations) {
  const items = integrations.map(
    (i, idx) =>
      `      new sentrysdk.${i}()` + (idx < integrations.length - 1 ? "," : "")
  );
  return [
    `public with sharing class ${className} extends sentrysdk.SentryConfig {`,
    `  public override List<sentrysdk.ISentryIntegration> getIntegrations() {`,
    `    return new List<sentrysdk.ISentryIntegration>{`,
    ...items,
    `    };`,
    `  }`,
    `}`,
    ""
  ].join("\n");
}

function buildApexMeta(apiVersion) {
  return [
    `<?xml version="1.0" encoding="UTF-8"?>`,
    `<ApexClass xmlns="http://soap.sforce.com/2006/04/metadata">`,
    `    <apiVersion>${apiVersion}</apiVersion>`,
    `    <status>Active</status>`,
    `</ApexClass>`,
    ""
  ].join("\n");
}

function buildCustomMetadata(className, dsn, sampling) {
  const samplingValue = parseFloat(sampling).toFixed(1);
  return [
    `<?xml version="1.0" encoding="UTF-8" ?>`,
    `<CustomMetadata`,
    `  xmlns="http://soap.sforce.com/2006/04/metadata"`,
    `  xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"`,
    `  xmlns:xsd="http://www.w3.org/2001/XMLSchema"`,
    `>`,
    `    <label>Default</label>`,
    `    <protected>false</protected>`,
    `    <values>`,
    `        <field>sentrysdk__ApexClass__c</field>`,
    `        <value xsi:type="xsd:string">${className}</value>`,
    `    </values>`,
    `    <values>`,
    `        <field>sentrysdk__DSN__c</field>`,
    `        <value xsi:type="xsd:string">${dsn}</value>`,
    `    </values>`,
    `    <values>`,
    `        <field>sentrysdk__Enabled__c</field>`,
    `        <value xsi:type="xsd:boolean">true</value>`,
    `    </values>`,
    `    <values>`,
    `        <field>sentrysdk__Sampling__c</field>`,
    `        <value xsi:type="xsd:double">${samplingValue}</value>`,
    `    </values>`,
    `</CustomMetadata>`,
    ""
  ].join("\n");
}

function buildRemoteSite(remoteUrl) {
  return [
    `<?xml version="1.0" encoding="UTF-8" ?>`,
    `<RemoteSiteSetting xmlns="http://soap.sforce.com/2006/04/metadata">`,
    `    <disableProtocolSecurity>false</disableProtocolSecurity>`,
    `    <isActive>true</isActive>`,
    `    <url>${remoteUrl}</url>`,
    `</RemoteSiteSetting>`,
    ""
  ].join("\n");
}

async function setup(projectArg) {
  const projectRoot = projectArg ? path.resolve(projectArg) : process.cwd();

  if (!fs.existsSync(projectRoot)) {
    console.error(pc.red(`Path not found: ${projectRoot}`));
    process.exit(1);
  }

  let sfdxProject;
  try {
    sfdxProject = readSfdxProject(projectRoot);
  } catch (e) {
    console.error(pc.red(e.message));
    process.exit(1);
  }

  const defaultDirEntry =
    sfdxProject.packageDirectories?.find((d) => d.default) ??
    sfdxProject.packageDirectories?.[0];
  if (!defaultDirEntry) {
    console.error(pc.red("No packageDirectories found in sfdx-project.json"));
    process.exit(1);
  }

  const apiVersion = sfdxProject.sourceApiVersion ?? "61.0";

  console.log(pc.bold("\nSalesforce Sentry — Setup Wizard"));
  console.log(`Project: ${pc.cyan(projectRoot)}\n`);

  const answers = await prompts(
    [
      {
        type: "text",
        name: "dsn",
        message: "Sentry DSN",
        validate: (v) => validateDSN(v) ?? true
      },
      {
        type: "text",
        name: "className",
        message: "Apex config class name",
        initial: "MySentryConfig",
        validate: (v) =>
          /^[A-Za-z][A-Za-z0-9_]*$/.test(v)
            ? true
            : "Must be a valid Apex identifier"
      },
      {
        type: "number",
        name: "sampling",
        message: "Sampling rate (0–100)",
        initial: 100,
        validate: (v) =>
          v >= 0 && v <= 100 ? true : "Must be between 0 and 100"
      },
      {
        type: "multiselect",
        name: "integrations",
        message: "Integrations to enable",
        choices: INTEGRATIONS,
        hint: "- Space to select. Return to submit",
        instructions: false
      }
    ],
    { onCancel: () => process.exit(0) }
  );

  if (!answers.dsn) process.exit(0);

  const { dsn, className, sampling, integrations } = answers;
  const { remoteUrl } = parseDSN(dsn);

  const baseDir = path.join(
    projectRoot,
    defaultDirEntry.path,
    "main",
    "default"
  );
  const classesDir = path.join(baseDir, "classes");
  const metadataDir = path.join(baseDir, "customMetadata");
  const remoteSiteDir = path.join(baseDir, "remoteSiteSettings");

  const files = [
    {
      path: path.join(classesDir, `${className}.cls`),
      content: buildApexClass(className, integrations),
      label: `${className}.cls`
    },
    {
      path: path.join(classesDir, `${className}.cls-meta.xml`),
      content: buildApexMeta(apiVersion),
      label: `${className}.cls-meta.xml`
    },
    {
      path: path.join(
        metadataDir,
        "sentrysdk__Sentry_Config.Default.md-meta.xml"
      ),
      content: buildCustomMetadata(className, dsn, sampling),
      label: "sentrysdk__Sentry_Config.Default.md-meta.xml"
    },
    {
      path: path.join(remoteSiteDir, "Sentry.remoteSite-meta.xml"),
      content: buildRemoteSite(remoteUrl),
      label: "Sentry.remoteSite-meta.xml"
    }
  ];

  console.log("\n" + pc.bold("Files to create:"));
  for (const f of files) {
    const exists = fs.existsSync(f.path);
    console.log(
      `  ${exists ? pc.yellow("~ overwrite") : pc.green("+ create  ")}  ${
        f.label
      }`
    );
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

  for (const f of files) {
    fs.mkdirSync(path.dirname(f.path), { recursive: true });
    fs.writeFileSync(f.path, f.content, "utf8");
  }

  console.log(pc.green("\n✓ Done."));
  console.log(pc.dim("  Deploy to your org: sf project deploy start\n"));
}

module.exports = { setup };
