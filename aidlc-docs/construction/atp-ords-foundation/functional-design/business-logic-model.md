# Business Logic Model: UOW-002 ATP/ORDS Supplier Request Foundation

## Purpose

This document defines the detailed business logic model for the ATP/ORDS supplier request foundation. It describes component behavior, request lifecycle flows, ORDS-facing operations, validation boundaries, error behavior, and property-based test requirements to carry forward.

## Unit Scope

UOW-002 provides:

- ATP persistence for supplier requests and related records using the finalized flattened phase-one schema.
- ATP workflow logic as the source of truth.
- ORDS APIs for Visual Builder.
- Requester, Reviewer, and Admin role enforcement based on Oracle IAM subject/role context. Local ORDS tests pass this context through request parameters.
- Foundational validation.
- Structured storage for validation results, duplicate evidence, deterministic risk results, Reviewer adjustment points, AI assessment history, action history, Fusion supplier reference records, integration jobs, and configuration.
- Structured storage for Admin-managed risky-country configuration and Reviewer-applied Gemini justification-risk adjustments.
- Role-filtered dashboards and stable API response shapes.

UOW-002 does not implement deep duplicate matching, risk scoring, Gemini prompt logic, OIC payload transformation, or final Fusion supplier master logic. It provides the structures and contracts those later units use.

## Component Logic

| Component | Functional Behavior in UOW-002 |
|---|---|
| Authorization Component | Resolves actor subject ID and role context. Blocks unauthorized ORDS actions before protected state changes. |
| ORDS API Layer | Exposes request, document metadata, review, integration log/job, supplier-reference, risk-rule, high-risk-country, and retry endpoints. Delegates business decisions to ATP package logic. |
| Supplier Request Repository | Persists the flattened supplier request, document metadata, and read models. Provides stable retrieval for dashboards and request detail views. |
| Request Workflow Component | Owns allowed status transitions and writes `ACTION_HISTORY` records. |
| Validation Component | Runs foundational validation for mandatory fields, contact email, tax applicability, site/business-unit capture, provided bank metadata, duplicate evidence, deterministic risk scoring, and configured score bands. |
| Document Component | Stores document metadata, request version, latest flag, uploader, and optional BLOB content in `REQUEST_DOCUMENT`. |
| Supplier Master Reference Component | Stores seeded/mock and future Fusion-synced supplier references in `FUSION_SUPPLIER_REF`, `FUSION_SUPPLIER_TAX_REF`, `FUSION_SUPPLIER_SITE_REF`, and `FUSION_SUPPLIER_BANK_REF`. |
| Review Decision Component | Persists reviewer Accept, Reject, Send Correction, and Gemini justification-risk adjustment decisions in `ACTION_HISTORY` and invokes workflow transitions where applicable. |
| Dashboard Query Component | Produces role-aware dashboard rows and request detail projections for Visual Builder. |
| Integration Log and Retry Component | Stores each AI, Fusion, or sync attempt as an `INTEGRATION_JOB` row, exposes Admin diagnostic views, and creates retry rows linked by `parent_job_id`. |
| Audit Component | Uses `ACTION_HISTORY`, `AI_ASSESSMENT`, and `INTEGRATION_JOB` as append-oriented history sources for workflow, review, integration, retry, and AI activity. |
| Configuration Component | Reads active scalar `CONFIGURATION` rows plus structured `RISK_RULE_CONFIG`, `RISK_SCORE_BAND_CONFIG`, `HIGH_RISK_COUNTRY_CONFIG`, `TAX_REQUIREMENT_CONFIG`, `BUSINESS_UNIT_SITE_MAPPING`, and `GENERIC_JUSTIFICATION_PHRASE` rows. |

## ORDS Operation Model

