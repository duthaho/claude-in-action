#!/usr/bin/env python3
"""Print the library.db schema and a few sample rows so you can see what the
MCP server will expose. Run this from the lab's starter directory.
"""
from __future__ import annotations

import sqlite3
import sys
from pathlib import Path

DB = Path(__file__).parent / "library.db"


def main() -> int:
    if not DB.exists():
        print(f"{DB} does not exist — run `python build_db.py` first", file=sys.stderr)
        return 2

    con = sqlite3.connect(DB)
    cur = con.cursor()

    print("=== tables ===")
    for (name,) in cur.execute("SELECT name FROM sqlite_master WHERE type='table' ORDER BY name;"):
        print(f"  {name}")

    print("\n=== schemas ===")
    for (name,) in cur.execute("SELECT name FROM sqlite_master WHERE type='table' ORDER BY name;"):
        print(f"\n-- {name}")
        for row in cur.execute(f"PRAGMA table_info({name});"):
            cid, col_name, col_type, notnull, dflt, pk = row
            flags = []
            if pk:
                flags.append("PK")
            if notnull:
                flags.append("NOT NULL")
            print(f"  {col_name}: {col_type} {' '.join(flags)}")

    print("\n=== sample rows ===")
    for table in ("authors", "books", "checkouts"):
        print(f"\n-- {table}")
        for row in cur.execute(f"SELECT * FROM {table} LIMIT 3;"):
            print(f"  {row}")

    con.close()
    return 0


if __name__ == "__main__":
    sys.exit(main())
