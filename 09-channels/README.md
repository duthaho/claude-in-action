# Section 09 — Channels

> Status: **v2.0 — built**

A **channel** is any way of getting events into or out of a Claude Code session without sitting in front of the TUI. The two primary shapes: *out* (consume the JSONL stream Claude emits with `--output-format stream-json`) and *in* (trigger Claude from an external event like a new file in a directory). Same underlying `claude -p` binary; different surrounding pipe shape.

## Learning objectives

After this section you can:

- Parse `claude -p --output-format stream-json` line by line and extract session, tools, and tokens.
- Write a headless bot that runs Claude on every file dropped into an `inbox/` directory, safely and idempotently.
- Choose between a shell-script channel and graduating to a real SDK integration.

## Labs

- [lab-01-stream-json-consumer](lab-01-stream-json-consumer/) — intermediate, ~30 min — a Node consumer that turns Claude's JSONL event stream into a five-line summary.
- [lab-02-headless-bot](lab-02-headless-bot/) — intermediate, ~35 min — a shell bot that summarises every file in `inbox/` into `outbox/`, idempotent on re-run.

## References

- [Official docs: Headless mode](https://docs.claude.com/en/docs/claude-code/headless)
- [Official docs: CLI reference](https://docs.claude.com/en/docs/claude-code/cli-reference)
