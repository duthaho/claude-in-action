# Lab 03 — Custom MCP Stub

> Section: 07-mcp · Difficulty: intermediate · Est: 40 min

## Goal

You write a minimal MCP server from scratch. It exposes two tools — `get_quote` (returns a random fortune-style quote from a bundled list) and `echo` (returns whatever string it was given) — and speaks the MCP protocol over stdio. You do **not** use a framework or an SDK. The server is a single Python file that reads JSON-RPC messages from stdin, writes responses to stdout, and handles the three message types (`initialize`, `tools/list`, `tools/call`) you need to be a valid MCP server. By the end you can read the MCP protocol docs and recognize every field, and you have a working stub you can grow into a real server.

## Prerequisites

- Claude Code installed and logged in
- Python 3.10+
- Completed: [lab-01-filesystem-mcp](../lab-01-filesystem-mcp/), [lab-02-sqlite-mcp](../lab-02-sqlite-mcp/)

## What you'll build

- `starter/server.py` — the MCP server. Single file, no dependencies, ~80 lines.
- `starter/test_server.py` — a stdlib `unittest` that drives the server through stdin/stdout and asserts three protocol interactions (initialize, list, call) return the right shape.
- `starter/.mcp.json` — wiring that runs the server under `python server.py`.

## Steps

1. Change into the starter and read the scaffold:
   ```bash
   cd 07-mcp/lab-03-custom-mcp-stub/starter
   cat server.py
   ```
   The scaffold has a working `main()` loop that reads one line per message and writes one line per response. Only the `handle()` function is missing — you fill it in.
2. Read the three message types you need to handle, in the JSON-RPC 2.0 envelope format MCP uses:

   **`initialize`** request:
   ```json
   {"jsonrpc": "2.0", "id": 1, "method": "initialize", "params": {"protocolVersion": "2024-11-05", "capabilities": {}}}
   ```
   Must respond with:
   ```json
   {"jsonrpc": "2.0", "id": 1, "result": {"protocolVersion": "2024-11-05", "capabilities": {"tools": {}}, "serverInfo": {"name": "lab-stub", "version": "0.1.0"}}}
   ```

   **`tools/list`** request:
   ```json
   {"jsonrpc": "2.0", "id": 2, "method": "tools/list"}
   ```
   Must respond with a `result.tools` array containing two tool descriptors — one for `get_quote`, one for `echo`. Each descriptor has `name`, `description`, and `inputSchema` (a JSON schema).

   **`tools/call`** request:
   ```json
   {"jsonrpc": "2.0", "id": 3, "method": "tools/call", "params": {"name": "echo", "arguments": {"text": "hi"}}}
   ```
   Must respond with `result.content` — an array of content parts, where each part is `{"type": "text", "text": "..."}`.
3. Implement `handle()` in `server.py` to route the three methods and return the correct responses.
4. Fill in `QUOTES` at the top of the file with at least three entries. Pick something stable — no randomness involving time — so `test_server.py` can assert the result.
5. Run the tests:
   ```bash
   python -m unittest -v test_server.py
   ```
   All three tests should pass.
6. Wire the server into `.mcp.json`:
   ```json
   {
     "mcpServers": {
       "lab-stub": {
         "type": "stdio",
         "command": "python",
         "args": ["server.py"]
       }
     }
   }
   ```
7. Launch Claude Code from inside `starter/` (optional — verification doesn't require it). Ask Claude *"use the lab-stub server to get a quote"*. It should call `get_quote` through MCP and print the result.

## Verify

```bash
bash ../../scripts/verify-lab.sh 07-mcp/lab-03-custom-mcp-stub
```

The script:

- Runs `python -m unittest -v test_server.py` from the starter — all tests must pass.
- Checks `.mcp.json` has a `lab-stub` stdio server pointing at `python server.py`.
- Checks `server.py` has `handle` defined and handles `initialize`, `tools/list`, `tools/call`.

## Solution

See `solution/` for one acceptable implementation. `solution/README.md` walks through each of the three message types, explains the JSON-RPC envelope, and points out which fields MCP uses and which it inherits from JSON-RPC verbatim.

## Going further

- Add a third tool `add(a, b)` that returns the sum. What does its `inputSchema` look like?
- Handle an unknown `method` by returning a JSON-RPC `error` object instead of silently closing. What error code does the spec require?
- Replace the hand-rolled stdio loop with the official `mcp` Python package. Is the scaffold smaller or larger?

## References

- [MCP spec](https://modelcontextprotocol.io/specification/)
- [Official docs: MCP](https://docs.claude.com/en/docs/claude-code/mcp)
