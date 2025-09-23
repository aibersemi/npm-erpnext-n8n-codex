#!/usr/bin/env bash
set -euo pipefail

# Helper to open MariaDB shell inside ERPNext DB container via docker compose.
# It reads credentials from infra/erpnext/.env if present, otherwise from environment.

COMPOSE_FILE="infra/erpnext/compose.yaml"
ENV_FILE="infra/erpnext/.env"

if [[ ! -f "$COMPOSE_FILE" ]]; then
  echo "Compose file not found: $COMPOSE_FILE" >&2
  exit 1
fi

# Load env file if exists (without exporting secrets to shell history)
if [[ -f "$ENV_FILE" ]]; then
  # shellcheck disable=SC2046
  export $(grep -E '^[A-Za-z_][A-Za-z0-9_]*=' "$ENV_FILE" | xargs)
fi

DB_USER_=${DB_USER:-root}
DB_PASSWORD_=${DB_PASSWORD:-${DB_ROOT_PASSWORD:-}}
DB_NAME_=${DB_NAME:-}

if [[ -z "$DB_PASSWORD_" ]]; then
  echo "Database password not found. Set DB_PASSWORD or DB_ROOT_PASSWORD in $ENV_FILE" >&2
  exit 1
fi

# Determine project name to target the right containers
PROJECT_DIR=$(dirname "$COMPOSE_FILE")
PROJECT_NAME=$(basename "$PROJECT_DIR")

# Get container ID for mariadb service
CID=$(docker compose -f "$COMPOSE_FILE" -p "$PROJECT_NAME" ps -q mariadb)
if [[ -z "$CID" ]]; then
  echo "MariaDB container not found. Is the stack up?" >&2
  echo "Hint: docker compose -f $COMPOSE_FILE -p $PROJECT_NAME up -d" >&2
  exit 1
fi

echo "Connecting to MariaDB in container: $CID (user: $DB_USER_, db: ${DB_NAME_:-<none>})"

if [[ -n "$DB_NAME_" ]]; then
  docker exec -it "$CID" mysql -u"$DB_USER_" -p"$DB_PASSWORD_" "$DB_NAME_"
else
  docker exec -it "$CID" mysql -u"$DB_USER_" -p"$DB_PASSWORD_"
fi

