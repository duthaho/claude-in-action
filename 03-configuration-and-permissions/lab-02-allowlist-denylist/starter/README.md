# Starter — lab-02-allowlist-denylist

Two things already exist:

- `src/hello.py` — a normal source file Claude should be able to read.
- `secrets/api_key.txt` — a file Claude must never read.

Your job: write `.claude/settings.json` with an `allow` list that only grants the four read-only tools and a `deny` list that keeps `secrets/` off-limits. See the lab README one level up.