| Operation | Actor | Behavior |
|---|---|---|
| `GET /` | Any caller | Return service metadata and available resource summary. |
| `GET /health` | Any caller | Return ORDS health status. |
| `GET /requests` | Requester, Reviewer, Admin | Return role-aware request rows. Requesters see owned requests; Reviewers and Admins can see broader queue/log-support rows according to backend rules. |
| `POST /requests` | Requester | Resolve role, validate create permission, create `DRAFT`, return request ID. |
| `PUT /requests/{id}` | Requester owner | Resolve role, verify editable state, update draft/correction fields, return update status. Editable states include `DRAFT`, `VALIDATION_FAILED`, and `CORRECTION_REQUIRED`. |
| `GET /requests/{id}` | Requester owner, Reviewer, Admin where relevant | Return request detail with role-appropriate fields and allowed actions. |
| `POST /requests/{id}/submit` | Requester owner | Move to `SUBMITTED`, run foundational validation, then route to `VALIDATION_FAILED` or `UNDER_REVIEW`. |
| `POST /requests/{id}/documents` | Requester owner | Store document metadata and optional document content placeholder. |
| `GET /requests/{id}/documents/{document_id}` | Requester owner, Reviewer, Admin where relevant | Return document metadata for a specific request document. |
| `POST /requests/{id}/review` | Reviewer | Record Accept, Reject, or Send Correction decision and invoke workflow transition. |
| `POST /requests/{id}/justification-risk-adjustment` | Reviewer | Apply `+3`, `+5`, or `+10` points after reviewing Gemini's business-justification risk advice; record the adjustment in audit and recompute final risk display. |
| `POST /requests/{id}/ai-regeneration` | Reviewer | Queue a new `AI_EXPLANATION` job without overwriting older `AI_ASSESSMENT` rows. |
| `POST /requests/{id}/retry` | Admin | Retry the latest eligible technical failure for the request by creating a new `INTEGRATION_JOB` row. |
| `GET /integration-logs` | Admin | Return `INTEGRATION_JOB` rows with parent/child retry chains, payload references, response references, errors, timestamps, retry counts, and retry eligibility. |
| `GET /integration-jobs` | OIC | Return ready or filtered `INTEGRATION_JOB` rows for `AI_EXPLANATION`, `FUSION_CREATE`, or `SUPPLIER_SYNC`. |
| `POST /integration-jobs/{job_id}/claim` | OIC | Mark a ready integration job as claimed. |
| `PUT /integration-jobs/{job_id}/result` | OIC | Record success/failure results, Fusion supplier identifiers, or AI assessment output. |
| `POST /supplier-reference/batch` | OIC/Admin seed path | Upsert Fusion supplier reference cache data. |
| `GET /risk-rules` | Admin | Return active deterministic risk-rule weights and allocation data. |
| `PUT /risk-rules/{rule_code}` | Admin | Update one risk rule and reject the change unless all active risk-rule weights total exactly 100. |
| `GET /high-risk-countries` | Admin or system process | Return the seeded and Admin-maintained risky-country list used by the `HIGH_RISK_COUNTRY` rule. |
| `PUT /high-risk-countries/{country_code}` | Admin | Add, activate, deactivate, or update a risky-country entry for future assessments. |

## Lifecycle Flow

### Create Draft

1. Visual Builder sends supplier request input to ORDS.
2. ORDS resolves `UserContext`.
3. Authorization Component confirms Requester create permission.
4. Supplier Request Repository creates one `SUPPLIER_REQUEST` row containing phase-one supplier, contact, address, site, tax, bank, and business fields.
5. Workflow Component sets status to `DRAFT`.
6. Audit Component records request creation.
7. ORDS returns request ID, request number, status, and editable fields.

### Update Draft or Correction

1. Requester submits edited data.
2. ORDS confirms the requester owns the request.
3. Workflow Component confirms the request is editable. Editable statuses are `DRAFT`, `VALIDATION_FAILED`, and `CORRECTION_REQUIRED`.
4. Repository updates allowed fields.
5. If bank data is provided, the stored representation uses encrypted/protected data, fingerprint, last four, bank country, and bank currency.
6. `ACTION_HISTORY` records the update summary.

### Submit Request

1. Requester submits a `DRAFT` or `VALIDATION_FAILED` request.
2. Workflow Component transitions to `SUBMITTED`.
3. Validation Component runs foundational validation.
4. Validation findings are stored in `REQUEST_ASSESSMENT.validation_results_json`.
5. If blocking findings exist, Workflow Component transitions to `VALIDATION_FAILED`.
6. If no blocking findings exist, duplicate evidence and deterministic risk are calculated using active risk weights, the Admin-managed risky-country list, and configured score bands.
7. Assessment results are stored in the latest `REQUEST_ASSESSMENT` row.
8. An `AI_EXPLANATION` job is queued so Gemini can review risk explanations and the business justification.
9. Workflow Component transitions to `UNDER_REVIEW`.
10. ORDS returns the new status, validation summary, deterministic risk summary, and next allowed actions.

