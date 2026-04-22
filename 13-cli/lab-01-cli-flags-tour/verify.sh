#!/usr/bin/env bash
set -euo pipefail

LAB_DIR="$(cd "$(dirname "$0")" && pwd)"
STARTER="$LAB_DIR/starter"
DRIVE="$STARTER/drive.sh"

fail=0

if [[ ! -f "$DRIVE" ]]; then
  echo "FAIL: expected $DRIVE to exist"
  exit 1
fi

# Check against code only — strip shell comment lines so the hints in the
# starter TODO comments don't accidentally satisfy the grep.
CODE=$(grep -v '^[[:space:]]*#' "$DRIVE" || true)

check_pattern() {
  local pattern="$1" message="$2"
  if ! echo "$CODE" | grep -qE -- "$pattern"; then
    echo "FAIL: $message"
    fail=1
  fi
}

# Each task function must still be defined (don't rename them).
for fn in task_one_print task_two_output_format task_three_append_system task_four_restrict_tools task_five_max_turns; do
  if ! grep -qE "^${fn}\s*\(\)" "$DRIVE"; then
    echo "FAIL: drive.sh must still define function ${fn} — don't rename it"
    fail=1
  fi
done

# Required flags in actual code lines.
if ! echo "$CODE" | grep -qE 'claude[[:space:]]+-p([[:space:]]|$)' && \
   ! echo "$CODE" | grep -qE 'claude[[:space:]]+--print([[:space:]]|$)'; then
  echo "FAIL: drive.sh must actually invoke 'claude -p' (or --print) in at least one task"
  fail=1
fi

check_pattern '--output-format[[:space:]]+json' "drive.sh must use --output-format json in a real claude invocation (not just a comment)"
check_pattern '--append-system-prompt' "drive.sh must use --append-system-prompt in a real claude invocation"
check_pattern '--allowedTools' "drive.sh must use --allowedTools in a real claude invocation"
check_pattern '--max-turns[[:space:]]+[0-9]+' "drive.sh must use --max-turns <N> in a real claude invocation"

# Reject stub functions — bare ':' no-op shouldn't remain in any task.
if grep -qE '^[[:space:]]+:[[:space:]]*$' "$DRIVE"; then
  echo "FAIL: drive.sh still has a bare ':' no-op inside a task function — replace TODO stubs with real claude invocations"
  fail=1
fi

if [[ "$fail" -eq 0 ]]; then
  echo "PASS: CLI flags tour covers all five required flags"
  exit 0
fi
exit 1
