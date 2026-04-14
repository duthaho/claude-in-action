import unittest

from messy import greeting


class TestGreeting(unittest.TestCase):
    def test_greeting(self):
        self.assertEqual(greeting("world"), "hello, world")


if __name__ == "__main__":
    unittest.main()
