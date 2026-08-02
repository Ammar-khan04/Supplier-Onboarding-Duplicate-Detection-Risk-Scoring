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

CONTAINER_NAME="${DB_CONTAINER_NAME:-supplier-oracle-db}"
SPFILE_PATH="/opt/oracle/oradata/dbconfig/FREE/dbs/spfileFREE.ora"

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

if ! "${ENGINE_CMD[@]}" exec "${CONTAINER_NAME}" test -f "${SPFILE_PATH}"; then
  printf 'FAIL Oracle spfile was not found yet. Wait for initial Oracle database creation to create dbconfig, then rerun this script.\n' >&2
  exit 1
fi

if "${ENGINE_CMD[@]}" exec "${CONTAINER_NAME}" bash -lc "strings '${SPFILE_PATH}' | grep -qi '_enable_memory_protection_keys'"; then
  printf 'Oracle memory-protection-key workaround is already present in the spfile.\n'
else
  printf 'Adding Oracle memory-protection-key workaround to the local spfile...\n'
  "${ENGINE_CMD[@]}" exec "${CONTAINER_NAME}" bash -lc "set -euo pipefail
cat >/tmp/supplier-create-pfile.sql <<'SQL'
whenever sqlerror exit sql.sqlcode
create pfile='/tmp/initFREE-supplier.ora' from spfile='${SPFILE_PATH}';
exit
SQL
sqlplus -s / as sysdba @/tmp/supplier-create-pfile.sql
cp /tmp/initFREE-supplier.ora /tmp/initFREE-supplier-fixed.ora
printf '%s\n' '*._enable_memory_protection_keys=FALSE' >> /tmp/initFREE-supplier-fixed.ora
cat >/tmp/supplier-recreate-spfile.sql <<'SQL'
whenever sqlerror exit sql.sqlcode
create spfile='${SPFILE_PATH}' from pfile='/tmp/initFREE-supplier-fixed.ora';
exit
SQL
sqlplus -s / as sysdba @/tmp/supplier-recreate-spfile.sql
strings '${SPFILE_PATH}' | grep -i '_enable_memory_protection_keys'"
fi

"${COMPOSE_CMD[@]}" --env-file .env restart oracle-db

printf '\nOracle DB container restarted with the local MPK workaround applied.\n'
printf 'Run ./scripts/install-local-oracle-schema.sh if the first boot failed before setup scripts ran.\n'
