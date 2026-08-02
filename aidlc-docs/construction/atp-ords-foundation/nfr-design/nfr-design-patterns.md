# NFR Design Patterns: UOW-002 ATP/ORDS Supplier Request Foundation

## Purpose

This document defines the design patterns that incorporate the approved NFR Requirements into UOW-002. It focuses on resilience, scalability, performance, security, privacy, auditability, maintainability, and testability patterns.

## Scope Boundary

UOW-002 designs patterns for ATP persistence, PL/SQL package behavior, ORDS API contracts, role enforcement, foundational validation, dashboard query models, document metadata, action history, AI assessment history, integration job logs, configuration, and retry metadata.

Full production identity, centralized monitoring, disaster recovery, Fusion payload transformation, Gemini orchestration, and deep duplicate/risk algorithms are deferred to later stages or units.

## Pattern Summary

| Pattern ID | Pattern | NFR Drivers | Applied To |
|---|---|---|---|
| NFRP-001 | Transactional Workflow Package | Reliability, auditability | Request create, submit, validation result routing, review decision, correction, integration status changes. |
| NFRP-002 | Backend Authorization Guard | Security, maintainability | Protected ORDS actions for Requester, Reviewer, and Admin. |
| NFRP-003 | Safe Data Projection | Security, privacy, usability | Request detail, dashboards, Admin logs, bank fields, integration summaries. |
| NFRP-004 | Append-Oriented History | Auditability, reliability | `ACTION_HISTORY`, `AI_ASSESSMENT`, `INTEGRATION_JOB`. |
| NFRP-005 | Retry Lineage | Reliability, auditability | Admin retry of eligible technical integration failures. |
| NFRP-006 | Filtered List Query | Performance, scalability | Requester dashboard, Reviewer queue, Admin logs, integration job history. |
| NFRP-007 | Stable Response Envelope | Maintainability, usability | ORDS detail, dashboard, validation, review, log, and configuration responses. |
| NFRP-008 | Configuration Lookup | Maintainability, reliability | Tax applicability, business-unit/site mapping, retry limits, generic phrases, score bands, risk weights, and Admin-managed risky countries. |
| NFRP-010 | Human-Confirmed AI Risk Adjustment | Auditability, explainability | Gemini business-justification risk advice, Reviewer `+3`/`+5`/`+10` adjustment, final risk projection. |
| NFRP-009 | Test Boundary and Property Harness | Testability, reliability | PL/SQL package contracts, ORDS endpoints, Python example tests, Python PBT tests. |

## NFRP-001: Transactional Workflow Package

### Design

ATP package procedures own business state transitions. A state-changing operation must:

1. Resolve and validate the actor.
2. Lock or re-read the current request state consistently.
3. Validate the requested transition against the allowed transition table.
4. Apply the state change.
5. Insert the required `ACTION_HISTORY`, validation, or integration log row.
6. Return the new status and allowed actions.

### Applies To

- `create_request`
- `update_request`
- `submit_request`
- `record_validation_result`
- `record_review_decision`
- `apply_justification_risk_adjustment`
- `request_correction`
- `record_integration_status`
- `retry_integration_job`

### Design Constraints

- No request can reach `SUBMITTED_TO_FUSION` or `CREATED_IN_FUSION` without prior `APPROVED`.
- A failed state transition leaves protected state unchanged.
- Transaction boundaries must keep state and history consistent.

## NFRP-002: Backend Authorization Guard

### Design

Every protected ORDS handler calls an ATP authorization guard before invoking package logic.

| Actor | Guarded Actions |
|---|---|
| Requester | Create draft, update own editable request, submit own editable request, view own request. |
| Reviewer | View review queue and details, accept, reject, request correction, mark duplicate outcome, apply Gemini justification-risk adjustment. |
| Admin | View integration diagnostics, view retry history, retry eligible technical failures, maintain risky-country list. |

### Design Constraints

- Visual Builder role selection is a display and demo convenience, not the final authorization boundary.
- Denied actions must not mutate request, review, retry, or log state.
- Invalid or expired role assignments return a controlled authorization error.

## NFRP-003: Safe Data Projection

### Design

ORDS reads should use safe views or package-built response projections. These projections expose only fields allowed for the actor and screen.

Bank-related values in normal responses are limited to:

- `masked_account_display`
- `account_last4`
- `bank_country_code`
- protected fingerprint presence indicators where useful

### Applies To

- Request detail response.
- Requester dashboard.
- Reviewer dashboard and detail evidence.
- Admin integration log views.
- Integration job response summaries.

### Design Constraints

- Full bank account values must not appear in normal UI responses.
- Admin logs may show payload and response references, not unrestricted sensitive payload content.
- PBT bank masking properties must be carried into Code Generation.

## NFRP-004: Append-Oriented History

### Design

History-like records are append-oriented and not edited as normal business data.

| Table | Append Purpose |
|---|---|
| `ACTION_HISTORY` | Status transitions, reviewer actions, correction requests, duplicate outcomes, invalid operational actions where appropriate. |
| `AI_ASSESSMENT` | Each Gemini response or regenerated summary. |
| `INTEGRATION_JOB` | Each integration attempt and retry attempt. |

### Design Constraints

- Regenerating an AI assessment appends a new row.
- Retrying an integration job appends a new row.
- Configuration changes do not rewrite historical rows.
- Reviewer-applied Gemini justification-risk adjustments append audit/history and do not rewrite the Gemini assessment that suggested them.
- The latest displayable row is selected through status, timestamp, attempt number, or active/success criteria.

## NFRP-005: Retry Lineage

