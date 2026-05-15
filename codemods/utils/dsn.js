"use strict";

// https://<publicKey>@<host>/<projectId>
function parseDSN(dsn) {
  if (!dsn || typeof dsn !== "string") return { valid: false };
  const match = dsn.match(/^https?:\/\/([^@]+)@([^/]+)\/(\d+)$/);
  if (!match) return { valid: false };
  const [, publicKey, host, projectId] = match;
  return {
    valid: true,
    publicKey,
    host,
    projectId,
    remoteUrl: `https://${host}`
  };
}

function validateDSN(dsn) {
  const parsed = parseDSN(dsn);
  if (!parsed.valid)
    return "Invalid DSN — expected https://<key>@<host>/<projectId>";
  return null;
}

module.exports = { parseDSN, validateDSN };
