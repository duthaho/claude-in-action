# BRANCHES — lab-02-branching-explorations

This is the *shape* of the document you produce in the lab root. Your exact code may differ slightly in formatting; the paragraph text should reflect your own reasoning.

## Branch A

In-place sort by timestamp only:

```python
def sort_events(events: list[Event]) -> list[Event]:
    events.sort(key=lambda e: e.timestamp)
    return events
```

Trade-offs: minimal code, zero allocation. Mutates the caller's list — any reference they held to `events` now points to a sorted sequence. Python's sort is stable, so events that share a timestamp keep their *input* order — which looks deterministic in casual testing but depends entirely on how the caller constructed the list. The `test_tied_timestamps_broken_by_id` test *fails* here: the input had `zeta` before `alpha`, and a stable sort by timestamp preserves that. A real caller might be surprised.

## Branch B

Pure function with explicit tie-breaker:

```python
def sort_events(events: list[Event]) -> list[Event]:
    return sorted(events, key=lambda e: (e.timestamp, e.id))
```

Trade-offs: pure — the input list is untouched, so callers can rely on that. The tuple `key` makes tie-breaking explicit and deterministic: two events with the same timestamp now sort by `id` ascending, matching the docstring contract. The cost is one allocation (a new list) — negligible for any realistic input size, and worth it for the clearer semantics. Both tests pass.

## Decision

I adopt **Branch B**. The tie-breaking by `id` matches the docstring contract (which `test_tied_timestamps_broken_by_id` pins), and the pure-function shape makes the API easier to reason about — a caller reading `sorted = sort_events(events)` never has to wonder whether `events` itself was mutated. The allocation cost is not a real concern at the scale this code is likely to run.

Branch A would be the better pick in one specific case: if this function were a hot path on very large lists *and* we knew the caller never reused the input after calling. That's not the situation here — but it's a judgement call worth writing down.
