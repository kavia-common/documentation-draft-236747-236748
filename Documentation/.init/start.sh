#!/usr/bin/env bash
set -euo pipefail
: "${WORKSPACE:?}"
WS="${WORKSPACE}"
cd "$WS"
LOG_DIR="$WS/tools/logs"; mkdir -p "$LOG_DIR"
# start mkdocs serve with exec so PID maps to python process; bind to 127.0.0.1:8000
exec mkdocs serve --dev-addr=127.0.0.1:8000
