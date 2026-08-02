# NFR Requirements: UOW-002 ATP/ORDS Supplier Request Foundation

## Purpose

This document defines non-functional requirements for the ATP/ORDS foundation unit. It translates approved project NFRs into unit-specific requirements for performance, scalability, security, reliability, auditability, maintainability, usability, and testing.

## Scope Boundary

UOW-002 owns ATP persistence, PL/SQL-backed workflow behavior, ORDS API contracts, foundational validation, role enforcement, dashboard query models, and append-oriented history/log/configuration structures.

UOW-002 does not own final Fusion supplier master behavior, deep duplicate matching, full risk scoring, Gemini prompt orchestration, OIC payload transformations, or production operations runbooks. Those remain later-unit or later-stage concerns.

## NFR Requirement Matrix

| ID | Category | Requirement | Verification Direction |
|---|---|---|---|
| UOW002-NFR-PERF-001 | Performance | Request create, update, submit, review, dashboard, and log APIs should respond within about 2 seconds for approved prototype volumes under normal test conditions. | Example API timing tests in Code Generation and Build/Test. |
| UOW002-NFR-PERF-002 | Performance | Submit validation should complete within about 2 seconds for one request with one primary site, one primary contact, optional bank profile, and supplier document metadata. | Example lifecycle tests plus timing notes. |
| UOW002-NFR-PERF-003 | Performance | Dashboard and log queries must use indexed/filterable access patterns and must not depend on hardcoded tiny sample datasets. | Schema/index review and query scenario tests. |
| UOW002-NFR-SCALE-001 | Scalability | The foundation must support at least 50 to 100 supplier requests and a few hundred supplier reference records for phase one. | Seed data and dashboard/query tests. |
| UOW002-NFR-SCALE-002 | Scalability | ORDS list endpoints must support stable filtering and pagination or limit parameters for dashboards and logs. | ORDS contract review and API tests. |
| UOW002-NFR-SEC-001 | Security and Privacy | ORDS/ATP must enforce phase-one Requester, Reviewer, and Admin role permissions for protected actions. | Role/action example tests and PBT permission invariants. |
| UOW002-NFR-SEC-002 | Security and Privacy | Normal UI, dashboard, detail, and log responses must not expose full bank account values. | Example tests and PBT bank masking invariants. |
| UOW002-NFR-SEC-003 | Security and Privacy | Bank data storage must use encrypted/protected values where needed, last-four values, bank country/currency, and protected fingerprints rather than relying on unrestricted full account display. | Schema review and response tests. |
| UOW002-NFR-SEC-004 | Security and Privacy | Production identity integration, deeper encryption/key management, and formal security baseline controls are documented limitations for phase one. | Design review. |
| UOW002-NFR-REL-001 | Reliability | ATP workflow logic must keep request state transitions transactionally consistent with `ACTION_HISTORY` records. | Workflow example tests and stateful PBT. |
| UOW002-NFR-REL-002 | Reliability | Business validation failures must be separated from technical integration failures. | Status/error classification tests. |
| UOW002-NFR-REL-003 | Reliability | Admin retry must be allowed only for eligible technical integration failures and must create a new `INTEGRATION_JOB` row linked to the original job. | Retry chain example tests and PBT invariants. |
| UOW002-NFR-REL-004 | Reliability | Retry must never bypass validation, review, approval, duplicate-risk review, or high-risk review gates. | Workflow stateful PBT. |
| UOW002-NFR-AUD-001 | Auditability | `ACTION_HISTORY` must preserve status changes and reviewer decisions with actor, status transition, reason, and timestamp. | Schema review and lifecycle tests. |
| UOW002-NFR-AUD-002 | Auditability | `AI_ASSESSMENT` must append regenerated AI assessments instead of overwriting prior responses. | Example tests and PBT invariant. |
| UOW002-NFR-AUD-003 | Auditability | `INTEGRATION_JOB` must preserve attempt history, retry lineage, OIC instance ID, payload reference, response reference, error data, retryable flag, attempt number, and timestamps. | Schema review and retry tests. |
| UOW002-NFR-AUD-004 | Auditability | Reviewer-applied Gemini business-justification risk adjustments must preserve points, actor, request version, AI assessment reference, reason, prior score, adjusted score, and timestamp. | Schema review, lifecycle tests, and PBT invariant. |
| UOW002-NFR-OBS-001 | Observability | Admin-facing ORDS APIs must expose support diagnostic data from `INTEGRATION_JOB` without leaking unrestricted sensitive values. | Admin endpoint tests. |
| UOW002-NFR-MAINT-001 | Maintainability | Business state changes must live in ATP package logic, with ORDS as a resource API boundary and Visual Builder as a presentation layer. | Code structure review. |
| UOW002-NFR-MAINT-002 | Maintainability | Generated artifacts must follow the approved workspace structure: `oracle/atp/schema/`, `oracle/atp/packages/`, `oracle/atp/seed/`, `oracle/ords/modules/`, `tests/example/`, and `tests/property/`. | File structure review during Code Generation. |
| UOW002-NFR-MAINT-003 | Maintainability | Risk weights, score bands, and risky countries must use structured configuration tables instead of relying on opaque JSON-only configuration values. | Schema review and configuration API tests. |
| UOW002-NFR-UX-001 | Usability | Requester, Reviewer, and Admin responses must include allowed actions so Visual Builder does not infer workflow permissions from raw tables. | API contract review and UI scenario tests. |
| UOW002-NFR-UX-002 | Usability | Requester correction rows must include correction reason and Edit action only when the requester owns an editable request. | Dashboard tests and PBT correction visibility invariant. |
| UOW002-NFR-TEST-001 | Testing | UOW-002 must include example-based tests for create, submit, validation failure, review accept/reject/correction, correction resubmit, Admin log view, and retry scenarios. | Code Generation test plan and generated tests. |
| UOW002-NFR-TEST-002 | Testing | UOW-002 must include property-based tests for identified workflow, permission, persistence, masking, retry, upsert, AI history, dashboard visibility, correction, risky-country configuration, and justification-risk adjustment properties. | PBT tests generated under `tests/property/`. |
| UOW002-NFR-TEST-003 | Testing | PBT runs must support shrinking and reproducibility through framework seed logging or deterministic seed configuration. | Build/Test instructions and CI/test command review. |

