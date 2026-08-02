# Code Generation Plan: UOW-002 ATP/ORDS Supplier Request Foundation

## Stage Context

This is the required Part 1 Code Generation plan for `UOW-002 ATP/ORDS Supplier Request Foundation`.

This plan was the approved source for the implementation pass. Later user-provided finalized schema input superseded early draft schema assumptions where noted in the "Finalized Schema Reconciliation" section below.

The unit generated the ATP/ORDS backend foundation for Visual Builder: finalized Oracle schema scripts, PL/SQL package logic, ORDS module definitions, local runtime wiring, seed data, example tests, property-based tests, and code summaries.

## Planning Checklist

- [x] Read `aidlc-docs/aidlc-state.md` for workspace root, project type, enabled extensions, and current stage.
- [x] Read `.aidlc-rule-details/construction/code-generation.md`.
- [x] Read `.aidlc-rule-details/common/content-validation.md`.
- [x] Read `.aidlc-rule-details/extensions/testing/property-based/property-based-testing.md`.
- [x] Read UOW-002 requirements, user stories, unit story map, functional design, NFR requirements, NFR design, and infrastructure design artifacts.
- [x] Review the existing local Oracle Database Free and ORDS setup under `oracle/local/`.
- [x] Determine final code locations outside `aidlc-docs/`.
- [x] Include story traceability and PBT requirements in this plan.
- [x] Record the initial local runtime blocker and later verify Docker Compose, Oracle Database Free, and ORDS runtime after setup.
- [x] Validate this plan content uses no Mermaid diagrams, no ASCII diagrams, and parser-compatible Markdown.

## Source Artifacts Loaded

- `aidlc-docs/aidlc-state.md`
- `aidlc-docs/inception/requirements/requirements.md`
- `aidlc-docs/inception/user-stories/stories.md`
- `aidlc-docs/inception/application-design/unit-of-work.md`
- `aidlc-docs/inception/application-design/unit-of-work-dependency.md`
- `aidlc-docs/inception/application-design/unit-of-work-story-map.md`
- `aidlc-docs/construction/atp-ords-foundation/functional-design/domain-entities.md`
- `aidlc-docs/construction/atp-ords-foundation/functional-design/business-rules.md`
- `aidlc-docs/construction/atp-ords-foundation/functional-design/business-logic-model.md`
- `aidlc-docs/construction/atp-ords-foundation/nfr-requirements/nfr-requirements.md`
- `aidlc-docs/construction/atp-ords-foundation/nfr-requirements/tech-stack-decisions.md`
- `aidlc-docs/construction/atp-ords-foundation/nfr-design/nfr-design-patterns.md`
- `aidlc-docs/construction/atp-ords-foundation/nfr-design/logical-components.md`
- `aidlc-docs/construction/atp-ords-foundation/infrastructure-design/infrastructure-design.md`
- `aidlc-docs/construction/atp-ords-foundation/infrastructure-design/deployment-architecture.md`
- `oracle/local/README.md`
- `oracle/local/docker-compose.yml`
- `oracle/local/db-init/00-create-app-user.sql`
- `oracle/local/db-init/01-schema.sql`
- `oracle/local/db-init/02-seed.sql`
- `oracle/local/ords/sql/10-enable-schema.sql`
- `oracle/local/ords/sql/20-define-modules.sql`
- `.aidlc-rule-details/construction/code-generation.md`
- `.aidlc-rule-details/common/content-validation.md`
- `.aidlc-rule-details/extensions/testing/property-based/property-based-testing.md`

## Unit Context

| Item | Decision |
|---|---|
| Project type | Greenfield |
| Unit | UOW-002 ATP/ORDS Supplier Request Foundation |
| Build order | First backend construction unit |
| Owns | ATP persistence, ORDS contracts, foundational validation, workflow state, IAM subject/role authorization context, audit/log/config storage, safe projections, local runtime wrapper |
| Does not own | Final duplicate/risk algorithms, Gemini orchestration, OIC payload transformation, Fusion supplier master logic, production OCI tenancy provisioning |
| Direct dependencies | None for initial build |
| Used by | Visual Builder UI binding, duplicate/risk logic, OIC/Fusion/Gemini integration, audit/test/demo evidence |
| Current local assets | Starter local runtime under `oracle/local/` |
| Runtime status | Docker Compose local Oracle Database Free and ORDS are running and verified at `http://localhost:8080/ords/supplier-onboarding/v1/` |

