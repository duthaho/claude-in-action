#!/usr/bin/env bash
# Turn starter/ into a tiny git repo with a v0.1.0 tag and several commits since.
set -euo pipefail

STARTER_DIR="$(cd "$(dirname "$0")" && pwd)"
cd "$STARTER_DIR"

if [[ -d .git ]]; then
  echo "git repo already initialized"
  exit 0
fi

git init -q
git config user.email lab@example.invalid
git config user.name "Lab"

cat > app.py <<'EOF'
def main():
    return 0
EOF
git add app.py
git commit -q -m "initial"
git tag v0.1.0

# Several commits after the tag — the ones the skill will summarize.
cat > README.md <<'EOF'
# sample app
EOF
git add README.md
git commit -q -m "docs: add README"

cat > app.py <<'EOF'
def main():
    print("hello")
    return 0
EOF
git add app.py
git commit -q -m "feat: print hello on startup"

mkdir -p tests
cat > tests/test_app.py <<'EOF'
from app import main
def test_main():
    assert main() == 0
EOF
git add tests
git commit -q -m "test: add smoke test for main"

cat > app.py <<'EOF'
def main():
    print("hello, world")
    return 0
EOF
git add app.py
git commit -q -m "fix: greeting should say 'hello, world'"

cat >> README.md <<'EOF'

A tiny app.
EOF
git add README.md
git commit -q -m "docs: expand README"

echo "bootstrap done"
git log --oneline v0.1.0..HEAD
