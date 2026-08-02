# Project Progress Summary

## Project

Supplier Onboarding, Duplicate Detection & Risk Scoring

## Current Status

| Item | Status |
|---|---|
| Project type | Greenfield |
| Current AIDLC phase | Construction |
| Current AIDLC stage | Build and Test |
| Last completed stage | Code Generation Review for UOW-002 ATP/ORDS Supplier Request Foundation |
| Current review gate | Build and Test instruction generation and summary finalization are pending |
| Code generation status | Approved for the current UOW-002 backend/database scope |
| Oracle ATP/ORDS SQL/PLSQL/ORDS artifacts | Generated and verified locally |
| Visual Builder prototype | Built as a custom HTML/CSS Visual Builder prototype source |
| Postman collection | Generated and verified with 41 endpoint requests |

## Executive Summary

We used AIDLC to move the project from transcript discovery into a structured Oracle-native supplier onboarding prototype. The solution captures supplier requests, validates required fields, detects duplicate supplier risk against Fusion reference data, calculates explainable risk, stores Gemini advisory summaries, supports human review, and queues approved suppliers for Oracle Fusion ERP creation through OIC-style integration jobs.

The current formal AIDLC stage is Build and Test. Code Generation for `UOW-002 ATP/ORDS Supplier Request Foundation` is approved. The local database, ORDS service, seed data, Postman collection, and test harnesses have been generated and verified, but the formal Build/Test instruction package is not yet complete.

## Source Inputs Used

| Source | How It Was Used |
|---|---|
| Customer discovery transcript | Primary business source for request fields, validation, duplicate/risk, review decisions, logs, retry behavior, and Oracle/Fusion/Gemini direction. |
| `supplier_portal.html` | Visual reference for the early Visual Builder prototype layout. |
| `/home/ammarkhan/Downloads/technical-design (2).md` | Finalized schema/API source for the ATP/ORDS implementation pass. |
| AIDLC workflow rules | Used to structure requirements, stories, planning, application design, units, construction design, code generation, and Build/Test. |
| User answers and approvals | Used to resolve role scope, ATP/ORDS direction, log tables, correction workflow, PBT selection, Admin configuration, and endpoint progression. |

## AIDLC Stage Progress

| Phase | Stage | Status | Main Output |
|---|---|---|---|
| Inception | Workspace Detection | Complete | Greenfield project confirmed; reverse engineering skipped. |
| Inception | Requirements Analysis | Complete | Transcript converted into formal requirements. |
| Inception | User Stories Planning | Complete | Story planning and personas created. |
| Inception | User Stories Generation | Complete | User stories and personas generated. |
| Inception | Workflow Planning | Complete | Remaining AIDLC path defined. |
| Inception | Application Design | Complete | Oracle-native architecture defined. |
| Inception | Units Generation | Complete | Project decomposed into buildable units. |
| Construction | Functional Design for UOW-002 | Complete and approved | ATP/ORDS domain entities, business rules, and logic model generated. |
| Construction | NFR Requirements for UOW-002 | Complete and approved | Performance, privacy, reliability, auditability, maintainability, usability, and testing NFRs generated. |
| Construction | NFR Design for UOW-002 | Complete and approved | NFR design patterns and logical components generated. |
| Construction | Infrastructure Design for UOW-002 | Complete and approved | Local and cloud ATP/ORDS infrastructure approach documented. |
| Construction | Code Generation for UOW-002 | Complete and approved | ATP schema, PL/SQL packages, ORDS module, local Docker runtime, seed scripts, tests, and Postman setup generated. |
| Construction | Build and Test | In progress | Verification has run; formal instruction files and Build/Test summary still need finalization. |

## Approved Role Model

| Role | Main Responsibilities |
|---|---|
| Requester | Create supplier requests, provide supplier data, upload/provide evidence, correct returned requests, resubmit, and track status. |
| Reviewer | Handle procurement, master-data, finance/payment, compliance/tax/document, duplicate, risk, approval, rejection, duplicate closure, and correction-request concerns. |
| Admin | Inspect OIC/Fusion logs, diagnose technical failures, view payload/response references, maintain risk configuration, maintain high-risk countries, and retry eligible failures. |

Finance, Compliance, and Supplier Data Governance are business concerns handled under Reviewer. IT/support responsibilities are represented by Admin.

## Core Application Flow

