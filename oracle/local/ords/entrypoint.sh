#!/usr/bin/env bash
set -euo pipefail

: "${DB_HOST:=oracle-db}"
: "${DB_PORT:=1521}"
: "${DB_SERVICE:=FREEPDB1}"
: "${ORDS_CONFIG:=/etc/ords/config}"
: "${ORDS_DB_POOL:=}"
: "${APP_USER:=SUPPLIER_APP}"
: "${APP_PASSWORD:=SupplierApp12345}"

if [ -z "${ORACLE_PWD:-}" ]; then
  printf 'ORACLE_PWD is required.\n' >&2
  exit 1
fi

if [ -z "${ORDS_PUBLIC_USER_PASSWORD:-}" ]; then
  printf 'ORDS_PUBLIC_USER_PASSWORD is required.\n' >&2
  exit 1
fi

mkdir -p "${ORDS_CONFIG}" /var/log/ords

until nc -z "${DB_HOST}" "${DB_PORT}"; do
  printf 'Waiting for Oracle Database at %s:%s...\n' "${DB_HOST}" "${DB_PORT}"
  sleep 5
done

if [ ! -f "${ORDS_CONFIG}/.supplier-ords-installed" ]; then
  printf 'Installing ORDS into %s:%s/%s...\n' "${DB_HOST}" "${DB_PORT}" "${DB_SERVICE}"

  ORDS_INSTALL_ARGS=(
    install
    --admin-user SYS \
    --proxy-user \
    --db-hostname "${DB_HOST}" \
    --db-port "${DB_PORT}" \
    --db-servicename "${DB_SERVICE}" \
    --feature-sdw true \
    --feature-db-api true \
    --feature-rest-enabled-sql true \
    --gateway-mode disabled \
    --log-folder /var/log/ords \
    --password-stdin
  )

  if [ -n "${ORDS_DB_POOL}" ]; then
    ORDS_INSTALL_ARGS+=(--db-pool "${ORDS_DB_POOL}")
  fi

  printf '%s\n%s\n' "${ORACLE_PWD}" "${ORDS_PUBLIC_USER_PASSWORD}" | ords --config "${ORDS_CONFIG}" "${ORDS_INSTALL_ARGS[@]}"

  sql -s "sys/${ORACLE_PWD}@//${DB_HOST}:${DB_PORT}/${DB_SERVICE} as sysdba" @/opt/ords-init/10-enable-schema.sql
  sql -s "${APP_USER}/${APP_PASSWORD}@//${DB_HOST}:${DB_PORT}/${DB_SERVICE}" @/opt/ords-init/20-define-modules.sql

  touch "${ORDS_CONFIG}/.supplier-ords-installed"
fi

exec ords --config "${ORDS_CONFIG}" serve --port 8080
