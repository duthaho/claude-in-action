#!/usr/bin/env bash
# Turns starter/ into a tiny git repo with two staged-but-uncommitted changes.
# Idempotent: safe to re-run. Leaves the working tree in the expected "dirty" state.
set -euo pipefail

STARTER_DIR="$(cd "$(dirname "$0")" && pwd)"
cd "$STARTER_DIR"

if [[ -d .git ]]; then
  echo "git repo already initialized in $STARTER_DIR"
else
  git init -q
  git -c user.email=lab@example.invalid -c user.name="Lab" \
      commit -q --allow-empty -m "initial"
fi

# Seed tracked files if they are missing.
if [[ ! -f math.py ]]; then
  cat > math.py <<'EOF'
def add(a, b):
    return a + b
EOF
  git add math.py
  git -c user.email=lab@example.invalid -c user.name="Lab" \
      commit -q -m "add math module"
fi

# Make the two dirty changes.
cat > math.py <<'EOF'
def add(a, b):
    return a + b


def subtract(a, b):
    return a - b
EOF

cat > CHANGELOG.md <<'EOF'
# Changelog

## Unreleased
- Add `subtract` helper to `math` module.
EOF

git add math.py CHANGELOG.md
echo "bootstrap done — two staged changes ready"
git status --short