## Code Location Decision

Application code and runtime artifacts will be generated under the workspace root only. Documentation summaries will be generated under `aidlc-docs/`.

| Artifact Type | Target Path |
|---|---|
| ATP schema scripts | `oracle/atp/schema/` |
| ATP PL/SQL packages | `oracle/atp/packages/` |
| ATP seed scripts | `oracle/atp/seed/` |
| ORDS modules | `oracle/ords/modules/` |
| Local database/ORDS runner | `oracle/local/` |
| Example tests | `tests/example/` |
| Property-based tests | `tests/property/` |
| Test dependency/config files | `tests/requirements.txt`, `pytest.ini` |
| Code summary documents | `aidlc-docs/construction/atp-ords-foundation/code/` |

## Configuration Format Decision

The user requested no raw JSON-style configuration for human-readable business settings.

Code Generation must therefore use:

- Structured tables for strict business controls: `RISK_RULE_CONFIG`, `RISK_SCORE_BAND_CONFIG`, and `HIGH_RISK_COUNTRY_CONFIG`.
- Simple scalar key/value rows in `CONFIGURATION` only where a generic setting is still needed.
- Human-readable seed values and descriptions.
- No raw JSON values for risky countries, score bands, risk weights, tax requirements, generic justification phrases, or business-unit/site mappings.

ORDS responses are still REST responses, but business-maintained configuration stored in ATP must remain readable and table-shaped.

## Story Traceability

| Story | UOW-002 Code Generation Coverage |
|---|---|
| US-001 | Create and update draft request API, persistence, and `DRAFT` state. |
| US-002 | Attachment metadata and object-reference persistence/API contract. |
| US-003 | Submit workflow and foundational validation. |
| US-004 | Status tracking and requester dashboard data. |
| US-005 | Correction, requester edit visibility, and resubmit flow. |
| US-006 | Foundational validation storage and execution surface. |
| US-007 | Supplier reference tables for seeded/mock and future synced data. |
| US-008 | Duplicate result storage tables and supplier reference access. |
| US-009 | Risk result storage, structured risk configuration, risky-country list, and reviewer-adjusted final score support. |
| US-010 | AI assessment history storage with Gemini business-justification metadata. |
| US-010A | Reviewer `+3`, `+5`, and `+10` justification-risk adjustment persistence and audit. |
| US-011 | Append-only regenerated AI assessment history. |
| US-012 | Reviewer dashboard/query endpoint. |
| US-013 | Request detail aggregation with validation, duplicate, risk, AI, history, attachments, integration, and allowed actions. |
| US-014 | Approval workflow state and approved request source data. |
| US-015 | Accept, reject, duplicate-as-reject, and correction decisions in `ACTION_HISTORY`. |
| US-016 | Requester-visible correction reason and edit action. |
| US-019 | Masked bank storage/display contract. |
| US-020 | Approved request data for later OIC/Fusion submission. |
| US-021 | Fusion response and supplier number storage fields. |
| US-022 | Integration failure status and log storage. |
| US-023 | Retry job chain persistence with `parent_job_id` and attempt numbers. |
| US-024 | Seeded demo data support. |
| US-026 | Audit tables and write surfaces. |

## Generation Plan

### Step 1: Formal Project Structure Setup

- [x] Create or verify `oracle/atp/schema/`, `oracle/atp/packages/`, `oracle/atp/seed/`, `oracle/ords/modules/`, `tests/example/`, `tests/property/`, and `aidlc-docs/construction/atp-ords-foundation/code/`.
- [x] Keep all executable code and runtime scripts outside `aidlc-docs/`.
- [x] Reuse `oracle/local/` as the local runner rather than creating a duplicate local setup.

### Step 2: ATP Schema Generation

