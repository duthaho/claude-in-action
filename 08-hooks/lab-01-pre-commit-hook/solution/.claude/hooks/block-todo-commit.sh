#!/usr/bin/env bash
# PreToolUse hook: block `git commit` calls when any staged file contains TODO.
# Input: JSON on stdin with the Claude Code hook envelope (see docs).
# Output on block: JSON on stdout with permissionDecision: "deny".
# On allow: exit 0 with no output.

set -euo pipefail

envelope=$(cat < /dev/stdin)
command=$(printf '%s' "$envelope" | python -c "import json,sys; print(json.load(sys.stdin).get('tool_input',{}).get('command',''))")

if [[ "$command" != *"git commit"* ]]; then
  exit 0
fi

diff_out=$(git diff --cached 2>/dev/null || true)

if [[ -z "$diff_out" ]]; then
  exit 0
fi

if ! echo "$diff_out" | grep -qE '^\+.*\bTODO\b'; then
  exit 0
fi

python - <<'PY'
import json, sys
reason = (
    "Commit blocked: staged changes contain a TODO marker. "
    "Resolve or remove the TODO before committing, or amend the hook if this is intentional."
)
json.dump({
    "hookSpecificOutput": {
        "hookEventName": "PreToolUse",
        "permissionDecision": "deny",
        "permissionDecisionReason": reason,
    }
}, sys.stdout)
PY
