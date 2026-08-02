# Logical Components: UOW-002 ATP/ORDS Supplier Request Foundation

## Purpose

This document defines the logical components needed to realize the UOW-002 NFR Design patterns. It describes how ATP schema objects, PL/SQL packages, ORDS resources, safe projections, and test harness components should be organized during Code Generation.

## Logical Component Catalog

| Component ID | Logical Component | Responsibility | Primary NFR Patterns |
|---|---|---|---|
| LC-UOW002-001 | Request Core Tables | Store flattened supplier request fields and document metadata. | Safe Data Projection, Filtered List Query. |
| LC-UOW002-002 | IAM Subject Authorization Context | Use Oracle IAM subject IDs and role context for local/prototype authorization checks. | Backend Authorization Guard. |
| LC-UOW002-003 | Workflow Package | Own state transitions, request mutation, validation routing, review decisions, correction, and integration status updates. | Transactional Workflow Package, Append-Oriented History. |
| LC-UOW002-004 | Authorization Package | Resolve `UserContext` and enforce role/action/resource permissions. | Backend Authorization Guard. |
| LC-UOW002-005 | Validation Package | Run foundational validation and write assessment findings, duplicate evidence, and deterministic risk results. | Transactional Workflow Package, Configuration Lookup. |
| LC-UOW002-006 | Dashboard Query Package | Produce role-filtered dashboard rows and allowed action summaries. | Filtered List Query, Stable Response Envelope, Safe Data Projection. |
| LC-UOW002-007 | Review Package | Persist Accept, Reject, duplicate outcome, Send Correction, and Gemini justification-risk adjustment decisions. | Transactional Workflow Package, Append-Oriented History. |
| LC-UOW002-008 | Integration Job Package | Create, update, query, and retry `INTEGRATION_JOB` rows. | Retry Lineage, Append-Oriented History. |
| LC-UOW002-009 | Configuration Package | Read active configuration for validation, routing, retry limits, lookup values, score bands, risk rules, and risky-country list. | Configuration Lookup. |
| LC-UOW002-010 | Safe Projection Views | Expose masked and role-appropriate data for ORDS reads. | Safe Data Projection, Stable Response Envelope. |
| LC-UOW002-011 | ORDS Resource Modules | Expose REST endpoints for request, submit, document, review, integration log/job, supplier-reference, risk-rule, high-risk-country, and retry flows. | Stable Response Envelope, Backend Authorization Guard. |
| LC-UOW002-012 | Test Harness Components | Provide example and property-based test utilities. | Test Boundary and Property Harness. |

## ATP Schema Components

### Core Tables

| Table Group | Tables |
|---|---|
| Request data | `SUPPLIER_REQUEST`, `REQUEST_DOCUMENT`. |
| Identity context | Oracle IAM subject IDs and role claims; no local role tables in the finalized schema. |
| Assessment results | `REQUEST_ASSESSMENT` for validation findings, duplicate evidence, deterministic risk, Reviewer adjustment points, and final risk display. |
| History and logs | `ACTION_HISTORY`, `AI_ASSESSMENT`, `INTEGRATION_JOB`. |
| Configuration | `CONFIGURATION`, `RISK_RULE_CONFIG`, `RISK_SCORE_BAND_CONFIG`, `HIGH_RISK_COUNTRY_CONFIG`, `TAX_REQUIREMENT_CONFIG`, `BUSINESS_UNIT_SITE_MAPPING`, `GENERIC_JUSTIFICATION_PHRASE`. |
| Supplier reference | `FUSION_SUPPLIER_REF`, `FUSION_SUPPLIER_TAX_REF`, `FUSION_SUPPLIER_SITE_REF`, `FUSION_SUPPLIER_BANK_REF`. |

### Constraints and Index Direction

Code Generation should include:

- Primary keys on all durable entities.
- Foreign keys from child records to `SUPPLIER_REQUEST` where appropriate.
- Foreign keys from retry rows to parent `INTEGRATION_JOB` where possible.
- Unique or conditional uniqueness for Fusion supplier reference source identifiers.
- Check constraints or lookup constraints for request status, integration type, active flags, component, risk level, duplicate level, adjustment points, and severity values where practical.
- Indexes for dashboard filters: requester, status, business unit, country, supplier type, risk level, updated timestamp.
- Indexes for Admin log filters: request ID, integration type, status, retryable flag, parent job ID, created timestamp.
- Indexes for Admin risky-country maintenance: country code, active flag, updated timestamp.
- Indexes for Reviewer justification-risk adjustments: request ID, request version, latest flag, actor, action timestamp.
- Indexes for Fusion supplier reference lookup: normalized supplier name, tax fingerprint, country, email domain, phone, and protected bank fingerprint where present.

