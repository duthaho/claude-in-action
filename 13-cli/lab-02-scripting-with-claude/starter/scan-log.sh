#!/usr/bin/env bash
# scan-log.sh — feed an access log through `claude -p`, get structured JSON
# back, then post-process into a markdown report.
#
# Pipeline:
#   cat access.log | claude -p "..." --output-format json   # Claude returns JSON
#         │
#         ▼
#   extract .result                                         # strip the envelope
#         │
#         ▼
#   sort by count desc + format as markdown bullets         # post-process
#         │
#         ▼
#   report.md

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
LOG="${1:-$SCRIPT_DIR/logs/access.log}"
CANNED="$SCRIPT_DIR/logs/canned-response.json"
REPORT="$SCRIPT_DIR/report.md"

PROMPT='Extract the top error endpoints from this access log. Reply ONLY with JSON in this shape: {"errors":[{"endpoint":"...","count":N,"sample_status":N}]}. No prose, no markdown fences.'

fetch_summary() {
  # TODO 1: if `claude` is on PATH, pipe "$LOG" through it with the prompt above
  # and --output-format json. The reply is an envelope; print the .result
  # field to stdout.
  #
  # If `claude` is NOT on PATH, print the canned response so the pipeline still
  # works offline for CI.
  #
  # Hint:
  #   claude -p "$PROMPT" --output-format json < "$LOG"
  # and extract .result with python (we don't require jq):
  #   python -c "import json, sys; print(json.loads(sys.stdin.read())['result'])"
  :
}

to_markdown() {
  # TODO 2: read JSON on stdin (the body returned by fetch_summary), sort
  # errors by count descending, and print one bullet per error:
  #
  #   - `/api/payments` - 4 failures (status 500)
  #
  # Hint: use `python -c` with a short script; data = json.load(sys.stdin).
  :
}

main() {
  body=$(fetch_summary)
  echo "$body" | to_markdown > "$REPORT"
  echo "wrote $REPORT"
  cat "$REPORT"
}

main "$@"
