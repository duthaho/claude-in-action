# Lab 02 — Scripting with Claude: Log → Report Pipeline

> Section: 13-cli · Difficulty: intermediate · Est: 35 min

## Goal

You build a bash pipeline that reads an access log, asks `claude -p` for a structured JSON summary of the top error endpoints, strips the JSON envelope, post-processes the result in Python, and writes `report.md`. The starter ships a real-looking log file and a canned response so the pipeline works end-to-end offline — no API key needed — and the same script hits a real Claude when one's available. Two-stage pipelines of this shape (structured in, structured out, transform downstream) are how you get Claude into a production workflow without inventing a framework.

## Prerequisites

- Claude Code installed and logged in (optional — the script falls back to a canned response when `claude` isn't available)
- Completed: [lab-01-cli-flags-tour](../lab-01-cli-flags-tour/)
- Tools: bash, `python` ≥ 3.9

## What you'll build

- `starter/scan-log.sh` with both TODOs filled in: `fetch_summary` calls Claude (or uses the canned fallback), `to_markdown` transforms the JSON into a bulleted markdown report.
- `starter/report.md` produced when you run the script — three bullets, one per error endpoint, sorted by count descending.

## Steps

1. Read the starter files:
   ```bash
   cd 13-cli/lab-02-scripting-with-claude/starter
   cat logs/access.log          # the input — 18 real-looking requests
   cat logs/canned-response.json # the fallback Claude "reply" — already JSON
   cat scan-log.sh              # your pipeline with two TODOs
   ```
2. Fill in **TODO 1** — `fetch_summary`. Branch on `command -v claude`. If `claude` is available, run:
   ```bash
   claude -p "$PROMPT" --output-format json < "$LOG" \
     | python -c "import json, sys; print(json.loads(sys.stdin.read())['result'])"
   ```
   The second half strips the envelope (`--output-format json` wraps the reply in `{"type":"result","result":"...","usage":{...}}`). If `claude` is missing, `cat "$CANNED"` instead. Either way, `fetch_summary` prints JSON to stdout.
3. Fill in **TODO 2** — `to_markdown`. Read JSON on stdin, sort `errors` by count descending, print one bullet per error:
   ```
   - `/api/payments` - 4 failures (status 500)
   ```
   A short `python -c` script is the cleanest approach; see the solution if stuck.
4. Run the pipeline:
   ```bash
   bash scan-log.sh
   ```
   You should see three bullets — payments (4), search (4), checkout (3) — written to `report.md` and echoed to stdout.
5. Open `report.md` and confirm the bullets are sorted by count descending.

## Verify

```bash
bash ../../scripts/verify-lab.sh 13-cli/lab-02-scripting-with-claude
```

The script executes `scan-log.sh` against the starter log (via the canned-response fallback so no API key is needed), then grep-checks `report.md` for the three expected endpoint bullets in the right order.

## Solution

See `solution/scan-log.sh` for a complete pipeline and `solution/README.md` for three explanations: why structured JSON in and out, why a canned-response fallback is non-negotiable for CI-testable pipelines, and when to graduate from bash + python to a real SDK script.

## Going further

- Swap the prompt so Claude returns *severity-weighted* rankings — e.g., 5xx counts more than 429. The canned-response file will need updating too.
- Add a `--since <ISO-timestamp>` argument that trims the log before passing it to Claude.
- Chain a second `claude -p` call that takes the bullet list and writes a paragraph-length incident summary suitable for Slack.

## References

- [Official docs: Headless mode](https://docs.claude.com/en/docs/claude-code/headless) — `claude -p` and `--output-format`
- [Official docs: CLI reference](https://docs.claude.com/en/docs/claude-code/cli-reference) — the envelope shape of `--output-format json`
