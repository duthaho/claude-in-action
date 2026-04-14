#!/usr/bin/env python3
"""Tiny todo CLI. See CLAUDE.md for conventions."""
from __future__ import annotations

import sys


def main(argv: list[str]) -> int:
    if len(argv) < 2:
        print("usage: todo.py {add|list|done} [args...]", file=sys.stderr)
        return 2
    return 0


if __name__ == "__main__":
    sys.exit(main(sys.argv))