- [x] Generate `oracle/atp/schema/001_core_request_schema.sql` for flattened `SUPPLIER_REQUEST` and `REQUEST_DOCUMENT`.
- [x] Generate `oracle/atp/schema/002_workflow_history_result_schema.sql` for `REQUEST_ASSESSMENT`, Fusion reference cache tables, `ACTION_HISTORY`, `AI_ASSESSMENT`, and `INTEGRATION_JOB`.
- [x] Generate `oracle/atp/schema/003_configuration_schema.sql` for `CONFIGURATION`, `RISK_RULE_CONFIG`, `RISK_SCORE_BAND_CONFIG`, `HIGH_RISK_COUNTRY_CONFIG`, `TAX_REQUIREMENT_CONFIG`, `BUSINESS_UNIT_SITE_MAPPING`, and `GENERIC_JUSTIFICATION_PHRASE` without JSON-valued business settings.
- [x] Generate `oracle/atp/schema/004_views_indexes.sql` for safe projections, dashboard indexes, admin log indexes, supplier lookup indexes, and masked-bank-safe views.

### Step 3: ATP Seed Data Generation

- [x] Retain `oracle/atp/seed/001_seed_roles_permissions.sql` as a no-op compatibility seed after finalized IAM subject-column reconciliation.
- [x] Generate `oracle/atp/seed/002_seed_configuration.sql` with readable scalar configuration, risk rules totaling 100 active deterministic points, score bands, seeded risky countries, tax rules, generic phrase rows, and business-unit/site mappings.
- [x] Generate `oracle/atp/seed/003_seed_supplier_reference_and_demo.sql` with mock Fusion supplier references and demo scenarios for clean, duplicate, missing tax, bank mismatch, incomplete address, vague justification, and integration failure cases.

### Step 4: PL/SQL Package Specification Generation

- [x] Generate package specs for `supplier_auth_pkg`, `supplier_workflow_pkg`, `supplier_validation_pkg`, `supplier_request_pkg`, `supplier_review_pkg`, `supplier_dashboard_pkg`, `supplier_integration_pkg`, `supplier_config_pkg`, and `supplier_projection_pkg` under `oracle/atp/packages/`.
- [x] Define public procedures/functions for create, update, submit, review, correction, justification-risk adjustment, retry, configuration maintenance, risky-country maintenance, dashboards, request detail projection, and safe response helpers.

### Step 5: PL/SQL Package Body Generation

- [x] Implement role resolution and backend authorization checks.
- [x] Implement allowed workflow transitions and `ACTION_HISTORY` writes.
- [x] Implement foundational validation for mandatory fields, email-like contact, address/site, applicable tax, non-negative spend, and provided bank metadata.
- [x] Implement request create, update, submit, correction edit, document metadata, and read behavior.
- [x] Implement reviewer Accept, Reject, Send Correction, Duplicate status, and `+3`, `+5`, `+10` Gemini justification-risk adjustment behavior.
- [x] Implement Admin integration log query, retry eligibility, retry row creation, risky-country maintenance, and risk-weight allocation checks.
- [x] Implement safe projections that mask bank values and return stable allowed actions.

### Step 6: ORDS Module Generation

- [x] Generate `oracle/ords/modules/001_supplier_onboarding_module.sql`.
- [x] Define package-backed ORDS handlers for service index, health, request list/create/detail/update/submit, request documents, review decision, AI regeneration, justification-risk adjustment, Admin retry, integration logs/jobs, supplier reference batch, risk rules, and high-risk countries.
- [x] Preserve local base URL compatibility: `/ords/supplier-onboarding/v1/`.
- [x] Replace starter direct-SQL mutation handlers with package-backed handlers where workflow, validation, role checks, or audit writes are required.

### Step 7: Local Runtime Reconciliation

- [x] Update `oracle/local/docker-compose.yml` if needed so local containers can mount formal `oracle/atp/` and `oracle/ords/` scripts read-only.
- [x] Update `oracle/local/db-init/01-schema.sql` to call or mirror the formal schema scripts.
- [x] Update `oracle/local/db-init/02-seed.sql` to call or mirror the formal seed scripts.
- [x] Update `oracle/local/ords/sql/20-define-modules.sql` to call or mirror the formal ORDS module.
- [x] Keep `oracle/local/scripts/preflight-local-oracle-ords.sh`, `start-local-oracle-ords.sh`, `check-local-oracle-ords.sh`, and `stop-local-oracle-ords.sh` aligned with the final endpoint set.

### Step 8: Example-Based API and Database Tests