## PL/SQL Package Components

| Package | Core Responsibilities |
|---|---|
| `supplier_request_pkg` | Create, update, retrieve, and submit supplier requests. |
| `supplier_auth_pkg` | Resolve user context and authorize role/action/resource combinations. |
| `supplier_workflow_pkg` | Validate and apply status transitions. |
| `supplier_validation_pkg` | Run foundational validation and store findings. |
| `supplier_review_pkg` | Accept, reject, duplicate outcome, correction actions, and Reviewer-applied justification-risk adjustment. |
| `supplier_dashboard_pkg` | Build requester, reviewer, and admin dashboard responses. |
| `supplier_integration_pkg` | Create integration job rows, update job status, and evaluate retry eligibility. |
| `supplier_config_pkg` | Read active configuration and lookup values. |
| `supplier_projection_pkg` | Build masked and stable response sections for ORDS. |

Package names can be adjusted during Code Generation to match local naming conventions, but responsibilities should remain separated.

## ORDS Resource Components

| Resource | Method | Backing Component | Notes |
|---|---|---|---|
| `/` | `GET` | ORDS module | Return service metadata. |
| `/health` | `GET` | ORDS module | Return health status. |
| `/requests` | `GET` | `supplier_projection_pkg` | Return role-aware request list with `limit` and `offset`. |
| `/requests` | `POST` | `supplier_request_pkg` | Create draft request. |
| `/requests/{id}` | `GET` | `supplier_projection_pkg` | Return stable, role-aware detail response. |
| `/requests/{id}` | `PUT` | `supplier_request_pkg` | Update draft, validation failed, or correction requested request. |
| `/requests/{id}/submit` | `POST` | `supplier_request_pkg`, `supplier_validation_pkg`, `supplier_workflow_pkg` | Submit and route to validation failed or under review. |
| `/requests/{id}/documents` | `POST` | `supplier_request_pkg` | Store request document metadata and optional content placeholder. |
| `/requests/{id}/documents/{document_id}` | `GET` | `REQUEST_DOCUMENT` | Return document metadata for a request document. |
| `/requests/{id}/review` | `POST` | `supplier_review_pkg` | Accept, reject, duplicate outcome, or send correction. |
| `/requests/{id}/justification-risk-adjustment` | `POST` | `supplier_review_pkg`, `supplier_projection_pkg` | Apply Reviewer-selected `+3`, `+5`, or `+10` justification-risk points when Gemini flags risky justification. |
| `/requests/{id}/ai-regeneration` | `POST` | `supplier_integration_pkg` | Queue a new AI explanation job. |
| `/requests/{id}/retry` | `POST` | `supplier_integration_pkg`, `supplier_workflow_pkg` | Retry the latest eligible technical failure for a request. |
| `/integration-logs` | `GET` | `supplier_integration_pkg` | Return filtered integration job and retry chain rows. |
| `/integration-jobs` | `GET` | `supplier_integration_pkg` | Return OIC-pollable jobs filtered by type and status. |
| `/integration-jobs/{job_id}/claim` | `POST` | `supplier_integration_pkg` | Claim a ready integration job. |
| `/integration-jobs/{job_id}/result` | `PUT` | `supplier_integration_pkg` | Record OIC/Fusion/Gemini success or failure. |
| `/supplier-reference/batch` | `POST` | `supplier_integration_pkg` and reference tables | Upsert Fusion supplier reference cache data. |
| `/risk-rules` | `GET` | `supplier_config_pkg` | Return Admin-readable risk rules and allocation evidence. |
| `/risk-rules/{rule_code}` | `PUT` | `supplier_config_pkg` | Update one rule and reject allocations that do not total exactly 100. |
| `/high-risk-countries` | `GET` | `supplier_config_pkg` | Return seeded and Admin-maintained risky-country list. |
| `/high-risk-countries/{country_code}` | `PUT` | `supplier_config_pkg` | Add, activate, deactivate, or update an existing risky-country entry. |

## Safe Response Components

### Request Detail Projection

The request detail projection should include:

- Request header.
- Supplier, address, contact, business, tax, bank, and intended-site fields from `SUPPLIER_REQUEST`.
- Document metadata.
- Validation summary.
- Duplicate evidence from `REQUEST_ASSESSMENT`.
- Risk results from `REQUEST_ASSESSMENT`.
- Latest AI assessment.
- Gemini business-justification risk metadata.
- Reviewer-applied justification-risk adjustment and final adjusted score.
- Action history summary.
- Integration summary.
- Allowed actions.

### Dashboard Projection

Dashboard rows should include:

