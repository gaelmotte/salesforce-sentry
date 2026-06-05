"use strict";

/**
 * Ordered registry of all adoption migrations.
 * Each entry exposes { version, transform, validate }.
 * Migrations are applied in array order — add new entries at the end.
 * @type {Array<{ version: string, transform: Function, validate: Function, idempotent?: boolean }>}
 */
const registry = [
  { version: "v0.1", ...require("./v0.1") },
  { version: "v0.2", ...require("./v0.2") }
];

module.exports = registry;
