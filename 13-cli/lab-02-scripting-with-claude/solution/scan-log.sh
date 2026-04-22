#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
LOG="${1:-$SCRIPT_DIR/logs/access.log}"
CANNED="$SCRIPT_DIR/logs/canned-response.json"
REPORT="$SCRIPT_DIR/report.md"

PROMPT='Extract the top error endpoints from this access log. Reply ONLY with JSON in this shape: {"errors":[{"endpoint":"...","count":N,"sample_status":N}]}. No prose, no markdown fences.'

fetch_summary() {
  if command -v claude >/dev/null 2>&1; then
    claude -p "$PROMPT" --output-format json < "$LOG" \
      | python -c "import json, sys; print(json.loads(sys.stdin.read())['result'])"
  else
    cat "$CANNED"
  fi
}

to_markdown() {
  python -c '
import json, sys
data = json.loads(sys.stdin.read())
errors = sorted(data["errors"], key=lambda e: -e["count"])
for e in errors:
    print("- `{}` - {} failures (status {})".format(e["endpoint"], e["count"], e["sample_status"]))
'
}

main() {
  body=$(fetch_summary)
  echo "$body" | to_markdown > "$REPORT"
  echo "wrote $REPORT"
  cat "$REPORT"
}

main "$@"
