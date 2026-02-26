#!/usr/bin/env bash
set -euo pipefail
: "${WORKSPACE:?}"
WS="${WORKSPACE}"
cd "$WS"
exec python3 -m mkdocs serve -a 0.0.0.0:8000
