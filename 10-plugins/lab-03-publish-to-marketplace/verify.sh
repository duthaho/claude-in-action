#!/usr/bin/env bash
set -euo pipefail

LAB_DIR="$(cd "$(dirname "$0")" && pwd)"
STARTER="$LAB_DIR/starter"
MARKET="$STARTER/marketplace/.claude-plugin/marketplace.json"
LOG="$LAB_DIR/LISTING-LOG.md"

fail=0

if [[ ! -f "$MARKET" ]]; then
  echo "FAIL: expected $MARKET to exist"
  exit 1
fi

if ! MARKET_JSON="$MARKET" MARKET_ROOT="$STARTER/marketplace" python -c '
import json, os, sys

try:
    with open(os.environ["MARKET_JSON"], encoding="utf-8") as f:
        d = json.load(f)
except Exception as e:
    print("FAIL: marketplace.json is not valid JSON:", e, file=sys.stderr)
    sys.exit(2)

name = d.get("name")
if not isinstance(name, str) or not name.strip():
    print("FAIL: marketplace.json must have a non-empty name field", file=sys.stderr)
    sys.exit(3)

owner = d.get("owner") or {}
if not isinstance(owner, dict) or not owner.get("name"):
    print("FAIL: marketplace.json must have owner.name populated", file=sys.stderr)
    sys.exit(4)

plugins = d.get("plugins")
if not isinstance(plugins, list) or len(plugins) < 2:
    print("FAIL: marketplace.json must list at least 2 plugins (quote-of-the-day and daily-standup)", file=sys.stderr)
    sys.exit(5)

by_name = {p.get("name"): p for p in plugins if isinstance(p, dict)}
for required in ("quote-of-the-day", "daily-standup"):
    if required not in by_name:
        print("FAIL: marketplace.json plugins[] must include an entry named " + repr(required), file=sys.stderr)
        sys.exit(6)

market_root = os.environ["MARKET_ROOT"]

for p in plugins:
    pname = p.get("name")
    psrc = p.get("source")
    if not pname or not psrc:
        print("FAIL: every plugin entry needs name and source", file=sys.stderr)
        sys.exit(7)
    if not psrc.startswith("./"):
        print("FAIL: source for " + repr(pname) + " must be a relative path starting with ./ — got " + repr(psrc), file=sys.stderr)
        sys.exit(8)
    plugin_dir = os.path.normpath(os.path.join(market_root, psrc))
    pj = os.path.join(plugin_dir, ".claude-plugin", "plugin.json")
    if not os.path.isfile(pj):
        print("FAIL: source " + repr(psrc) + " for " + repr(pname) + " does not point to a directory containing .claude-plugin/plugin.json", file=sys.stderr)
        sys.exit(9)
    try:
        with open(pj, encoding="utf-8") as f:
            inner = json.load(f)
    except Exception as e:
        print("FAIL: " + pj + " is not valid JSON: " + str(e), file=sys.stderr)
        sys.exit(10)
    if inner.get("name") != pname:
        print("FAIL: plugin.json at " + pj + " has name " + repr(inner.get("name")) + ", but marketplace entry says " + repr(pname) + " — they must match", file=sys.stderr)
        sys.exit(11)

sys.exit(0)
'; then
  fail=1
fi

if [[ ! -f "$LOG" ]]; then
  echo "FAIL: expected LISTING-LOG.md in the lab root — this is Tier-2 evidence that /plugin listed both plugins"
  fail=1
else
  for needle in quote-of-the-day daily-standup; do
    if ! grep -q "$needle" "$LOG"; then
      echo "FAIL: LISTING-LOG.md must mention $needle"
      fail=1
    fi
  done
fi

if [[ "$fail" -eq 0 ]]; then
  echo "PASS: marketplace manifest publishes both plugins and listing log is present"
  exit 0
fi
exit 1
