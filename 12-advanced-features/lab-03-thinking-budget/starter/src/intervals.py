"""Merge overlapping intervals.

Given a list of (start, end) tuples, return a minimal list of merged intervals
covering the same points. Intervals are half-open in spirit but closed for this
exercise — [1, 3] and [3, 5] should merge into [1, 5].

Example:
    merge_intervals([(1, 3), (2, 4), (5, 7)]) == [(1, 4), (5, 7)]
"""


def merge_intervals(intervals):
    if not intervals:
        return []
    sorted_intervals = sorted(intervals)
    result = [sorted_intervals[0]]
    for start, end in sorted_intervals[1:]:
        last_start, last_end = result[-1]
        if start <= last_end:
            result[-1] = (last_start, end)
        else:
            result.append((start, end))
    return result
