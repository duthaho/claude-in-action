#!/usr/bin/env bash
# Offline test fixture for block-prod-writes.sh.
# Feeds canned envelopes via stdin and asserts exit + stdout behaviour.
# Run with: bash .claude/hooks/test_block_prod_writes.sh

set -euo pipefail

HOOK_DIR="$(cd "$(dirname "$0")" && pwd)"
HOOK="$HOOK_DIR/block-prod-writes.sh"
# project root = two levels up from .claude/hooks/
export CLAUDE_PROJECT_DIR="$(cd "$HOOK_DIR/../.." && pwd)"

pass=0
fail=0

run_case() {
  local label="$1"
  local envelope="$2"
  local expect_block="$3"  # "block" or "allow"

  local out
  out=$(printf '%s' "$envelope" | bash "$HOOK" 2>/dev/null || true)

  if [[ "$expect_block" == "block" ]]; then
    if echo "$out" | grep -q '"permissionDecision": "deny"'; then
      echo "PASS: $label (blocked as expected)"
      pass=$((pass + 1))
    else
      echo "FAIL: $label (expected deny JSON, got: ${out:-<empty>})"
      fail=$((fail + 1))
    fi
  else
    if [[ -z "$out" ]]; then
      echo "PASS: $label (allowed as expected)"
      pass=$((pass + 1))
    else
      echo "FAIL: $label (expected silent allow, got: $out)"
      fail=$((fail + 1))
    fi
  fi
}

run_case "prod/config.yaml"              '{"tool_input":{"file_path":"prod/config.yaml"}}'           block
run_case "dev/config.yaml"               '{"tool_input":{"file_path":"dev/config.yaml"}}'            allow
run_case "prod/../dev/x.yaml (normalised to dev/)" '{"tool_input":{"file_path":"prod/../dev/x.yaml"}}' allow

echo ""
echo "Summary: $pass passed, $fail failed"
[[ $fail -eq 0 ]] || exit 1
