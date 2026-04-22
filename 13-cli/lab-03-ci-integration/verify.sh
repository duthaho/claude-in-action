#!/usr/bin/env bash
set -euo pipefail

LAB_DIR="$(cd "$(dirname "$0")" && pwd)"
WORKFLOW="$LAB_DIR/starter/.github/workflows/claude-review.yml"

fail=0

if [[ ! -f "$WORKFLOW" ]]; then
  echo "FAIL: expected $WORKFLOW to exist"
  exit 1
fi

# Strip pure-comment lines so hint text in TODO blocks doesn't accidentally
# satisfy the grep checks below. We keep lines that have code + trailing
# comment (rare in YAML, but safe).
tmp=$(mktemp)
trap 'rm -f "$tmp"' EXIT
grep -v '^[[:space:]]*#' "$WORKFLOW" > "$tmp"
WORKFLOW="$tmp"

# Structural checks on the workflow YAML. We don't parse YAML — grep is enough
# since the key tokens are unique and distinctive.

# Trigger — must listen on pull_request events (not just workflow_dispatch).
if ! grep -qE '^[[:space:]]*pull_request:' "$WORKFLOW"; then
  echo "FAIL: workflow must trigger on pull_request events (see TODO 1)"
  fail=1
fi

if ! grep -qE '\btypes:[[:space:]]*\[[^]]*\bopened\b' "$WORKFLOW" \
  && ! grep -qE '^[[:space:]]*-[[:space:]]*opened' "$WORKFLOW"; then
  echo "FAIL: pull_request trigger should cover 'opened' (first-push reviews)"
  fail=1
fi

if ! grep -qE '\bsynchronize\b' "$WORKFLOW"; then
  echo "FAIL: pull_request trigger should cover 'synchronize' so follow-up pushes are re-reviewed"
  fail=1
fi

# Install step — must install the @anthropic-ai/claude-code npm package.
if ! grep -qE 'npm[[:space:]]+install[[:space:]]+-g[[:space:]]+@anthropic-ai/claude-code' "$WORKFLOW"; then
  echo "FAIL: must install Claude Code with 'npm install -g @anthropic-ai/claude-code' (see TODO 2)"
  fail=1
fi

# Claude invocation — must call `claude -p`, use the diff on stdin, restrict tools, and cap turns.
if ! grep -qE '\bclaude[[:space:]]+-p\b' "$WORKFLOW"; then
  echo "FAIL: must invoke 'claude -p' in the review step (see TODO 3)"
  fail=1
fi

if ! grep -qE -- '--allowedTools[[:space:]]+"[^"]*Read[^"]*Glob[^"]*Grep[^"]*"' "$WORKFLOW" \
  && ! grep -qE -- '--allowedTools[[:space:]]+"Read,Glob,Grep"' "$WORKFLOW"; then
  echo "FAIL: claude -p must restrict tools to 'Read,Glob,Grep' via --allowedTools"
  fail=1
fi

if ! grep -qE -- '--max-turns[[:space:]]+[0-9]+' "$WORKFLOW"; then
  echo "FAIL: claude -p must cap tool loops with --max-turns <N>"
  fail=1
fi

if ! grep -qE '<[[:space:]]*pr\.diff' "$WORKFLOW"; then
  echo "FAIL: claude -p must receive pr.diff on stdin ('< pr.diff')"
  fail=1
fi

# Secret plumbing — ANTHROPIC_API_KEY must be referenced from secrets.
if ! grep -qE 'ANTHROPIC_API_KEY:[[:space:]]*\$\{\{[[:space:]]*secrets\.ANTHROPIC_API_KEY' "$WORKFLOW"; then
  echo "FAIL: ANTHROPIC_API_KEY must be wired from secrets.ANTHROPIC_API_KEY via env: (see TODO 4)"
  fail=1
fi

if [[ "$fail" -eq 0 ]]; then
  echo "PASS: CI workflow has all required pieces"
  exit 0
fi
exit 1
