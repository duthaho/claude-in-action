#!/usr/bin/env bash
set -euo pipefail

LAB_DIR="$(cd "$(dirname "$0")" && pwd)"
AGENT="$LAB_DIR/starter/.claude/agents/researcher.md"

fail=0

if [[ ! -f "$AGENT" ]]; then
  echo "FAIL: expected $AGENT to exist"
  exit 1
fi

if ! head -1 "$AGENT" | grep -q '^---$'; then
  echo "FAIL: researcher.md must start with '---' (frontmatter open)"
  fail=1
fi

frontmatter=$(awk '/^---$/{c++; next} c==1{print} c==2{exit}' "$AGENT")

if ! echo "$frontmatter" | grep -qE '^name:[[:space:]]*researcher[[:space:]]*$'; then
  echo "FAIL: frontmatter must have 'name: researcher'"
  fail=1
fi

if ! echo "$frontmatter" | grep -q '^description:'; then
  echo "FAIL: frontmatter must have a 'description:' field"
  fail=1
fi

desc_line=$(echo "$frontmatter" | grep -i '^description:' || true)
if ! echo "$desc_line" | grep -qiE 'research|find|summari[sz]e|look up'; then
  echo "FAIL: description should include trigger words like 'research', 'find', 'summarise', or 'look up'"
  fail=1
fi

if ! echo "$frontmatter" | grep -q '^tools:'; then
  echo "FAIL: frontmatter must have a 'tools:' allowlist"
  fail=1
fi

tools_line=$(echo "$frontmatter" | grep -i '^tools:' || true)
for t in Read Grep Glob; do
  if ! echo "$tools_line" | grep -q "$t"; then
    echo "FAIL: tools list must include $t (researcher needs to read and search)"
    fail=1
  fi
done

if ! echo "$frontmatter" | grep -q '^disallowedTools:'; then
  echo "FAIL: frontmatter must include 'disallowedTools:' for defence in depth"
  fail=1
fi

disallowed_line=$(echo "$frontmatter" | grep -i '^disallowedTools:' || true)
for forbidden in Write Edit; do
  if ! echo "$disallowed_line" | grep -q "$forbidden"; then
    echo "FAIL: disallowedTools must include $forbidden"
    fail=1
  fi
done

body=$(awk '/^---$/{c++; next} c==2{print}' "$AGENT")

if ! echo "$body" | grep -qiE 'citation|path:line|grep'; then
  echo "FAIL: body should specify the procedure — mention 'citations', 'path:line', or 'grep'"
  fail=1
fi

for f in architecture.md api.md runbook.md; do
  if [[ ! -f "$LAB_DIR/starter/docs/$f" ]]; then
    echo "FAIL: expected starter/docs/$f to exist (corpus file was removed)"
    fail=1
  fi
done

if [[ "$fail" -eq 0 ]]; then
  echo "PASS: researcher subagent looks correct"
  exit 0
fi
exit 1
