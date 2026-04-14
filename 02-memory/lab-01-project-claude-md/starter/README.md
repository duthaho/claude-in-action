# todo-cli (lab starter)

A tiny Python todo manager. Dependency-free, standard library only.

## Usage

```bash
python todo.py add "buy milk"
python todo.py list
python todo.py done 0
```

State lives in `./todos.json` next to the script.

## Deliberate gaps

No timestamps, priorities, due dates, tags. No CLI framework. No tests. No error handling beyond "print and exit 2". These gaps are on purpose.
