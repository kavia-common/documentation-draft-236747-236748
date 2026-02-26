#!/usr/bin/env bash
set -euo pipefail
: "${WORKSPACE:?}"
WS="${WORKSPACE}"
cd "$WS"
TOOLS="$WS/tools"
LOG_DIR="$WS/tools/logs"; mkdir -p "$LOG_DIR"
SERVE_LOG="$LOG_DIR/serve.log"
: >"$SERVE_LOG"
command -v curl >/dev/null || (echo "curl missing" >&2; exit 2)
# build via helper and capture log
if ! "$TOOLS/build.sh" 2>&1 | tee "$LOG_DIR/build.log"; then
  echo "build failed; see $LOG_DIR/build.log" >&2; tail -n 200 "$LOG_DIR/build.log" >&2 || true; exit 6
fi
[ -f "$WS/site/index.html" ] || (echo "site/index.html missing" >&2; exit 6)
# start server in its own process group so we can reliably kill it
nohup "$TOOLS/start.sh" >"$SERVE_LOG" 2>&1 &
SERVER_PID=$!
# give a moment for process group to settle
sleep 0.5
# determine PGID; if setsid used or exec'd, PGID should equal SERVER_PID
PGID=$(ps -o pgid= -p "$SERVER_PID" 2>/dev/null | tr -d ' ' || echo "")
TIMEOUT=${VALIDATION_TIMEOUT:-30}
elapsed=0
while [ $elapsed -lt $TIMEOUT ]; do
  if curl -sS --fail http://127.0.0.1:8000/ >/dev/null 2>&1; then
    break
  fi
  sleep 1
  elapsed=$((elapsed+1))
done
if [ $elapsed -ge $TIMEOUT ]; then
  echo "server did not respond within ${TIMEOUT}s" >&2
  tail -n 400 "$SERVE_LOG" >&2 || true
  if [ -n "$PGID" ]; then
    kill -TERM -"$PGID" >/dev/null 2>&1 || true
    sleep 1
    kill -KILL -"$PGID" >/dev/null 2>&1 || true
  else
    kill "$SERVER_PID" >/dev/null 2>&1 || true
  fi
  wait "$SERVER_PID" 2>/dev/null || true
  exit 7
fi
echo "Validation success: site built at $WS/site and mkdocs serve responded. PID=${SERVER_PID} PGID=${PGID}"
# stop server cleanly
if [ -n "$PGID" ]; then
  kill -TERM -"$PGID" >/dev/null 2>&1 || true
  sleep 1
  kill -KILL -"$PGID" >/dev/null 2>&1 || true
else
  kill "$SERVER_PID" >/dev/null 2>&1 || true
  sleep 1
  kill -9 "$SERVER_PID" >/dev/null 2>&1 || true
fi
wait "$SERVER_PID" 2>/dev/null || true
