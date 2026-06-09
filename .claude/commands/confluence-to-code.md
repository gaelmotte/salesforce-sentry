Turn a sentrysdk ideation session from Confluence into implemented code.

**Confluence config (do not prompt the user for these):**

- cloudId: `c025c565-eee9-4d65-8753-a9ae6cab6dce`
- Parent page ID: `5358256148`

---

## Phase 1 — Select the session

Use `mcp__claude_ai_Atlassian__getConfluencePageDescendants` to list children of parent page `5358256148`. Exclude any page titled "archive".

**If `$ARGUMENTS` is empty:**
Present the available sessions as a numbered list (title + date). Ask the user to pick one by number or topic before continuing.

**If `$ARGUMENTS` is provided:**
Find the child page whose title best matches the argument. If no clear match, list candidates and ask.

---

## Phase 2 — Read and synthesize

Fetch the selected page with `mcp__claude_ai_Atlassian__getConfluencePage`. Read the **Summary**, **Ideas**, and **Next Steps** sections.

Cross-reference with the codebase: look up the relevant files, classes, and methods mentioned or implied. Use CLAUDE.md as your orientation guide for architecture and file locations.

---

## Phase 3 — Build the implementation plan

Present the plan in this format:

### Context

One paragraph recap of the ideation and what problem it solves.

### Implementation Tasks

Numbered list. Each item must include:

- What to do (behaviour change)
- Exact file path(s) to touch
- Specific class / method to add or modify
- Any constraints, Salesforce platform quirks, or gotchas

### Open Questions / Blockers

Anything unresolved that needs a decision before implementation.

---

## Phase 4 — Confirm and implement

Show the plan and ask: "Shall I implement this?" Wait for confirmation.

Once confirmed, use the **Agent tool** to spawn a subagent. Pass it:

- The full implementation plan from Phase 3
- The relevant file paths discovered during cross-referencing
- This instruction: "Implement the plan exactly as described. Make all necessary file edits. Do not add scope beyond what the plan specifies. Report what you changed when done."

The subagent handles all file edits. Report its summary back to the user when it finishes.
