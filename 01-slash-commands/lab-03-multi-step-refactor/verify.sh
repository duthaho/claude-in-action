#!/usr/bin/env bash
set -euo pipefail

LAB_DIR="$(cd "$(dirname "$0")" && pwd)"
STARTER="$LAB_DIR/starter"
CMD="$STARTER/.claude/commands/refactor.md"

fail=0

if [[ ! -f "$CMD" ]]; then
  echo "FAIL: expected $CMD to exist"
  exit 1
fi

if ! grep -q '^argument-hint:' "$CMD"; then
  echo "FAIL: missing 'argument-hint:' frontmatter"
  fail=1
fi

for needle in 'py_compile' 'unittest' 'ARGUMENTS'; do
  if ! grep -q "$needle" "$CMD"; then
    echo "FAIL: body should mention $needle"
    fail=1
  fi
done

# Check that starter code has been refactored clean.
if ! (cd "$STARTER" && python -m py_compile messy.py) >/dev/null 2>&1; then
  echo "FAIL: starter/messy.py does not compile — the lint step hasn't been done"
  fail=1
fi

if ! (cd "$STARTER" && python -m unittest -v test_messy.py) >/dev/null 2>&1; then
  echo "FAIL: starter/test_messy.py is still failing — the test step hasn't been done"
  fail=1
fi

if [[ "$fail" -eq 0 ]]; then
  echo "PASS: refactor command runs clean end-to-end"
  exit 0
fi
exit 1
