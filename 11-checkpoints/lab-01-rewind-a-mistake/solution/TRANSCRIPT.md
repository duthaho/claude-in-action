# TRANSCRIPT — lab-01-rewind-a-mistake

This is the *shape* of the transcript you produce in the lab root. Your exact output may vary slightly in the "after (broken)" section depending on how Claude wrote the `divide` method.

## Before

```python
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
```

## After (broken)

Claude added a `divide` method that silently returns 0 on divide-by-zero:

```python
class Calculator:
    """A small calculator with integer operations."""

    def add(self, a: int, b: int) -> int:
        return a + b

    def subtract(self, a: int, b: int) -> int:
        return a - b

    def divide(self, a: int, b: int) -> float:
        if b == 0:
            return 0
        return a / b


if __name__ == "__main__":
    c = Calculator()
    print(c.add(2, 3))
    print(c.subtract(10, 4))
```

## After rewind

Ran `/rewind` and selected the checkpoint from before the "add divide" message. Both the turn and the file were rolled back:

```python
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
```

## Comparison

The "Before" and "After rewind" blocks are byte-identical. The `divide` method Claude added is gone, and the conversation no longer shows the "add divide" turn in the session history. The checkpoint captured both changes as a single unit.
