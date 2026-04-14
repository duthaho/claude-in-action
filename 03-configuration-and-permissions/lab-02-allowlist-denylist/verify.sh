#!/usr/bin/env bash
set -euo pipefail

LAB_DIR="$(cd "$(dirname "$0")" && pwd)"
STARTER="$LAB_DIR/starter"
SETTINGS="$STARTER/.claude/settings.json"
SECRET="$STARTER/secrets/api_key.txt"

fail=0

if [[ ! -f "$SECRET" ]]; then
  echo "FAIL: $SECRET missing (the target of the deny rule)"
  fail=1
fi

if [[ ! -f "$SETTINGS" ]]; then
  echo "FAIL: $SETTINGS does not exist"
  exit 1
fi

check=$(python - "$SETTINGS" <<'PY'
import json, sys
s = json.load(open(sys.argv[1]))
errs = []
perms = s.get("permissions")
if not isinstance(perms, dict):
    errs.append("permissions object missing")
else:
    allow = perms.get("allow", [])
    if not isinstance(allow, list):
        errs.append("permissions.allow must be an array")
    else:
        # Must be exactly the four read-only tools (in any order).
        needed = {"Read", "Grep", "Glob", "LS"}
        forbidden = {"Write", "Edit", "Bash", "NotebookEdit"}
        allow_set = set(allow)
        missing = needed - allow_set
        if missing:
            errs.append(f"allow list missing: {sorted(missing)}")
        leaked = forbidden & allow_set
        if leaked:
            errs.append(f"allow list contains write/exec tools: {sorted(leaked)}")

    deny = perms.get("deny", [])
    if not isinstance(deny, list):
        errs.append("permissions.deny must be an array")
    else:
        if not any("secrets" in str(rule) for rule in deny):
            errs.append("deny list must contain a rule referencing 'secrets'")
print("\n".join(errs))
PY
)

if [[ -n "$check" ]]; then
  echo "FAIL (settings.json):"
  echo "$check"
  fail=1
fi

if [[ "$fail" -eq 0 ]]; then
  echo "PASS: allow/deny lists correctly configured"
  exit 0
fi
exit 1
