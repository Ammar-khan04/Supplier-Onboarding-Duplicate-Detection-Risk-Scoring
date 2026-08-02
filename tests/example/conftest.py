import os

import pytest
import requests

SEED_REQUEST_IDS = {
    "REQ-SEED-001": 1,
    "REQ-SEED-002": 2,
    "REQ-SEED-003": 3,
}


def _base_url() -> str:
    return os.getenv(
        "ORDS_BASE_URL",
        "http://localhost:8080/ords/supplier-onboarding/v1",
    ).rstrip("/")


@pytest.fixture(scope="session")
def ords_base_url() -> str:
    base_url = _base_url()
    try:
        response = requests.get(f"{base_url}/health", timeout=5)
        response.raise_for_status()
    except requests.RequestException as exc:
        pytest.skip(f"ORDS is not available at {base_url}: {exc}")
    return base_url


@pytest.fixture
def api(ords_base_url):
    class Client:
        def get(self, path, **params):
            response = requests.get(f"{ords_base_url}/{path.lstrip('/')}", params=params, timeout=10)
            response.raise_for_status()
            return response.json()

        def post(self, path, **data):
            response = requests.post(f"{ords_base_url}/{path.lstrip('/')}", data=data, timeout=10)
            response.raise_for_status()
            return response.json()

        def put(self, path, **params):
            response = requests.put(f"{ords_base_url}/{path.lstrip('/')}", params=params, timeout=10)
            response.raise_for_status()
            return response.json()

    return Client()


def items(payload):
    if isinstance(payload, dict) and "items" in payload:
        return payload["items"]
    if isinstance(payload, list):
        return payload
    return []


def request_rows(api, actor_subject_id="REV_PRIYA_SUB", actor_roles="REVIEWER", page_size=25, max_pages=100):
    rows = []

    for page in range(max_pages):
        payload = api.get(
            "requests",
            actor_subject_id=actor_subject_id,
            actor_roles=actor_roles,
            limit=page_size,
            offset=page * page_size,
        )
        page_rows = items(payload)
        rows.extend(page_rows)
        if len(page_rows) < page_size:
            break

    return rows


def find_request(api, request_number):
    if request_number in SEED_REQUEST_IDS:
        request_id = SEED_REQUEST_IDS[request_number]
        return api.get(
            f"requests/{request_id}",
            actor_subject_id="REV_PRIYA_SUB",
            actor_roles="REVIEWER",
        )

    for row in request_rows(api):
        if row.get("request_number") == request_number:
            return row
    raise AssertionError(f"Request not found: {request_number}")
