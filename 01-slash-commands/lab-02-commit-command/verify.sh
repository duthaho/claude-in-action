#!/usr/bin/env bash
set -euo pipefail

LAB_DIR="$(cd "$(dirname "$0")" && pwd)"
CMD="$LAB_DIR/starter/.claude/commands/commit.md"

if [[ ! -f "$CMD" ]]; then
  echo "FAIL: expected $CMD to exist"
  exit 1
fi

fail=0

if ! grep -q '^description:' "$CMD"; then
  echo "FAIL: missing 'description:' frontmatter"
  fail=1
fi

if ! grep -q 'git diff --cached' "$CMD"; then
  echo "FAIL: body should tell Claude to read the staged diff via 'git diff --cached'"
  fail=1
fi

if ! grep -q 'git commit' "$CMD"; then
  echo "FAIL: body should mention 'git commit'"
  fail=1
fi

if ! grep -qiE 'approv|confirm|wait|user' "$CMD"; then
  echo "FAIL: body should ask Claude to wait for user approval before committing"
  fail=1
fi

if [[ "$fail" -eq 0 ]]; then
  echo "PASS: commit command looks correct"
  exit 0
fi
exit 1
