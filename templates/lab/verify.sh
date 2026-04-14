#!/usr/bin/env bash
# Tier-1 verification for this lab.
# Exit 0 = learner's starter/ is in the expected finished state.
# Exit non-zero = something is missing or wrong.
#
# Prefer offline checks: diff against solution/, grep for a required string,
# test -f for a required file. Do NOT call `claude -p` here.

set -euo pipefail

LAB_DIR="$(cd "$(dirname "$0")" && pwd)"
STARTER="$LAB_DIR/starter"
SOLUTION="$LAB_DIR/solution"

# Example: whole-directory diff. Replace with lab-specific checks as needed.
if diff -r "$SOLUTION" "$STARTER" >/dev/null 2>&1; then
  echo "PASS: starter/ matches solution/"
  exit 0
else
  echo "FAIL: starter/ differs from solution/"
  diff -r "$SOLUTION" "$STARTER" || true
  exit 1
fi