- [x] Generate `tests/example/test_supplier_request_lifecycle.py` for create, submit, validation failed, under review, accept, reject, correction, and resubmit scenarios.
- [x] Generate `tests/example/test_reviewer_and_requester_actions.py` for role enforcement, allowed actions, correction Edit visibility, and Reviewer buttons.
- [x] Generate `tests/example/test_admin_config_and_logs.py` for Admin logs, retry eligibility, risky-country maintenance, risk allocation total, and score bands.
- [x] Generate `tests/example/test_sensitive_projection.py` for masked bank output and safe admin log projections.

### Step 9: Property-Based Test Generation

- [x] Generate `tests/property/generators.py` with domain-specific Hypothesis strategies for supplier requests, users, role/action pairs, workflow commands, bank profiles, supplier references, integration jobs, AI assessments, reviewer adjustments, and risky-country changes.
- [x] Generate workflow and status properties for P-UOW002-001 and P-UOW002-002.
- [x] Generate permission invariants for P-UOW002-003.
- [x] Generate request persistence round-trip properties for P-UOW002-004.
- [x] Generate bank masking properties for P-UOW002-005.
- [x] Generate supplier reference idempotence properties for P-UOW002-006.
- [x] Generate retry-chain properties for P-UOW002-007.
- [x] Generate AI append-only history properties for P-UOW002-008.
- [x] Generate correction visibility properties for P-UOW002-009.
- [x] Generate justification-risk adjustment properties for P-UOW002-010.
- [x] Generate risky-country configuration properties for P-UOW002-011.

### Step 10: Test Harness Configuration

- [x] Generate `tests/requirements.txt` with `pytest`, `hypothesis`, `requests`, and `oracledb`.
- [x] Generate `pytest.ini` with example and property test markers.
- [x] Configure Hypothesis usage so shrinking remains enabled and failures remain reproducible through Hypothesis reproduction output.
- [x] Add environment variables for ORDS base URL and optional database connection settings.

### Step 11: Local Smoke Check Updates

- [x] Update `oracle/local/scripts/check-local-oracle-ords.sh` to cover the final endpoint set.
- [x] Keep checks readable and tolerant of unavailable optional integration data.
- [x] Preserve clear failure messages for missing Compose runtime and unavailable ORDS.

### Step 12: Code Summary Documentation

- [x] Generate `aidlc-docs/construction/atp-ords-foundation/code/code-generation-summary.md`.
- [x] Generate `aidlc-docs/construction/atp-ords-foundation/code/api-contract-summary.md`.
- [x] Generate `aidlc-docs/construction/atp-ords-foundation/code/test-coverage-summary.md`.
- [x] Document generated files, endpoint coverage, story coverage, PBT coverage, local startup status, and remaining blockers.

### Step 13: Validation Pass

- [x] Validate generated Markdown has no Mermaid or ASCII diagram parsing risk unless explicitly validated first.
- [x] Run shell syntax checks on updated shell scripts.
- [x] Run SQL/PLSQL static checks where available from the local toolchain.

## Review Change Request: Finalized Schema Reconciliation

The user supplied `/home/ammarkhan/Downloads/technical-design (2).md` as the finalized schema source during Code Generation Review. This change request supersedes earlier draft schema assumptions where they conflict with the finalized technical design.

- [x] Log the finalized schema reference request in `aidlc-docs/audit.md`.
- [x] Read the finalized ATP table, IAM-role, status-model, risk, duplicate, integration, and ORDS endpoint sections.
- [x] Replace prototype ATP user/role tables with Oracle IAM subject-column assumptions.
- [x] Flatten the phase-one request model into `SUPPLIER_REQUEST` plus `REQUEST_DOCUMENT`.
- [x] Replace draft validation, duplicate, risk, and reviewer-adjustment tables with finalized `REQUEST_ASSESSMENT` history.
- [x] Replace generic supplier-reference draft tables with finalized Fusion reference-cache tables.
- [x] Reconcile `AI_ASSESSMENT`, `ACTION_HISTORY`, `INTEGRATION_JOB`, and `CONFIGURATION` with the finalized fields.
- [x] Reconcile PL/SQL package signatures and implementation with IAM subjects and finalized statuses.
- [x] Reconcile ORDS paths with the finalized `/requests`, `/integration-jobs`, `/supplier-reference/batch`, `/risk-rules`, and `/high-risk-countries` contracts.
- [x] Update seed scripts, local runtime checks, tests, and code summaries to match the finalized schema.
- [x] Run static validation and document any runtime blockers.
- [x] Run Python syntax checks for tests.
- [x] Run local preflight script to confirm the blocker remains limited to missing Docker Compose or Podman Compose, unless the runtime has been installed.

