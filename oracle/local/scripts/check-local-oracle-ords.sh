#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LOCAL_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"

cd "${LOCAL_DIR}"

if ! command -v curl >/dev/null 2>&1; then
  printf 'curl is required to check ORDS endpoints.\n' >&2
  exit 1
fi

if ! command -v python3 >/dev/null 2>&1; then
  printf 'python3 is required to parse ORDS endpoint responses.\n' >&2
  exit 1
fi

if [ -f .env ]; then
  set -a
  # shellcheck disable=SC1091
  . ./.env
  set +a
fi

ORDS_PORT="${ORDS_PORT:-8080}"
ORDS_BASE_URL="${ORDS_BASE_URL:-http://localhost:${ORDS_PORT}/ords/supplier-onboarding/v1}"

printf 'Checking ORDS endpoints at %s\n' "${ORDS_BASE_URL}"

check_endpoint() {
  local path="$1"
  local url="${ORDS_BASE_URL}/${path}"

  if curl -fsS "${url}" >/dev/null; then
    printf 'OK %s\n' "${url}"
  else
    printf 'FAIL %s\n' "${url}" >&2
    return 1
  fi
}

check_endpoint ""
check_endpoint health
check_endpoint requests

REQUEST_ID="$(
  curl -fsS "${ORDS_BASE_URL}/requests?actor_subject_id=REQ_AMINA_SUB&actor_roles=REQUESTER&limit=1" |
    python3 -c 'import json, sys; payload = json.load(sys.stdin); items = payload.get("items", []); print(items[0]["request_id"] if items else "")'
)"

if [ -n "${REQUEST_ID}" ]; then
  check_endpoint "requests/${REQUEST_ID}?actor_subject_id=REQ_AMINA_SUB&actor_roles=REQUESTER"
else
  printf 'WARN no request rows available for request detail endpoint check.\n' >&2
fi

check_endpoint risk-rules
check_endpoint high-risk-countries
check_endpoint "integration-logs?actor_subject_id=ADM_LINDA_SUB&actor_roles=ADMIN"
check_endpoint "integration-jobs?type=AI_EXPLANATION&status=SUCCEEDED"

printf '\nORDS local endpoints are responding.\n'
