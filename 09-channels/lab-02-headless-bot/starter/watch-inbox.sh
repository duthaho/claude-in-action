#!/usr/bin/env bash
# watch-inbox.sh — headless bot: summarise every file in inbox/ into outbox/.
#
# Each file in inbox/ becomes outbox/<name>.summary.md containing a short
# summary produced by `claude -p`. Already-summarised files are skipped so the
# script is safe to re-run.
#
# Usage:
#   bash watch-inbox.sh               # one pass over the inbox
#   bash watch-inbox.sh --watch       # stay running, poll every 5s (stretch goal)

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
INBOX="$SCRIPT_DIR/inbox"
OUTBOX="$SCRIPT_DIR/outbox"

mkdir -p "$OUTBOX"

process_one() {
  local src="$1"
  local base
  base="$(basename "$src")"
  local dest="$OUTBOX/$base.summary.md"

  # TODO 1: skip if $dest already exists — the bot must be idempotent, or
  # a second run will re-summarise everything and waste tokens.

  echo "summarising $base"

  # TODO 2: call claude -p headlessly.
  #   - Pipe the file content on stdin.
  #   - Use --output-format text (or omit --output-format; text is default).
  #   - The prompt: "Summarise the following in <=3 bullet points. Reply with
  #     bullets only, no preamble."
  #   - Redirect stdout into $dest.
  #
  #   Hint: `claude -p "<prompt>" < "$src" > "$dest"`
  #
  #   If claude is unavailable in this environment (CI without a key), fall
  #   back to writing a stub so the script is still testable:
  #     echo "(stub summary — claude not available)" > "$dest"

  echo "wrote $dest"
}

main() {
  # TODO 3: iterate every regular file in $INBOX and call process_one on it.
  # Use `shopt -s nullglob` so the loop is empty (not literal "$INBOX/*") when
  # inbox has no files.
  :
}

main "$@"