## Review Change Request: Local Database Dockerization

The user confirmed Docker Desktop and the earlier ORDS issue are working and requested the database be Dockerized.

- [x] Log the database Dockerization request in `aidlc-docs/audit.md`.
- [x] Confirm `oracle/local/docker-compose.yml` defines an `oracle-db` service with Oracle Database Free, persistent volume storage, and schema/seed init mounts.
- [x] Add DB-only helper scripts for starting and checking the local Oracle database without requiring ORDS.
- [x] Update `oracle/local/README.md` with DB-only start and verification instructions.
- [x] Run shell syntax checks for the updated local runtime scripts.
- [x] Start the local `oracle-db` service through Docker Compose.
- [x] Add repeatable local scripts for Oracle Docker Desktop MPK repair and schema installation after a first-boot failure.
- [x] Reconcile Admin-maintained configuration tables so business settings are human-readable and not JSON-valued.
- [x] Verify the container reaches healthy status under the stricter `SUPPLIER_APP` schema healthcheck.
- [x] Verify the `SUPPLIER_APP` schema and seeded supplier request data are reachable from inside the container.
- [x] Verify active risk-rule weights total 100 and the seeded high-risk-country list is present.

## Review Change Request: Local ORDS Startup Verification

The user attempted to start local ORDS after the database-only flow and hit a false port-conflict failure because Oracle DB was already running on port 1521.

- [x] Log the ORDS startup failure and fix request in `aidlc-docs/audit.md`.
- [x] Update ORDS preflight so already-running Compose services can reuse their expected ports.
- [x] Add the required ORDS inherit-privileges grant for `SUPPLIER_APP`.
- [x] Move `ORDS.enable_schema` into the app-schema ORDS module setup instead of running it as `SYS`.
- [x] Update the ORDS entrypoint for ORDS 26.2 `serve --port` syntax.
- [x] Make the ORDS pool name optional so local routing remains `/ords/supplier-onboarding/v1/` without an extra pool segment.
- [x] Rebuild/recreate only the ORDS image/config volume while preserving the Oracle DB volume.
- [x] Verify all local ORDS smoke endpoints pass through `check-local-oracle-ords.sh`.

## Review Change Request: Live ORDS Endpoint and DB Write Verification

The user requested a Postman-style live test of all local endpoints and confirmation that writes persist in Oracle.

- [x] Log the live endpoint/database write test request in `aidlc-docs/audit.md`.
- [x] Create `oracle/local/scripts/test-local-ords-endpoints.py` as a repeatable local endpoint and database persistence test.
- [x] Test read endpoints for base route, health, requests, risk rules, high-risk countries, integration logs, and integration jobs.
- [x] Test request creation, request detail readback, request update, document metadata creation, document readback, and submission.
- [x] Test AI regeneration job creation, integration job claim, and integration job result recording.
- [x] Rename the integration-result ORDS status bind to `job_status` and use query parameters for local OIC-style PUT result recording.
- [x] Test reviewer approval, Fusion-create job success, Fusion-create job failure, retry job creation, and supplier reference upsert.
- [x] Test Admin risk-rule update and high-risk-country update using query parameters for local ORDS PUT binding.
- [x] Run direct Oracle SQL verification for request rows, statuses, documents, assessments, action history, integration jobs, retry parentage, supplier reference rows, high-risk-country update, risk-rule total, and invalid objects.
- [x] Update code summaries and API notes with live endpoint/database verification results.

## Review Change Request: Demo Data Seeding and AI Result Wiring

The user confirmed the tables are visible in a database GUI and requested dummy data, plus confirmation that hitting ORDS endpoints populates the tables.

