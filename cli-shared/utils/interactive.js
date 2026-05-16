"use strict";

const { createPatch } = require("diff");
const pc = require("picocolors");
const prompts = require("prompts");

function colorDiff(patch) {
  return patch
    .split("\n")
    .map((line) => {
      if (line.startsWith("+++") || line.startsWith("---"))
        return pc.bold(line);
      if (line.startsWith("+")) return pc.green(line);
      if (line.startsWith("-")) return pc.red(line);
      if (line.startsWith("@@")) return pc.cyan(line);
      return pc.dim(line);
    })
    .join("\n");
}

async function showDiffAndPrompt(transform) {
  const relPath = transform.path.replace(process.cwd() + "/", "");
  const divider = pc.dim("─".repeat(60));

  console.log("\n" + divider);
  console.log(pc.bold(" " + transform.label));
  console.log(pc.dim(" " + relPath));
  console.log(divider);

  const patch = createPatch(
    relPath,
    transform.oldContent,
    transform.newContent,
    "",
    "",
    { context: 3 }
  );
  const hunks = patch.split("\n").slice(4).join("\n");
  console.log(colorDiff(hunks));

  const { decision } = await prompts(
    {
      type: "select",
      name: "decision",
      message: "Apply this change?",
      choices: [
        { title: pc.green("Yes"), value: "yes" },
        { title: pc.dim("No"), value: "no" },
        { title: pc.yellow("All remaining"), value: "all" },
        { title: pc.red("Quit"), value: "quit" }
      ],
      initial: 0
    },
    { onCancel: () => ({ decision: "quit" }) }
  );

  return decision ?? "quit";
}

module.exports = { colorDiff, showDiffAndPrompt };
