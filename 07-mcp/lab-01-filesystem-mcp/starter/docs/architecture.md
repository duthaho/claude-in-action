# Architecture

Three tiers:

1. **API** — FastAPI, stateless, behind a load balancer.
2. **Worker** — background jobs over a Redis queue.
3. **Store** — Postgres primary, read replica for heavy queries.

Nothing in this directory is real. It exists for the filesystem MCP lab to have something to expose.