### Review Decision

1. Reviewer opens a role-filtered request detail view.
2. If Gemini flagged the business justification as risky, Visual Builder shows the original justification, Gemini rationale, deterministic risk score, and three adjustment buttons: `+3`, `+5`, and `+10`.
3. Reviewer may apply one justification-risk adjustment for the request version, or leave the AI finding unapplied.
4. Review Decision Component stores the adjustment fields on the latest `REQUEST_ASSESSMENT` row and records the action in `ACTION_HISTORY`, then recalculates the final score as deterministic score plus approved adjustment, capped at 100.
5. If the request is `UNDER_REVIEW`, Visual Builder shows three primary business decision buttons: Accept, Reject, and Send Correction. Duplicate closure remains supported as a reject/duplicate outcome.
6. Reviewer submits one business decision.
7. Send Correction requires a correction reason.
8. Review Decision Component records the decision in `ACTION_HISTORY`.
9. Workflow Component validates the current state and applies the transition.
10. If Accepted, the request becomes `APPROVED` and eligible for later OIC/Fusion submission.
11. If Rejected, the request becomes `REJECTED`.
12. If Send Correction is selected, the request becomes `CORRECTION_REQUIRED` and the correction reason is visible to the requester.

### Requester Correction

1. Requester opens the requester dashboard or request detail page.
2. Dashboard Query Component returns owned requests with status `CORRECTION_REQUIRED`.
3. The response includes the latest correction reason from `ACTION_HISTORY`.
4. Visual Builder shows an Edit button for that requester-owned request.
5. Requester edits the request through `PUT /requests/{id}`.
6. Requester resubmits through `POST /requests/{id}/submit`.
7. Workflow Component records the correction update and resubmission in `ACTION_HISTORY`.

### Integration Result Capture

1. OIC or package logic creates an `INTEGRATION_JOB` row.
2. `integration_type` is `AI_EXPLANATION`, `FUSION_CREATE`, or `SUPPLIER_SYNC`.
3. When Fusion/OIC succeeds, the job stores response reference/details and supplier number where applicable.
4. Workflow Component transitions the request to `CREATED_IN_FUSION` for successful Fusion creation.
5. When Fusion/OIC fails technically, the job stores error type, error message, and retryable flag.
6. Workflow Component transitions the request to `INTEGRATION_FAILED` for failed Fusion creation.
7. Admin dashboard surfaces the structured diagnostic row.

### Admin Retry

1. Admin selects retry from an integration log row.
2. ORDS verifies Admin retry permission.
3. Integration Log and Retry Component confirms the failure is technical, the request was approved, and retry limit rules allow retry.
4. A new `INTEGRATION_JOB` row is created with `parent_job_id` referencing the original job.
5. `attempt_number` is incremented from the retry chain.
6. The retry handoff updates the new job status according to the result.
7. Retry never changes review outcome and never bypasses validation or approval.

### Dashboard Query

1. Visual Builder calls `GET /requests` with the current actor context.
2. ORDS resolves role and filters data in the backend.
3. Dashboard Query Component returns stable rows with request summary, status, risk/duplicate placeholders where absent, and allowed actions.
4. Requester rows in `CORRECTION_REQUIRED` status include correction reason and allowed action `EDIT`.
5. Reviewer request-detail rows in `UNDER_REVIEW` include allowed actions `ACCEPT`, `REJECT`, and `SEND_CORRECTION`.
6. Visual Builder renders the returned shape without owning workflow decisions.

## State Transition Model

