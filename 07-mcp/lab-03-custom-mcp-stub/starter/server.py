#!/usr/bin/env python3
"""Minimal MCP server stub — scaffold.

The main() loop reads one JSON-RPC message per line from stdin and writes
one JSON-RPC response per line to stdout. Your job is to fill in handle()
so it responds correctly to 'initialize', 'tools/list', and 'tools/call'.

The server exposes two tools:
  - get_quote()           — returns a random-looking quote from QUOTES
  - echo(text: str)       — returns the provided text verbatim

Run it manually with:
  echo '{"jsonrpc":"2.0","id":1,"method":"initialize","params":{}}' | python server.py
"""
from __future__ import annotations

import json
import sys
from typing import Any

QUOTES: list[str] = [
    # Fill in at least three quotes. They should be stable so tests can assert on them.
]


def handle(message: dict[str, Any]) -> dict[str, Any]:
    """Route a JSON-RPC message and return the response envelope.

    TODO: implement the three message types described in the lab README.
    For now, this raises so tests fail until you fill it in.
    """
    raise NotImplementedError("fill in handle()")


def main() -> int:
    for line in sys.stdin:
        line = line.strip()
        if not line:
            continue
        try:
            msg = json.loads(line)
        except json.JSONDecodeError:
            continue
        try:
            response = handle(msg)
        except Exception as exc:
            response = {
                "jsonrpc": "2.0",
                "id": msg.get("id"),
                "error": {"code": -32603, "message": f"internal error: {exc}"},
            }
        sys.stdout.write(json.dumps(response) + "\n")
        sys.stdout.flush()
    return 0


if __name__ == "__main__":
    sys.exit(main())
