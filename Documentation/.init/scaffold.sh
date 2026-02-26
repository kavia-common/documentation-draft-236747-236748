#!/usr/bin/env bash
set -euo pipefail
WORKSPACE="/tmp/kavia/workspace/code-generation/documentation-draft-236747-236748/Documentation"
export WORKSPACE
: "${WORKSPACE:?workspace must be set}"
WS="${WORKSPACE}"
mkdir -p "$WS/docs" "$WS/tools" "$WS/tools/logs"
# mkdocs.yml
if [ ! -f "$WS/mkdocs.yml" ]; then
  cat > "$WS/mkdocs.yml" <<'YML'
site_name: Documentation Draft
nav:
  - Home: index.md
  - Getting Started: getting-started.md
  - Reference:
    - Usage: usage.md
    - API: api.md
theme:
  name: 'material'
YML
fi
# docs
[ -f "$WS/docs/index.md" ] || cat > "$WS/docs/index.md" <<'MD'
# Documentation Draft

Welcome to the documentation draft.
MD
[ -f "$WS/docs/getting-started.md" ] || cat > "$WS/docs/getting-started.md" <<'MD'
# Getting Started

Quick start guide.
MD
[ -f "$WS/docs/usage.md" ] || cat > "$WS/docs/usage.md" <<'MD'
# Usage

Usage information.
MD
[ -f "$WS/docs/api.md" ] || cat > "$WS/docs/api.md" <<'MD'
# API

API reference placeholder.
MD
# build helper: outputs to stdout so callers can tee
BUILD_SH="$WS/tools/build.sh"
if [ ! -f "$BUILD_SH" ]; then
  cat > "$BUILD_SH" <<'SH'
#!/usr/bin/env bash
set -euo pipefail
: "${WORKSPACE:?}"
WS="${WORKSPACE}"
cd "$WS"
python3 -m mkdocs build --clean
SH
  chmod +x "$BUILD_SH"
fi
# start helper: exec the python process so PID maps to server
START_SH="$WS/tools/start.sh"
if [ ! -f "$START_SH" ]; then
  cat > "$START_SH" <<'SH'
#!/usr/bin/env bash
set -euo pipefail
: "${WORKSPACE:?}"
WS="${WORKSPACE}"
cd "$WS"
exec python3 -m mkdocs serve -a 0.0.0.0:8000
SH
  chmod +x "$START_SH"
fi