### Design

`INTEGRATION_JOB` acts as both a small work queue and attempt history.

Retry uses:

- `parent_job_id` for original-attempt linkage.
- `attempt_number` for retry ordering.
- `retryable` for eligibility.
- `error_type` for business-vs-technical failure handling.
- status values such as `FAILED`, `RETRY_QUEUED`, `IN_PROGRESS`, and `SUCCEEDED`.

### Retry Eligibility Checks

An Admin retry is accepted only when:

- The actor has Admin retry permission.
- The failure is technical, not business validation.
- The linked request was previously approved.
- Current request state allows technical retry.
- The configured retry limit has not been exceeded.

### Design Constraints

- Retry cannot bypass validation, duplicate/risk review, or approval.
- Rejected retry attempts do not create successful retry rows.
- Invalid retry attempts should be auditable in `ACTION_HISTORY` where appropriate.

## NFRP-006: Filtered List Query

### Design

Dashboard and log endpoints must be backed by indexed/filterable queries.

Recommended filters:

- Request status.
- Requester.
- Business unit.
- Country.
- Supplier type.
- Risk level where available.
- Duplicate risk where available.
- Integration type.
- Integration status.
- Retryable flag.
- Created or updated timestamp range.

### Design Constraints

- List endpoints must support limit and offset or equivalent bounded result parameters.
- ORDS must not return all raw rows for client-side filtering.
- Query logic must tolerate absent duplicate, risk, or AI outputs by returning empty or pending sections.

## NFRP-007: Stable Response Envelope

### Design

ORDS responses should expose predictable sections even when later-unit data is not yet populated.

Recommended detail sections:

- `request`
- `site`
- `contact`
- `bank`
- `documents`
- `validation`
- `duplicate`
- `risk`
- `ai_assessment`
- `action_history`
- `integration_summary`
- `allowed_actions`

### Design Constraints

- Missing duplicate, risk, or AI data is represented as empty or pending, not omitted unpredictably.
- Allowed actions are computed by backend logic.
- Visual Builder should not infer workflow permissions from raw status alone.

## NFRP-008: Configuration Lookup

### Design

The `CONFIGURATION` table provides active configuration values to package logic.

Configuration types include:

- `TAX_REQUIREMENT`
- `BUSINESS_UNIT_SITE_MAPPING`
- `GENERIC_JUSTIFICATION_PHRASE`
- `HIGH_RISK_COUNTRY_CONFIG`
- `SCORE_THRESHOLD`
- `LOOKUP`
- `RETRY_LIMIT`

### Design Constraints

- Only active configuration rows are used.
- Missing required configuration should produce a controlled validation or configuration error.
- Admin risky-country changes affect only future risk assessments and do not change the active 100-point risk-weight allocation.
- Historical action, AI, or integration records are not rewritten when configuration changes.

## NFRP-010: Human-Confirmed AI Risk Adjustment

### Design

Gemini can flag business-justification risk, but risk-score mutation requires an explicit Reviewer action.

The request detail projection should expose:

- Deterministic risk score.
- Gemini justification-risk flag and rationale.
- Gemini suggested severity or suggested points.
- Allowed Reviewer adjustment values: `3`, `5`, and `10`.
- Current Reviewer-applied adjustment for the request version, if any.
- Final score and final risk level.

### Design Constraints

- Gemini output alone never changes request status or numeric risk score.
- Only `+3`, `+5`, and `+10` are valid Reviewer justification-risk additions.
- Final score is capped at the configured maximum score.
- Adjustments are auditable and linked to the request version and AI assessment reviewed.
- Regenerating AI appends a new assessment and does not erase prior Reviewer adjustments.

## NFRP-009: Test Boundary and Property Harness

### Design

The ATP package layer and ORDS API layer must be designed so tests can exercise logic without relying only on Visual Builder.

Code Generation must create:

- Example tests for known lifecycle scenarios.
- Property tests using `pytest` and `hypothesis`.
- Domain generators for request payloads, role/action pairs, workflow command sequences, bank inputs, supplier references, retry chains, and AI assessment events.
- Test helpers for resetting or seeding controlled state.

### Required Properties to Preserve

- Valid workflow command sequences never produce invalid status transitions.
- Requests cannot reach Fusion-created states without prior approval.
- Disallowed role/action combinations do not mutate protected state.
- Valid request write/read behavior preserves supported values except documented normalization/masking.
- Normal responses never reveal full bank account values.
- Supplier reference upsert is idempotent for the same source identifier.
- Retry chains remain consistent with accepted retry actions.
- AI assessment regeneration appends history.
- Gemini justification-risk advice does not mutate score without a Reviewer action.
- Reviewer justification-risk adjustments are limited to allowed values and keep final score within bounds.
- Admin risky-country changes affect future country-rule applicability without changing total risk-weight allocation.
- Correction Edit action appears only for owned editable requests.

## Extension Compliance

| Extension Rule | Status | Rationale |
|---|---|---|
| Property-Based Testing | Compliant for this stage | NFR Design preserves PBT-01 properties and the PBT-09 framework selection, with implementation deferred to Code Generation. |
| Security Baseline | Disabled | Security Baseline is disabled in `aidlc-state.md`; transcript-specific backend role checks and bank masking are still designed. |
| Resiliency Baseline | Disabled | Resiliency Baseline is disabled in `aidlc-state.md`; transcript-specific retry, error classification, and append-only logging are still designed. |

## Content Validation

- No Mermaid diagrams are used.
- No ASCII diagrams are used.
- Markdown tables and lists are simple and parser-compatible.
