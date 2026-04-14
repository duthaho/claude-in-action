#!/usr/bin/env bash
set -euo pipefail

LAB_DIR="$(cd "$(dirname "$0")" && pwd)"
STARTER="$LAB_DIR/starter"

fail=0

# Bug A fix: the local file must now live at the correct path/name.
if [[ ! -f "$STARTER/.claude/CLAUDE.local.md" ]]; then
  echo "FAIL: expected $STARTER/.claude/CLAUDE.local.md (bug A not fixed — the local file was misnamed)"
  fail=1
fi

# The old misnamed file should no longer be the only copy. Allow it to exist
# (we don't forbid extras) but the correctly-named one must be present above.

# Bug B fix: project CLAUDE.md must use "never" in the no-commit rule.
PROJECT_MD="$STARTER/CLAUDE.md"
if [[ ! -f "$PROJECT_MD" ]]; then
  echo "FAIL: $PROJECT_MD does not exist"
  exit 1
fi
if ! grep -qi 'never.*commit' "$PROJECT_MD"; then
  echo "FAIL: project CLAUDE.md should use 'never ... commit' (bug B — replace 'avoid' with 'never')"
  fail=1
fi
if grep -qi 'avoid.*commit' "$PROJECT_MD"; then
  echo "FAIL: project CLAUDE.md still says 'avoid ... commit' (bug B not fully fixed)"
  fail=1
fi

# Bug C fix: user file must no longer contain the auto-commit rule.
USER_MD="$STARTER/fake-home/.claude/CLAUDE.md"
if [[ ! -f "$USER_MD" ]]; then
  echo "FAIL: $USER_MD does not exist"
  fail=1
elif grep -qi 'auto-commit' "$USER_MD"; then
  echo "FAIL: user CLAUDE.md still contains the 'auto-commit is fine' rule (bug C — remove or replace it)"
  fail=1
fi

# Notes file must document all three bugs as fixed.
NOTES="$STARTER/notes.md"
if [[ ! -f "$NOTES" ]]; then
  echo "FAIL: $NOTES does not exist"
  fail=1
else
  for letter in A B C; do
    if ! grep -qiE "bug $letter.*fix" "$NOTES"; then
      echo "FAIL: notes.md does not document 'Bug $letter ... fix' — write up each bug you fixed"
      fail=1
    fi
  done
fi

if [[ "$fail" -eq 0 ]]; then
  echo "PASS: all three memory bugs fixed and documented"
  exit 0
fi
exit 1
