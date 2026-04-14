#!/usr/bin/env python3
"""Minimal MCP server stub — solution.

Exposes two tools:
  - get_quote()           — returns the first quote from QUOTES (deterministic for tests)
  - echo(text: str)       — returns the provided text verbatim

Speaks JSON-RPC 2.0 over stdio with one message per line.
"""
from __future__ import annotations

import json
import sys
from typing import Any

QUOTES: list[str] = [
    "The only way out is through. — Robert Frost",
    "Make it work, make it right, make it fast. — Kent Beck",
    "Simplicity is prerequisite for reliability. — Dijkstra",
]

SERVER_NAME = "lab-stub"
SERVER_VERSION = "0.1.0"
PROTOCOL_VERSION = "2024-11-05"

TOOLS = [
    {
        "name": "get_quote",
        "description": "Return a fortune-style quote. Takes no arguments.",
        "inputSchema": {
            "type": "object",
            "properties": {},
            "required": [],
        },
    },
    {
        "name": "echo",
        "description": "Return the provided text verbatim. Useful for sanity-checking round-trip communication.",
        "inputSchema": {
            "type": "object",
            "properties": {
                "text": {"type": "string", "description": "Text to echo"},
            },
            "required": ["text"],
        },
    },
]


def _ok(msg_id: Any, result: dict) -> dict:
    return {"jsonrpc": "2.0", "id": msg_id, "result": result}


def _err(msg_id: Any, code: int, message: str) -> dict:
    return {"jsonrpc": "2.0", "id": msg_id, "error": {"code": code, "message": message}}


def handle(message: dict[str, Any]) -> dict[str, Any]:
    method = message.get("method")
    msg_id = message.get("id")
    params = message.get("params") or {}

    if method == "initialize":
        return _ok(
            msg_id,
            {
                "protocolVersion": PROTOCOL_VERSION,
                "capabilities": {"tools": {}},
                "serverInfo": {"name": SERVER_NAME, "version": SERVER_VERSION},
            },
        )

    if method == "tools/list":
        return _ok(msg_id, {"tools": TOOLS})

    if method == "tools/call":
        name = params.get("name")
        args = params.get("arguments") or {}
        if name == "get_quote":
            text = QUOTES[0] if QUOTES else ""
            return _ok(msg_id, {"content": [{"type": "text", "text": text}]})
        if name == "echo":
            return _ok(msg_id, {"content": [{"type": "text", "text": args.get("text", "")}]})
        return _err(msg_id, -32601, f"unknown tool: {name}")

    return _err(msg_id, -32601, f"method not found: {method}")


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
            response = _err(msg.get("id"), -32603, f"internal error: {exc}")
        sys.stdout.write(json.dumps(response) + "\n")
        sys.stdout.flush()
    return 0


if __name__ == "__main__":
    sys.exit(main())
