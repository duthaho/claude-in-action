#!/usr/bin/env python3
"""Tiny todo CLI used as shared starter material across several labs.

Subcommands:
    add "<text>"     append a new todo
    list              print all todos with their index and state
    done <index>      mark the todo at <index> as done

Storage: a JSON file at ./todos.json in the current working directory.
Keep this small and dependency-free on purpose — it is a learning target,
not a product. Labs that need richer behavior should extend it in their
own starter/ copy.
"""
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


def cmd_add(text: str) -> int:
    todos = load()
    todos.append({"text": text, "done": False})
    save(todos)
    print(f"added: {text}")
    return 0


def cmd_list() -> int:
    todos = load()
    if not todos:
        print("(no todos)")
        return 0
    for i, t in enumerate(todos):
        mark = "x" if t["done"] else " "
        print(f"{i}: [{mark}] {t['text']}")
    return 0


def cmd_done(index_str: str) -> int:
    todos = load()
    try:
        index = int(index_str)
    except ValueError:
        print(f"not a number: {index_str}", file=sys.stderr)
        return 2
    if index < 0 or index >= len(todos):
        print(f"index out of range: {index}", file=sys.stderr)
        return 2
    todos[index]["done"] = True
    save(todos)
    print(f"done: {todos[index]['text']}")
    return 0


def main(argv: list[str]) -> int:
    if len(argv) < 2:
        print("usage: todo.py {add|list|done} [args...]", file=sys.stderr)
        return 2
    cmd = argv[1]
    if cmd == "add":
        if len(argv) < 3:
            print("usage: todo.py add <text>", file=sys.stderr)
            return 2
        return cmd_add(" ".join(argv[2:]))
    if cmd == "list":
        return cmd_list()
    if cmd == "done":
        if len(argv) != 3:
            print("usage: todo.py done <index>", file=sys.stderr)
            return 2
        return cmd_done(argv[2])
    print(f"unknown command: {cmd}", file=sys.stderr)
    return 2


if __name__ == "__main__":
    sys.exit(main(sys.argv))
