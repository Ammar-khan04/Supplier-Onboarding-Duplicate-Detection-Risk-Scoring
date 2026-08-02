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
  ENGINE_CMD=(docker)
elif command -v docker-compose >/dev/null 2>&1; then
  ENGINE_CMD=(docker)
elif podman compose version >/dev/null 2>&1; then
  ENGINE_CMD=(podman)
elif command -v podman-compose >/dev/null 2>&1; then
  ENGINE_CMD=(podman)
else
  printf 'Docker Compose or Podman Compose was not found.\n' >&2
  exit 1
fi

if ! "${ENGINE_CMD[@]}" inspect "${CONTAINER_NAME}" >/dev/null 2>&1; then
  printf 'FAIL %s container was not found. Start it with ./scripts/start-local-oracle-db.sh\n' "${CONTAINER_NAME}" >&2
  exit 1
fi

printf 'Waiting for Oracle database SQL access'
for _ in $(seq 1 60); do
  if "${ENGINE_CMD[@]}" exec "${CONTAINER_NAME}" bash -lc "printf '%s\n' 'set heading off feedback off pagesize 0 verify off' \"select 'READY' from dual;\" 'exit' | sqlplus -s / as sysdba | grep -q READY"; then
    printf '\n'
    break
  fi
  printf '.'
  sleep 5
done

if ! "${ENGINE_CMD[@]}" exec "${CONTAINER_NAME}" bash -lc "printf '%s\n' 'set heading off feedback off pagesize 0 verify off' \"select 'READY' from dual;\" 'exit' | sqlplus -s / as sysdba | grep -q READY"; then
  printf '\nFAIL Oracle database SQL access is not ready yet.\n' >&2
  exit 1
fi

if "${ENGINE_CMD[@]}" exec \
  -e "APP_USER=${APP_USER}" \
  -e "APP_PASSWORD=${APP_PASSWORD}" \
  -e "DB_SERVICE=${DB_SERVICE}" \
  "${CONTAINER_NAME}" \
  bash -lc "printf '%s\n' 'set heading off feedback off pagesize 0 verify off' \"select 'SUPPLIER_SCHEMA_READY=' || count(*) from user_tables where table_name = 'SUPPLIER_REQUEST';\" 'exit' | sqlplus -s \"\${APP_USER}/\${APP_PASSWORD}@//localhost:1521/\${DB_SERVICE}\" | grep -q 'SUPPLIER_SCHEMA_READY=1'"; then
  printf 'SUPPLIER_APP schema is already installed.\n'
  exit 0
fi

printf 'Installing SUPPLIER_APP schema, packages, and seed data...\n'
"${ENGINE_CMD[@]}" exec "${CONTAINER_NAME}" bash -lc 'sqlplus -s / as sysdba <<SQL
@/opt/oracle/scripts/setup/00-create-app-user.sql
@/opt/oracle/scripts/setup/01-schema.sql
@/opt/oracle/scripts/setup/02-seed.sql
exit
SQL'

printf '\nSUPPLIER_APP schema installation complete.\n'
