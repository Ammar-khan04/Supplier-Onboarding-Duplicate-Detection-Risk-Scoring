# Code Generation Summary: UOW-002 ATP/ORDS Supplier Request Foundation

## Status

Code Generation has been reconciled with `/home/ammarkhan/Downloads/technical-design (2).md`, which the user identified as the finalized schema source.

The generated backend keeps Visual Builder as the presentation layer. ATP owns deterministic validation, duplicate evidence, risk scoring, workflow status, audit history, integration queue/history, and safe request projections. ORDS exposes the finalized REST contract.

## Generated Application Artifacts

| Area | Files |
|---|---|
| ATP schema | `oracle/atp/schema/001_core_request_schema.sql`, `002_workflow_history_result_schema.sql`, `003_configuration_schema.sql`, `004_views_indexes.sql` |
| ATP seed data | `oracle/atp/seed/001_seed_roles_permissions.sql`, `002_seed_configuration.sql`, `003_seed_supplier_reference_and_demo.sql` |
| PL/SQL packages | `oracle/atp/packages/supplier_auth_pkg.*`, `supplier_workflow_pkg.*`, `supplier_config_pkg.*`, `supplier_validation_pkg.*`, `supplier_request_pkg.*`, `supplier_review_pkg.*`, `supplier_dashboard_pkg.*`, `supplier_integration_pkg.*`, `supplier_projection_pkg.*` |
| ORDS module | `oracle/ords/modules/001_supplier_onboarding_module.sql` |
| Local runtime | `oracle/local/docker-compose.yml`, `oracle/local/db-init/01-schema.sql`, `oracle/local/db-init/02-seed.sql`, `oracle/local/ords/sql/20-define-modules.sql`, `oracle/local/scripts/check-local-oracle-ords.sh`, `oracle/local/README.md` |
| Example tests | `tests/example/` |
| Property tests | `tests/property/` |
| Test config | `tests/requirements.txt`, `pytest.ini` |

## Finalized Schema Decisions

| Topic | Implementation |
|---|---|
| Identity and roles | Oracle IAM owns users and roles. ATP stores stable subject IDs such as `requester_subject_id` and `actor_subject_id`; no `APP_USER`, `APP_ROLE`, or `USER_ROLE` tables are generated. |
| Request model | Phase one uses one flattened `SUPPLIER_REQUEST` current-state row plus `REQUEST_DOCUMENT` rows. |
| Deterministic assessment | `REQUEST_ASSESSMENT` stores validation results, duplicate matches, deterministic risk score, Reviewer adjustment points, final displayed risk score, risk level, risk factors, request version, and latest flag. |
| Fusion reference cache | `FUSION_SUPPLIER_REF`, `FUSION_SUPPLIER_TAX_REF`, `FUSION_SUPPLIER_SITE_REF`, and `FUSION_SUPPLIER_BANK_REF` store local matching reference data. |
| Gemini | `AI_ASSESSMENT` stores each Gemini response append-only. Gemini is advisory by itself and does not mutate score or workflow state. |
| Reviewer decisions | `ACTION_HISTORY` stores approve, reject, correction, duplicate, justification-risk adjustment, and other auditable actions. |
| Integration | `INTEGRATION_JOB` is both work queue and attempt history for `AI_EXPLANATION`, `FUSION_CREATE`, and `SUPPLIER_SYNC`. |
| Configuration | `CONFIGURATION` stores simple scalar settings only. `RISK_RULE_CONFIG`, `RISK_SCORE_BAND_CONFIG`, `HIGH_RISK_COUNTRY_CONFIG`, `TAX_REQUIREMENT_CONFIG`, `BUSINESS_UNIT_SITE_MAPPING`, and `GENERIC_JUSTIFICATION_PHRASE` store Admin-maintained business settings in readable columns. |

## Key Implementation Decisions

| Topic | Implementation |
|---|---|
| Workflow | `supplier_workflow_pkg` enforces finalized statuses including `CORRECTION_REQUIRED` and `DUPLICATE`. |
| Validation and risk | `supplier_validation_pkg` writes a new latest `REQUEST_ASSESSMENT` on submission and updates current risk fields on `SUPPLIER_REQUEST`. |
| Risk allocation | Active risk-rule weights must total exactly 100. The seeded model uses 55 base points and 45 duplicate-related points, and package validation rejects saved allocations that do not add to 100. |
| High-risk countries | Admin can activate, deactivate, or update countries through `/high-risk-countries/{country_code}`. |
| Justification-risk adjustment | Reviewer can call `/requests/{request_id}/justification-risk-adjustment` after a successful Gemini assessment to add `+3`, `+5`, or `+10` points to the deterministic score, capped at 100. |
| Sensitive bank data | Safe views expose last four only. Fingerprints are used internally for matching and are not returned in ordinary request responses. |
| ORDS paths | The module now uses finalized paths such as `/requests`, `/integration-jobs`, `/supplier-reference/batch`, `/risk-rules`, and `/high-risk-countries`. |

## Story Coverage