## Performance and Volume Targets

| Area | Phase-One Target |
|---|---|
| Supplier requests | 50 to 100 active/demo requests. |
| Supplier references | At least a few hundred seeded or mock/Fusion-synced references. |
| Request create/update/submit | About 2 seconds for expected prototype data under normal test conditions. |
| Dashboard queries | About 2 seconds for filtered role dashboards under expected prototype volumes. |
| Admin log queries | About 2 seconds for filtered integration log and retry history views under expected prototype volumes. |
| Growth posture | Avoid hardcoded dataset assumptions; use keys, indexes, filters, and pagination/limits where lists can grow. |

These targets are phase-one design targets, not production service-level agreements. Production SLAs require environment-specific benchmarking and operations design.

## Security and Privacy Requirements

- Backend role checks are required for all protected ORDS actions.
- Visual Builder role visibility is not the authorization boundary.
- Requesters can mutate only their own editable requests.
- Reviewers can accept, reject, or request correction only for reviewable requests.
- Admins can inspect integration logs and retry eligible technical failures, but cannot approve, reject, mark duplicate, or edit requester data.
- Normal responses must display only masked bank values and last-four values.
- Integration payload references and response summaries must not expose unrestricted full bank account values.
- Production identity integration is deferred and must remain visible as a phase-one limitation.

## Reliability Requirements

- ATP workflow package logic is the source of truth for status transitions.
- Workflow transitions and their related history records must be committed consistently.
- Blocking validation findings move requests to `VALIDATION_FAILED`.
- Passing foundational validation moves requests to `UNDER_REVIEW`.
- Fusion-created states require prior reviewer approval.
- Technical integration failures move approved Fusion submissions to `INTEGRATION_FAILED`.
- Admin retry creates a new retry attempt row and preserves the original failure row.
- Business validation failures are corrected/resubmitted by Requesters, not retried by Admins.

