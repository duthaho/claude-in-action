#!/usr/bin/env bash
set -euo pipefail

LAB_DIR="$(cd "$(dirname "$0")" && pwd)"
STARTER="$LAB_DIR/starter"
MARKET="$STARTER/marketplace/.claude-plugin/marketplace.json"
PLUGIN="$STARTER/marketplace/plugins/greeter/.claude-plugin/plugin.json"
CMD="$STARTER/marketplace/plugins/greeter/commands/greet.md"
LOG="$LAB_DIR/INSTALL-LOG.md"

fail=0

if [[ ! -f "$MARKET" ]]; then
  echo "FAIL: expected $MARKET to exist"
  fail=1
else
  if ! python -c "
import json, sys
try:
    d = json.load(sys.stdin)
except Exception as e:
    print('FAIL: marketplace.json is not valid JSON:', e, file=sys.stderr)
    sys.exit(2)

if not d.get('name'):
    print('FAIL: marketplace.json must have a non-empty name field', file=sys.stderr)
    sys.exit(3)

plugins = d.get('plugins')
if not isinstance(plugins, list) or not plugins:
    print('FAIL: marketplace.json must list at least one plugin', file=sys.stderr)
    sys.exit(4)

for p in plugins:
    if not p.get('name') or not p.get('source'):
        print('FAIL: each plugin entry needs a name and source', file=sys.stderr)
        sys.exit(5)

sys.exit(0)
" < "$MARKET"; then
    fail=1
  fi
fi

if [[ ! -f "$PLUGIN" ]]; then
  echo "FAIL: expected $PLUGIN to exist"
  fail=1
else
  if ! python -c "
import json, sys
try:
    d = json.load(sys.stdin)
except Exception as e:
    print('FAIL: plugin.json is not valid JSON:', e, file=sys.stderr)
    sys.exit(2)

if d.get('name') != 'greeter':
    print('FAIL: plugin.json name must be \"greeter\" — got', repr(d.get('name')), file=sys.stderr)
    sys.exit(3)

if not d.get('version'):
    print('FAIL: plugin.json must have a version field', file=sys.stderr)
    sys.exit(4)

sys.exit(0)
" < "$PLUGIN"; then
    fail=1
  fi
fi

if [[ ! -f "$CMD" ]]; then
  echo "FAIL: expected $CMD (the /greet command body) to exist"
  fail=1
fi

if [[ ! -f "$LOG" ]]; then
  echo "FAIL: expected INSTALL-LOG.md in the lab root — this is the Tier-2 evidence that you ran /plugin install and /greet"
  fail=1
else
  if ! grep -qE 'plugin marketplace add' "$LOG"; then
    echo "FAIL: INSTALL-LOG.md must record the /plugin marketplace add command you ran"
    fail=1
  fi
  if ! grep -qE 'plugin install' "$LOG"; then
    echo "FAIL: INSTALL-LOG.md must record the /plugin install command you ran"
    fail=1
  fi
fi

if [[ "$fail" -eq 0 ]]; then
  echo "PASS: marketplace and plugin shapes look correct, install log present"
  exit 0
fi
exit 1
