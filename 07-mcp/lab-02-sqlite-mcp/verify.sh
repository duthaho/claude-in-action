#!/usr/bin/env bash
set -euo pipefail

LAB_DIR="$(cd "$(dirname "$0")" && pwd)"
STARTER="$LAB_DIR/starter"
MCP="$STARTER/.mcp.json"
QUERIES="$STARTER/queries.md"
BUILD="$STARTER/build_db.py"
DB="$STARTER/library.db"

fail=0

for f in "$BUILD" "$MCP" "$QUERIES"; do
  if [[ ! -f "$f" ]]; then
    echo "FAIL: missing $f"
    fail=1
  fi
done
[[ "$fail" -ne 0 ]] && exit 1

# Build the DB if it doesn't exist — verifier should be idempotent.
if [[ ! -f "$DB" ]]; then
  (cd "$STARTER" && python build_db.py) >/dev/null
fi

# Verify DB has the expected tables.
db_check=$(python - "$DB" <<'PY'
import sqlite3, sys
con = sqlite3.connect(sys.argv[1])
cur = con.cursor()
tables = {row[0] for row in cur.execute("SELECT name FROM sqlite_master WHERE type='table';")}
needed = {"authors", "books", "checkouts"}
missing = needed - tables
if missing:
    print(f"library.db missing tables: {sorted(missing)}")
PY
)
if [[ -n "$db_check" ]]; then
  echo "FAIL: $db_check"
  fail=1
fi

# Verify .mcp.json shape.
mcp_check=$(python - "$MCP" <<'PY'
import json, sys
data = json.load(open(sys.argv[1]))
errs = []
servers = data.get("mcpServers", {})
if "library-db" not in servers:
    errs.append("mcpServers.library-db missing")
else:
    entry = servers["library-db"]
    if entry.get("type", "stdio") != "stdio":
        errs.append("library-db.type must be 'stdio'")
    if not isinstance(entry.get("command"), str):
        errs.append("library-db.command must be a string")
    args = entry.get("args", [])
    if not any("library.db" in str(a) for a in args):
        errs.append("library-db.args must reference library.db")
print("\n".join(errs))
PY
)
if [[ -n "$mcp_check" ]]; then
  echo "FAIL (mcp.json):"
  echo "$mcp_check"
  fail=1
fi

# Verify queries.md structure.
if ! grep -qE '^## Tools' "$QUERIES"; then
  echo "FAIL: queries.md missing '## Tools' section"
  fail=1
fi
if ! grep -qE '^## Queries' "$QUERIES"; then
  echo "FAIL: queries.md missing '## Queries' section"
  fail=1
fi

q_count=$(grep -cE '^### Q[0-9]' "$QUERIES" || true)
if [[ "${q_count:-0}" -lt 5 ]]; then
  echo "FAIL: queries.md has ${q_count:-0} questions, need at least 5"
  fail=1
fi

if ! grep -qiE 'list_tables|describe_table' "$QUERIES"; then
  echo "FAIL: queries.md must include at least one discovery question using list_tables or describe_table"
  fail=1
fi

if [[ "$fail" -eq 0 ]]; then
  echo "PASS: sqlite MCP lab artifacts all correct"
  exit 0
fi
exit 1
