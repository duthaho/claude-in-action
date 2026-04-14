#!/usr/bin/env bash
# Scaffold a new lab directory from templates/lab/.
# Usage: bash scripts/new-lab.sh <section-dir> <lab-slug> [--sandbox todo-cli]
# Example: bash scripts/new-lab.sh 01-slash-commands lab-04-docs-command
# Example: bash scripts/new-lab.sh 02-memory lab-04-split-memory --sandbox todo-cli

set -euo pipefail

if [[ $# -lt 2 ]]; then
  echo "Usage: $0 <section-dir> <lab-slug> [--sandbox <project>]" >&2
  exit 2
fi

SECTION="$1"
LAB_SLUG="$2"
SANDBOX=""

shift 2
while [[ $# -gt 0 ]]; do
  case "$1" in
    --sandbox)
      SANDBOX="${2:-}"
      shift 2
      ;;
    *)
      echo "Unknown flag: $1" >&2
      exit 2
      ;;
  esac
done

REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
TEMPLATE="$REPO_ROOT/templates/lab"
TARGET="$REPO_ROOT/$SECTION/$LAB_SLUG"

if [[ ! -d "$REPO_ROOT/$SECTION" ]]; then
  echo "Section directory does not exist: $SECTION" >&2
  exit 2
fi

if [[ -e "$TARGET" ]]; then
  echo "Lab already exists: $TARGET" >&2
  exit 2
fi

# Copy the template (preserving structure, skipping .gitkeep placeholders).
mkdir -p "$TARGET"
cp "$TEMPLATE/README.md" "$TARGET/README.md"
cp "$TEMPLATE/verify.sh" "$TARGET/verify.sh"
cp "$TEMPLATE/.lab-meta.yml" "$TARGET/.lab-meta.yml"
mkdir -p "$TARGET/starter"
mkdir -p "$TARGET/solution"
cp "$TEMPLATE/solution/README.md" "$TARGET/solution/README.md"

chmod +x "$TARGET/verify.sh" 2>/dev/null || true

# Optionally seed starter/ from a shared sandbox project.
if [[ -n "$SANDBOX" ]]; then
  SANDBOX_DIR="$REPO_ROOT/sandbox/$SANDBOX"
  if [[ ! -d "$SANDBOX_DIR" ]]; then
    echo "Sandbox project not found: $SANDBOX_DIR" >&2
    exit 2
  fi
  cp -r "$SANDBOX_DIR/." "$TARGET/starter/"
  echo "Seeded starter/ from sandbox/$SANDBOX"
fi

echo "Created: $TARGET"
echo "Next steps:"
echo "  1. Edit $SECTION/$LAB_SLUG/README.md"
echo "  2. Fill in starter/ and solution/"
echo "  3. Update .lab-meta.yml"
echo "  4. Run: bash scripts/list-labs.sh   # regenerate INDEX.md"
