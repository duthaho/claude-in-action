#!/usr/bin/env bash
set -euo pipefail

LAB_DIR="$(cd "$(dirname "$0")" && pwd)"
STARTER="$LAB_DIR/starter"
CALC="$STARTER/src/calculator.py"
TRANSCRIPT="$LAB_DIR/TRANSCRIPT.md"

fail=0

if [[ ! -f "$CALC" ]]; then
  echo "FAIL: expected $CALC to exist — the starter Calculator"
  fail=1
else
  # Starter should still define add and subtract but not divide (rewind should have restored it).
  if ! grep -qE 'def[[:space:]]+add\(' "$CALC"; then
    echo "FAIL: $CALC must still define add() — did you commit a broken state to starter?"
    fail=1
  fi
  if ! grep -qE 'def[[:space:]]+subtract\(' "$CALC"; then
    echo "FAIL: $CALC must still define subtract() — did you commit a broken state to starter?"
    fail=1
  fi
  if grep -qE 'def[[:space:]]+divide\(' "$CALC"; then
    echo "FAIL: $CALC must NOT contain divide() — starter should be pre-mistake state; you probably forgot to rewind before saving"
    fail=1
  fi
fi

if [[ ! -f "$TRANSCRIPT" ]]; then
  echo "FAIL: expected TRANSCRIPT.md in the lab root — Tier-2 evidence of the rewind exercise"
  fail=1
else
  for header in "## Before" "## After (broken)" "## After rewind" "## Comparison"; do
    if ! grep -qF "$header" "$TRANSCRIPT"; then
      echo "FAIL: TRANSCRIPT.md must contain the header '$header'"
      fail=1
    fi
  done
  if ! grep -q '/rewind' "$TRANSCRIPT"; then
    echo "FAIL: TRANSCRIPT.md must mention /rewind (the command you ran)"
    fail=1
  fi
  if ! grep -q 'divide' "$TRANSCRIPT"; then
    echo "FAIL: TRANSCRIPT.md must mention 'divide' (the method the mistake introduced)"
    fail=1
  fi
fi

if [[ "$fail" -eq 0 ]]; then
  echo "PASS: rewind exercise evidence looks correct"
  exit 0
fi
exit 1