- Request ID and request number.
- Supplier name.
- Status.
- Country.
- Business unit.
- Requester.
- Risk and duplicate placeholders.
- Integration status where relevant.
- Correction reason summary where relevant.
- Allowed actions.

### Admin Log Projection

Admin log rows should include:

- Job ID.
- Parent job ID.
- Request ID.
- Integration type.
- Status.
- Attempt number.
- OIC instance ID.
- Payload reference.
- Response reference.
- Error type.
- Error message.
- Retryable flag.
- Timestamps.

Admin projections must not expose unrestricted full bank values.

## Resilience Components

| Component | Resilience Responsibility |
|---|---|
| Workflow Package | Prevent invalid state transitions and keep state/history consistent. |
| Integration Job Package | Preserve failed attempts and retry lineage. |
| Configuration Package | Apply active retry limits and validation/routing rules. |
| Review Package | Ensure Gemini justification-risk advice changes score only through a Reviewer action with allowed point values. |
| ORDS Handlers | Return controlled errors for authorization, validation, conflict, and retry failures. |
| History Tables | Preserve recovery and diagnostic evidence after business or technical failures. |

## Scalability and Performance Components

| Component | Design Requirement |
|---|---|
| Dashboard Query Package | Use indexed predicates and bounded result sets. |
| Admin Log Query Package | Support filters by status, type, request, retryable flag, and timestamp. |
| Fusion Supplier Reference Tables | Support lookup indexes for duplicate detection. |
| Risky Country Configuration | Support quick active-country lookup during risk calculation and Admin list maintenance. |
| ORDS List Endpoints | Support limit and offset or equivalent bounded-list parameters. |
| Projection Views | Avoid returning raw full table data to Visual Builder. |

## Security and Privacy Components

| Component | Design Requirement |
|---|---|
| Authorization Package | Enforce actor, role, resource ownership, and allowed action checks. |
| Safe Projection Views | Suppress full bank values and internal database details. |
| ORDS Modules | Require actor subject/role context for local testing and call authorization before mutation. |
| Review Adjustment Projection | Distinguish deterministic risk, Gemini suggested risk, Reviewer-approved adjustment, and final score. |
| Integration Job Projection | Show references and diagnostics without unrestricted sensitive payload disclosure. |
| Audit Tables | Preserve actor, timestamp, and reason for protected changes. |

## Test Harness Components

Code Generation should create:

| Component | Purpose |
|---|---|
| `tests/example/` lifecycle tests | Pin expected behavior for create, submit, validation failed, under review, accept, reject, correction, Admin logs, and retry. |
| `tests/property/` domain generators | Generate request payloads, users, roles, actions, bank profiles, supplier references, integration jobs, and workflow command sequences. |
| `tests/property/` workflow properties | Verify valid state transitions and no Fusion-created state without approval. |
| `tests/property/` permission properties | Verify denied role/action combinations do not mutate protected state. |
| `tests/property/` masking properties | Verify normal API responses never reveal full bank values. |
| `tests/property/` retry properties | Verify retry chains and attempt numbers remain consistent. |
| `tests/property/` history properties | Verify AI assessment regeneration appends rows and does not overwrite history. |
| `tests/property/` justification-risk properties | Verify Gemini output alone does not mutate risk, Reviewer adjustments are limited to `3`, `5`, or `10`, and final score remains bounded. |
| `tests/property/` risky-country properties | Verify Admin country-list changes affect high-risk-country applicability without altering the 100-point rule-weight allocation. |
| dependency file | Include `pytest`, `hypothesis`, `requests`, and `oracledb` where direct database tests are used. |

## Deferred Logical Components

| Deferred Component | Reason |
|---|---|
| Production identity provider integration | Final design assumes Oracle IAM, but cloud identity wiring belongs to later deployment/hardening. |
| Centralized monitoring and alerting | Infrastructure Design or future Operations concern. |
| OCI Object Storage bucket and signed URL strategy | Infrastructure Design concern. |
| OIC/Fusion payload transformation components | Owned by UOW-004. |
| Gemini orchestration components | Owned by UOW-004. |
| Duplicate/risk algorithm packages | Owned by UOW-003. |

## Extension Compliance

| Extension Rule | Status | Rationale |
|---|---|---|
| Property-Based Testing | Compliant for this stage | Logical test harness components preserve PBT-01 properties and PBT-09 framework decisions for Code Generation. |
| Security Baseline | Disabled | Security Baseline is disabled, but backend role checks and bank masking remain in the design. |
| Resiliency Baseline | Disabled | Resiliency Baseline is disabled, but retry lineage, error classification, and transactional state patterns remain in the design. |

## Content Validation

- No Mermaid diagrams are used.
- No ASCII diagrams are used.
- Markdown tables and lists are simple and parser-compatible.
