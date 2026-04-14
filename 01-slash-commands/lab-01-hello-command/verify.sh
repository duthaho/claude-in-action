#!/usr/bin/env bash
# lab-01-hello-command verification.
# Passes when starter/.claude/commands/hello.md exists and looks like a real slash command.
set -euo pipefail

LAB_DIR="$(cd "$(dirname "$0")" && pwd)"
TARGET="$LAB_DIR/starter/.claude/commands/hello.md"

if [[ ! -f "$TARGET" ]]; then
  echo "FAIL: expected $TARGET to exist"
  exit 1
fi

if ! grep -q '^description:' "$TARGET"; then
  echo "FAIL: $TARGET is missing a 'description:' frontmatter line"
  exit 1
fi

# Body must mention the repo / working directory / current directory concept.
if ! grep -qiE 'repo|repository|working directory|current directory' "$TARGET"; then
  echo "FAIL: $TARGET body does not reference the current repo or working directory"
  exit 1
fi

echo "PASS: hello command looks correct"
exit 0
