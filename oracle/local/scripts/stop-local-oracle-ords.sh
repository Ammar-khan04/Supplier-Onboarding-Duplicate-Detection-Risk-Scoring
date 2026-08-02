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

if docker compose version >/dev/null 2>&1; then
  COMPOSE_CMD=(docker compose)
elif command -v docker-compose >/dev/null 2>&1; then
  COMPOSE_CMD=(docker-compose)
elif podman compose version >/dev/null 2>&1; then
  COMPOSE_CMD=(podman compose)
elif command -v podman-compose >/dev/null 2>&1; then
  COMPOSE_CMD=(podman-compose)
else
  printf 'Docker Compose or Podman Compose was not found.\n' >&2
  exit 1
fi

if [ "${1:-}" = "--volumes" ]; then
  "${COMPOSE_CMD[@]}" --env-file .env down -v
  printf 'Local Oracle DB and ORDS containers stopped; volumes removed.\n'
else
  "${COMPOSE_CMD[@]}" --env-file .env down
  printf 'Local Oracle DB and ORDS containers stopped; volumes retained.\n'
fi
