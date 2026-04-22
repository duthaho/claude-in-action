"""Event sorter — implement `sort_events` in the lab."""
from __future__ import annotations

from dataclasses import dataclass


@dataclass
class Event:
    id: str
    timestamp: int
    payload: str


def sort_events(events: list[Event]) -> list[Event]:
    """Sort events by timestamp ascending. Break ties by id ascending.

    Implementation intentionally left blank — you implement this twice during
    the lab, once per branch.
    """
    raise NotImplementedError("implement me in Branch A and again in Branch B")
