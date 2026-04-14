# Lab 01 — Filesystem MCP

> Section: 07-mcp · Difficulty: beginner · Est: 20 min

## Goal

You write a `.mcp.json` file that wires the official filesystem MCP server into Claude Code, scoped to a single docs directory. When the config is correct, launching Claude Code from the lab's starter gives the model a new set of tools — `list_directory`, `read_file`, etc. — that only work inside the docs tree. The config itself is the artifact of this lab; you don't have to actually boot the MCP process to know your config is right. By the end you know what a server entry looks like, the difference between stdio and HTTP transports, and how to scope a filesystem server so it cannot wander out of the directory you meant.

## Prerequisites

- Claude Code installed and logged in
- Completed: [lab-01-settings-tour](../../03-configuration-and-permissions/lab-01-settings-tour/)

## What you'll build

- A `starter/.mcp.json` declaring one server named `docs-fs`
- The server uses the stdio transport and runs `npx @modelcontextprotocol/server-filesystem`
- The server's `args` array scopes it to `./docs` so it cannot read files outside that tree
- Verification checks the JSON shape without actually running `npx`

## Steps

1. Change into the lab starter and inspect the fake docs tree:
   ```bash
   cd 07-mcp/lab-01-filesystem-mcp/starter
   ls -la docs/
   ```
   There are a handful of sample files — `api.md`, `architecture.md`, `README.md`. These are what the MCP server will expose.
2. Create `.mcp.json` at the project root (next to `docs/`, not inside it). It needs this shape:
   ```json
   {
     "mcpServers": {
       "docs-fs": {
         "type": "stdio",
         "command": "npx",
         "args": ["-y", "@modelcontextprotocol/server-filesystem", "./docs"]
       }
     }
   }
   ```
   Replace the values if you need to, but keep the server name `docs-fs` (the verifier looks for it).
3. Think about scoping. The last element in `args` — `"./docs"` — is the *root* the server is allowed to operate on. If you wrote `"."` there instead, the server would expose the whole starter directory, including the `secrets/` subdirectory. Re-read your config with that in mind.
4. Add a second, broader server entry called `home-fs` that does expose `"."` (the whole starter). Name it differently so you can compare them.
5. Launch Claude Code from inside `starter/`. (If you don't have `npx` available, skip this step — the verifier doesn't require a working process.) Ask *"what MCP servers are available?"* and confirm both `docs-fs` and `home-fs` are listed.
6. Delete the `home-fs` entry. You almost never want a filesystem server scoped to the whole repo — you want it scoped to the specific subtree you're exposing.

## Verify

```bash
bash ../../scripts/verify-lab.sh 07-mcp/lab-01-filesystem-mcp
```

The script checks:

- `starter/.mcp.json` exists and parses as valid JSON.
- It has a `mcpServers.docs-fs` entry.
- `docs-fs.type` is `"stdio"` (or omitted, which defaults to stdio).
- `docs-fs.command` is `"npx"` or a similar command invocation.
- `docs-fs.args` contains `./docs` (the scope).
- The broader `home-fs` entry is **not** present (step 6 must have been done).

## Solution

See `solution/` for the final two files: `.mcp.json` with just the `docs-fs` entry, and the untouched `docs/` tree. `solution/README.md` explains why the filesystem server takes a root argument, what the alternatives to stdio transport look like, and why exposing the whole repo is an anti-pattern.

## Going further

- Add a third server entry using the HTTP transport (`"type": "http"`, `"url": "http://localhost:3000"`). Which fields are required/forbidden compared to stdio?
- Add an `env` block to the `docs-fs` entry passing `READ_ONLY=true` to the child process. Check whether the server actually honors this variable.
- Move `.mcp.json` to `~/.claude/.mcp.json` (user scope). What changes — is the server now available in every repo?

## References

- [Official docs: MCP](https://docs.claude.com/en/docs/claude-code/mcp)
- [MCP filesystem server](https://github.com/modelcontextprotocol/servers/tree/main/src/filesystem)