1. Requester creates a supplier onboarding request in Visual Builder.
2. Visual Builder calls ORDS `POST /requests`.
3. ORDS writes the request to ATP through PL/SQL packages.
4. Requester submits the request through `POST /requests/{id}/submit`.
5. ATP runs required-field validation, duplicate evidence checks, deterministic risk scoring, and AI job creation.
6. OIC-style jobs process Gemini advisory output and Fusion supplier creation.
7. Reviewer reviews request details, validation findings, duplicate evidence, deterministic risk, and Gemini advisory text.
8. Reviewer may apply no justification-risk adjustment or explicitly add `+3`, `+5`, or `+10` points.
9. Reviewer approves, rejects, marks duplicate, or sends correction.
10. If correction is requested, Requester sees an Edit action and resubmits.
11. If approved, a `FUSION_CREATE` integration job is queued.
12. Fusion success or failure is written back to ATP.
13. Admin reviews integration logs and retries eligible technical failures.

## Visual Builder Prototype

| File | Purpose |
|---|---|
| `visual-builder/item-1-start-page.html` | Current custom Visual Builder page source for Requester, Reviewer, and Admin flows. |
| `visual-builder/README.md` | Sharing/import notes and backend contract summary for the prototype. |
| `visual-builder/*.png` | Screenshots from Visual Builder preview and update checks. |

Current prototype capabilities:

- Requester dashboard, request creation, required-field validation, document metadata area, correction banner, and edit behavior.
- Reviewer request detail, duplicate/risk evidence, Gemini advisory area, `+3`, `+5`, `+10` justification-risk controls, Accept, Reject, Mark Duplicate, and Send Correction.
- Admin integration/audit log view, retry area, high-risk country maintenance, and risk-rule weight editor with active weights totaling 100.

## Backend and Database

| Area | Files |
|---|---|
| ATP schema | `oracle/atp/schema/001_core_request_schema.sql`, `002_workflow_history_result_schema.sql`, `003_configuration_schema.sql`, `004_views_indexes.sql` |
| ATP packages | `oracle/atp/packages/supplier_*.pks`, `oracle/atp/packages/supplier_*.pkb` |
| ATP seed data | `oracle/atp/seed/001_seed_roles_permissions.sql`, `002_seed_configuration.sql`, `003_seed_supplier_reference_and_demo.sql` |
| ORDS module | `oracle/ords/modules/001_supplier_onboarding_module.sql` |
| Local runtime | `oracle/local/docker-compose.yml`, `oracle/local/ords/Dockerfile`, `oracle/local/ords/entrypoint.sh`, `oracle/local/scripts/` |
| Local schema mirrors | `oracle/local/db-init/01-schema.sql`, `oracle/local/db-init/02-seed.sql`, `oracle/local/ords/sql/20-define-modules.sql` |

Generated tables include `SUPPLIER_REQUEST`, `REQUEST_DOCUMENT`, `REQUEST_ASSESSMENT`, Fusion reference cache tables, `AI_ASSESSMENT`, `ACTION_HISTORY`, `INTEGRATION_JOB`, scalar `CONFIGURATION`, `RISK_RULE_CONFIG`, `RISK_SCORE_BAND_CONFIG`, `HIGH_RISK_COUNTRY_CONFIG`, `TAX_REQUIREMENT_CONFIG`, `BUSINESS_UNIT_SITE_MAPPING`, and `GENERIC_JUSTIFICATION_PHRASE`.

## Current API Contract

Base URL:

```text
http://localhost:8080/ords/supplier-onboarding/v1/
```

Current route groups:

- Requester/reviewer/admin request list and detail: `GET /requests`, `GET /requests/{id}`.
- Request lifecycle: `POST /requests`, `PUT /requests/{id}`, `POST /requests/{id}/submit`.
- Documents: `POST /requests/{id}/documents`, `GET /requests/{id}/documents/{document_id}`.
- Reviewer actions: `POST /requests/{id}/review`, `POST /requests/{id}/justification-risk-adjustment`, `POST /requests/{id}/ai-regeneration`.
- OIC jobs: `GET /integration-jobs`, `POST /integration-jobs/{job_id}/claim`, `PUT /integration-jobs/{job_id}/result`.
- Admin/support: `GET /integration-logs`, `POST /requests/{id}/retry`.
- Supplier reference sync: `POST /supplier-reference/batch`.
- Admin configuration: `GET /risk-rules`, `PUT /risk-rules/{rule_code}`, `GET /high-risk-countries`, `PUT /high-risk-countries/{country_code}`.

Local ORDS 26.2 `PUT` handlers are verified with query parameters for request updates, integration job results, risk-rule updates, and high-risk-country updates.

## Verification Completed

