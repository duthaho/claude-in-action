# Solution — lab-03-custom-mcp-stub

The finished starter has three files:

- `server.py` — the MCP server. ~90 lines including the tool descriptors.
- `test_server.py` — the protocol tests (unchanged from starter).
- `.mcp.json` — runs `python server.py`.

## Why this works

MCP over stdio is far simpler than the docs make it sound. The full protocol for a trivial server is:

1. **One JSON-RPC message per line on stdin.** JSON-RPC 2.0 envelopes look like `{"jsonrpc": "2.0", "id": N, "method": "...", "params": {...}}`. Requests have an `id`, notifications don't.
2. **One JSON-RPC response per line on stdout.** Responses echo the `id` and carry either a `result` object or an `error` object, never both.
3. **Three methods to implement for a minimum-viable server.** `initialize` tells Claude what protocol version and capabilities the server supports. `tools/list` advertises the tools. `tools/call` actually runs one.

Everything past that is polish. Streaming results, notifications, resources, prompts — all optional. You can write a working MCP server in about 60 lines of stdlib Python.

## Walking through each message type

### `initialize`

The first message the client sends. The server returns its protocol version, its capabilities (a dict of feature flags — `"tools": {}` is enough to advertise "yes I have tools"), and its `serverInfo` (a name and version string shown in the client's server list). You do **not** return the tools themselves here — only the fact that you support tools.

### `tools/list`

The client asks for the list of tools. The server returns an array of tool descriptors. Each descriptor has three fields:

- `name` — what the client uses to invoke the tool
- `description` — shown to the model when deciding which tool to pick
- `inputSchema` — a JSON Schema describing the arguments

The `description` field is the single most important line in a tool descriptor for the same reason the `description` field in a skill is the most important line in a skill (see lab 04-01). It's what the model uses to decide when to reach for the tool.

### `tools/call`

The client sends `params.name` (which tool) and `params.arguments` (a dict matching the tool's `inputSchema`). The server runs the tool and returns a `result.content` array — typically `[{"type": "text", "text": "..."}]` for a text result, but content parts can also be images (`{"type": "image", "data": "...", "mimeType": "..."}`) or resources.

## Why JSON-RPC, specifically

MCP uses JSON-RPC 2.0 because JSON-RPC already solved the "how do I do synchronous and async requests over a duplex channel" problem in 2010, and nobody wanted to re-solve it. The upshot for you:

- Every request has an `id`. Every response echoes it.
- Errors have codes from a standardized list (`-32601` = method not found, `-32602` = invalid params, `-32603` = internal error).
- Notifications (messages with no `id`) don't get a response. You can mostly ignore them for a minimum-viable server.

## Why we hand-roll instead of using the `mcp` package

There's an official `mcp` Python package that wraps all of this in `@tool` decorators. It's a good choice for a real server. For a learning lab, hand-rolling is better: you see the JSON on the wire, you find out what "initialize" actually sends back, and you can read the protocol spec without squinting. Once you understand the protocol, switching to the SDK is a 10-minute port.

## Key decisions

- **`QUOTES[0]`, not `random.choice(QUOTES)`.** The tests need a stable result. In a real server you'd return random quotes. For a test, determinism is cheap and chaos is expensive.
- **Tool descriptors as a module-level constant.** The alternative — building them inside `handle()` — means the descriptors get rebuilt on every `tools/list` call. Module-level is trivially faster and makes it obvious there's one canonical list.
- **`_ok` and `_err` helpers.** Shared envelope construction is better than repeating `{"jsonrpc": "2.0", "id": msg_id, "result": ...}` seven times.
- **Unknown methods return an error.** A silent drop would confuse clients. `-32601` is the right code.

## If you got stuck

- **"The test hangs."** Your server is probably not calling `sys.stdout.flush()` after writing. Line-buffering isn't guaranteed when stdout is a pipe.
- **"I get `internal error: ...` for everything."** Your `handle()` function is raising — look at the exception. Common causes: `KeyError` on a missing `params` field, or `TypeError` from a JSON schema that doesn't match what the test sends.
- **"Tools show up in Claude but don't work."** Your `tools/call` response shape is probably wrong. It must be `{"result": {"content": [{"type": "text", "text": "..."}]}}`, not a bare text string or an object with other field names.
