# Section 09 — Channels

> Status: **coming in v2.0**

Channels are event-driven push mechanisms that let external systems (Telegram, Discord, iMessage) deliver events into a Claude Code session — a new paradigm distinct from hooks or MCP. Planned labs:

- `lab-01-stream-json-consumer` — pipe `claude -p --output-format stream-json` into a Node consumer script.
- `lab-02-headless-bot` — a shell script that runs Claude on every new file dropped into an `inbox/` directory.

## References

- [Official docs: Channels](https://docs.claude.com/en/docs/claude-code/channels)
