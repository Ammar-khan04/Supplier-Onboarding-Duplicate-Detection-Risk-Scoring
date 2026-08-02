#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LOCAL_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"

cd "${LOCAL_DIR}"

if [ -f .env ]; then
  set -a
  # shellcheck disable=SC1091
  . ./.env
  set +a
fi

APP_USER="${APP_USER:-SUPPLIER_APP}"
APP_PASSWORD="${APP_PASSWORD:-SupplierApp12345}"
DB_SERVICE="${DB_SERVICE:-FREEPDB1}"
CONTAINER_NAME="${DB_CONTAINER_NAME:-supplier-oracle-db}"

if docker compose version >/dev/null 2>&1; then
  COMPOSE_CMD=(docker compose)
  ENGINE_CMD=(docker)
elif command -v docker-compose >/dev/null 2>&1; then
  COMPOSE_CMD=(docker-compose)
  ENGINE_CMD=(docker)
elif podman compose version >/dev/null 2>&1; then
  COMPOSE_CMD=(podman compose)
  ENGINE_CMD=(podman)
elif command -v podman-compose >/dev/null 2>&1; then
  COMPOSE_CMD=(podman-compose)
  ENGINE_CMD=(podman)
else
  printf 'Docker Compose or Podman Compose was not found.\n' >&2
  exit 1
fi

if ! "${ENGINE_CMD[@]}" inspect "${CONTAINER_NAME}" >/dev/null 2>&1; then
  printf 'FAIL %s container was not found. Start it with ./scripts/start-local-oracle-db.sh\n' "${CONTAINER_NAME}" >&2
  exit 1
fi

printf 'Container status:\n'
"${COMPOSE_CMD[@]}" --env-file .env ps oracle-db

HEALTH_STATUS="$("${ENGINE_CMD[@]}" inspect --format '{{if .State.Health}}{{.State.Health.Status}}{{else}}no-healthcheck{{end}}' "${CONTAINER_NAME}")"
if [ "${HEALTH_STATUS}" = "starting" ]; then
  printf '\nOracle DB health: starting. Waiting for Docker healthcheck to finish'
  for _ in $(seq 1 36); do
    sleep 5
    HEALTH_STATUS="$("${ENGINE_CMD[@]}" inspect --format '{{if .State.Health}}{{.State.Health.Status}}{{else}}no-healthcheck{{end}}' "${CONTAINER_NAME}")"
    printf '.'
    if [ "${HEALTH_STATUS}" != "starting" ]; then
      break
    fi
  done
  printf '\n'
fi

printf '\nOracle DB health: %s\n' "${HEALTH_STATUS}"

if [ "${HEALTH_STATUS}" != "healthy" ]; then
  printf 'Database is not healthy yet. Recent logs:\n' >&2
  "${COMPOSE_CMD[@]}" --env-file .env logs --tail=80 oracle-db >&2
  exit 1
fi

printf '\nChecking project schema from inside the DB container...\n'
"${ENGINE_CMD[@]}" exec \
  -e "APP_USER=${APP_USER}" \
  -e "APP_PASSWORD=${APP_PASSWORD}" \
  -e "DB_SERVICE=${DB_SERVICE}" \
  "${CONTAINER_NAME}" \
  bash -lc 'printf "%s\n" \
    "set heading off feedback off pagesize 0 verify off" \
    "select '\''USER_TABLES='\'' || count(*) from user_tables;" \
    "select '\''HAS_SUPPLIER_REQUEST='\'' || count(*) from user_tables where table_name = '\''SUPPLIER_REQUEST'\'';" \
    "select '\''SEEDED_REQUESTS='\'' || count(*) from supplier_request;" \
    "exit" | sqlplus -s "${APP_USER}/${APP_PASSWORD}@//localhost:1521/${DB_SERVICE}"'

printf '\nLocal Oracle DB is running and the project schema is reachable.\n'
