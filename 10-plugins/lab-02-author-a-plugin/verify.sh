#!/usr/bin/env bash
set -euo pipefail

LAB_DIR="$(cd "$(dirname "$0")" && pwd)"
STARTER="$LAB_DIR/starter/quote-of-the-day"
MANIFEST="$STARTER/.claude-plugin/plugin.json"
CMD="$STARTER/commands/quote.md"
SKILL="$STARTER/skills/wordcount/SKILL.md"
QUOTES="$STARTER/quotes.txt"

fail=0

if [[ ! -f "$MANIFEST" ]]; then
  echo "FAIL: expected $MANIFEST to exist"
  fail=1
else
  if ! python -c "
import json, sys
try:
    d = json.load(sys.stdin)
except Exception as e:
    print('FAIL: plugin.json is not valid JSON:', e, file=sys.stderr)
    sys.exit(2)

if d.get('name') != 'quote-of-the-day':
    print('FAIL: plugin.json name must be exactly \"quote-of-the-day\" — got', repr(d.get('name')), file=sys.stderr)
    sys.exit(3)

if not d.get('version'):
    print('FAIL: plugin.json must have a non-empty version field (e.g. \"1.0.0\")', file=sys.stderr)
    sys.exit(4)

desc = d.get('description')
if not isinstance(desc, str) or len(desc.strip()) < 10:
    print('FAIL: plugin.json must have a non-empty description (at least 10 chars)', file=sys.stderr)
    sys.exit(5)

author = d.get('author') or {}
if not isinstance(author, dict) or not author.get('name'):
    print('FAIL: plugin.json must have author.name populated', file=sys.stderr)
    sys.exit(6)

sys.exit(0)
" < "$MANIFEST"; then
    fail=1
  fi
fi

if [[ ! -f "$CMD" ]]; then
  echo "FAIL: expected $CMD (your /quote command body)"
  fail=1
else
  # YAML frontmatter with a description
  if ! head -5 "$CMD" | grep -qE '^description:'; then
    echo "FAIL: $CMD must have YAML frontmatter with a 'description:' field"
    fail=1
  fi
  if ! grep -q 'quotes.txt' "$CMD"; then
    echo "FAIL: /quote command body must reference quotes.txt so it reads the bundled data"
    fail=1
  fi
fi

if [[ ! -f "$SKILL" ]]; then
  echo "FAIL: expected $SKILL (your wordcount skill)"
  fail=1
else
  if ! grep -qE '^name:[[:space:]]+wordcount[[:space:]]*$' "$SKILL"; then
    echo "FAIL: SKILL.md frontmatter must declare 'name: wordcount' (on its own line)"
    fail=1
  fi
  if ! grep -qiE 'word' "$SKILL"; then
    echo "FAIL: SKILL.md must mention 'word' in the description so the matcher picks it up"
    fail=1
  fi
fi

if [[ ! -f "$QUOTES" ]]; then
  echo "FAIL: $QUOTES missing — don't delete the bundled data"
  fail=1
elif [[ ! -s "$QUOTES" ]]; then
  echo "FAIL: $QUOTES is empty — don't delete the bundled data"
  fail=1
fi

if [[ "$fail" -eq 0 ]]; then
  echo "PASS: plugin directory shape and manifest look correct"
  exit 0
fi
exit 1
