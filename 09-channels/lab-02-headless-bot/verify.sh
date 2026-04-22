#!/usr/bin/env bash
set -euo pipefail

LAB_DIR="$(cd "$(dirname "$0")" && pwd)"
STARTER="$LAB_DIR/starter"
SCRIPT="$STARTER/watch-inbox.sh"
INBOX="$STARTER/inbox"
OUTBOX="$STARTER/outbox"

fail=0

if [[ ! -f "$SCRIPT" ]]; then
  echo "FAIL: expected $SCRIPT to exist"
  exit 1
fi

# Shape checks — guard against a learner who skips the TODOs and hard-codes a
# single-file copy. Idempotency, claude call, and loop are all required.
if ! grep -qE '\[\[ -f .*dest|-f[[:space:]]+"\$dest"' "$SCRIPT"; then
  echo "FAIL: watch-inbox.sh must check for an existing output file (idempotency)"
  fail=1
fi

if ! grep -qE 'claude -p' "$SCRIPT"; then
  echo "FAIL: watch-inbox.sh must invoke 'claude -p' somewhere"
  fail=1
fi

if ! grep -qE 'for[[:space:]]+[A-Za-z_]+[[:space:]]+in[[:space:]]+"?\$INBOX' "$SCRIPT"; then
  echo "FAIL: watch-inbox.sh must iterate \"\$INBOX\"/* in a for-loop"
  fail=1
fi

if ! grep -qE 'command -v claude|which claude' "$SCRIPT"; then
  echo "FAIL: watch-inbox.sh must use 'command -v claude' (or equivalent) so it degrades gracefully when claude is missing"
  fail=1
fi

# Fixture inbox files must still be there — deleting them breaks the lab.
for fixture in "2026-01-14-standup.txt" "feature-request.md"; do
  if [[ ! -f "$INBOX/$fixture" ]]; then
    echo "FAIL: expected starter/inbox/$fixture — don't delete the fixtures"
    fail=1
  fi
done

# Runtime check — actually run the bot and confirm every inbox file produced an
# outbox entry. Clean the outbox first so this is a fresh pass.
find "$OUTBOX" -maxdepth 1 -name '*.summary.md' -type f -delete 2>/dev/null || true

if ! bash "$SCRIPT" >/dev/null 2>&1; then
  echo "FAIL: bash watch-inbox.sh exited non-zero on the starter inbox"
  fail=1
else
  for fixture in "2026-01-14-standup.txt" "feature-request.md"; do
    expected="$OUTBOX/$fixture.summary.md"
    if [[ ! -f "$expected" ]]; then
      echo "FAIL: expected $expected after running the bot"
      fail=1
    elif [[ ! -s "$expected" ]]; then
      echo "FAIL: $expected exists but is empty — the bot wrote nothing to it"
      fail=1
    fi
  done

  # Second run must be idempotent — it must produce no new files and exit 0.
  before=$(find "$OUTBOX" -maxdepth 1 -name '*.summary.md' -type f | wc -l | tr -d ' ')
  bash "$SCRIPT" >/dev/null 2>&1 || { echo "FAIL: second run of watch-inbox.sh failed"; fail=1; }
  after=$(find "$OUTBOX" -maxdepth 1 -name '*.summary.md' -type f | wc -l | tr -d ' ')
  if [[ "$before" != "$after" ]]; then
    echo "FAIL: second run changed outbox file count ($before → $after) — bot is not idempotent"
    fail=1
  fi
fi

if [[ "$fail" -eq 0 ]]; then
  echo "PASS: headless bot processes the inbox and is idempotent"
  exit 0
fi
exit 1
