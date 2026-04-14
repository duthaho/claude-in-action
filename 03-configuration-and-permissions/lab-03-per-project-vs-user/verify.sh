#!/usr/bin/env bash
set -euo pipefail

LAB_DIR="$(cd "$(dirname "$0")" && pwd)"
STARTER="$LAB_DIR/starter"
USER_F="$STARTER/fake-home/.claude/settings.json"
PROJ_F="$STARTER/.claude/settings.json"
ANALYSIS="$STARTER/analysis.md"

fail=0

for f in "$USER_F" "$PROJ_F"; do
  if [[ ! -f "$f" ]]; then
    echo "FAIL: missing $f"
    exit 1
  fi
  if ! python -c "import json,sys; json.load(open(sys.argv[1]))" "$f" 2>/dev/null; then
    echo "FAIL: $f is not valid JSON"
    exit 1
  fi
done

check=$(python - "$USER_F" "$PROJ_F" <<'PY'
import json, sys
user = json.load(open(sys.argv[1]))
proj = json.load(open(sys.argv[2]))
errs = []

# Project should NOT have an empty env object. Either absent or non-empty.
if "env" in proj:
    if not isinstance(proj["env"], dict) or len(proj["env"]) == 0:
        errs.append("project settings.json still has an empty or invalid 'env' object — delete the key entirely so the user value passes through")

# Project must keep model and permissions.defaultMode.
if not isinstance(proj.get("model"), str) or not proj.get("model"):
    errs.append("project settings.json must keep a non-empty 'model' value")
perms = proj.get("permissions", {})
if not isinstance(perms, dict) or not perms.get("defaultMode"):
    errs.append("project settings.json must keep 'permissions.defaultMode'")

# User must keep env.EDITOR = "vim" and apiKeyHelper.
if user.get("env", {}).get("EDITOR") != "vim":
    errs.append("user settings.json must still have env.EDITOR == 'vim'")
if not isinstance(user.get("apiKeyHelper"), str) or not user.get("apiKeyHelper"):
    errs.append("user settings.json must still have apiKeyHelper set")

print("\n".join(errs))
PY
)

if [[ -n "$check" ]]; then
  echo "FAIL:"
  echo "$check"
  fail=1
fi

if [[ ! -f "$ANALYSIS" ]]; then
  echo "FAIL: $ANALYSIS does not exist — write the precedence analysis"
  fail=1
else
  if ! grep -qiE '^#+ *before' "$ANALYSIS"; then
    echo "FAIL: analysis.md needs a 'Before' section"
    fail=1
  fi
  if ! grep -qiE '^#+ *after' "$ANALYSIS"; then
    echo "FAIL: analysis.md needs an 'After' section"
    fail=1
  fi
fi

if [[ "$fail" -eq 0 ]]; then
  echo "PASS: precedence conflict resolved and documented"
  exit 0
fi
exit 1
