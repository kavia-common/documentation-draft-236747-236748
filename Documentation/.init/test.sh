#!/usr/bin/env bash
set -euo pipefail
: "${WORKSPACE:?}"
WS="${WORKSPACE}"
cd "$WS"
TOOLS="$WS/tools"
LOG_DIR="$WS/tools/logs"; mkdir -p "$LOG_DIR"
BUILD_LOG="$LOG_DIR/build.log"
[ -x "$TOOLS/build.sh" ] || (echo "build helper missing" >&2; exit 2)
rm -rf "$WS/site"
if ! "$TOOLS/build.sh" 2>&1 | tee "$BUILD_LOG"; then
  echo "Build failed; tail of log:" >&2
  tail -n 200 "$BUILD_LOG" >&2 || true
  exit 5
fi
[ -f "$WS/site/index.html" ] || { echo "site/index.html missing" >&2; tail -n 200 "$BUILD_LOG" >&2 || true; exit 6; }
if ! grep -qi "Documentation Draft" "$WS/site/index.html"; then
  echo "content check failed" >&2; exit 7
fi
echo "OK: site/index.html validated"
