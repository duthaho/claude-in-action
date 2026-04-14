#!/usr/bin/env bash
# Thin runner: given a lab directory, invoke its verify.sh.
# Usage: bash scripts/verify-lab.sh <section>/<lab-dir>
# Example: bash scripts/verify-lab.sh 01-slash-commands/lab-01-hello-command

set -euo pipefail

if [[ $# -ne 1 ]]; then
  echo "Usage: $0 <section>/<lab-dir>" >&2
  exit 2
fi

REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
LAB_PATH="$REPO_ROOT/$1"

if [[ ! -d "$LAB_PATH" ]]; then
  echo "Lab directory not found: $LAB_PATH" >&2
  exit 2
fi

if [[ ! -f "$LAB_PATH/verify.sh" ]]; then
  echo "No verify.sh in $LAB_PATH" >&2
  exit 2
fi

bash "$LAB_PATH/verify.sh"
