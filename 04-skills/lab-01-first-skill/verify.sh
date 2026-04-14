#!/usr/bin/env bash
set -euo pipefail

LAB_DIR="$(cd "$(dirname "$0")" && pwd)"
SKILL="$LAB_DIR/starter/.claude/skills/changelog-writer/SKILL.md"

fail=0

if [[ ! -f "$SKILL" ]]; then
  echo "FAIL: expected $SKILL to exist"
  exit 1
fi

# Must have frontmatter delimiters.
if ! head -1 "$SKILL" | grep -q '^---$'; then
  echo "FAIL: SKILL.md must start with '---' (frontmatter open)"
  fail=1
fi

# Extract frontmatter block (lines between the first two '---').
frontmatter=$(awk '/^---$/{c++; next} c==1{print} c==2{exit}' "$SKILL")

if ! echo "$frontmatter" | grep -qE '^name:[[:space:]]*changelog-writer[[:space:]]*$'; then
  echo "FAIL: frontmatter must have 'name: changelog-writer'"
  fail=1
fi

if ! echo "$frontmatter" | grep -q '^description:'; then
  echo "FAIL: frontmatter must have a 'description:' field"
  fail=1
fi

# Description should mention changelog or release notes.
desc_line=$(echo "$frontmatter" | grep -i '^description:' || true)
if ! echo "$desc_line" | grep -qiE 'changelog|release note'; then
  echo "FAIL: description should mention 'changelog' or 'release notes' so Claude can match it"
  fail=1
fi

# Body should mention git log and either Keep a Changelog or a category name.
body=$(awk '/^---$/{c++; next} c==2{print}' "$SKILL")

if ! echo "$body" | grep -q 'git log'; then
  echo "FAIL: body should tell Claude to run 'git log'"
  fail=1
fi

if ! echo "$body" | grep -qiE 'keep a changelog|### Added|### Fixed|### Changed'; then
  echo "FAIL: body should reference 'Keep a Changelog' or one of its category headings"
  fail=1
fi

if [[ "$fail" -eq 0 ]]; then
  echo "PASS: changelog-writer skill looks correct"
  exit 0
fi
exit 1
