#!/usr/bin/env bash
set -euo pipefail

LAB_DIR="$(cd "$(dirname "$0")" && pwd)"
STARTER="$LAB_DIR/starter"
SETTINGS="$STARTER/.claude/settings.json"
AGENT="$STARTER/.claude/agents/researcher.md"
QUESTIONS="$STARTER/QUESTIONS.md"
TEMPLATE="$STARTER/REPORT-TEMPLATE.md"
TEAM_PROMPT="$STARTER/TEAM-PROMPT.md"

fail=0

if [[ ! -f "$SETTINGS" ]]; then
  echo "FAIL: expected $SETTINGS to exist"
  exit 1
fi

if ! python -c "
import json, sys
d = json.load(sys.stdin)
v = d.get('env', {}).get('CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS')
sys.exit(0 if str(v) == '1' else 1)
" < "$SETTINGS" 2>/dev/null; then
  echo "FAIL: settings.json must have env.CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS = \"1\""
  fail=1
fi

if [[ ! -f "$AGENT" ]]; then
  echo "FAIL: expected $AGENT to exist"
  fail=1
else
  if ! head -1 "$AGENT" | grep -q '^---$'; then
    echo "FAIL: researcher.md must start with '---' (frontmatter open)"
    fail=1
  fi
  fm=$(awk '/^---$/{c++; next} c==1{print} c==2{exit}' "$AGENT")
  if ! echo "$fm" | grep -qE '^name:[[:space:]]*researcher[[:space:]]*$'; then
    echo "FAIL: researcher.md frontmatter must have 'name: researcher'"
    fail=1
  fi
  tools_line=$(echo "$fm" | grep -i '^tools:' || true)
  for t in Read Grep Glob; do
    if ! echo "$tools_line" | grep -q "$t"; then
      echo "FAIL: researcher tools list must include $t"
      fail=1
    fi
  done
  disallowed_line=$(echo "$fm" | grep -i '^disallowedTools:' || true)
  if [[ -z "$disallowed_line" ]]; then
    echo "FAIL: researcher.md must declare 'disallowedTools' for defence in depth"
    fail=1
  else
    for d in Write Edit; do
      if ! echo "$disallowed_line" | grep -q "$d"; then
        echo "FAIL: disallowedTools must include $d"
        fail=1
      fi
    done
  fi
fi

if [[ ! -f "$QUESTIONS" ]]; then
  echo "FAIL: expected $QUESTIONS to exist"
  fail=1
else
  count=$(grep -cE '^[[:space:]]*[0-9]+\.' "$QUESTIONS" || true)
  if [[ "$count" -lt 3 ]]; then
    echo "FAIL: QUESTIONS.md must list at least 3 enumerated questions (found $count)"
    fail=1
  fi
fi

if [[ ! -f "$TEMPLATE" ]]; then
  echo "FAIL: expected $TEMPLATE to exist — synthesis requires a pinned shape"
  fail=1
fi

if [[ ! -f "$TEAM_PROMPT" ]]; then
  echo "FAIL: expected $TEAM_PROMPT to exist"
  fail=1
else
  if ! grep -qi 'researcher' "$TEAM_PROMPT"; then
    echo "FAIL: TEAM-PROMPT.md must reference the 'researcher' agent type"
    fail=1
  fi
  if ! grep -qiE 'three|parallel|each question|fan.?out' "$TEAM_PROMPT"; then
    echo "FAIL: TEAM-PROMPT.md must make the scale-out explicit (mention 'three', 'parallel', or 'each question')"
    fail=1
  fi
fi

for f in refunds.md webhooks.md idempotency.md; do
  if [[ ! -f "$STARTER/sources/$f" ]]; then
    echo "FAIL: expected starter/sources/$f to exist (corpus file was removed)"
    fail=1
  fi
done

if [[ "$fail" -eq 0 ]]; then
  echo "PASS: parallel-researchers team looks correct"
  exit 0
fi
exit 1
