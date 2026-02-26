#!/usr/bin/env bash
set -euo pipefail
# install mkdocs-material into the same python3 used by mkdocs; respects PKG_VER env
: "${WORKSPACE:?workspace must be set by env-001}"
WS="${WORKSPACE}"
cd "$WS"
PY=python3
PIP="$PY -m pip"
PKG_NAME="mkdocs-material"
PKG_VER="${PKG_VER:-}"
PKG_SPEC="$PKG_NAME${PKG_VER}"
LOG_DIR="$WS/tools/logs"; mkdir -p "$LOG_DIR"
INSTALL_LOG="$LOG_DIR/mkdocs-material-install.log"
# read mkdocs version (if present)
MKDOCS_VER=$($PY -c "import mkdocs,sys; print(mkdocs.__version__)" 2>/dev/null || echo "")
if [ -z "$MKDOCS_VER" ]; then
  echo "warning: mkdocs not found in python3; attempting to install mkdocs-material may fail" >&2
fi
# If already importable, skip install
if $PY -c "import importlib; importlib.import_module('mkdocs_material')" >/dev/null 2>&1; then
  $PY -c "import mkdocs, mkdocs_material; print('mkdocs', getattr(mkdocs,'__version__','none'),'mkdocs_material',getattr(mkdocs_material,'__version__','unknown'))"
  exit 0
fi
# attempt install (user-level where possible; fallback to sudo if permission denied)
# Try user install first to avoid needing sudo in container environments
if $PIP install --disable-pip-version-check --no-input --user $PKG_SPEC >"$INSTALL_LOG" 2>&1; then
  :
else
  # retry system-wide with sudo
  if sudo $PIP install --disable-pip-version-check --no-input $PKG_SPEC >>"$INSTALL_LOG" 2>&1; then
    :
  else
    echo "mkdocs-material install failed; see $INSTALL_LOG" >&2
    tail -n 200 "$INSTALL_LOG" >&2 || true
    exit 3
  fi
fi
# post-install compatibility check
$PY - <<'PY'
import sys
try:
    import mkdocs
    import mkdocs_material
except Exception as e:
    print('import-failed', e, file=sys.stderr); sys.exit(4)
mv = getattr(mkdocs, '__version__', '')
mmv = getattr(mkdocs_material, '__version__', '')
try:
    mja = int(mv.split('.')[0]) if mv else 0
except:
    mja = 0
print('mkdocs', mv, 'mkdocs_material', mmv)
if mja and mja < 1:
    print('warning: mkdocs major version <1; verify mkdocs-material compatibility', file=sys.stderr)
PY
