#!/usr/bin/env bash
set -euo pipefail

# If tini is available and USE_TINI set, we will exec tini at the end
USE_TINI_FLAG=0
if command -v tini >/dev/null 2>&1 && [ "${USE_TINI:-1}" = "1" ]; then
  USE_TINI_FLAG=1
fi

ASSETS_CSS_DIR="/home/frappe/frappe-bench/sites/assets/css"
SITE_DIR="/home/frappe/frappe-bench"

ensure_assets() {
  if ls "$ASSETS_CSS_DIR"/*.css >/dev/null 2>&1; then
    echo "[erpnext-entrypoint] assets css sudah ada, skip build"
    return 0
  fi
  echo "[erpnext-entrypoint] build assets (first-run)"
  # Prepare caches to avoid permission issues
  if id frappe >/dev/null 2>&1; then
    runuser -u frappe -- bash -lc "mkdir -p ~/.cache/yarn ~/.npm && echo ok" || true
    # Ensure env so yarn/npm use frappe's HOME
    runuser -u frappe -- bash -lc "cd '$SITE_DIR' && export HOME=~ && export YARN_CACHE_FOLDER=~/.cache/yarn npm_config_cache=~/.npm && bench build" || true
  else
    echo "[erpnext-entrypoint] user frappe tidak ditemukan, mencoba langsung bench build"
    export HOME=/root
    export YARN_CACHE_FOLDER=/root/.cache/yarn npm_config_cache=/root/.npm
    mkdir -p "$YARN_CACHE_FOLDER" "$npm_config_cache" || true
    (cd "$SITE_DIR" && bench build) || true
  fi
}

ensure_assets

# Decide default command: if none provided, run bench server like upstream
if [ $# -eq 0 ]; then
  if [ $USE_TINI_FLAG -eq 1 ]; then
    exec tini -g -- bash -lc "cd '$SITE_DIR' && exec bench server"
  else
    exec bash -lc "cd '$SITE_DIR' && exec bench server"
  fi
else
  if [ $USE_TINI_FLAG -eq 1 ]; then
    exec tini -g -- "$@"
  else
    exec "$@"
  fi
fi
