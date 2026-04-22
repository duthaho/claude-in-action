#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
INBOX="$SCRIPT_DIR/inbox"
OUTBOX="$SCRIPT_DIR/outbox"

PROMPT='Summarise the following in <=3 bullet points. Reply with bullets only, no preamble.'

mkdir -p "$OUTBOX"

process_one() {
  local src="$1"
  local base
  base="$(basename "$src")"
  local dest="$OUTBOX/$base.summary.md"

  if [[ -f "$dest" ]]; then
    echo "skip $base (already summarised)"
    return 0
  fi

  echo "summarising $base"

  if command -v claude >/dev/null 2>&1; then
    claude -p "$PROMPT" --output-format text < "$src" > "$dest"
  else
    echo "(stub summary — claude not available)" > "$dest"
  fi

  echo "wrote $dest"
}

main() {
  shopt -s nullglob
  for f in "$INBOX"/*; do
    [[ -f "$f" ]] || continue
    process_one "$f"
  done
}

main "$@"
