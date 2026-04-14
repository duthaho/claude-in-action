#!/usr/bin/env bash
set -euo pipefail

LAB_DIR="$(cd "$(dirname "$0")" && pwd)"
SKILL_DIR="$LAB_DIR/starter/.claude/skills/adr-writer"
SKILL="$SKILL_DIR/SKILL.md"
SHORT="$SKILL_DIR/resources/template-short.md"
LONG="$SKILL_DIR/resources/template-long.md"

fail=0

for f in "$SKILL" "$SHORT" "$LONG"; do
  if [[ ! -f "$f" ]]; then
    echo "FAIL: missing $f"
    fail=1
  fi
done
[[ "$fail" -ne 0 ]] && exit 1

# Skill frontmatter checks.
frontmatter=$(awk '/^---$/{c++; next} c==1{print} c==2{exit}' "$SKILL")
if ! echo "$frontmatter" | grep -qE '^name:[[:space:]]*adr-writer[[:space:]]*$'; then
  echo "FAIL: frontmatter must have 'name: adr-writer'"
  fail=1
fi
desc_line=$(echo "$frontmatter" | grep -i '^description:' || true)
if ! echo "$desc_line" | grep -qiE 'adr|architecture decision|decision record'; then
  echo "FAIL: description should mention ADR, architecture decision, or decision record"
  fail=1
fi

body=$(awk '/^---$/{c++; next} c==2{print}' "$SKILL")

# Body must reference both resource files by relative path.
if ! echo "$body" | grep -q 'resources/template-short.md'; then
  echo "FAIL: body must reference 'resources/template-short.md'"
  fail=1
fi
if ! echo "$body" | grep -q 'resources/template-long.md'; then
  echo "FAIL: body must reference 'resources/template-long.md'"
  fail=1
fi

# Body must mention numbering and the output path pattern.
if ! echo "$body" | grep -qiE 'NNNN|highest|next.*number'; then
  echo "FAIL: body should describe ADR numbering behavior (NNNN / highest / next number)"
  fail=1
fi
if ! echo "$body" | grep -q 'docs/adr'; then
  echo "FAIL: body should reference the docs/adr output path"
  fail=1
fi

# Short template has the expected three headings.
for needle in '^# ADR' '^## Status' '^## Decision'; do
  if ! grep -qE "$needle" "$SHORT"; then
    echo "FAIL: template-short.md missing heading matching: $needle"
    fail=1
  fi
done

# Long template has additional sections.
for needle in '^## Context' '^## Consequences' '^## Alternatives considered'; do
  if ! grep -qE "$needle" "$LONG"; then
    echo "FAIL: template-long.md missing heading: $needle"
    fail=1
  fi
done

if [[ "$fail" -eq 0 ]]; then
  echo "PASS: adr-writer skill with bundled resources looks correct"
  exit 0
fi
exit 1
