#!/usr/bin/env bash
# drive.sh — a tour of the most useful `claude` CLI flags.
# Each function below is one experiment. Uncomment the one you want to run,
# or call the function by name: `bash drive.sh task_one`.
#
# The verifier reads this file to confirm each flag appears at least once in
# its expected shape — even if you never actually run the experiments against
# a live `claude`. Fill in the TODOs; don't remove or rename the functions.

set -euo pipefail

# 1) Print-mode. Bread and butter for headless use: send a single prompt and
#    print the reply to stdout. No TUI, no session.
task_one_print() {
  # TODO 1: call claude in print mode with the prompt "Reply with exactly: OK".
  # Hint: the short flag is `-p`, the long form is `--print`.
  :
}

# 2) Choose the output format. Default is plain text; `json` wraps the whole
#    reply in an envelope you can feed to `jq`; `stream-json` streams JSONL.
task_two_output_format() {
  # TODO 2: same prompt as task 1, but request JSON output so we get an
  # envelope like {"type": "result", "result": "...", "usage": {...}}.
  # Hint: --output-format json
  :
}

# 3) Append to the system prompt. The built-in system prompt stays; your text
#    is appended. Use this to set tone, persona, or domain constraints.
task_three_append_system() {
  # TODO 3: append a system prompt that forces Claude to answer only in
  # rhyming couplets. Then send a simple prompt like "Explain recursion in
  # two lines."
  # Hint: --append-system-prompt "<your text>"
  :
}

# 4) Restrict the tool set. Headless runs in CI usually shouldn't be allowed
#    to Edit files — receiving "here's a diff" as output is safer than
#    letting the agent mutate the repo.
task_four_restrict_tools() {
  # TODO 4: run a prompt with only read-only tools allowed:
  # Read, Glob, Grep. All other tools must be disallowed.
  # Hint: --allowedTools "Read,Glob,Grep"
  :
}

# 5) Bound the tool-use loop. When the agent iterates, cap the number of
#    turns so a runaway prompt can't burn unlimited tokens.
task_five_max_turns() {
  # TODO 5: run a short prompt with --max-turns 2.
  # Hint: --max-turns <N>
  :
}

# Entry point: run each task by name, or run all if none given.
if [[ "${1:-}" == "" ]]; then
  task_one_print
  task_two_output_format
  task_three_append_system
  task_four_restrict_tools
  task_five_max_turns
else
  "$1"
fi