| State | Editable By Requester | Reviewable By Reviewer | Retryable By Admin | Notes |
|---|---|---|---|---|
| `DRAFT` | Yes | No | No | Initial or correction-edit state. |
| `SUBMITTED` | No | No | No | Transient validation state. |
| `VALIDATION_FAILED` | Yes | No | No | Requester corrects and resubmits. |
| `UNDER_REVIEW` | No | Yes | No | Reviewer evaluates evidence and chooses action. |
| `CORRECTION_REQUIRED` | Yes | No | No | Requester sees correction reason and an Edit button. |
| `APPROVED` | No | Limited read | No | Eligible for Fusion submission path. |
| `REJECTED` | No | Limited read | No | Terminal business decision unless reopened by future scope. |
| `DUPLICATE` | No | Limited read | No | Terminal duplicate closure unless reopened by future scope. |
| `SUBMITTED_TO_FUSION` | No | Read | No | Integration in progress. |
| `CREATED_IN_FUSION` | No | Read | No | Terminal success for phase one. |
| `INTEGRATION_FAILED` | No | Read | Yes, if eligible | Technical failure handled by Admin retry. |

## Validation Logic Model

Foundational validation produces structured findings and determines whether submission can proceed to review.

| Validation Area | Blocking Behavior |
|---|---|
| Supplier name | Missing value blocks submission. |
| Country | Missing value blocks submission. |
| Supplier type | Missing value blocks submission. |
| Business unit | Missing value blocks submission. |
| Contact email | Missing or invalid email-like value blocks submission. |
| Address or site | Missing address/site information blocks submission. |
| Tax registration | Missing value blocks submission only where applicable by country/type rule. |
| Expected annual spend | Negative value blocks submission. |
| Bank information | Missing value does not block initial submission; provided bank data must be represented safely and bank country mismatch is stored as a finding/input. |

Validation reads active `TAX_REQUIREMENT_CONFIG`, `BUSINESS_UNIT_SITE_MAPPING`, and `GENERIC_JUSTIFICATION_PHRASE` rows where applicable. Risk calculation reads `RISK_RULE_CONFIG`, `RISK_SCORE_BAND_CONFIG`, and `HIGH_RISK_COUNTRY_CONFIG`.

## Error Handling Model

| Error Type | Example | System Behavior |
|---|---|---|
| Authorization error | Requester tries to approve | Reject action, no business state mutation, audit unauthorized attempt where appropriate. |
| Validation error | Missing supplier name | Store validation finding, move to `VALIDATION_FAILED`, return actionable messages. |
| Conflict error | Reviewer acts on non-reviewable request | Reject action and keep current state unchanged. |
| Integration technical error | OIC timeout or Fusion service error | Store integration attempt details, move to `INTEGRATION_FAILED`, expose Admin retry when eligible. |
| Business integration error | Fusion rejects invalid business data | Store response and error; retry only if correction/review path resolves the business issue. |

## Stable Response Shape Rules

- Request detail responses include sections for request data, validation, duplicate, risk, latest AI assessment, review/action history, document metadata, integration summary, and allowed actions.
- Missing duplicate, risk, or AI data is returned as empty or pending sections rather than omitted structural fields.
- Dashboard rows use stable field names for status, requester, supplier, country, business unit, risk level, duplicate risk, integration status, and allowed actions.
- Sensitive values are represented only in masked/protected form.
- Reviewer detail responses for `UNDER_REVIEW` include `ACCEPT`, `REJECT`, and `SEND_CORRECTION` allowed actions, plus justification-risk adjustment metadata and allowed adjustment values when Gemini flags justification risk.
- Requester dashboard/detail responses for `CORRECTION_REQUIRED` include the correction reason and `EDIT` allowed action.

## Testable Properties

PBT-01 is satisfied by identifying the properties below. These properties must be carried into Code Generation planning.

