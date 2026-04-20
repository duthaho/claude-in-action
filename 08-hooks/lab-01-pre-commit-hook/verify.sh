#!/usr/bin/env bash
set -euo pipefail

LAB_DIR="$(cd "$(dirname "$0")" && pwd)"
STARTER="$LAB_DIR/starter"
SETTINGS="$STARTER/.claude/settings.json"
HOOK="$STARTER/.claude/hooks/block-todo-commit.sh"

fail=0

if [[ ! -f "$SETTINGS" ]]; then
  echo "FAIL: expected $SETTINGS to exist"
  exit 1
fi

if ! python -c "
import json, sys
try:
    d = json.load(sys.stdin)
except Exception as e:
    print('FAIL: settings.json is not valid JSON:', e, file=sys.stderr)
    sys.exit(2)

pre = d.get('hooks', {}).get('PreToolUse')
if not isinstance(pre, list) or not pre:
    print('FAIL: hooks.PreToolUse must be a non-empty list', file=sys.stderr)
    sys.exit(3)

entry = next((e for e in pre if e.get('matcher') == 'Bash'), None)
if not entry:
    print('FAIL: need a hook entry with matcher: \"Bash\"', file=sys.stderr)
    sys.exit(4)

inner = entry.get('hooks', [])
cmd_hook = next((h for h in inner if h.get('type') == 'command'), None)
if not cmd_hook:
    print('FAIL: inner hooks must include a type: \"command\" entry', file=sys.stderr)
    sys.exit(5)

if 'block-todo-commit.sh' not in (cmd_hook.get('command') or ''):
    print('FAIL: command must reference block-todo-commit.sh', file=sys.stderr)
    sys.exit(6)

if 'git commit' not in (cmd_hook.get('if') or ''):
    print('FAIL: inner hook should include an if: filter narrowing to git commit, otherwise it fires on every Bash call', file=sys.stderr)
    sys.exit(7)

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
  if ! grep -q 'git diff --cached' "$HOOK"; then
    echo "FAIL: hook must inspect 'git diff --cached' to see staged changes"
    fail=1
  fi
  if ! grep -q 'TODO' "$HOOK"; then
    echo "FAIL: hook must scan for the 'TODO' marker"
    fail=1
  fi
  if ! grep -qE 'permissionDecision.*deny|"deny"' "$HOOK"; then
    echo "FAIL: hook must emit permissionDecision: \"deny\" when blocking (see PreToolUse JSON schema)"
    fail=1
  fi
fi

if [[ "$fail" -eq 0 ]]; then
  echo "PASS: pre-commit hook wiring looks correct"
  exit 0
fi
exit 1
