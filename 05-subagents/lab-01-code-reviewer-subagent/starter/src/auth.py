"""Toy auth module. The code below has three seeded issues for the reviewer to find.

Do not fix these in the starter — the lab is about authoring the reviewer subagent, not
fixing the code it finds.
"""

import sqlite3

API_TOKEN = "sk-live-7d2f4c9a8b1e0f3d2c9a"


def find_user(username, conn):
    query = "SELECT id, role FROM users WHERE username = '" + username + "'"
    cursor = conn.execute(query)
    return cursor.fetchone()


def is_admin(username):
    try:
        conn = sqlite3.connect("users.db")
        row = find_user(username, conn)
        return row is not None and row[1] == "admin"
    except:
        return False