| Property ID | Component | Category | Property |
|---|---|---|---|
| P-UOW002-001 | Request Workflow Component | Stateful/invariant | For generated valid action sequences, each resulting status transition is in the allowed transition table. |
| P-UOW002-002 | Request Workflow Component | Invariant | No generated sequence can reach `SUBMITTED_TO_FUSION` or `CREATED_IN_FUSION` unless the sequence includes an accepted Reviewer approval. |
| P-UOW002-003 | Authorization Component | Invariant | For every generated user role and action, denied actions leave protected request, review, retry, and log state unchanged. |
| P-UOW002-004 | Supplier Request Repository | Round-trip | Generated valid supplier request inputs written and read back preserve supplier, contact, site, justification, category, spend, and applicable tax data, except documented normalization and derived fields. |
| P-UOW002-005 | Bank Representation | Invariant | Generated bank inputs never produce normal API responses containing an unmasked full account value. |
| P-UOW002-006 | Supplier Master Reference Component | Idempotence | Reapplying the same supplier reference source record produces the same active reference set as applying it once. |
| P-UOW002-007 | Integration Log and Retry Component | Invariant | `INTEGRATION_JOB` retry chains remain consistent with accepted retry attempts and rejected retry attempts do not create successful retry rows. |
| P-UOW002-008 | Dashboard Query Component | Invariant | Role-filtered dashboards do not return rows outside the role's visibility rules. |
| P-UOW002-009 | AI Assessment History | Invariant | Regenerating an AI assessment appends a new row and never overwrites prior assessment rows. |
| P-UOW002-010 | Correction Flow | Stateful/invariant | A requester sees an Edit action only for owned requests in editable states, including `CORRECTION_REQUIRED`. |
| P-UOW002-011 | Justification Risk Adjustment | Invariant | Gemini justification-risk metadata alone never changes numeric score; generated Reviewer adjustments are limited to `3`, `5`, or `10`, and final risk score remains bounded. |
| P-UOW002-012 | Risky Country Configuration | Invariant | Generated Admin risky-country changes affect `HIGH_RISK_COUNTRY` applicability for future assessments without changing the active 100-point rule-weight allocation. |

Components without current PBT properties:

| Component | Rationale |
|---|---|
| Document metadata storage | Only metadata persistence is defined in this unit; round-trip behavior is covered by repository/API persistence tests. |
| AI assessment generation | UOW-002 stores generated AI assessments and justification-risk metadata, but Gemini prompt generation properties belong to UOW-004. |
| Duplicate/risk scoring storage | UOW-002 stores result structures and Reviewer adjustments, but deeper matching/scoring algorithms belong to UOW-003. |

## Functional Completeness Against UOW-002 Stories

| Story | Coverage in This Design |
|---|---|
| US-001 | Request create/update API and `DRAFT` state. |
| US-002 | Document metadata and object-reference model. |
| US-003 | Submit workflow and foundational validation. |
| US-004 | Status history and requester dashboard model. |
| US-005 | Correction/resubmit behavior through `CORRECTION_REQUIRED`, correction reason display, requester Edit action, and resubmission. |
| US-006 | Validation storage and foundational validation execution surface. |
| US-007 | Supplier reference storage for sync output. |
| US-008 | Duplicate result storage and supplier reference access. |
| US-009 | Risk result storage, Admin risky-country access, and Reviewer-adjusted final risk support. |
| US-010 | AI assessment storage with business-justification risk metadata. |
| US-010A | Reviewer justification-risk adjustment storage and audit behavior. |
| US-011 | Regenerated AI assessment storage and timestamp support without overwriting history. |
| US-012 | Reviewer dashboard/query model. |
| US-013 | Request detail aggregation contract. |
| US-014 | Approval workflow state. |
| US-015 | Accept, reject, and correction decision persistence through `ACTION_HISTORY`. |
| US-016 | Correction workflow state with requester-visible Edit action. |
| US-019 | Masked bank storage/display contract. |
| US-020 | Approved request source data for integration. |
| US-021 | Fusion response and supplier number storage. |
| US-022 | Integration failure status and log storage. |
| US-023 | Retry job chain persistence through `INTEGRATION_JOB.parent_job_id` and attempt numbers. |
| US-024 | Seeded demo data support. |
| US-026 | Audit tables and write surfaces. |

## Extension Compliance

| Extension Rule | Status | Rationale |
|---|---|---|
| PBT-01 | Compliant | Testable properties are identified per applicable component. |
| PBT-02 through PBT-08 | N/A for this stage | These rules govern generated tests during Code Generation. |
| PBT-09 | N/A for this stage | Framework selection is part of NFR Requirements. |
| PBT-10 | N/A for this stage | Complementary example/PBT implementation is handled in Code Generation and Build/Test. |

## Content Validation

- No Mermaid diagrams are used.
- No ASCII diagrams are used.
- Text flow descriptions and Markdown tables provide parser-compatible alternatives to diagrams.