| Check | Latest Result |
|---|---|
| Docker Compose config | Passed |
| Local Oracle DB health | Passed; `SUPPLIER_APP` has 17 tables |
| Local ORDS smoke check | Passed |
| Python syntax | Passed for generated tests and local scripts |
| Shell syntax | Passed for local scripts and ORDS entrypoint |
| Postman JSON validation | Passed |
| Postman/Newman endpoint run | Passed with 41 requests, 17 assertions, 0 failures |
| Python pytest suite | Passed in `.venv` with 24 tests total |
| Property tests | Passed with 11 tests |
| Example API tests | Passed with 13 tests |
| Live ORDS/database persistence | Passed with token `T1784715944` |
| Demo seed through ORDS | Passed with token `DEMO1784715959` |
| Visual Builder smoke | Passed; 17 required fields and risk weights total 100 |

## Postman Setup

| File | Purpose |
|---|---|
| `postman/supplier-onboarding-local.postman_collection.json` | Importable Postman collection with 41 runnable requests. |
| `postman/supplier-onboarding-local.postman_environment.json` | Local environment with `baseUrl` and role subject values. |
| `postman/README.md` | Import and run instructions. |
| `postman/vscode-extension-setup.md` | Cursor/VS Code Postman extension notes. |
| `deliverables/supplier-postman-setup-2026-07-22.zip` | Shareable Postman setup archive. |

## Test Harness

| File or Folder | Purpose |
|---|---|
| `tests/example/` | Example-based ORDS API tests for lifecycle, roles, logs, config, and safe projection. |
| `tests/property/` | Hypothesis property-based tests for workflow, permission, projection, retry, AI history, and config invariants. |
| `tests/frontend/smoke-visual-builder.js` | Playwright smoke test for the Visual Builder HTML prototype. |
| `tests/requirements.txt` | Python test dependencies: `pytest`, `hypothesis`, `requests`, and `oracledb`. |
| `pytest.ini` | Pytest discovery and marker config. |

System Python lacked `pip` and `ensurepip`, so the latest successful Python test execution used a workspace `.venv` created with the `virtualenv` zipapp.

## Current Documentation Set

| File | Purpose |
|---|---|
| `aidlc-docs/aidlc-state.md` | Current AIDLC phase, stage, extension configuration, progress, and next step. |
| `aidlc-docs/audit.md` | Append-only log of user inputs, approvals, and AI actions. |
| `aidlc-docs/inception/requirements/requirements.md` | Formal transcript-derived requirements. |
| `aidlc-docs/inception/user-stories/personas.md` | Personas and stakeholder roles. |
| `aidlc-docs/inception/user-stories/stories.md` | User stories and acceptance criteria. |
| `aidlc-docs/inception/business-flow.md` | Business-readable flow of who does what. |
| `aidlc-docs/inception/application-design/` | Component, service, dependency, and unit design artifacts. |
| `aidlc-docs/construction/atp-ords-foundation/functional-design/` | UOW-002 business logic and entity design. |
| `aidlc-docs/construction/atp-ords-foundation/nfr-requirements/` | UOW-002 NFR requirements and tech stack decisions. |
| `aidlc-docs/construction/atp-ords-foundation/nfr-design/` | UOW-002 NFR patterns and logical components. |
| `aidlc-docs/construction/atp-ords-foundation/infrastructure-design/` | UOW-002 local/cloud infrastructure design. |
| `aidlc-docs/construction/atp-ords-foundation/code/` | Code generation, API, schema reconciliation, coverage, and test summaries. |

## What Is Still Not Done

- Formal AIDLC Build/Test instruction files are not yet generated under `aidlc-docs/construction/build-and-test/`.
- Build/Test has not yet been presented for the required approval gate.
- Cloud ATP/ORDS migration is not done yet.
- Visual Builder is not yet wired to the cloud backend as live service connections.
- Real production IAM, OIC, Fusion, and Gemini credentials/integrations are not configured in this local prototype.
- Future table/schema changes mentioned by the user are not incorporated until the user provides them.

## Immediate Next Step

Complete the formal Build and Test stage by generating:

- `aidlc-docs/construction/build-and-test/build-instructions.md`
- `aidlc-docs/construction/build-and-test/unit-test-instructions.md`
- `aidlc-docs/construction/build-and-test/integration-test-instructions.md`
- `aidlc-docs/construction/build-and-test/performance-test-instructions.md`
- `aidlc-docs/construction/build-and-test/build-and-test-summary.md`

After that, the Build/Test stage requires review and approval before moving to the Operations placeholder or cloud deployment planning.

## Content Validation

- No Mermaid diagrams are used.
- No ASCII diagrams are used.
- Markdown tables and lists are parser-compatible.