- [x] Log the demo data and endpoint wiring request in `aidlc-docs/audit.md`.
- [x] Update `supplier_integration_pkg.complete_job` so completed `AI_EXPLANATION` jobs write append-only rows into `AI_ASSESSMENT`.
- [x] Update `PUT /integration-jobs/{job_id}/result` so OIC/Gemini result parameters can include AI summary, recommended actions, justification quality, and model name.
- [x] Update the live endpoint test to verify `AI_ASSESSMENT` persistence through ORDS.
- [x] Add `oracle/local/scripts/seed-demo-data-via-ords.py` for reusable supervisor/demo data seeding through ORDS.
- [x] Seed demo scenarios through ORDS for `DRAFT`, `VALIDATION_FAILED`, `UNDER_REVIEW`, `CORRECTION_REQUIRED`, `CREATED_IN_FUSION`, and `INTEGRATION_FAILED`.
- [x] Seed document metadata, request assessments, AI assessment, action history, integration jobs, retry job, supplier reference, risk rule update, and high-risk-country update through ORDS.
- [x] Verify seeded data with direct Oracle SQL after the ORDS calls.
- [x] Rerun the full live endpoint persistence test after the AI wiring change.

## Review Change Request: Final Requirements Coverage Fix

The final approval review found that active requirements FR-100, FR-101, FR-139, and FR-140 still require Reviewer-confirmed Gemini business-justification risk adjustment, but the generated ORDS/backend contract did not yet expose that action.

- [x] Add `deterministic_risk_score`, `reviewer_adjustment_points`, `reviewer_adjustment_reason`, `reviewer_adjusted_by_subject_id`, and `reviewer_adjusted_at` to `REQUEST_ASSESSMENT`.
- [x] Update deterministic submission assessment so the original deterministic score is stored separately from the final displayed score.
- [x] Add `supplier_review_pkg.apply_justification_risk_adjustment`.
- [x] Add `POST /requests/{request_id}/justification-risk-adjustment`.
- [x] Update safe request views and allowed actions so Reviewer detail can show/apply justification-risk adjustments.
- [x] Update live endpoint and demo seed scripts to exercise the adjustment path.
- [x] Apply the live local database upgrade, reload ORDS, and verify `INVALID_OBJECTS=0`.
- [x] Verify the live endpoint test passes with `ADJUSTMENT_POINTS=5` and `JUSTIFICATION_ACTION_ROWS=1`.

### Step 14: AIDLC Progress Updates

- [x] Mark each completed generation step `[x]` immediately in this plan during implementation.
- [x] Mark associated UOW-002 story coverage complete in this plan or the code summary when generated.
- [x] Update `aidlc-docs/aidlc-state.md` as Code Generation progresses.
- [x] Append audit entries for implementation actions and final Code Generation completion prompt.

## PBT Compliance Plan

| Rule | Planned Handling |
|---|---|
| PBT-01 | Carried forward from Functional Design properties P-UOW002-001 through P-UOW002-011. |
| PBT-02 | Covered by request write/read round-trip property tests. |
| PBT-03 | Covered by workflow, permission, masking, retry, AI history, correction, justification-risk, and risky-country invariants. |
| PBT-04 | Covered by supplier reference upsert and configuration behavior where idempotence is required. |
| PBT-05 | N/A unless a formal reference implementation is created during generation; simple model-based workflow checks will be used where practical. |
| PBT-06 | Covered by generated workflow command sequence tests. |
| PBT-07 | Covered by reusable domain-specific generators in `tests/property/generators.py`. |
| PBT-08 | Covered by Hypothesis defaults, reproducibility notes, and Build/Test instructions. |
| PBT-09 | Satisfied by `pytest` plus `hypothesis`, with dependencies generated in `tests/requirements.txt`. |
| PBT-10 | Covered by separate example tests for business-critical flows plus property tests for invariants. |

No blocking PBT findings apply to this planning artifact because the plan includes PBT test generation steps for the applicable UOW-002 properties.

## Expected Output Summary

If approved, Code Generation will create or update:

- Formal ATP schema scripts in `oracle/atp/schema/`.
- PL/SQL package specs and bodies in `oracle/atp/packages/`.
- Seed scripts in `oracle/atp/seed/`.
- ORDS module definitions in `oracle/ords/modules/`.
- Reconciled local runtime scripts under `oracle/local/`.
- Example and property tests under `tests/`.
- Code summary Markdown under `aidlc-docs/construction/atp-ords-foundation/code/`.

Live local startup can only be verified after Docker Compose or Podman Compose is installed.

## Content Validation

- No Mermaid diagrams are used.
- No ASCII diagrams are used.
- Markdown tables, lists, and code references are parser-compatible.
