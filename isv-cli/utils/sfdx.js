"use strict";
const shared = require("@salesforce-sentry/cli-shared/utils/sfdx");

function getNamespace(projectRoot) {
  const project = shared.readSfdxProject(projectRoot);
  const ns = project.namespace;
  if (!ns) {
    throw new Error(
      "No namespace set in sfdx-project.json.\n" +
        '  Set "namespace": "yourns" before running vendor.'
    );
  }
  return ns;
}

module.exports = {
  ...shared,
  getNamespace
};
