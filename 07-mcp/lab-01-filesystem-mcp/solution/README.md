# Solution — lab-01-filesystem-mcp

The finished starter has one new file: `.mcp.json`. It declares exactly one server (`docs-fs`) using the stdio transport, with its scope argument set to `./docs`.

## Why this works

An MCP server is a separate program that exposes a set of tools over a well-defined protocol. When Claude Code starts, it reads `.mcp.json`, looks at each `mcpServers` entry, and — for stdio servers — launches the child process and holds an open pipe to it. When you later use a tool from that server, Claude writes a request over the pipe and reads the response. Everything past the config file is Claude's problem, not yours.

The filesystem server is the best example for a first MCP lab because it's well-known, widely installed, and takes a single argument that completely determines what it can see: the root directory. Give it `./docs` and it can read, write, list, and search inside `docs/` — but `../secrets/api_key.txt` is invisible to it, because the server refuses paths outside its root at the protocol level. This is enforced by the server, not by Claude's permission system — two different mechanisms doing similar jobs at different layers.

## Why stdio, and when you'd pick something else

MCP has three common transports:

- **stdio** — the server is a child process; requests go over its stdin and responses come back on its stdout. Simplest to set up, no network, no ports, no auth. Right for local tools (filesystem, local git, local databases).
- **http** — the server is a running HTTP service at some URL. Right for hosted services (a shared team database, a company API gateway).
- **sse** — server-sent events, an HTTP variant optimized for streaming. Right for servers that push updates without being polled.

Rule of thumb: if the thing you're connecting to runs on your machine, use stdio. If it runs elsewhere, use http.

## Why exposing the whole repo is an anti-pattern

The tempting `"args": ["-y", "@modelcontextprotocol/server-filesystem", "."]` does work — Claude gets filesystem tools that can touch every file in the repo. But the point of MCP is to give the model a *narrower* set of capabilities than it already has via its built-in `Read`/`Edit` tools. Exposing the whole repo through MCP is worse than useless: it adds a new layer of tools that duplicate the built-ins, pollutes the tool list, and doesn't constrain anything.

If you're going to use a filesystem MCP server, pick a narrow root. If you want the whole repo, just use Claude's built-in filesystem tools instead.

## Key decisions

- **`"-y"` as the first arg.** That's `npx`'s "yes, auto-install if needed" flag. Without it, a first run might prompt and hang.
- **`@modelcontextprotocol/server-filesystem`** — the official package name. Other community servers use different names.
- **Relative path `./docs`** — because the MCP server is launched with the project dir as cwd, a relative path resolves to what you want. An absolute path would work too but breaks when a collaborator clones the repo to a different location.

## If you got stuck

- **"Claude says the server failed to start."** Missing `npx` or missing the official server package. Either install them or skip the actual launch — the lab's verification doesn't require a working process, only a correct config.
- **"The server sees files outside `./docs`."** You almost certainly put `"."` or `/path/to/repo` in the args instead of `"./docs"`. Re-read step 2.
- **"My JSON doesn't parse."** Trailing comma after the last `args` entry. JSON doesn't allow them.
