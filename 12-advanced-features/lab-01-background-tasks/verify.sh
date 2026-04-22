#!/usr/bin/env bash
set -euo pipefail

LAB_DIR="$(cd "$(dirname "$0")" && pwd)"
STARTER="$LAB_DIR/starter"
BUILD="$STARTER/slow-build.sh"
TRANSCRIPT="$LAB_DIR/TRANSCRIPT.md"

fail=0

if [[ ! -f "$BUILD" ]]; then
  echo "FAIL: expected $BUILD to exist — don't delete the workload script"
  fail=1
elif ! grep -q 'BUILD SUCCESS' "$BUILD"; then
  echo "FAIL: slow-build.sh should end with a BUILD SUCCESS line"
  fail=1
fi

if [[ ! -f "$TRANSCRIPT" ]]; then
  echo "FAIL: expected TRANSCRIPT.md in the lab root — Tier-2 evidence of the background-task exercise"
  fail=1
else
  for header in "## Launch" "## Interleaved work" "## Poll" "## Final" "## What I learned"; do
    if ! grep -qF "$header" "$TRANSCRIPT"; then
      echo "FAIL: TRANSCRIPT.md must contain the header '$header'"
      fail=1
    fi
  done
  if ! grep -qF 'slow-build.sh' "$TRANSCRIPT"; then
    echo "FAIL: TRANSCRIPT.md must reference slow-build.sh"
    fail=1
  fi
  if ! grep -qE 'BashOutput|run_in_background|background' "$TRANSCRIPT"; then
    echo "FAIL: TRANSCRIPT.md must mention BashOutput or run_in_background — otherwise there's no evidence you used background mode"
    fail=1
  fi
fi

if [[ "$fail" -eq 0 ]]; then
  echo "PASS: background-tasks evidence looks correct"
  exit 0
fi
exit 1
