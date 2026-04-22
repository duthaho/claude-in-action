#!/usr/bin/env bash
set -euo pipefail

LAB_DIR="$(cd "$(dirname "$0")" && pwd)"
STARTER="$LAB_DIR/starter"
CONSUMER="$STARTER/consumer.js"
FIXTURE="$STARTER/fixtures/events.jsonl"

fail=0

if [[ ! -f "$CONSUMER" ]]; then
  echo "FAIL: expected $CONSUMER to exist"
  exit 1
fi

if [[ ! -f "$FIXTURE" ]]; then
  echo "FAIL: expected $FIXTURE to exist — don't delete the captured stream"
  exit 1
fi

if ! command -v node >/dev/null 2>&1; then
  echo "FAIL: node is required to verify this lab — install Node 18+ and retry"
  exit 2
fi

# Source-level checks — a consumer that hard-codes the expected output could pass
# the runtime test without actually handling the event types. Require the
# learner to branch on all three meaningful types.
for pattern in '"system"' '"assistant"' '"result"'; do
  if ! grep -qF "$pattern" "$CONSUMER"; then
    echo "FAIL: consumer.js must branch on event.type === $pattern"
    fail=1
  fi
done

if ! grep -qE 'tool_use' "$CONSUMER"; then
  echo "FAIL: consumer.js must handle content blocks of type 'tool_use'"
  fail=1
fi

# Runtime check — pipe the fixture through the consumer and inspect the summary.
if output=$(node "$CONSUMER" < "$FIXTURE" 2>/dev/null); then
  check_line() {
    local needle="$1"
    if ! echo "$output" | grep -qF "$needle"; then
      echo "FAIL: consumer output missing expected line: $needle"
      echo "---- got ----"
      echo "$output"
      echo "-------------"
      fail=1
    fi
  }
  check_line "Session: demo-session-1"
  check_line "Model: claude-opus-4-7"
  check_line "Tools used: 2"
  check_line "Glob"
  check_line "Read"
  check_line "Tokens: 680/92"
  if ! echo "$output" | grep -q '^Final: .'; then
    echo "FAIL: consumer output missing non-empty 'Final: ...' line"
    fail=1
  fi
else
  echo "FAIL: node consumer.js exited non-zero on the fixture"
  fail=1
fi

if [[ "$fail" -eq 0 ]]; then
  echo "PASS: stream-json consumer handles the fixture correctly"
  exit 0
fi
exit 1
