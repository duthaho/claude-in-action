#!/usr/bin/env bash
set -euo pipefail

LAB_DIR="$(cd "$(dirname "$0")" && pwd)"
STARTER="$LAB_DIR/starter"
EVALS="$STARTER/.claude/skills/slug-generator/evals.json"
NOTES="$STARTER/evals-notes.md"
RUNNER="$STARTER/evals_runner.py"

fail=0

for f in "$EVALS" "$NOTES" "$RUNNER"; do
  if [[ ! -f "$f" ]]; then
    echo "FAIL: missing $f"
    fail=1
  fi
done
[[ "$fail" -ne 0 ]] && exit 1

check=$(python - "$EVALS" <<'PY'
import json, sys
data = json.load(open(sys.argv[1]))
cases = data.get("cases", [])
errs = []
normal = [c for c in cases if not c.get("expected_failure", False)]
expected_fail = [c for c in cases if c.get("expected_failure", False)]
if len(normal) < 4:
    errs.append(f"need at least 4 normal cases, found {len(normal)}")
if len(expected_fail) < 1:
    errs.append("need at least one case marked 'expected_failure: true'")
for c in cases:
    if "name" not in c or "input" not in c or "expected" not in c:
        errs.append(f"case missing required fields: {c}")
print("\n".join(errs))
PY
)

if [[ -n "$check" ]]; then
  echo "FAIL (evals.json):"
  echo "$check"
  fail=1
fi

# Run the eval harness — must exit 0.
if ! (cd "$STARTER" && python evals_runner.py) >/dev/null 2>&1; then
  echo "FAIL: evals_runner.py exited non-zero — at least one eval case is actually failing"
  fail=1
fi

# Notes must mention several case names.
if ! grep -qiE 'basic|long|truncat|expected.?fail|punctuat' "$NOTES"; then
  echo "FAIL: evals-notes.md should document each eval case"
  fail=1
fi

if [[ "$fail" -eq 0 ]]; then
  echo "PASS: eval suite runs clean and notes are present"
  exit 0
fi
exit 1
