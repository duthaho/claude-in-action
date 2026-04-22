#!/usr/bin/env bash
set -euo pipefail

LAB_DIR="$(cd "$(dirname "$0")" && pwd)"
STARTER="$LAB_DIR/starter"
INTERVALS="$STARTER/src/intervals.py"
TRANSCRIPT="$LAB_DIR/TRANSCRIPT.md"

fail=0

if [[ ! -f "$INTERVALS" ]]; then
  echo "FAIL: expected $INTERVALS to exist"
  fail=1
fi

if ! command -v python >/dev/null 2>&1; then
  echo "FAIL: python is required to verify this lab"
  exit 2
fi

# Tests must pass after the fix.
if (cd "$STARTER" && python -m unittest tests.test_intervals >/dev/null 2>&1); then
  :
else
  echo "FAIL: python -m unittest tests.test_intervals is still failing — the bug in src/intervals.py is not fixed"
  fail=1
fi

if [[ ! -f "$TRANSCRIPT" ]]; then
  echo "FAIL: expected TRANSCRIPT.md in the lab root — Tier-2 evidence of the thinking-budget comparison"
  fail=1
else
  for header in "## Default run" "## Think-hard run" "## Verdict"; do
    if ! grep -qF "$header" "$TRANSCRIPT"; then
      echo "FAIL: TRANSCRIPT.md must contain the header '$header'"
      fail=1
    fi
  done
  if ! grep -qiE 'think hard|extended thinking|ultrathink' "$TRANSCRIPT"; then
    echo "FAIL: TRANSCRIPT.md must mention 'think hard' or extended thinking — otherwise the comparison isn't there"
    fail=1
  fi
fi

if [[ "$fail" -eq 0 ]]; then
  echo "PASS: thinking-budget comparison is complete and the bug is fixed"
  exit 0
fi
exit 1
