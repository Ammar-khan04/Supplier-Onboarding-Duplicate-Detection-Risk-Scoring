# Test Coverage Summary: UOW-002 ATP/ORDS Supplier Request Foundation

## Test Layout

| Path | Purpose |
|---|---|
| `tests/example/` | Example-based API tests for concrete lifecycle, role, config, log, and masking scenarios. |
| `tests/property/` | Property-based model tests for generated UOW-002 invariants. |
| `tests/requirements.txt` | Python test dependencies. |
| `pytest.ini` | Test discovery and markers. |
| `oracle/local/scripts/test-local-ords-endpoints.py` | Live ORDS endpoint and direct Oracle persistence smoke test. |
| `oracle/local/scripts/seed-demo-data-via-ords.py` | Supervisor/demo data seeding through ORDS plus direct Oracle verification. |

## Example Tests

| File | Coverage |
|---|---|
| `tests/example/test_supplier_request_lifecycle.py` | Finalized `/requests` endpoints, seeded rows, create/submit, latest assessment JSON, correction Edit visibility. |
| `tests/example/test_reviewer_and_requester_actions.py` | Reviewer approve/reject/correction/duplicate actions, requester row isolation, Gemini advisory-only behavior. |
| `tests/example/test_admin_config_and_logs.py` | Active risk weights total 100, high-risk countries, integration logs. |
| `tests/example/test_sensitive_projection.py` | Bank last-four projection, no bank fingerprint/raw value in list/detail, payload references instead of raw payloads. |

Example tests call ORDS and skip cleanly when the local stack is not running.

## Property-Based Tests

| Property ID | File | Coverage |
|---|---|---|
| P-UOW002-001 | `tests/property/test_workflow_properties.py` | Generated workflow command sequences apply only allowed transitions. |
| P-UOW002-002 | `tests/property/test_workflow_properties.py` | Fusion-created states require prior approval. |
| P-UOW002-003 | `tests/property/test_permission_and_projection_properties.py` | Disallowed role/action pairs do not mutate protected state. |
| P-UOW002-004 | `tests/property/test_workflow_properties.py` | Request payload write/read model preserves supported fields. |
| P-UOW002-005 | `tests/property/test_permission_and_projection_properties.py` | Bank projection never exposes raw account values or internal fingerprints. |
| P-UOW002-006 | `tests/property/test_history_retry_config_properties.py` | Fusion supplier reference upsert is idempotent. |
| P-UOW002-007 | `tests/property/test_history_retry_config_properties.py` | Retry chain rows are created only for eligible failures. |
| P-UOW002-008 | `tests/property/test_history_retry_config_properties.py` | AI regeneration appends history and never overwrites prior rows. |
| P-UOW002-009 | `tests/property/test_permission_and_projection_properties.py` | Requester Edit action appears only for owned editable statuses. |
| P-UOW002-010 | `tests/property/test_history_retry_config_properties.py` | Active risk-rule weights total exactly 100. |
| P-UOW002-011 | `tests/property/test_history_retry_config_properties.py` | High-risk-country changes do not alter rule weights. |

## Execution Notes

Install dependencies. On this Ubuntu environment, system Python did not include `pip` or `ensurepip`, so the latest successful setup used the `virtualenv` zipapp to create `.venv` first.

```bash
curl -L https://bootstrap.pypa.io/virtualenv.pyz -o /tmp/virtualenv.pyz
python3 /tmp/virtualenv.pyz --clear .venv
.venv/bin/python -m pip install -r tests/requirements.txt
```

Run property tests without ORDS:

```bash
.venv/bin/python -m pytest tests/property
```

Run API examples after ORDS is running:

```bash
ORDS_BASE_URL=http://localhost:8080/ords/supplier-onboarding/v1 .venv/bin/python -m pytest tests/example
```

Run the live local ORDS and database persistence check:

```bash
cd oracle/local
./scripts/test-local-ords-endpoints.py
```

Seed readable demo data through ORDS:

```bash
cd oracle/local
./scripts/seed-demo-data-via-ords.py
```

Latest local runtime note: after the Postman and Build/Test support pass, the workspace `.venv` test run passed with 24 tests total: 11 property tests and 13 example API tests. The live ORDS/database persistence check passed with token `T1784715944`, including `ADJUSTMENT_POINTS=5` and `JUSTIFICATION_ACTION_ROWS=1`. The demo seed check passed with token `DEMO1784715959`, including `DEMO_ADJUSTMENT_POINTS=5` and `DEMO_RISK_TOTAL=100`. The lightweight ORDS smoke check and Postman/Newman collection also passed.

## PBT Compliance

| Rule | Status |
|---|---|
| PBT-01 | Compliant |
| PBT-02 | Compliant |
| PBT-03 | Compliant |
| PBT-04 | Compliant |
| PBT-05 | N/A for UOW-002 |
| PBT-06 | Compliant |
| PBT-07 | Compliant |
| PBT-08 | Compliant |
| PBT-09 | Compliant |
| PBT-10 | Compliant |

## Content Validation

- No Mermaid diagrams are used.
- No ASCII diagrams are used.
- Markdown tables and code references are parser-compatible.
