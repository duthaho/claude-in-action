#!/usr/bin/env bash
set -euo pipefail

LAB_DIR="$(cd "$(dirname "$0")" && pwd)"
STARTER="$LAB_DIR/starter"
MOCKUP="$STARTER/mockup.html"
OUTPUT="$STARTER/output.html"

fail=0

if [[ ! -f "$MOCKUP" ]]; then
  echo "FAIL: expected $MOCKUP to exist — don't delete the mockup (it's the visual target)"
  fail=1
else
  # Mockup should still contain its source strings — learner must not have
  # edited the target to match the output.
  for needle in "Pacific Espresso" "\$18.50"; do
    if ! grep -qF "$needle" "$MOCKUP"; then
      echo "FAIL: mockup.html is missing '$needle' — don't edit the target, edit output.html"
      fail=1
    fi
  done
fi

if [[ ! -f "$OUTPUT" ]]; then
  echo "FAIL: expected $OUTPUT to exist"
  fail=1
else
  # Must no longer be the stub comment-only file.
  if ! grep -qE '<html|<body|<div' "$OUTPUT"; then
    echo "FAIL: output.html has no HTML elements — it still looks like the stub. Paste Claude's reproduction here."
    fail=1
  fi

  # Required text content from the mockup.
  for needle in "Pacific Espresso" "Medium roast" "Single origin" "18.50" "Chocolate" "Caramel" "Add to cart"; do
    if ! grep -qF "$needle" "$OUTPUT"; then
      echo "FAIL: output.html missing expected text from mockup: '$needle'"
      fail=1
    fi
  done
fi

if [[ "$fail" -eq 0 ]]; then
  echo "PASS: image-to-HTML reproduction carries the mockup's content"
  exit 0
fi
exit 1
