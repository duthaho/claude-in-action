#!/usr/bin/env bash
set -euo pipefail

LAB_DIR="$(cd "$(dirname "$0")" && pwd)"
TARGET="$LAB_DIR/starter/CLAUDE.md"

fail=0

if [[ ! -f "$TARGET" ]]; then
  echo "FAIL: expected $TARGET to exist"
  exit 1
fi

word_count=$(wc -w < "$TARGET")
if [[ "$word_count" -lt 150 ]]; then
  echo "FAIL: CLAUDE.md is too short ($word_count words) — aim for 200–500"
  fail=1
fi

if ! grep -qiE '^#+ *(architecture|structure)' "$TARGET"; then
  echo "FAIL: CLAUDE.md should have an Architecture (or Structure) heading"
  fail=1
fi

if ! grep -qiE '^#+ *(rules|conventions|constraints|guidelines)' "$TARGET"; then
  echo "FAIL: CLAUDE.md should have a Rules (or Conventions/Constraints/Guidelines) heading"
  fail=1
fi

if ! grep -qiE 'depend|library|framework|stdlib|standard library' "$TARGET"; then
  echo "FAIL: CLAUDE.md should mention the 'no dependencies' constraint (look for 'dependency', 'library', 'stdlib', etc.)"
  fail=1
fi

if [[ "$fail" -eq 0 ]]; then
  echo "PASS: CLAUDE.md covers summary/architecture/rules adequately"
  exit 0
fi
exit 1
