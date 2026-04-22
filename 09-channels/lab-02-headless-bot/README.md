# Lab 02 — Headless Bot: File-Drop Channel

> Section: 09-channels · Difficulty: intermediate · Est: 35 min

## Goal

You build a tiny shell bot that watches an `inbox/` directory and summarises every file that lands there by piping its content through `claude -p`. Each summary is written to `outbox/<filename>.summary.md`. The bot is idempotent — running it twice never re-summarises a file — and degrades gracefully when `claude` isn't on the `PATH`, so the same script is safe to run in CI. The lesson underneath: you don't need a queue, a daemon, or a framework to turn Claude into an event-driven agent. A `for` loop over a directory is a channel.

## Prerequisites

- Claude Code installed and logged in (optional — the script falls back to a stub if `claude` isn't available)
- Completed: [lab-01-stream-json-consumer](../lab-01-stream-json-consumer/) (recommended — same headless theme)
- Tools: bash

## What you'll build

- `starter/watch-inbox.sh` filled in: skips already-processed files, iterates `inbox/`, calls `claude -p` per file.
- Two output files in `starter/outbox/` after running the bot: one per starter inbox file.

## Steps

1. Read the starter files:
   ```bash
   cd 09-channels/lab-02-headless-bot/starter
   ls inbox
   cat watch-inbox.sh
   ```
   The inbox has two files (a standup note and a feature request). The script has three `TODO` blocks: the idempotency check, the `claude -p` call, and the directory loop.
2. Implement **TODO 1** — the idempotency check. At the top of `process_one`, if the destination file already exists, print `skip <name>` and `return 0`. This is what makes the bot safe to re-run.
3. Implement **TODO 2** — the `claude -p` call. Pipe `$src` into `claude -p "$PROMPT" --output-format text` and redirect stdout into `$dest`. Wrap it in a `command -v claude` check so that if `claude` isn't installed, the script writes a stub line instead of failing. The stub path is what lets `verify.sh` run without an API key.
4. Implement **TODO 3** — the main loop. Use `shopt -s nullglob` so that an empty inbox doesn't iterate over the literal string `inbox/*`. Loop `for f in "$INBOX"/*`; for each regular file, call `process_one "$f"`.
5. Run the bot once:
   ```bash
   bash watch-inbox.sh
   ls outbox
   ```
   You should see two summary files. Open one and check the content — either a real Claude summary or the stub line.
6. Run the bot a second time. It should print `skip ...` for both files and write nothing new.

## Verify

```bash
bash ../../scripts/verify-lab.sh 09-channels/lab-02-headless-bot
```

The script inspects `watch-inbox.sh` for the three required pieces (existence check, `claude -p` call, directory loop), then actually executes the bot against the starter inbox and confirms an `outbox/<name>.summary.md` exists for every inbox file. No API call is needed — the stub fallback carries the script through CI.

## Solution

See `solution/`. `solution/README.md` explains why idempotency is correctness (not optimisation), why the `command -v claude` fallback matters for CI, and when this shell-script pattern should be upgraded to a real queue.

## Going further

- Add a `--watch` mode that loops every 5 seconds instead of running once. Remember to sleep between iterations.
- Hash each inbox file's content and include the hash in the output filename. Now you re-summarise when the content changes, not just when a new file name appears.
- Replace the prompt with something that returns JSON (`--output-format json`) and chain the output through `jq` to extract a single field. Pipe the result to a webhook via `curl`.

## References

- [Official docs: Headless mode](https://docs.claude.com/en/docs/claude-code/headless) — `claude -p`, stdin, output formats
- [Official docs: CLI reference](https://docs.claude.com/en/docs/claude-code/cli-reference) — the full flag list
