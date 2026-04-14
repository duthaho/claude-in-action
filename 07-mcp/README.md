# Section 07 — MCP

The **Model Context Protocol** is how Claude Code plugs into external tools with a standard interface. An MCP server is a program that exposes a set of tools (read a file, query a database, call an API, whatever); Claude Code is an MCP *client* that lists those tools, shows them to the model, and proxies calls. Once you understand MCP, connecting Claude to anything — a filesystem, a database, a third-party API, your own in-house service — becomes a single config file.

The labs in this section stay offline and self-contained. You will configure Claude to connect to a filesystem server, query a SQLite database through an MCP interface, and write your own minimal MCP server stub that returns static data. Verification does **not** require running a real MCP process — the checks inspect configuration files and code shapes. The point is to learn the MCP surface, not to fight with `npx` installation.

## Learning objectives

After finishing these labs, you can:

- Author a `.mcp.json` config that wires a named server to Claude Code
- Choose between the three common MCP transports (stdio, HTTP, SSE) based on the situation
- Read a vendor-provided MCP server's tool list and predict which calls will show up in Claude
- Sketch a minimal MCP server stub in Python and explain how Claude discovers its tools

## Labs

| # | Lab | Difficulty | Est. |
|---|---|---|---|
| 01 | [lab-01-filesystem-mcp](lab-01-filesystem-mcp/) | beginner | 20 min |
| 02 | [lab-02-sqlite-mcp](lab-02-sqlite-mcp/) | beginner | 30 min |
| 03 | [lab-03-custom-mcp-stub](lab-03-custom-mcp-stub/) | intermediate | 40 min |

## References

- [Official docs: MCP](https://docs.claude.com/en/docs/claude-code/mcp)
- [Model Context Protocol spec](https://modelcontextprotocol.io/)
