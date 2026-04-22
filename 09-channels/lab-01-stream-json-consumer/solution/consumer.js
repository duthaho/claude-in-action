#!/usr/bin/env node
const readline = require("readline");

const state = {
  sessionId: null,
  model: null,
  toolsUsed: [],
  finalText: null,
  inputTokens: 0,
  outputTokens: 0,
};

const rl = readline.createInterface({ input: process.stdin });

rl.on("line", (line) => {
  if (!line.trim()) return;
  let event;
  try {
    event = JSON.parse(line);
  } catch {
    console.error("skipped malformed line:", line.slice(0, 80));
    return;
  }

  switch (event.type) {
    case "system":
      if (event.subtype === "init") {
        state.sessionId = event.session_id || null;
        state.model = event.model || null;
      }
      break;

    case "assistant": {
      const content = event.message?.content || [];
      for (const block of content) {
        if (block.type === "tool_use" && block.name) {
          state.toolsUsed.push(block.name);
        } else if (block.type === "text" && block.text) {
          state.finalText = block.text;
        }
      }
      break;
    }

    case "result":
      if (typeof event.result === "string") {
        state.finalText = event.result;
      }
      if (event.usage) {
        state.inputTokens = event.usage.input_tokens || 0;
        state.outputTokens = event.usage.output_tokens || 0;
      }
      break;
  }
});

rl.on("close", () => {
  console.log(`Session: ${state.sessionId ?? "unknown"}`);
  console.log(`Model: ${state.model ?? "unknown"}`);
  console.log(
    `Tools used: ${state.toolsUsed.length}  ${state.toolsUsed.join(",")}`
  );
  console.log(`Final: ${state.finalText ?? ""}`);
  console.log(`Tokens: ${state.inputTokens}/${state.outputTokens}`);
});
