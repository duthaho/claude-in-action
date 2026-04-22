#!/usr/bin/env bash
set -euo pipefail

LAB_DIR="$(cd "$(dirname "$0")" && pwd)"
STARTER="$LAB_DIR/starter"
SCRIPT="$STARTER/scan-log.sh"
LOG="$STARTER/logs/access.log"
CANNED="$STARTER/logs/canned-response.json"
REPORT="$STARTER/report.md"

fail=0

for f in "$SCRIPT" "$LOG" "$CANNED"; do
  if [[ ! -f "$f" ]]; then
    echo "FAIL: expected $f to exist"
    exit 1
  fi
done

if ! command -v python >/dev/null 2>&1; then
  echo "FAIL: python is required to verify this lab"
  exit 2
fi

# Shape checks — code (not comments) must invoke claude -p with JSON output
# and must call python on stdin for transformation.
CODE=$(grep -v '^[[:space:]]*#' "$SCRIPT" || true)

if ! echo "$CODE" | grep -qE 'claude -p' ; then
  echo "FAIL: scan-log.sh must invoke 'claude -p' in a code line (not only in comments)"
  fail=1
fi

if ! echo "$CODE" | grep -qE -- '--output-format[[:space:]]+json' ; then
  echo "FAIL: scan-log.sh must use --output-format json so the reply is parseable"
  fail=1
fi

if ! echo "$CODE" | grep -qE 'command -v claude' ; then
  echo "FAIL: scan-log.sh must branch on 'command -v claude' so it works offline"
  fail=1
fi

if ! echo "$CODE" | grep -qE 'python' ; then
  echo "FAIL: scan-log.sh must use python to post-process Claude's output"
  fail=1
fi

# Runtime check — execute the script (it falls back to the canned response
# since claude isn't on PATH in CI) and inspect the generated report.md.
rm -f "$REPORT"

if ! bash "$SCRIPT" >/dev/null 2>&1; then
  echo "FAIL: bash scan-log.sh exited non-zero"
  fail=1
elif [[ ! -f "$REPORT" ]]; then
  echo "FAIL: scan-log.sh did not produce report.md"
  fail=1
else
  for endpoint in "/api/payments" "/api/search" "/api/checkout"; do
    if ! grep -qF "$endpoint" "$REPORT"; then
      echo "FAIL: report.md missing expected endpoint bullet for '$endpoint'"
      fail=1
    fi
  done
  # Payments should be first (count 4, listed before checkout/count 3). The
  # canned response has payments tied with search but listed first; sorting by
  # count desc (stable) preserves that.
  first_line=$(head -1 "$REPORT" || true)
  if ! echo "$first_line" | grep -qF '/api/payments'; then
    echo "FAIL: first bullet of report.md should be /api/payments (highest count) — got: $first_line"
    fail=1
  fi
fi

if [[ "$fail" -eq 0 ]]; then
  echo "PASS: scan-log pipeline produces the expected report"
  exit 0
fi
exit 1
