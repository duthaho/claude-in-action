#!/usr/bin/env python3
"""Build library.db from scratch."""
from __future__ import annotations

import sqlite3
from pathlib import Path

DB = Path(__file__).parent / "library.db"


def main() -> None:
    if DB.exists():
        DB.unlink()
    con = sqlite3.connect(DB)
    cur = con.cursor()
    cur.executescript(
        """
        CREATE TABLE authors (
            id   INTEGER PRIMARY KEY,
            name TEXT NOT NULL
        );
        CREATE TABLE books (
            id        INTEGER PRIMARY KEY,
            title     TEXT NOT NULL,
            author_id INTEGER NOT NULL REFERENCES authors(id),
            year      INTEGER NOT NULL
        );
        CREATE TABLE checkouts (
            id             INTEGER PRIMARY KEY,
            book_id        INTEGER NOT NULL REFERENCES books(id),
            borrower       TEXT NOT NULL,
            checked_out_on TEXT NOT NULL,
            returned_on    TEXT
        );
        """
    )
    cur.executemany(
        "INSERT INTO authors (id, name) VALUES (?, ?);",
        [
            (1, "Ursula K. Le Guin"),
            (2, "Ted Chiang"),
            (3, "N. K. Jemisin"),
            (4, "Kim Stanley Robinson"),
        ],
    )
    cur.executemany(
        "INSERT INTO books (id, title, author_id, year) VALUES (?, ?, ?, ?);",
        [
            (1, "The Left Hand of Darkness", 1, 1969),
            (2, "The Dispossessed", 1, 1974),
            (3, "Exhalation", 2, 2019),
            (4, "Stories of Your Life and Others", 2, 2002),
            (5, "The Fifth Season", 3, 2015),
            (6, "The Stone Sky", 3, 2017),
            (7, "Red Mars", 4, 1992),
            (8, "2312", 4, 2012),
        ],
    )
    cur.executemany(
        "INSERT INTO checkouts (id, book_id, borrower, checked_out_on, returned_on) VALUES (?, ?, ?, ?, ?);",
        [
            (1, 1, "alice",   "2026-03-01", "2026-03-15"),
            (2, 5, "bob",     "2026-03-02", "2026-03-20"),
            (3, 3, "alice",   "2026-03-10", None),
            (4, 7, "charlie", "2026-03-11", "2026-03-18"),
            (5, 2, "dina",    "2026-03-12", None),
            (6, 5, "alice",   "2026-03-25", None),
        ],
    )
    con.commit()
    con.close()
    print(f"built {DB}")


if __name__ == "__main__":
    main()
