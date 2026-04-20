#!/usr/bin/env bash
set -euo pipefail

LAB_DIR="$(cd "$(dirname "$0")" && pwd)"
STARTER="$LAB_DIR/starter"
SETTINGS="$STARTER/.claude/settings.json"
HOOK="$STARTER/.claude/hooks/log-edits.sh"
GITIGNORE="$STARTER/.claude/logs/.gitignore"

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

post = d.get('hooks', {}).get('PostToolUse')
if not isinstance(post, list) or not post:
    print('FAIL: hooks.PostToolUse must be a non-empty list', file=sys.stderr)
    sys.exit(3)

matched = False
for entry in post:
    matcher = str(entry.get('matcher') or '')
    if re.search(r'Edit', matcher) and re.search(r'Write', matcher):
        inner = entry.get('hooks', [])
        for h in inner:
            if h.get('type') == 'command' and 'log-edits.sh' in (h.get('command') or ''):
                matched = True
                break
if not matched:
    print('FAIL: need a PostToolUse entry with matcher covering both Edit and Write (e.g. \"Edit|Write\") whose command references log-edits.sh', file=sys.stderr)
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
  if ! grep -q 'edits.log' "$HOOK"; then
    echo "FAIL: hook must append to edits.log"
    fail=1
  fi
  if ! grep -qE 'mkdir[[:space:]]+-p|os\.makedirs' "$HOOK"; then
    echo "FAIL: hook must create the logs/ directory (mkdir -p) so it is self-healing"
    fail=1
  fi
  # PostToolUse cannot block. Scripts that try are a bug.
  if grep -q '"deny"' "$HOOK"; then
    echo "FAIL: hook must not emit permissionDecision: \"deny\" — PostToolUse cannot block the call that already happened"
    fail=1
  fi
  if grep -qE '^[[:space:]]*exit[[:space:]]+2[[:space:]]*$' "$HOOK"; then
    echo "FAIL: hook must not exit 2 — logger should not disturb the session"
    fail=1
  fi
fi

if [[ ! -f "$GITIGNORE" ]]; then
  echo "FAIL: expected $GITIGNORE to exist (log contents are private; log shape is public)"
  fail=1
elif ! grep -qE '\*\.log|edits\.log' "$GITIGNORE"; then
  echo "FAIL: .claude/logs/.gitignore must exclude log files (*.log or edits.log)"
  fail=1
fi

if [[ "$fail" -eq 0 ]]; then
  echo "PASS: post-tool logger looks correct"
  exit 0
fi
exit 1
