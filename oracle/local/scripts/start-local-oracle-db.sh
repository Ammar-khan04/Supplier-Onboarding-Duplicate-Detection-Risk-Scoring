#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LOCAL_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"

cd "${LOCAL_DIR}"

if [ ! -f .env ]; then
  cp .env.example .env
  printf 'Created oracle/local/.env from .env.example\n'
fi

set -a
# shellcheck disable=SC1091
. ./.env
set +a

if docker compose version >/dev/null 2>&1; then
  COMPOSE_CMD=(docker compose)
elif command -v docker-compose >/dev/null 2>&1; then
  COMPOSE_CMD=(docker-compose)
elif podman compose version >/dev/null 2>&1; then
  COMPOSE_CMD=(podman compose)
elif command -v podman-compose >/dev/null 2>&1; then
  COMPOSE_CMD=(podman-compose)
else
  printf 'Docker Compose or Podman Compose was not found. Install one, then rerun this script.\n' >&2
  exit 1
fi

for required_file in \
  docker-compose.yml \
  db-init/00-create-app-user.sql \
  db-init/01-schema.sql \
  db-init/02-seed.sql
do
  if [ ! -f "${required_file}" ]; then
    printf 'Missing required DB setup file: %s\n' "${required_file}" >&2
    exit 1
  fi
done

"${COMPOSE_CMD[@]}" --env-file .env up -d oracle-db

printf '\nLocal Oracle DB startup requested.\n'
printf 'Oracle PDB: localhost:%s/%s\n' "${DB_PORT:-1521}" "${DB_SERVICE:-FREEPDB1}"
printf 'Oracle EM Express: https://localhost:%s/em/\n' "${EM_PORT:-5500}"
printf 'Run ./scripts/check-local-oracle-db.sh after first startup completes.\n'
