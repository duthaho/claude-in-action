#!/usr/bin/env bash
set -euo pipefail

LAB_DIR="$(cd "$(dirname "$0")" && pwd)"
REVIEWER="$LAB_DIR/starter/.claude/agents/reviewer.md"
PATCHER="$LAB_DIR/starter/.claude/agents/patch-writer.md"
PIPELINE="$LAB_DIR/starter/PIPELINE.md"

fail=0

check_frontmatter() {
  local file="$1"
  local expected_name="$2"
  if [[ ! -f "$file" ]]; then
    echo "FAIL: expected $file to exist"
    return 1
  fi
  if ! head -1 "$file" | grep -q '^---$'; then
    echo "FAIL: $file must start with '---' (frontmatter open)"
    return 1
  fi
  local fm
  fm=$(awk '/^---$/{c++; next} c==1{print} c==2{exit}' "$file")
  if ! echo "$fm" | grep -qE "^name:[[:space:]]*${expected_name}[[:space:]]*$"; then
    echo "FAIL: $file frontmatter must have 'name: ${expected_name}'"
    return 1
  fi
  if ! echo "$fm" | grep -q '^description:'; then
    echo "FAIL: $file frontmatter must have a 'description:' field"
    return 1
  fi
  if ! echo "$fm" | grep -q '^tools:'; then
    echo "FAIL: $file frontmatter must have a 'tools:' field"
    return 1
  fi
}

check_frontmatter "$REVIEWER" "reviewer" || fail=1
check_frontmatter "$PATCHER" "patch-writer" || fail=1

if [[ -f "$REVIEWER" ]]; then
  reviewer_fm=$(awk '/^---$/{c++; next} c==1{print} c==2{exit}' "$REVIEWER")
  reviewer_tools=$(echo "$reviewer_fm" | grep -i '^tools:' || true)
  for t in Read Grep Glob; do
    if ! echo "$reviewer_tools" | grep -q "$t"; then
      echo "FAIL: reviewer tools must include $t"
      fail=1
    fi
  done
  for forbidden in Write Edit; do
    if echo "$reviewer_tools" | grep -q "$forbidden"; then
      echo "FAIL: reviewer tools must NOT include $forbidden (reviewer is read-only)"
      fail=1
    fi
  done
  reviewer_body=$(awk '/^---$/{c++; next} c==2{print}' "$REVIEWER")
  if ! echo "$reviewer_body" | grep -qE 'Critical|Warning'; then
    echo "FAIL: reviewer body should pin the Critical/Warning output shape"
    fail=1
  fi
fi

if [[ -f "$PATCHER" ]]; then
  patcher_fm=$(awk '/^---$/{c++; next} c==1{print} c==2{exit}' "$PATCHER")
  patcher_tools=$(echo "$patcher_fm" | grep -i '^tools:' || true)
  if ! echo "$patcher_tools" | grep -q 'Edit'; then
    echo "FAIL: patch-writer tools must include Edit"
    fail=1
  fi
  if echo "$patcher_tools" | grep -q 'Bash'; then
    echo "FAIL: patch-writer tools must NOT include Bash"
    fail=1
  fi
fi

if [[ ! -f "$PIPELINE" ]]; then
  echo "FAIL: expected starter/PIPELINE.md documenting the dispatch flow"
  fail=1
else
  for step in 'reviewer' 'parse' 'patch-writer' 'summari[sz]e'; do
    if ! grep -qiE "$step" "$PIPELINE"; then
      echo "FAIL: PIPELINE.md should reference '$step' (the four-step flow is: reviewer, parse, patch-writer, summarise)"
      fail=1
    fi
  done
fi

if [[ "$fail" -eq 0 ]]; then
  echo "PASS: handoff pipeline looks correct"
  exit 0
fi
exit 1
