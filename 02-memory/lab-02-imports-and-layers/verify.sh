#!/usr/bin/env bash
set -euo pipefail

LAB_DIR="$(cd "$(dirname "$0")" && pwd)"
STARTER="$LAB_DIR/starter"

fail=0

PROJECT_MD="$STARTER/CLAUDE.md"
USER_MD="$STARTER/fake-home/.claude/CLAUDE.md"
API_MD="$STARTER/docs/memory/api-style.md"

if [[ ! -f "$PROJECT_MD" ]]; then
  echo "FAIL: $PROJECT_MD does not exist"
  exit 1
fi

if ! grep -q '@import docs/memory/api-style.md' "$PROJECT_MD"; then
  echo "FAIL: project CLAUDE.md does not @import docs/memory/api-style.md"
  fail=1
fi

lines=$(wc -l < "$PROJECT_MD")
if [[ "$lines" -gt 40 ]]; then
  echo "FAIL: project CLAUDE.md still too long ($lines lines) — aim for <40 after split"
  fail=1
fi

if [[ ! -f "$USER_MD" ]]; then
  echo "FAIL: $USER_MD does not exist — user preferences not extracted"
  fail=1
else
  if ! grep -qiE 'pathlib|type hint|f-string' "$USER_MD"; then
    echo "FAIL: fake-home CLAUDE.md should mention Python preferences"
    fail=1
  fi
fi

if [[ ! -f "$API_MD" ]]; then
  echo "FAIL: $API_MD does not exist — API conventions not extracted"
  fail=1
else
  if ! grep -qiE 'trailing slash|201' "$API_MD"; then
    echo "FAIL: api-style.md should contain API conventions"
    fail=1
  fi
fi

# Check that personal prefs are no longer in the project file.
if grep -qiE 'pathlib|f-string|mypy strict' "$PROJECT_MD"; then
  echo "FAIL: personal Python prefs still in project CLAUDE.md — move them to the user file"
  fail=1
fi

if [[ "$fail" -eq 0 ]]; then
  echo "PASS: memory correctly split across three layers"
  exit 0
fi
exit 1
