#!/usr/bin/env node
// Consume a `claude -p --output-format stream-json` stream on stdin and
// print a summary when the stream ends.
//
// Expected summary format (one line per field, in this exact order):
//   Session: <session_id>
//   Model: <model>
//   Tools used: <count>  <Tool1>,<Tool2>,...
//   Final: <final assistant text>
//   Tokens: <input>/<output>
//
// Event shape reference (JSONL — one JSON object per line):
//   {"type": "system", "subtype": "init", "session_id": "...", "model": "...", "tools": [...]}
//   {"type": "assistant", "message": {"content": [{"type": "text"|"tool_use", ...}], "usage": {...}}}
//   {"type": "user", "message": {"content": [{"type": "tool_result", ...}]}}
//   {"type": "result", "subtype": "success", "result": "...", "usage": {...}}
//
// Run it:
//   node consumer.js < fixtures/events.jsonl
// Or against a live session:
//   claude -p "your prompt" --output-format stream-json | node consumer.js

const readline = require("readline");

const state = {
  sessionId: null,
  model: null,
  toolsUsed: [], // names in the order they were invoked
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
    // TODO: malformed lines shouldn't crash the consumer — log and skip.
    return;
  }

  // TODO: branch on event.type and update `state`.
  //
  //   system/init   → sessionId, model
  //   assistant     → walk message.content; tool_use → toolsUsed.push(name)
  //                   last text block in stream becomes finalText
  //                   (result.result is more reliable — see below)
  //   result        → finalText = event.result; usage → totals
  //
  // Ignore user/tool_result events here.
});

rl.on("close", () => {
  // TODO: print the 5-line summary described at the top of the file.
});