## Auditability and Observability Requirements

- `ACTION_HISTORY` is append-oriented for workflow and reviewer action evidence.
- `AI_ASSESSMENT` is append-oriented for Gemini response history.
- `INTEGRATION_JOB` is append-oriented for integration attempts and retries.
- `REQUEST_ASSESSMENT reviewer adjustment fields` is append-oriented for human-confirmed Gemini business-justification risk points.
- `CONFIGURATION` changes must not rewrite historical action, AI, or integration rows.
- Admin diagnostic views read from structured log fields instead of unstructured text only.
- Centralized production observability and alerting are deferred to Infrastructure Design, Build/Test, or future Operations planning.

## Maintainability Requirements

- ATP packages own workflow, validation, role checks, dashboard query composition, and retry eligibility.
- ORDS exposes resource-oriented routes and delegates business decisions to ATP packages.
- Visual Builder consumes stable ORDS response shapes and displays allowed actions.
- Generated code must preserve the approved folder layout from Units Generation.
- `RISK_RULE_CONFIG`, `RISK_SCORE_BAND_CONFIG`, and `HIGH_RISK_COUNTRY_CONFIG` own strict risk configuration that requires typed fields, totals, and active flags.
- `CONFIGURATION` remains available for mixed-shape settings such as generic phrase lists and business-unit/site mappings.
- Later units must be able to write duplicate, risk, AI, Fusion, and sync results through UOW-002 structures without changing core request ownership.

## Testing and PBT Requirements

Property-Based Testing is enabled in `aidlc-docs/aidlc-state.md`.

| PBT Rule | Status for This Stage | Requirement |
|---|---|---|
| PBT-09 | Compliant | Python `pytest` plus `hypothesis` is selected as the PBT framework for ATP/ORDS and later business logic/property checks. |
| PBT-01 | Already satisfied in Functional Design | Identified properties must be carried into Code Generation planning. |
| PBT-02 through PBT-08 | Deferred to Code Generation | Generated property tests must implement relevant round-trip, invariant, idempotence, generator quality, shrinking, and reproducibility rules. |
| PBT-10 | Deferred to Code Generation and Build/Test | Example-based tests must complement PBT for critical scenarios. |

Code Generation must create or update dependency declarations for the selected test harness, including `pytest`, `hypothesis`, `requests`, and `oracledb` where database-level tests are generated.

The PBT scope must include properties that Gemini justification metadata never mutates the numeric risk score until a Reviewer action is recorded, only `+3`, `+5`, and `+10` adjustments are accepted, final scores remain bounded from 0 through 100, active risky-country changes affect future deterministic scoring through configuration lookup, and risk-rule weights remain a 100-point allocation.

## Known NFR Limitations

- Security Baseline extension is disabled by prior answers; transcript-specific security requirements still apply.
- Resiliency Baseline extension is disabled by prior answers; transcript-specific reliability and retry requirements still apply.
- Production identity integration is out of scope for phase one.
- Formal DR, backups, monitoring, alerting, and operations runbooks are not owned by UOW-002 NFR Requirements.
- Real Fusion, Gemini, and OIC availability will be handled in later integration and infrastructure stages.

## Extension Compliance

| Extension Rule | Status | Rationale |
|---|---|---|
| PBT-09 | Compliant | The PBT framework is selected as Python `pytest` plus `hypothesis`, with dependency inclusion required during Code Generation. |
| PBT-01 | Previously compliant | Functional Design identified properties for UOW-002. |
| PBT-02 through PBT-08 | N/A for this stage | These govern generated tests during Code Generation. |
| PBT-10 | N/A for this stage | Complementary example/PBT implementation is handled in Code Generation and Build/Test. |
| Security Baseline | Disabled | Disabled in `aidlc-state.md`; transcript-specific bank masking and access constraints remain included. |
| Resiliency Baseline | Disabled | Disabled in `aidlc-state.md`; transcript-specific retry and error classification remain included. |

## Content Validation

- No Mermaid diagrams are used.
- No ASCII diagrams are used.
- Markdown tables and lists are simple and parser-compatible.