| Story | Status |
|---|---|
| US-001 | Implemented through `/requests` create/update and `DRAFT` state. |
| US-002 | Implemented through `REQUEST_DOCUMENT` and `/requests/{id}/documents`. |
| US-003 | Implemented through submit workflow and ATP assessment. |
| US-004 | Implemented through request list/detail projections. |
| US-005 | Implemented through `CORRECTION_REQUIRED`, requester `EDIT`, and resubmission. |
| US-006 | Implemented through `REQUEST_ASSESSMENT.validation_results_json`. |
| US-007 | Implemented through Fusion reference-cache tables and seed data. |
| US-008 | Implemented through duplicate evidence in `REQUEST_ASSESSMENT.duplicate_matches_json`. |
| US-009 | Implemented through deterministic risk score, risk factors, risk bands, and Admin configuration. |
| US-010 | Implemented through append-only `AI_ASSESSMENT`. |
| US-010A | Implemented through `REQUEST_ASSESSMENT.reviewer_adjustment_points`, final risk recalculation, and `ACTION_HISTORY` action `APPLY_JUSTIFICATION_RISK`. |
| US-011 | Implemented through latest flags on regenerated AI rows. |
| US-012 | Implemented through role-aware request list/detail for Reviewer. |
| US-013 | Implemented through `request_detail_safe_v`. |
| US-014 | Implemented through approval workflow and Fusion create job queue. |
| US-015 | Implemented through `ACTION_HISTORY`. |
| US-016 | Implemented through correction action history and requester allowed actions. |
| US-019 | Implemented through safe bank projections. |
| US-020 | Implemented through approved request source data and Fusion job payload references. |
| US-021 | Implemented through Fusion supplier ID/number fields. |
| US-022 | Implemented through `INTEGRATION_FAILED` status and integration job errors. |
| US-023 | Implemented through retry rows linked by `parent_job_id`. |
| US-024 | Implemented through seeded demo requests and Fusion reference data. |
| US-026 | Implemented through `ACTION_HISTORY`, `AI_ASSESSMENT`, and `INTEGRATION_JOB`. |

## Runtime Status

The local Oracle Database Free and ORDS setup points to the generated ATP/ORDS scripts.

Live startup is now working locally through Docker Compose. `supplier-oracle-db` and `supplier-ords` are running, `/ords/supplier-onboarding/v1/` returns a JSON index, and the concrete smoke endpoints pass through `oracle/local/scripts/check-local-oracle-ords.sh`.

The repeatable live endpoint write test is `oracle/local/scripts/test-local-ords-endpoints.py`. The latest passing run used token `T1784700331` and verified ORDS writes with direct SQL against Oracle, including `AI_ASSESSMENT` persistence through an `AI_EXPLANATION` integration result and Reviewer justification-risk adjustment persistence.

The repeatable demo data seed script is `oracle/local/scripts/seed-demo-data-via-ords.py`. The latest passing demo run used token `DEMO1784700360` and created readable rows for `DRAFT`, `VALIDATION_FAILED`, `UNDER_REVIEW`, `CORRECTION_REQUIRED`, `CREATED_IN_FUSION`, and `INTEGRATION_FAILED` scenarios, including an under-review row with `DEMO_ADJUSTMENT_POINTS=5`.

## Validation Results

| Check | Result |
|---|---|
| Markdown diagram scan | Passed: no Mermaid or ASCII diagrams generated in code summaries or the code generation plan. |
| ASCII scan | Passed: generated Oracle, ORDS, local runtime, tests, and code-summary files are ASCII-only. |
| Shell syntax | Passed: local ORDS shell scripts parse with `bash -n`. |
| Python syntax | Passed: `tests/` parses with `python3 -m compileall`. |
| SQL/PLSQL static check | Passed through local Oracle install/runtime checks; live schema reports `INVALID_OBJECTS=0`. |
| Property test execution | Passed in workspace `.venv`: 11 property tests passed. |
| Local ORDS smoke check | Passed: base route, health, requests, request detail, risk rules, high-risk countries, integration logs, and integration jobs respond. |
| Live ORDS write test | Passed: request lifecycle, documents, AI job, AI assessment write, justification-risk adjustment, integration claim/result, review approval, Fusion success, Fusion failure, retry, supplier sync, risk-rule update, and high-risk-country update persist in Oracle. |
| Demo seed through ORDS | Passed: `DEMO_REQUEST_ROWS=6`, with one row each for draft, validation failed, under review, correction required, Fusion created, and integration failed, plus `DEMO_ADJUSTMENT_POINTS=5`. |
| Direct DB persistence check | Passed: `REQUEST_ROWS=2`, `SUCCESS_STATUS=CREATED_IN_FUSION`, `RETRY_STATUS=INTEGRATION_FAILED`, `DOCUMENT_ROWS=2`, `ASSESSMENT_ROWS=2`, `AI_ROWS=1`, `ADJUSTMENT_POINTS=5`, `JUSTIFICATION_ACTION_ROWS=1`, `ACTION_ROWS=17`, `INTEGRATION_ROWS=6`, `SUPPLIER_REF_ROWS=1`, `HIGH_RISK_XZ=Y`, `RISK_RULE_UPDATED_BY=ADM_LINDA_SUB,TOTAL=100`, and `INVALID_OBJECTS=0`. |

## Extension Compliance

| Extension Rule | Status | Rationale |
|---|---|---|
| PBT-01 | Compliant | UOW-002 properties are represented in generated tests. |
| PBT-02 | Compliant | Request write/read model property test generated. |
| PBT-03 | Compliant | Workflow, permission, masking, retry, AI history, and configuration invariants generated. |
| PBT-04 | Compliant | Supplier reference upsert idempotence property generated. |
| PBT-05 | N/A | No separate optimized algorithm/reference implementation exists in UOW-002. |
| PBT-06 | Compliant | Workflow command sequence property tests generated. |
| PBT-07 | Compliant | Domain-specific Hypothesis generators generated in `tests/property/generators.py`. |
| PBT-08 | Compliant | Hypothesis shrinking remains enabled. |
| PBT-09 | Compliant | `pytest` and `hypothesis` dependencies generated in `tests/requirements.txt`. |
| PBT-10 | Compliant | Example tests and property tests are separated. |

## Content Validation

- No Mermaid diagrams are used.
- No ASCII diagrams are used.
- Markdown tables and code references are parser-compatible.
