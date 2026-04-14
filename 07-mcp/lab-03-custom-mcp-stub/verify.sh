#!/usr/bin/env bash
set -euo pipefail

LAB_DIR="$(cd "$(dirname "$0")" && pwd)"
STARTER="$LAB_DIR/starter"
SERVER="$STARTER/server.py"
TESTS="$STARTER/test_server.py"
MCP="$STARTER/.mcp.json"

fail=0

for f in "$SERVER" "$TESTS" "$MCP"; do
  if [[ ! -f "$f" ]]; then
    echo "FAIL: missing $f"
    fail=1
  fi
done
[[ "$fail" -ne 0 ]] && exit 1

# Run the protocol tests — all must pass.
if ! (cd "$STARTER" && python -m unittest -v test_server.py) 2>&1 | tail -20; then
  echo "FAIL: test_server.py did not all pass"
  fail=1
fi
if ! (cd "$STARTER" && python -m unittest test_server.py) >/dev/null 2>&1; then
  echo "FAIL: test_server.py has failing tests"
  fail=1
fi

# .mcp.json must wire lab-stub to python server.py.
mcp_check=$(python - "$MCP" <<'PY'
import json, sys
data = json.load(open(sys.argv[1]))
errs = []
servers = data.get("mcpServers", {})
stub = servers.get("lab-stub")
if not stub:
    errs.append("mcpServers.lab-stub missing")
else:
    if stub.get("type", "stdio") != "stdio":
        errs.append("lab-stub.type must be 'stdio'")
    if "python" not in str(stub.get("command", "")):
        errs.append("lab-stub.command must invoke python")
    args = stub.get("args", [])
    if not any("server.py" in str(a) for a in args):
        errs.append("lab-stub.args must reference server.py")
print("\n".join(errs))
PY
)
if [[ -n "$mcp_check" ]]; then
  echo "FAIL (.mcp.json):"
  echo "$mcp_check"
  fail=1
fi

# server.py must handle the three methods.
for method in 'initialize' 'tools/list' 'tools/call'; do
  if ! grep -q "\"$method\"\|'$method'" "$SERVER"; then
    echo "FAIL: server.py should handle '$method'"
    fail=1
  fi
done

if [[ "$fail" -eq 0 ]]; then
  echo "PASS: custom MCP stub server is functional"
  exit 0
fi
exit 1
