#!/usr/bin/env bash
# Simulated slow multi-phase build. Total ~18s. Prints one line per phase so
# polling output with BashOutput mid-run shows partial progress.

set -euo pipefail

echo "Phase 1/4: compile"
sleep 5
echo "Phase 2/4: link"
sleep 5
echo "Phase 3/4: test"
sleep 5
echo "Phase 4/4: package"
sleep 3
echo "BUILD SUCCESS: artifacts/app-$(date -u +%Y%m%dT%H%M%SZ).tar.gz"
