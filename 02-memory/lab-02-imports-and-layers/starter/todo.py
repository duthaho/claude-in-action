#!/usr/bin/env python3
"""Tiny todo CLI."""
from __future__ import annotations

import json
import sys
from pathlib import Path

STORE = Path("todos.json")


def load() -> list[dict]:
    if not STORE.exists():
        return []
    return json.loads(STORE.read_text(encoding="utf-8"))


def save(todos: list[dict]) -> None:
    STORE.write_text(json.dumps(todos, indent=2), encoding="utf-8")


def main(argv: list[str]) -> int:
    if len(argv) < 2:
        print("usage: todo.py {add|list|done} [args...]", file=sys.stderr)
        return 2
    return 0


if __name__ == "__main__":
    sys.exit(main(sys.argv))
