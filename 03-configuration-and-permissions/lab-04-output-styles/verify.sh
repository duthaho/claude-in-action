#!/usr/bin/env bash
set -euo pipefail

LAB_DIR="$(cd "$(dirname "$0")" && pwd)"
STARTER="$LAB_DIR/starter"
STYLE="$STARTER/.claude/output-styles/terse.md"
SETTINGS="$STARTER/.claude/settings.json"
NOTES="$STARTER/notes.md"

fail=0

if [[ ! -f "$STYLE" ]]; then
  echo "FAIL: $STYLE does not exist"
  exit 1
fi

# Frontmatter must open with --- on line 1.
if ! head -1 "$STYLE" | grep -q '^---$'; then
  echo "FAIL: terse.md must start with '---' (frontmatter)"
  fail=1
fi

# Extract frontmatter block.
frontmatter=$(awk '/^---$/{c++; next} c==1{print} c==2{exit}' "$STYLE")

if ! echo "$frontmatter" | grep -qE '^name:[[:space:]]*terse[[:space:]]*$'; then
  echo "FAIL: frontmatter must set 'name: terse'"
  fail=1
fi
if ! echo "$frontmatter" | grep -q '^description:'; then
  echo "FAIL: frontmatter must have a non-empty 'description' field"
  fail=1
fi

# Body must reference response shape (at least one of several keywords).
body=$(awk '/^---$/{c++; next} c==2{print}' "$STYLE")
if ! echo "$body" | grep -qiE 'code|preamble|prose|sentence|preambl'; then
  echo "FAIL: terse.md body should reference response shape (code/preamble/prose/sentence)"
  fail=1
fi

# settings.json must be valid JSON and set outputStyle=terse.
if [[ ! -f "$SETTINGS" ]]; then
  echo "FAIL: $SETTINGS does not exist"
  fail=1
else
  check=$(python - "$SETTINGS" <<'PY'
import json, sys
s = json.load(open(sys.argv[1]))
if s.get("outputStyle") != "terse":
    print("settings.json outputStyle must equal 'terse'")
PY
)
  if [[ -n "$check" ]]; then
    echo "FAIL: $check"
    fail=1
  fi
fi

# notes.md must have each of the three Q headings answered (non-empty content below).
if [[ ! -f "$NOTES" ]]; then
  echo "FAIL: $NOTES does not exist"
  fail=1
else
  check=$(python - "$NOTES" <<'PY'
import re, sys
text = open(sys.argv[1]).read()
# Split on Q headings, check each section past the first is non-empty past the placeholder.
sections = re.split(r'^## Q\d+:', text, flags=re.MULTILINE)
errs = []
if len(sections) < 4:
    errs.append("notes.md should have three '## Q' headings")
else:
    for i, body in enumerate(sections[1:], start=1):
        body = body.strip()
        # Strip any leading quoted question-restate line
        content = body
        if "(Your answer here.)" in content or len(content) < 80:
            errs.append(f"notes.md Q{i} still has the placeholder or is too short — write at least a paragraph")
print("\n".join(errs))
PY
)
  if [[ -n "$check" ]]; then
    echo "FAIL:"
    echo "$check"
    fail=1
  fi
fi

if [[ "$fail" -eq 0 ]]; then
  echo "PASS: custom output style wired correctly and classification notes written"
  exit 0
fi
exit 1
