# Lab 02 — SQLite MCP

> Section: 07-mcp · Difficulty: beginner · Est: 30 min

## Goal

You wire a SQLite MCP server to a small pre-built `library.db` database and write a `queries.md` file listing the five queries you'd ask Claude to run through the server. The goal is to understand what an MCP server's *tool surface* looks like from the client side — which operations it exposes, what arguments they take, what shape the results come back in — and to practice thinking about MCP in terms of "which tool would I use" rather than "how does the server work internally". By the end you can read an MCP server's tool list and predict which calls Claude will make to satisfy a natural-language request.

## Prerequisites

- Claude Code installed and logged in
- Completed: [lab-01-filesystem-mcp](../lab-01-filesystem-mcp/)

## What you'll build

- A `starter/.mcp.json` with a server entry named `library-db`
- A `starter/queries.md` with at least five natural-language queries, each annotated with the MCP tool Claude would use and the SQL that tool would emit
- No Python or JS code — the database is pre-built and the server is an off-the-shelf MCP server

## Steps

1. Change into the starter and look at the database:
   ```bash
   cd 07-mcp/lab-02-sqlite-mcp/starter
   python inspect_db.py        # prints schema + sample rows
   ```
   The pre-built `library.db` has three tables: `books`, `authors`, `checkouts`. Every `books` row has an `author_id` pointing at `authors`; `checkouts` records who borrowed what and when.
2. Create `.mcp.json`. The server entry should use stdio transport and run a SQLite MCP server. You can use any implementation — the most common one is `mcp-server-sqlite` (an npm package) or the reference Python package. For this lab, use this shape:
   ```json
   {
     "mcpServers": {
       "library-db": {
         "type": "stdio",
         "command": "uvx",
         "args": ["mcp-server-sqlite", "--db-path", "./library.db"]
       }
     }
   }
   ```
   If you prefer Node, swap `"command"` to `"npx"` and use the JS package name. The verifier accepts either.
3. Read the SQLite MCP server's advertised tool list (the README of whichever package you picked; the common ones expose `list_tables`, `describe_table`, `read_query`, and sometimes `write_query`). Write down the five tools in `queries.md` under a `## Tools` section.
4. Under a `## Queries` section in `queries.md`, write five natural-language questions a user might ask about the library DB. For each:
   - State the question in plain English.
   - Name the MCP tool Claude would use.
   - Write the SQL the tool would run.
   Example:
   ```markdown
   ### Q1: "How many books did each author write?"
   Tool: `read_query`
   SQL: `SELECT a.name, COUNT(*) FROM authors a JOIN books b ON b.author_id = a.id GROUP BY a.id;`
   ```
5. Make at least one of your five questions a *tool discovery* question — something where the answer comes from `list_tables` or `describe_table`, not from `read_query`. This forces you to think about non-SQL tools.
6. Launch Claude Code from inside `starter/` (if you have `uvx`/`npx` available) and ask one of your natural-language questions. Confirm Claude uses the tool you predicted.

## Verify

```bash
bash ../../scripts/verify-lab.sh 07-mcp/lab-02-sqlite-mcp
```

The script checks that:

- `.mcp.json` declares a `library-db` stdio server that references `library.db` in its args.
- `queries.md` has both `## Tools` and `## Queries` sections.
- `queries.md` contains at least five `### Q` questions.
- At least one question mentions `list_tables` or `describe_table` (the discovery-tool requirement).
- The SQLite database file `library.db` still exists and still has the three expected tables.

## Solution

See `solution/` for an example `queries.md`, `.mcp.json`, and the rebuilt database. `solution/README.md` walks through why planning queries against an MCP surface is different from planning them against a raw database and how you should use `list_tables` and `describe_table` even when you already know the schema.

## Going further

- Add a second database file `archive.db` and wire it as a second MCP server entry. Which server wins when both advertise `read_query`?
- Experiment with the server's `write_query` tool (if your chosen package exposes it). Should you include write queries in the allow list, or limit the server to read-only?
- Swap the SQLite package for a different implementation and observe which tool names change.

## References

- [Official docs: MCP](https://docs.claude.com/en/docs/claude-code/mcp)
- [MCP server examples](https://modelcontextprotocol.io/examples)
