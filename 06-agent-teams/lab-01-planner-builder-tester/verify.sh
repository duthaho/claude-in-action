#!/usr/bin/env bash
set -euo pipefail

LAB_DIR="$(cd "$(dirname "$0")" && pwd)"
STARTER="$LAB_DIR/starter"
SETTINGS="$STARTER/.claude/settings.json"
AGENTS_DIR="$STARTER/.claude/agents"
SPEC="$STARTER/SPEC.md"
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

check_agent() {
  local name="$1"
  local file="$AGENTS_DIR/${name}.md"
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
  if ! echo "$fm" | grep -qE "^name:[[:space:]]*${name}[[:space:]]*$"; then
    echo "FAIL: $file frontmatter must have 'name: ${name}'"
    return 1
  fi
  if ! echo "$fm" | grep -q '^description:'; then
    echo "FAIL: $file must have a non-empty 'description:'"
    return 1
  fi
  if ! echo "$fm" | grep -q '^tools:'; then
    echo "FAIL: $file must declare a 'tools:' field so the teammate role is scoped"
    return 1
  fi
}

check_agent "planner" || fail=1
check_agent "builder" || fail=1
check_agent "tester" || fail=1

if [[ -f "$AGENTS_DIR/planner.md" ]]; then
  planner_tools=$(awk '/^---$/{c++; next} c==1 && /^tools:/{print; exit}' "$AGENTS_DIR/planner.md")
  for forbidden in Edit Write Bash; do
    if echo "$planner_tools" | grep -q "$forbidden"; then
      echo "FAIL: planner.md must NOT include $forbidden (planner is read-only)"
      fail=1
    fi
  done
fi

if [[ -f "$AGENTS_DIR/builder.md" ]]; then
  builder_tools=$(awk '/^---$/{c++; next} c==1 && /^tools:/{print; exit}' "$AGENTS_DIR/builder.md")
  if ! echo "$builder_tools" | grep -q 'Edit'; then
    echo "FAIL: builder.md must include Edit in its tools list"
    fail=1
  fi
  if echo "$builder_tools" | grep -q 'Bash'; then
    echo "FAIL: builder.md must NOT include Bash (tester owns running commands)"
    fail=1
  fi
fi

if [[ -f "$AGENTS_DIR/tester.md" ]]; then
  tester_tools=$(awk '/^---$/{c++; next} c==1 && /^tools:/{print; exit}' "$AGENTS_DIR/tester.md")
  if ! echo "$tester_tools" | grep -q 'Bash'; then
    echo "FAIL: tester.md must include Bash in its tools list (it runs the test command)"
    fail=1
  fi
  if echo "$tester_tools" | grep -q 'Edit'; then
    echo "FAIL: tester.md must NOT include Edit (tester is code-read-only)"
    fail=1
  fi
fi

if [[ ! -f "$SPEC" ]]; then
  echo "FAIL: expected $SPEC to exist"
  fail=1
fi

if [[ ! -f "$TEAM_PROMPT" ]]; then
  echo "FAIL: expected $TEAM_PROMPT to exist (the prompt the learner pastes to start the team)"
  fail=1
else
  for name in planner builder tester; do
    if ! grep -q "$name" "$TEAM_PROMPT"; then
      echo "FAIL: TEAM-PROMPT.md must reference teammate '$name'"
      fail=1
    fi
  done
fi

if [[ "$fail" -eq 0 ]]; then
  echo "PASS: planner-builder-tester team looks correct"
  exit 0
fi
exit 1
