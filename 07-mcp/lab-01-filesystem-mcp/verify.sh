#!/usr/bin/env bash
set -euo pipefail

LAB_DIR="$(cd "$(dirname "$0")" && pwd)"
MCP="$LAB_DIR/starter/.mcp.json"

fail=0

if [[ ! -f "$MCP" ]]; then
  echo "FAIL: $MCP does not exist"
  exit 1
fi

if ! python -c "import json,sys; json.load(open(sys.argv[1]))" "$MCP" 2>/dev/null; then
  echo "FAIL: .mcp.json is not valid JSON"
  exit 1
fi

check=$(python - "$MCP" <<'PY'
import json, sys
data = json.load(open(sys.argv[1]))
errs = []

servers = data.get("mcpServers")
if not isinstance(servers, dict):
    errs.append("top-level 'mcpServers' must be an object")
else:
    # Must have docs-fs, must NOT have home-fs (step 6).
    if "docs-fs" not in servers:
        errs.append("mcpServers.docs-fs missing")
    if "home-fs" in servers:
        errs.append("mcpServers.home-fs should have been removed in step 6")

    docs = servers.get("docs-fs", {})
    if not isinstance(docs, dict):
        errs.append("docs-fs must be an object")
    else:
        t = docs.get("type", "stdio")
        if t != "stdio":
            errs.append(f"docs-fs.type must be 'stdio', got {t!r}")
        if not isinstance(docs.get("command"), str) or not docs.get("command"):
            errs.append("docs-fs.command must be a non-empty string")
        args = docs.get("args", [])
        if not isinstance(args, list):
            errs.append("docs-fs.args must be a list")
        else:
            if not any("docs" in str(a) for a in args):
                errs.append("docs-fs.args must scope the server to './docs' (no arg references 'docs')")
            # It should NOT contain just "." as the scope.
            if "." in args:
                errs.append("docs-fs.args contains bare '.' — the server must be scoped to ./docs, not the repo root")

print("\n".join(errs))
PY
)

if [[ -n "$check" ]]; then
  echo "FAIL:"
  echo "$check"
  fail=1
fi

if [[ "$fail" -eq 0 ]]; then
  echo "PASS: .mcp.json wires docs-fs correctly and home-fs was removed"
  exit 0
fi
exit 1
