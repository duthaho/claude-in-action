#!/usr/bin/env bash
set -euo pipefail

LAB_DIR="$(cd "$(dirname "$0")" && pwd)"
AGENT="$LAB_DIR/starter/.claude/agents/code-reviewer.md"

fail=0

if [[ ! -f "$AGENT" ]]; then
  echo "FAIL: expected $AGENT to exist"
  exit 1
fi

if ! head -1 "$AGENT" | grep -q '^---$'; then
  echo "FAIL: code-reviewer.md must start with '---' (frontmatter open)"
  fail=1
fi

frontmatter=$(awk '/^---$/{c++; next} c==1{print} c==2{exit}' "$AGENT")

if ! echo "$frontmatter" | grep -qE '^name:[[:space:]]*code-reviewer[[:space:]]*$'; then
  echo "FAIL: frontmatter must have 'name: code-reviewer'"
  fail=1
fi

if ! echo "$frontmatter" | grep -q '^description:'; then
  echo "FAIL: frontmatter must have a 'description:' field"
  fail=1
fi

desc_line=$(echo "$frontmatter" | grep -i '^description:' || true)
if ! echo "$desc_line" | grep -qiE 'review|code quality|audit'; then
  echo "FAIL: description should mention 'review', 'code quality', or 'audit' so Claude can match it"
  fail=1
fi

if ! echo "$frontmatter" | grep -q '^tools:'; then
  echo "FAIL: frontmatter must have a 'tools:' field restricting the subagent's capabilities"
  fail=1
fi

tools_line=$(echo "$frontmatter" | grep -i '^tools:' || true)
for t in Read Grep Glob; do
  if ! echo "$tools_line" | grep -q "$t"; then
    echo "FAIL: tools list must include $t (reviewer needs to read and search code)"
    fail=1
  fi
done

for forbidden in Write Edit; do
  if echo "$tools_line" | grep -q "$forbidden"; then
    echo "FAIL: tools list must NOT include $forbidden (a reviewer should not modify files)"
    fail=1
  fi
done

body=$(awk '/^---$/{c++; next} c==2{print}' "$AGENT")

if ! echo "$body" | grep -qiE 'severity|critical|warning'; then
  echo "FAIL: body should specify output severity levels (Critical/Warning/Note)"
  fail=1
fi

if [[ "$fail" -eq 0 ]]; then
  echo "PASS: code-reviewer subagent looks correct"
  exit 0
fi
exit 1
