#!/usr/bin/env python3
"""Print the library.db schema and a few sample rows."""
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
    print("\n=== sample rows ===")
    for table in ("authors", "books", "checkouts"):
        print(f"\n-- {table}")
        for row in cur.execute(f"SELECT * FROM {table} LIMIT 3;"):
            print(f"  {row}")
    con.close()
    return 0


if __name__ == "__main__":
    sys.exit(main())
