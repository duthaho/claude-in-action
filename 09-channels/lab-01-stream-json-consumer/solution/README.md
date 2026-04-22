# Solution — lab-01-stream-json-consumer

> Try the steps in the lab's `README.md` first — peek here after.

## What stream-json actually looks like

`claude -p --output-format stream-json` emits one JSON object per line (JSONL). Each line's shape depends on its `type`:

- **`system`** — bookkeeping. `subtype: "init"` carries `session_id`, `model`, and the allow-listed `tools`. There is also a `subtype: "compact_boundary"` if the session was compacted mid-run, which you can ignore.
- **`assistant`** — the model's output. Crucially, this is a *stream* of messages, not a single message — one line per turn in the internal tool-use loop. Each line's `message.content` is an array of content blocks: `type: "text"` carries model text, `type: "tool_use"` carries `{name, input, id}`.
- **`user`** — the synthetic user turn that carries `tool_result` blocks back to the model. You usually don't care about these in a summariser.
- **`result`** — terminal. `result.result` is the canonical final text (equivalent to the last assistant text block). `result.usage` has total tokens. `is_error` tells you whether the run completed successfully.

## Why the parser is line-at-a-time

A live stream may be slow: Claude thinks, calls a tool, waits for the tool, thinks again. If your consumer buffered the whole stream and then parsed JSON, you'd only see results after the run ended. Reading line-by-line means you can *react* to tool-use events as they happen — post to Slack, update a dashboard, kill the run if it loops. The fixture in this lab is an already-captured stream, but the same code works on a live pipe.

## Why we trust `result.result` over "last assistant text"

Both usually contain the same text, but they can diverge:

- If the run ended in an error, `result.is_error === true` and `result.result` holds the error message. The last assistant text block may be stale.
- During tool-use chains, the last assistant content block in the stream can be a `tool_use`, not text. In that case `finalText` from assistant blocks would skip to a text block *before* the tool call, which is misleading.

The consumer in this solution does both: it keeps the last assistant text *and* overwrites with `result.result` when the terminal event arrives. That way it still produces a useful summary if someone Ctrl-C's the stream before `result` fires.

## What this lab doesn't do

Real stream consumers track much more — per-tool latency, error rates, cost per turn, conversation pruning. This one is deliberately minimal: five fields, one function. The goal is to learn the event shape, not to build a production dashboard.
