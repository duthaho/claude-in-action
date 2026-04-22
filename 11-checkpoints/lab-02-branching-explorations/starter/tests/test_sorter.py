from src.sorter import Event, sort_events


def test_unique_timestamps():
    events = [
        Event(id="a", timestamp=3, payload="x"),
        Event(id="b", timestamp=1, payload="y"),
        Event(id="c", timestamp=2, payload="z"),
    ]
    result = sort_events(events)
    assert [e.id for e in result] == ["b", "c", "a"]


def test_tied_timestamps_broken_by_id():
    events = [
        Event(id="zeta", timestamp=5, payload="x"),
        Event(id="alpha", timestamp=5, payload="y"),
        Event(id="mike", timestamp=3, payload="z"),
    ]
    result = sort_events(events)
    assert [e.id for e in result] == ["mike", "alpha", "zeta"]
