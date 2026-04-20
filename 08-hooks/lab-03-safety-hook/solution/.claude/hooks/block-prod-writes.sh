#!/usr/bin/env bash
# PreToolUse hook: deny Edit/Write when the target file_path resolves under prod/.
# Input: JSON envelope on stdin with tool_input.file_path.
# Output on block: JSON on stdout with permissionDecision: "deny".
# On allow: exit 0 silently.

set -euo pipefail

envelope=$(cat < /dev/stdin)

printf '%s' "$envelope" | python -c "
import json, os, sys

try:
    env = json.load(sys.stdin)
except Exception:
    sys.exit(0)

raw_path = (env.get('tool_input') or {}).get('file_path', '')
if not raw_path:
    sys.exit(0)

project_dir = os.environ.get('CLAUDE_PROJECT_DIR') or os.getcwd()
if not os.path.isabs(raw_path):
    abs_path = os.path.join(project_dir, raw_path)
else:
    abs_path = raw_path
abs_path = os.path.realpath(abs_path)

prod_root = os.path.realpath(os.path.join(project_dir, 'prod'))

if abs_path == prod_root or abs_path.startswith(prod_root + os.sep):
    reason = (
        f'Write to {raw_path} denied: this path is under prod/. '
        f'Edit dev/ or a feature branch instead, or update the hook if a prod edit is genuinely required.'
    )
    json.dump({
        'hookSpecificOutput': {
            'hookEventName': 'PreToolUse',
            'permissionDecision': 'deny',
            'permissionDecisionReason': reason,
        }
    }, sys.stdout)
"
