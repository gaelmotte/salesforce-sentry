"use strict";

const { test, describe } = require("node:test");
const assert = require("node:assert/strict");
const path = require("path");
const fs = require("fs");

const migration = require("../migrations/v0.1");
const { collectApexTransforms } = require("../migrations/v0.1/apex");
const { transformLWCSource } = require("../migrations/v0.1/lwc");

const fixturesDir = path.join(__dirname, "../migrations/v0.1/__fixtures__");

const ENDUSER_OPTS = {
  capturePrefix: "sentrysdk.Sentry",
  sentryImportPath: "sentrysdk/sentryMixin"
};
const ISV_OPTS = {
  capturePrefix: "Sentry",
  sentryImportPath: "c/sentryMixin"
};

// ---------------------------------------------------------------------------
// Apex — @AuraEnabled
// ---------------------------------------------------------------------------
describe("v0.1 Apex — @AuraEnabled", () => {
  test("wraps method in try/catch with AuraHandledException (enduser)", async (t) => {
    const inputPath = path.join(fixturesDir, "apex-aura/input.cls");
    const expected = fs.readFileSync(
      path.join(fixturesDir, "apex-aura/expected.cls"),
      "utf8"
    );
    const transforms = await migration.transform([inputPath], ENDUSER_OPTS);
    assert.equal(transforms.length, 1, "should produce exactly one transform");
    assert.equal(transforms[0].newContent, expected);
  });

  test("uses ISV namespace prefix when capturePrefix is 'Sentry'", async (t) => {
    const inputPath = path.join(fixturesDir, "apex-aura/input.cls");
    const transforms = await migration.transform([inputPath], ISV_OPTS);
    assert.equal(transforms.length, 1);
    assert.ok(
      transforms[0].newContent.includes("Sentry.captureException(e);"),
      "should use Sentry.captureException without namespace"
    );
    assert.ok(
      !transforms[0].newContent.includes("sentrysdk."),
      "should not include sentrysdk namespace"
    );
  });

  test("is idempotent — skips already-instrumented file", async (t) => {
    const expectedPath = path.join(fixturesDir, "apex-aura/expected.cls");
    const transforms = await migration.transform([expectedPath], ENDUSER_OPTS);
    assert.equal(
      transforms.length,
      0,
      "should produce no transforms for already-instrumented file"
    );
  });
});

// ---------------------------------------------------------------------------
// Apex — trigger
// ---------------------------------------------------------------------------
describe("v0.1 Apex — trigger", () => {
  test("wraps trigger body in try/catch with generic catch", async (t) => {
    const inputPath = path.join(fixturesDir, "apex-trigger/input.trigger");
    const expected = fs.readFileSync(
      path.join(fixturesDir, "apex-trigger/expected.trigger"),
      "utf8"
    );
    const transforms = await migration.transform([inputPath], ENDUSER_OPTS);
    assert.equal(transforms.length, 1, "should produce exactly one transform");
    assert.equal(transforms[0].newContent, expected);
  });

  test("is idempotent — skips already-instrumented trigger", async (t) => {
    const expectedPath = path.join(
      fixturesDir,
      "apex-trigger/expected.trigger"
    );
    const transforms = await migration.transform([expectedPath], ENDUSER_OPTS);
    assert.equal(transforms.length, 0);
  });
});

