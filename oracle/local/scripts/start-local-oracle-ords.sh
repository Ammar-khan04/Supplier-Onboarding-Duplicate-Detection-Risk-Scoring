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

./scripts/preflight-local-oracle-ords.sh

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

"${COMPOSE_CMD[@]}" --env-file .env up -d --build

printf '\nLocal Oracle DB and ORDS startup requested.\n'
printf 'Oracle PDB: localhost:%s/%s\n' "${DB_PORT:-1521}" "${DB_SERVICE:-FREEPDB1}"
printf 'ORDS base: http://localhost:%s/ords/supplier-onboarding/v1/\n' "${ORDS_PORT:-8080}"
printf 'Run ./scripts/check-local-oracle-ords.sh after the first database startup completes.\n'
