#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LOCAL_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"

cd "${LOCAL_DIR}"

fail() {
  printf 'FAIL %s\n' "$*" >&2
  exit 1
}

ok() {
  printf 'OK   %s\n' "$*"
}

detect_compose_cmd() {
  if docker compose version >/dev/null 2>&1; then
    printf 'docker compose'
  elif command -v docker-compose >/dev/null 2>&1; then
    printf 'docker-compose'
  elif podman compose version >/dev/null 2>&1; then
    printf 'podman compose'
  elif command -v podman-compose >/dev/null 2>&1; then
    printf 'podman-compose'
  else
    return 1
  fi
}

check_file() {
  [ -f "$1" ] || fail "Missing required file: $1"
  ok "Found $1"
}

check_port_free() {
  local port="$1"
  local label="$2"

  if command -v python3 >/dev/null 2>&1; then
    python3 - "$port" "$label" <<'PY'
import socket
import sys

port = int(sys.argv[1])
label = sys.argv[2]

sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
try:
    sock.bind(("127.0.0.1", port))
except OSError as exc:
    print(f"FAIL Port {port} for {label} is not available: {exc}", file=sys.stderr)
    sys.exit(1)
finally:
    sock.close()
PY
  elif command -v ss >/dev/null 2>&1; then
    if ss -ltn 2>/dev/null | awk '{print $4}' | grep -Eq "[:.]${port}$"; then
      fail "Port ${port} for ${label} is already in use."
    fi
  else
    printf 'WARN Cannot check port %s for %s because python3 and ss are unavailable.\n' "${port}" "${label}" >&2
    return 0
  fi

  ok "Port ${port} is available for ${label}"
}

check_file docker-compose.yml
check_file .env.example
check_file db-init/00-create-app-user.sql
check_file db-init/01-schema.sql
check_file db-init/02-seed.sql
check_file ords/Dockerfile
check_file ords/entrypoint.sh
check_file ords/sql/10-enable-schema.sql
check_file ords/sql/20-define-modules.sql

if [ -f .env ]; then
  set -a
  # shellcheck disable=SC1091
  . ./.env
  set +a
  ok "Loaded .env"
else
  ok ".env not found; startup script will create it from .env.example"
fi

COMPOSE_DISPLAY="$(detect_compose_cmd)" || fail "Docker Compose or Podman Compose was not found."
ok "Compose command detected: ${COMPOSE_DISPLAY}"

case "${COMPOSE_DISPLAY}" in
  "docker compose")
    COMPOSE_CMD=(docker compose)
    ;;
  docker-compose)
    COMPOSE_CMD=(docker-compose)
    ;;
  "podman compose")
    COMPOSE_CMD=(podman compose)
    ;;
  podman-compose)
    COMPOSE_CMD=(podman-compose)
    ;;
esac

case "${COMPOSE_DISPLAY}" in
  docker*)
    docker info >/dev/null 2>&1 || fail "Docker is installed but the daemon is not reachable for this user."
    ok "Docker daemon is reachable"
    ;;
  podman*)
    podman info >/dev/null 2>&1 || fail "Podman is installed but not reachable for this user."
    ok "Podman is reachable"
    ;;
esac

command -v curl >/dev/null 2>&1 || fail "curl is required for endpoint checks."
ok "curl is available"

DB_PORT="${DB_PORT:-1521}"
ORDS_PORT="${ORDS_PORT:-8080}"
EM_PORT="${EM_PORT:-5500}"

if "${COMPOSE_CMD[@]}" --env-file .env ps oracle-db 2>/dev/null | awk 'NR > 1 && /Up/ {found=1} END {exit !found}'; then
  ok "Oracle DB service is already running; reusing ports ${DB_PORT} and ${EM_PORT}"
else
  check_port_free "${DB_PORT}" "Oracle listener"
  check_port_free "${EM_PORT}" "Oracle Enterprise Manager"
fi

if "${COMPOSE_CMD[@]}" --env-file .env ps ords 2>/dev/null | awk 'NR > 1 && /Up/ {found=1} END {exit !found}'; then
  ok "ORDS service is already running; reusing port ${ORDS_PORT}"
else
  check_port_free "${ORDS_PORT}" "ORDS HTTP"
fi

printf '\nPreflight complete. You can start local Oracle Database Free and ORDS.\n'
