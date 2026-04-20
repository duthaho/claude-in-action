"""Config loader. The bare except: was narrowed to ValueError by the patch-writer
subagent after the reviewer flagged it.
"""

import json
from pathlib import Path


def load(path: str) -> dict:
    raw = Path(path).read_text(encoding="utf-8")
    try:
        return json.loads(raw)
    except ValueError:
        return {}
