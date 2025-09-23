#!/usr/bin/env bash
set -euo pipefail

# If tini is available and USE_TINI set, re-exec via tini for proper signal handling
if command -v tini >/dev/null 2>&1 && [ "${USE_TINI:-1}" = "1" ]; then
  if [ "${1:-}" != "__wrapped" ]; then
    exec tini -g -- "$0" __wrapped "$@"
  fi
fi

ASSETS_CSS_DIR="/home/frappe/frappe-bench/sites/assets/css"
SITE_DIR="/home/frappe/frappe-bench"

ensure_assets() {
  if ls "$ASSETS_CSS_DIR"/*.css >/dev/null 2>&1; then
    echo "[erpnext-entrypoint] assets css sudah ada, skip build"
    return 0
  fi
  echo "[erpnext-entrypoint] build assets (first-run)"
  # Run bench build as frappe user without password prompt
  if id frappe >/dev/null 2>&1; then
    su -s /bin/bash -p -c "cd '$SITE_DIR' && bench build" frappe || true
  else
    echo "[erpnext-entrypoint] user frappe tidak ditemukan, mencoba langsung bench build"
    (cd "$SITE_DIR" && bench build) || true
  fi
}

ensure_assets

# Decide default command: if none provided, run bench server like upstream
if [ $# -eq 0 ]; then
  exec bash -lc "cd '$SITE_DIR' && exec bench server"
else
  exec "$@"
fi

