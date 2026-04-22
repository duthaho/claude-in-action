import os
import sys
import unittest

sys.path.insert(0, os.path.join(os.path.dirname(__file__), ".."))

from src.intervals import merge_intervals


class MergeIntervalsTest(unittest.TestCase):
    def test_empty(self):
        self.assertEqual(merge_intervals([]), [])

    def test_single(self):
        self.assertEqual(merge_intervals([(1, 3)]), [(1, 3)])

    def test_disjoint(self):
        self.assertEqual(merge_intervals([(1, 3), (5, 7)]), [(1, 3), (5, 7)])

    def test_overlap(self):
        self.assertEqual(merge_intervals([(1, 3), (2, 4), (5, 7)]), [(1, 4), (5, 7)])

    def test_adjacent_touch(self):
        self.assertEqual(merge_intervals([(1, 3), (3, 5)]), [(1, 5)])

    def test_contained(self):
        # The subtle one: second interval is fully inside the first.
        # Merging must keep the outer end, not shrink to the inner end.
        self.assertEqual(merge_intervals([(1, 10), (2, 5)]), [(1, 10)])

    def test_contained_with_tail(self):
        self.assertEqual(
            merge_intervals([(1, 10), (2, 5), (6, 8), (11, 12)]),
            [(1, 10), (11, 12)],
        )


if __name__ == "__main__":
    unittest.main()
