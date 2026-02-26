#!/usr/bin/env bash
set -euo pipefail
: "${WORKSPACE:?}"
WS="${WORKSPACE}"
cd "$WS"
LOG_DIR="$WS/tools/logs"; mkdir -p "$LOG_DIR"
: >"$LOG_DIR/build.log"
command -v mkdocs >/dev/null || (echo "mkdocs not on PATH" >&2; exit 3)
# ensure docs exist minimally
[ -d "$WS/docs" ] || mkdir -p "$WS/docs" && echo "# Documentation Index" > "$WS/docs/index.md"
# run headless build
mkdocs build --clean 2>&1 | tee "$LOG_DIR/build.log"
# verify output
if [ ! -f "$WS/site/index.html" ]; then
  echo "site/index.html missing after build" >&2
  tail -n 200 "$LOG_DIR/build.log" >&2 || true
  exit 6
fi
