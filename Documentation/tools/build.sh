#!/usr/bin/env bash
set -euo pipefail
: "${WORKSPACE:?}"
WS="${WORKSPACE}"
cd "$WS"
python3 -m mkdocs build --clean
