class Calculator:
    """A small calculator with integer operations."""

    def add(self, a: int, b: int) -> int:
        return a + b

    def subtract(self, a: int, b: int) -> int:
        return a - b


if __name__ == "__main__":
    c = Calculator()
    print(c.add(2, 3))
    print(c.subtract(10, 4))
