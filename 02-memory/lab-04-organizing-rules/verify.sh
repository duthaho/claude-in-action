#!/usr/bin/env bash
set -euo pipefail

LAB_DIR="$(cd "$(dirname "$0")" && pwd)"
STARTER="$LAB_DIR/starter"
RULES_DIR="$STARTER/.claude/rules"
CLAUDE_MD="$STARTER/CLAUDE.md"

fail=0

# Four required rules files, each non-empty.
for name in architecture.md testing.md commits.md style.md; do
  f="$RULES_DIR/$name"
  if [[ ! -f "$f" ]]; then
    echo "FAIL: missing $f"
    fail=1
    continue
  fi
  if [[ ! -s "$f" ]]; then
    echo "FAIL: $f is empty"
    fail=1
  fi
done

# CLAUDE.md must still exist, under 10 lines, and mention .claude/rules.
if [[ ! -f "$CLAUDE_MD" ]]; then
  echo "FAIL: $CLAUDE_MD missing"
  fail=1
else
  lines=$(wc -l < "$CLAUDE_MD")
  if [[ "$lines" -gt 10 ]]; then
    echo "FAIL: CLAUDE.md has $lines lines — trim to under 10 (summary + rules pointer only)"
    fail=1
  fi
  if ! grep -q '\.claude/rules' "$CLAUDE_MD"; then
    echo "FAIL: CLAUDE.md should mention '.claude/rules' so human readers know where rules live"
    fail=1
  fi
  # Must not contain the old topic headings — those got moved to rules/.
  for heading in '## Architecture' '## Testing' '## Commit hygiene' '## Style'; do
    if grep -qF "$heading" "$CLAUDE_MD"; then
      echo "FAIL: CLAUDE.md still contains heading '$heading' — that content should live under .claude/rules/ now"
      fail=1
    fi
  done
fi

if [[ "$fail" -eq 0 ]]; then
  echo "PASS: rules split into four topic files and CLAUDE.md trimmed"
  exit 0
fi
exit 1
