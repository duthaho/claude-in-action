#!/usr/bin/env bash
set -euo pipefail

LAB_DIR="$(cd "$(dirname "$0")" && pwd)"
STARTER="$LAB_DIR/starter"
SORTER="$STARTER/src/sorter.py"
TESTS="$STARTER/tests/test_sorter.py"
BRANCHES="$LAB_DIR/BRANCHES.md"

fail=0

if [[ ! -f "$SORTER" ]]; then
  echo "FAIL: expected $SORTER to exist"
  fail=1
else
  if ! grep -q 'NotImplementedError' "$SORTER"; then
    echo "FAIL: $SORTER should still contain 'NotImplementedError' — it's the fork point. Rewind after Branch B, or don't save the starter in a branched state."
    fail=1
  fi
fi

if [[ ! -f "$TESTS" ]]; then
  echo "FAIL: expected $TESTS to exist — don't delete the test file"
  fail=1
elif [[ ! -s "$TESTS" ]]; then
  echo "FAIL: $TESTS is empty"
  fail=1
fi

if [[ ! -f "$BRANCHES" ]]; then
  echo "FAIL: expected BRANCHES.md in the lab root — Tier-2 evidence of the branching exercise"
  fail=1
else
  for header in "## Branch A" "## Branch B" "## Decision"; do
    if ! grep -qF "$header" "$BRANCHES"; then
      echo "FAIL: BRANCHES.md must contain the header '$header'"
      fail=1
    fi
  done
  # Need at least two python-fenced code blocks (one per branch)
  count=$(grep -cE '^```python' "$BRANCHES" || true)
  if [[ "$count" -lt 2 ]]; then
    echo 'FAIL: BRANCHES.md must contain two separate ```python code blocks (one per branch) — found '"$count"
    fail=1
  fi
fi

if [[ "$fail" -eq 0 ]]; then
  echo "PASS: branching-exploration evidence looks correct"
  exit 0
fi
exit 1
