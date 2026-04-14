# Solution — lab-02-sqlite-mcp

The finished starter has four files plus the built database:

- `build_db.py`, `inspect_db.py` — unchanged helpers from the starter.
- `library.db` — built from `build_db.py`.
- `.mcp.json` — one server entry wiring a SQLite MCP server.
- `queries.md` — five planned queries, two of them using discovery tools.

## Why planning queries beats asking ad-hoc

The temptation with a new MCP server is to wire it up, launch Claude, and start asking questions in natural language. That works, and it's fine for exploration. But when you want to *understand* an MCP surface, write the queries first. Forcing yourself to name the tool for each question exposes three things you wouldn't otherwise notice:

1. **The tool list is an API.** Before you write the queries, the tool list looks like a menu of features. After, it looks like an API surface — each tool has a purpose, and some purposes overlap. `list_tables` and `read_query("SELECT name FROM sqlite_master ...")` return the same data; the former is just a better call.
2. **Dedicated tools beat generic ones.** `describe_table(name)` is strictly better than `read_query("PRAGMA table_info(name);")` for the same reason `GET /users/42` is strictly better than `POST /sql { "query": "SELECT * FROM users WHERE id=42" }`. Dedicated tools are faster to call, safer to expose, and easier for Claude to select.
3. **Write tools are a foothold.** A SQLite MCP server with `write_query` lets Claude modify the database. That might be what you want, or it might be catastrophic. Deciding *before* you wire the server is cheaper than deciding after.

## Why the two-tool split — discovery vs read — matters

Discovery tools (`list_tables`, `describe_table`) are idempotent, side-effect-free, and safe even in a stranger's hand. Read tools (`read_query`) are still side-effect-free for SELECT, but they are *more expressive* — you could read a billion-row join, block the server, get a memory error. In a session where you are drafting queries, you want Claude to start with discovery, plan against the discovered schema, then run the read. That pattern is the MCP-shaped version of "look before you leap".

## Key decisions

- **Server name is `library-db`, not `sqlite`.** MCP server names are displayed in tool lists. A descriptive name ("library-db") beats a generic one ("sqlite") when you have more than one database wired up.
- **`uvx` instead of `pip install`.** `uvx` is like `npx` for Python: it runs a package in an ephemeral venv without installing it globally. This keeps the learner's environment clean.
- **Relative path `./library.db`.** Same reason as lab 01 — relative paths survive a clone to a different directory.
- **Skipped `write_query` and `create_table`.** Not needed for this lab's questions, and leaving them out reduces the attack surface.

## If you got stuck

- **"`uvx` isn't installed."** Install it (`pip install uv`) or swap the config to use `npx` with the JavaScript SQLite MCP package. The verifier accepts either command.
- **"Claude uses `read_query` for everything, including `list_tables`."** That's a real Claude behavior — it tends to over-use the most general tool. You can nudge it by putting "prefer dedicated discovery tools when available" in `CLAUDE.md` or in your prompt.
- **"My query count is four, not five."** Re-read the steps — at least one question must use a discovery tool. If all five use `read_query`, you don't have a discovery question.