// ---------------------------------------------------------------------------
// LWC — SentryMixin (internal component)
// ---------------------------------------------------------------------------
describe("v0.1 LWC — internal component (SentryMixin)", () => {
  test("adds SentryMixin and import for internal component", (t) => {
    const source = fs.readFileSync(
      path.join(fixturesDir, "lwc/contactCard/contactCard.js"),
      "utf8"
    );
    const expected = fs.readFileSync(
      path.join(fixturesDir, "lwc/contactCard/contactCard.expected.txt"),
      "utf8"
    );
    const result = transformLWCSource(source, false, "sentrysdk/sentryMixin");
    assert.equal(result, expected);
  });

  test("adds SentryBoundaryMixin for exposed component", (t) => {
    const source = fs.readFileSync(
      path.join(fixturesDir, "lwc/accountDashboard/accountDashboard.js"),
      "utf8"
    );
    const expected = fs.readFileSync(
      path.join(
        fixturesDir,
        "lwc/accountDashboard/accountDashboard.expected.txt"
      ),
      "utf8"
    );
    const result = transformLWCSource(source, true, "sentrysdk/sentryMixin");
    assert.equal(result, expected);
  });

  test("uses c/sentryMixin import path for ISV", (t) => {
    const source = fs.readFileSync(
      path.join(fixturesDir, "lwc/contactCard/contactCard.js"),
      "utf8"
    );
    const result = transformLWCSource(source, false, "c/sentryMixin");
    assert.ok(result !== null);
    assert.ok(
      result.includes('"c/sentryMixin"'),
      "should use c/sentryMixin import path"
    );
    assert.ok(
      !result.includes("sentrysdk"),
      "should not use sentrysdk import path"
    );
  });

  test("is idempotent — returns null for already-instrumented source", (t) => {
    const source = `import { LightningElement } from "lwc";
import { SentryMixin, Sentry } from "sentrysdk/sentryMixin";
export default class ContactCard extends SentryMixin(LightningElement, "ContactCard") {}`;
    const result = transformLWCSource(source, false, "sentrysdk/sentryMixin");
    assert.equal(result, null, "should return null when already instrumented");
  });

  test("returns null for source with no LightningElement", (t) => {
    const source = `import { api } from "lwc";
export default class MyUtil {}`;
    const result = transformLWCSource(source, false, "sentrysdk/sentryMixin");
    assert.equal(result, null);
  });
});

// ---------------------------------------------------------------------------
// via migration.transform — full file scan
// ---------------------------------------------------------------------------
describe("v0.1 migration.transform — LWC via file paths", () => {
  test("finds uninstrumented LWC component via file path", async (t) => {
    const jsPath = path.join(fixturesDir, "lwc/contactCard/contactCard.js");
    const transforms = await migration.transform([jsPath], ENDUSER_OPTS);
    assert.equal(
      transforms.length,
      1,
      "should find the uninstrumented LWC file"
    );
    assert.ok(transforms[0].newContent.includes("SentryMixin"));
  });

  test("skips files without a matching .js-meta.xml", async (t) => {
    const noMetaPath = path.join(
      fixturesDir,
      "lwc/noMetaComponent/noMetaComponent.js"
    );
    const transforms = await migration.transform([noMetaPath], ENDUSER_OPTS);
    assert.equal(
      transforms.length,
      0,
      "should skip LWC JS files that have no meta.xml"
    );
  });
});

// ---------------------------------------------------------------------------
// validate
// ---------------------------------------------------------------------------
describe("v0.1 validate", () => {
  test("reports violation for uninstrumented Apex file", async (t) => {
    const inputPath = path.join(fixturesDir, "apex-aura/input.cls");
    const violations = await migration.validate([inputPath], ENDUSER_OPTS);
    assert.equal(violations.length, 1);
    assert.equal(violations[0].filePath, inputPath);
    assert.equal(violations[0].severity, "warn");
  });

  test("reports no violations for already-instrumented Apex file", async (t) => {
    const expectedPath = path.join(fixturesDir, "apex-aura/expected.cls");
    const violations = await migration.validate([expectedPath], ENDUSER_OPTS);
    assert.equal(violations.length, 0);
  });

  test("reports violation for uninstrumented trigger", async (t) => {
    const inputPath = path.join(fixturesDir, "apex-trigger/input.trigger");
    const violations = await migration.validate([inputPath], ENDUSER_OPTS);
    assert.equal(violations.length, 1);
  });

  test("reports no violations when no relevant files are passed", async (t) => {
    const violations = await migration.validate([], ENDUSER_OPTS);
    assert.equal(violations.length, 0);
  });
});
