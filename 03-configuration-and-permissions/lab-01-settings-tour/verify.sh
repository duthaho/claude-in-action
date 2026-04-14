#!/usr/bin/env bash
set -euo pipefail

LAB_DIR="$(cd "$(dirname "$0")" && pwd)"
STARTER="$LAB_DIR/starter"
SETTINGS="$STARTER/.claude/settings.json"
LOCAL="$STARTER/.claude/settings.local.json"
GITIGNORE="$STARTER/.gitignore"

fail=0

if [[ ! -f "$SETTINGS" ]]; then
  echo "FAIL: $SETTINGS does not exist"
  exit 1
fi

if ! python -c "import json,sys; json.load(open(sys.argv[1]))" "$SETTINGS" 2>/dev/null; then
  echo "FAIL: $SETTINGS is not valid JSON"
  exit 1
fi

# Check required keys via Python (cross-platform).
check_project=$(python - "$SETTINGS" <<'PY'
import json, sys
s = json.load(open(sys.argv[1]))
errs = []
model = s.get("model")
if not isinstance(model, str) or not model or model == "default":
    errs.append("model must be a non-empty string other than 'default'")
env = s.get("env")
if not isinstance(env, dict) or env.get("LAB_MODE") != "true":
    errs.append("env.LAB_MODE must equal the string 'true'")
perms = s.get("permissions")
if not isinstance(perms, dict) or not perms.get("defaultMode"):
    errs.append("permissions.defaultMode must be set")
print("\n".join(errs))
PY
)

if [[ -n "$check_project" ]]; then
  echo "FAIL (project settings.json):"
  echo "$check_project"
  fail=1
fi

if [[ ! -f "$LOCAL" ]]; then
  echo "FAIL: $LOCAL does not exist (step 5 not done)"
  fail=1
else
  check_local=$(python - "$LOCAL" <<'PY'
import json, sys
s = json.load(open(sys.argv[1]))
perms = s.get("permissions", {})
if perms.get("defaultMode") != "bypassPermissions":
    print("settings.local.json must set permissions.defaultMode to 'bypassPermissions'")
PY
)
  if [[ -n "$check_local" ]]; then
    echo "FAIL (local settings): $check_local"
    fail=1
  fi
fi

if [[ ! -f "$GITIGNORE" ]] || ! grep -q '^\.claude/settings\.local\.json' "$GITIGNORE"; then
  echo "FAIL: .gitignore must contain '.claude/settings.local.json' (step 7)"
  fail=1
fi

if [[ "$fail" -eq 0 ]]; then
  echo "PASS: settings.json, settings.local.json, and .gitignore all correct"
  exit 0
fi
exit 1
