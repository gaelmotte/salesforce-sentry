"use strict";

const fs = require("fs");
const { XMLParser } = require("fast-xml-parser");

const parser = new XMLParser({ ignoreAttributes: false, parseTagValue: true });

function readMetaXml(filePath) {
  try {
    return parser.parse(fs.readFileSync(filePath, "utf8"));
  } catch {
    return null;
  }
}

module.exports = { readMetaXml };
