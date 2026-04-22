# Lab 01 — Consume a stream-json Channel

> Section: 09-channels · Difficulty: intermediate · Est: 30 min

## Goal

You write a Node script that consumes the JSONL stream produced by `claude -p --output-format stream-json` and prints a five-line summary: session id, model, tools invoked, final text, token totals. The lab ships a captured stream as `fixtures/events.jsonl` so you can build and test the consumer offline — once it works on the fixture, the same code works against a live `claude -p` pipe. This is the foundational pattern behind every Claude-Code-as-a-channel integration: a process reads JSONL events, reacts to each, and emits something downstream.

## Prerequisites

- Claude Code installed and logged in
- Completed: [lab-01-cli-flags-tour](../../13-cli/lab-01-cli-flags-tour/) (optional — helps to have seen `claude -p` before)
- Tools: `node` ≥ 18 on `PATH`

## What you'll build

- `starter/consumer.js` filled in so it parses each JSONL event and tracks state.
- Five-line summary output when run against `fixtures/events.jsonl`.

## Steps

1. Change into the starter and run the stub once to see what it prints:
   ```bash
   cd 09-channels/lab-01-stream-json-consumer/starter
   node consumer.js < fixtures/events.jsonl
   ```
   The stub parses every line but never updates state, so you get an empty summary. That's the starting point.
2. Open `fixtures/events.jsonl`. Every line is one event. Find each of the four `type` values: `system`, `assistant`, `user`, `result`. Read the top comment in `consumer.js` for the expected shape — the fixture matches it exactly.
3. Implement the `rl.on("line")` branch for `type === "system"`. Capture `session_id` and `model` into `state` when `subtype === "init"`.
4. Implement the branch for `type === "assistant"`. Walk `event.message.content`; for each block whose `type === "tool_use"`, push `block.name` onto `state.toolsUsed`. For each block whose `type === "text"`, set `state.finalText = block.text`. You're keeping the *last* text block you saw.
5. Implement the branch for `type === "result"`. Overwrite `state.finalText` from `event.result` (the canonical final text — the solution README explains why this is better than trusting the last assistant text). Copy `event.usage.input_tokens` / `output_tokens` into `state`.
6. Implement `rl.on("close")`. Print the five lines exactly as documented at the top of `consumer.js`:
   ```
   Session: <session_id>
   Model: <model>
   Tools used: <count>  <Tool1>,<Tool2>,...
   Final: <final assistant text>
   Tokens: <input>/<output>
   ```
7. Run the consumer again against the fixture:
   ```bash
   node consumer.js < fixtures/events.jsonl
   ```
   You should see `Session: demo-session-1`, `Tools used: 2  Glob,Read`, and `Tokens: 680/92`.

## Verify

```bash
bash ../../scripts/verify-lab.sh 09-channels/lab-01-stream-json-consumer
```

The script pipes `fixtures/events.jsonl` into your `consumer.js` and checks the five summary lines against expected values. It also greps your source for the required event-type branches so a cheating one-shot print won't pass.

## Solution

See `solution/`. `solution/README.md` explains the event schema in detail, why `result.result` is more reliable than the last assistant text block, and where this pattern leads in production (Slack bots, dashboards, kill-switches).

## Going further

- Add per-tool latency. Each `tool_use` and its corresponding `tool_result` share a `tool_use_id` — time the gap between them.
- Drop the fixture and drive the consumer from a live pipe: `claude -p "list files in cwd" --output-format stream-json | node consumer.js`. What changes about how events arrive?
- Emit your summary as JSON instead of five lines, and pipe it into `jq` — now your consumer is a reusable building block.

## References

- [Official docs: CLI reference](https://docs.claude.com/en/docs/claude-code/cli-reference) — `--output-format stream-json`
- [Official docs: Headless mode](https://docs.claude.com/en/docs/claude-code/headless) — `claude -p` from scripts
- [Official docs: SDK overview](https://docs.claude.com/en/docs/claude-code/sdk) — when to graduate from shell piping to a real SDK integration
