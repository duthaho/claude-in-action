# Solution — lab-02-headless-bot

> Try the steps in the lab's `README.md` first — peek here after.

## The headless-bot pattern

The shape is dumb on purpose: a directory you drop files into, another directory summaries land in, and a small shell script that maps one to the other. No queue, no daemon, no lock file. You can reason about the whole thing in thirty seconds, and when it breaks — when `claude -p` times out, when the inbox file is binary, when two runs race — you can fix it in thirty more.

This pattern scales further than it looks. Swap `inbox/` for an S3 bucket + `aws s3 cp`. Swap the summariser for a code-review prompt and point it at PR diffs. Swap the output for a Slack webhook POST. The *shape* stays identical: discrete inputs → stateless transformation → durable outputs.

## Why idempotency matters more than you think

Re-running the bot should be free. If `outbox/feature-request.md.summary.md` exists, skip. This isn't optimisation — it's correctness. Without it:

- A crash mid-run, followed by restart, silently double-charges tokens for every file.
- A human debugging the script runs it three times while inspecting output; every run costs money.
- If you ever put this behind cron, every tick re-summarises the whole inbox.

The cheapest idempotency check is "does the output file exist?" If you want stronger guarantees — "has the *content* changed since I last summarised?" — hash the input and include the hash in the output path. But that's a second lab.

## Why the claude-availability fallback

The `if command -v claude` branch exists so the script is **testable in CI without a key**. Most headless pipelines you'll build need CI coverage; requiring a live Claude call in every test run means every engineer needs a key, every CI runner needs a secret, and every test is slow and rate-limited. A stub branch means `verify.sh` can run the whole flow offline, against a real filesystem, with zero cost.

## When to graduate from a shell script

- When you need retries with backoff. Shell `until` loops work but get ugly fast.
- When you need to fan out — ten workers pulling from the same inbox. You'll want a real queue.
- When you need observability — p95 latency, cost per file, error rates. A one-line `echo` log doesn't cut it.

Until then, the shell script is the right abstraction. The point of this lab is that you *don't* need Kafka to get Claude reacting to events — a `for` loop, stdin, and a well-named output file are sometimes the whole system.
