#!/usr/bin/env bash
set -euo pipefail

# Reset total ERPNext data: drop volumes (db, sites, assets, logs, redis)
# and recreate fresh stack. Use with caution.

COMPOSE_FILE="infra/erpnext/compose.yaml"
ENV_FILE="infra/erpnext/.env"

if [[ ! -f "$COMPOSE_FILE" ]]; then
  echo "Compose file tidak ditemukan: $COMPOSE_FILE" >&2
  exit 1
fi

# Muat env bila ada (agar variabel dipakai ulang saat up)
if [[ -f "$ENV_FILE" ]]; then
  export $(grep -E '^[A-Za-z_][A-Za-z0-9_]*=' "$ENV_FILE" | xargs)
fi

PROJECT_DIR=$(dirname "$COMPOSE_FILE")
PROJECT_NAME=$(basename "$PROJECT_DIR")

echo "[ERP-RESET] Mematikan stack ERPNext..."
docker compose -f "$COMPOSE_FILE" -p "$PROJECT_NAME" down -v || true

echo "[ERP-RESET] Menghapus volume persisten lama..."
# Daftar volume sesuai compose.yaml
VOLS=(
  "${PROJECT_NAME}_db_data"
  "${PROJECT_NAME}_sites"
  "${PROJECT_NAME}_assets"
  "${PROJECT_NAME}_logs"
  "${PROJECT_NAME}_redis_cache"
  "${PROJECT_NAME}_redis_queue"
  "${PROJECT_NAME}_redis_socketio"
)

for v in "${VOLS[@]}"; do
  if docker volume inspect "$v" > /dev/null 2>&1; then
    echo " - hapus volume: $v"
    docker volume rm -f "$v" >/dev/null
  else
    echo " - volume tidak ada: $v"
  fi
done

echo "[ERP-RESET] Menyalakan kembali stack ERPNext (kosong)..."
docker compose -f "$COMPOSE_FILE" -p "$PROJECT_NAME" up -d

echo "[ERP-RESET] Menunggu healthcheck MariaDB..."
ATTEMPTS=60
SLEEP=5
for i in $(seq 1 $ATTEMPTS); do
  STATUS=$(docker compose -f "$COMPOSE_FILE" -p "$PROJECT_NAME" ps --status running | awk '/mariadb/ {print $1}') || true
  if [[ -n "$STATUS" ]]; then
    # Periksa langsung dengan mysqladmin ping di container
    CID=$(docker compose -f "$COMPOSE_FILE" -p "$PROJECT_NAME" ps -q mariadb)
    if docker exec "$CID" mysqladmin ping -h 127.0.0.1 -p"${DB_ROOT_PASSWORD:-${DB_PASSWORD:-}}" --silent >/dev/null 2>&1; then
      echo "[ERP-RESET] MariaDB siap."
      break
    fi
  fi
  echo "  -> menunggu... ($i/$ATTEMPTS)"
  sleep "$SLEEP"
done

echo "[ERP-RESET] Status kontainer terkait:"
docker compose -f "$COMPOSE_FILE" -p "$PROJECT_NAME" ps

echo "[ERP-RESET] Selesai. ERPNext kini kosong seperti baru. Lanjutkan inisialisasi site via bench atau wizard."

