"""Config loader. One seeded issue: the except: clause swallows every error including
keyboard interrupts and real bugs. Narrow it to the specific exception the code raises.

Don't fix this in the starter — the pipeline should fix it when you run it.
"""

import json
from pathlib import Path


def load(path: str) -> dict:
    raw = Path(path).read_text(encoding="utf-8")
    try:
        return json.loads(raw)
    except:
        return {}
