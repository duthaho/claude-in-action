#!/usr/bin/env bash
# PostToolUse hook: append one line to .claude/logs/edits.log for every Edit or Write call.
# Exits 0 unconditionally — a logger should never disturb the session it observes.

set +e

LOG_DIR="${CLAUDE_PROJECT_DIR:-.}/.claude/logs"
LOG_FILE="$LOG_DIR/edits.log"
mkdir -p "$LOG_DIR"

envelope=$(cat < /dev/stdin)

printf '%s' "$envelope" | python -c "
import json, sys
from datetime import datetime, timezone

try:
    envelope = json.load(sys.stdin)
except Exception:
    sys.exit(0)

tool = envelope.get('tool_name') or envelope.get('hook_event_name') or 'unknown'
path = (envelope.get('tool_input') or {}).get('file_path', '<no-path>')
ts = datetime.now(timezone.utc).isoformat(timespec='seconds')
print(f'{ts} | {tool} | {path}')
" >> "$LOG_FILE" 2>/dev/null

exit 0
