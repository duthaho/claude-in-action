#!/usr/bin/env bash
set -euo pipefail

task_one_print() {
  claude -p "Reply with exactly: OK"
}

task_two_output_format() {
  claude -p "Reply with exactly: OK" --output-format json
}

task_three_append_system() {
  claude -p "Explain recursion in two lines." \
    --append-system-prompt "Always answer in rhyming couplets. No exceptions."
}

task_four_restrict_tools() {
  claude -p "List the Python files in this directory." \
    --allowedTools "Read,Glob,Grep"
}

task_five_max_turns() {
  claude -p "Find the first TODO in this repo." --max-turns 2
}

if [[ "${1:-}" == "" ]]; then
  task_one_print
  task_two_output_format
  task_three_append_system
  task_four_restrict_tools
  task_five_max_turns
else
  "$1"
fi
