#!/usr/bin/env bash
set -euo pipefail

LAB_DIR="$(cd "$(dirname "$0")" && pwd)"
STARTER="$LAB_DIR/starter"
SETTINGS="$STARTER/.claude/settings.json"
HOOK="$STARTER/.claude/hooks/block-prod-writes.sh"
TESTS="$STARTER/.claude/hooks/test_block_prod_writes.sh"

fail=0

if [[ ! -f "$SETTINGS" ]]; then
  echo "FAIL: expected $SETTINGS to exist"
  exit 1
fi

if ! python -c "
import json, re, sys
try:
    d = json.load(sys.stdin)
except Exception as e:
    print('FAIL: settings.json is not valid JSON:', e, file=sys.stderr)
    sys.exit(2)

pre = d.get('hooks', {}).get('PreToolUse')
if not isinstance(pre, list) or not pre:
    print('FAIL: hooks.PreToolUse must be a non-empty list', file=sys.stderr)
    sys.exit(3)

matched = False
for entry in pre:
    matcher = str(entry.get('matcher') or '')
    if re.search(r'Edit', matcher) and re.search(r'Write', matcher):
        for h in entry.get('hooks', []):
            if h.get('type') == 'command' and 'block-prod-writes.sh' in (h.get('command') or ''):
                matched = True
                break
if not matched:
    print('FAIL: need a PreToolUse entry with matcher covering Edit and Write whose command references block-prod-writes.sh', file=sys.stderr)
    sys.exit(4)
sys.exit(0)
" < "$SETTINGS"; then
  fail=1
fi

if [[ ! -f "$HOOK" ]]; then
  echo "FAIL: expected $HOOK to exist"
  fail=1
else
  if ! grep -qE 'sys\.stdin|/dev/stdin|read[[:space:]]' "$HOOK"; then
    echo "FAIL: hook must read Claude's JSON envelope from stdin"
    fail=1
  fi
  if ! grep -qE 'file_path|tool_input' "$HOOK"; then
    echo "FAIL: hook must extract tool_input.file_path to know the target path"
    fail=1
  fi
  if ! grep -qE 'realpath|os\.path\.realpath|normpath' "$HOOK"; then
    echo "FAIL: hook must normalise the path (realpath/normpath) — otherwise prod/../dev/ fools it"
    fail=1
  fi
  if ! grep -qE 'permissionDecision.*deny|"deny"' "$HOOK"; then
    echo "FAIL: hook must emit permissionDecision: \"deny\" when blocking (PreToolUse JSON schema)"
    fail=1
  fi
fi

if [[ ! -f "$TESTS" ]]; then
  echo "FAIL: expected $TESTS offline test fixture to exist"
  fail=1
else
  if ! test_output=$(bash "$TESTS" 2>&1); then
    echo "FAIL: test fixture bash $TESTS exited non-zero"
    echo "$test_output"
    fail=1
  else
    pass_count=$(echo "$test_output" | grep -c '^PASS:' || true)
    if [[ "$pass_count" -lt 3 ]]; then
      echo "FAIL: test fixture must produce at least 3 PASS lines (got $pass_count)"
      echo "$test_output"
      fail=1
    fi
  fi
fi

for f in "prod/config.yaml" "dev/config.yaml"; do
  if [[ ! -f "$STARTER/$f" ]]; then
    echo "FAIL: expected starter/$f (fixture file) to exist"
    fail=1
  fi
done

if [[ "$fail" -eq 0 ]]; then
  echo "PASS: safety hook looks correct"
  exit 0
fi
exit 1
