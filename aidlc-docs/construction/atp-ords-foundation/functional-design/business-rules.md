# Business Rules: UOW-002 ATP/ORDS Supplier Request Foundation

## Purpose

This document defines the detailed business rules for the ATP/ORDS foundation. The rules describe validation, workflow, permissions, retry behavior, masking, dashboard filtering, and audit expectations.

## Final Functional Decisions

| Question Area | Decision |
|---|---|
| Domain model | Finalized flattened phase-one `SUPPLIER_REQUEST` model plus document, assessment, Fusion reference, history, integration, and structured configuration tables. |
| Workflow owner | ATP package/state-machine logic is the source of truth. |
| Authorization | Oracle IAM owns real users and roles. Local/prototype calls pass actor subject and role context to ORDS, and ATP packages enforce protected actions. |
| Validation split | UOW-002 owns foundational validation, duplicate evidence, deterministic risk calculation, and assessment storage for the current scope; later units can extend deeper algorithms. |
| Bank information | Store encrypted/protected value where needed, last-four, bank country/currency, and protected comparison fingerprint. |
| Supplier references | Use Fusion reference tables for seeded, mock Fusion, and future OIC-synced Fusion records. |
| Documents | Store document metadata, request version, latest flag, uploader, and optional content placeholder in ATP; production file content belongs in object storage. |
| Admin logs | Store each integration attempt and retry as `INTEGRATION_JOB` rows. |
| AI history | Store every Gemini response in `AI_ASSESSMENT`; regenerated summaries do not overwrite history. |
| Action history | Store status changes and reviewer decisions in `ACTION_HISTORY`. |
| Configuration | Store scalar settings in `CONFIGURATION` and human-maintained business controls in structured configuration tables. |
| Risky country maintenance | Admin manages a seeded risky-country list separately from generic `CONFIGURATION`. |
| Justification risk adjustment | Gemini can flag business-justification risk, but only Reviewer-selected `+3`, `+5`, or `+10` points can alter the final score. |
| Dashboards | UOW-002 owns role-filtered dashboard query models and stable ORDS response shapes. |
| PBT | Identify PBT-01 properties for workflow, permissions, masking, retry/log state, and persistence. |

## Role and Permission Rules

| Rule ID | Rule |
|---|---|
| RBAC-001 | Every protected ORDS action must resolve actor subject ID and app-role context before executing business logic. |
| RBAC-002 | Requesters may create draft requests. |
| RBAC-003 | Requesters may edit their own requests only while the request is editable: `DRAFT`, `VALIDATION_FAILED`, or `CORRECTION_REQUIRED`. |
| RBAC-004 | Requesters may submit or resubmit their own editable requests. |
| RBAC-005 | Requesters may view their own request statuses and final supplier number when available. |
| RBAC-006 | Reviewers may view submitted, under-review, approved, rejected, duplicate, and correction-related request details needed for review. |
| RBAC-007 | Reviewers may accept, reject, or request correction only when the request is in a reviewable state. The backend action for Accept is stored as approval. |
| RBAC-008 | Admins may view integration logs, OIC instance IDs, payload references, response details, error messages, timestamps, retry counts, and retry eligibility. |
| RBAC-009 | Admins may retry only eligible technical integration failures. |
| RBAC-010 | Admin retry permissions do not allow approval, rejection, duplicate marking, or requester data editing. |
| RBAC-011 | Visual Builder visibility rules are helpful for user experience but are not trusted as the final authorization boundary. |
| RBAC-012 | Admins may add, deactivate, or update risky-country rows, but cannot make Reviewer decisions through the risky-country configuration screen. |
| RBAC-013 | Reviewers may apply a Gemini justification-risk adjustment of `+3`, `+5`, or `+10` only for reviewable requests. |

## Supplier Request Data Rules

| Rule ID | Rule |
|---|---|
| DATA-001 | A supplier request must have one request header record. |
| DATA-002 | A request must capture supplier name, supplier type, supplier country, business unit, requester, business justification, product/service category, and expected annual spend when supplied by the UI. |
| DATA-003 | A request must capture one primary supplier contact with contact email. |
| DATA-004 | A request must capture one primary intended supplier site for phase one, or an intended business unit mapping sufficient to validate the site/business-unit requirement. |
| DATA-005 | Tax registration number is required when the selected country and supplier type indicate tax registration is applicable. |
| DATA-006 | Bank information is optional at initial request. If bank information is provided, bank country and protected account representation must be validated and stored. |
| DATA-007 | Document metadata can exist without storing production binary content in ATP. |
| DATA-008 | All externally visible request records use generated request IDs or request numbers, not database internals. |

## Foundational Validation Rules

UOW-002 validates the request enough to safely accept, store, submit, review, and route it. UOW-003 later extends validation with duplicate detection, risk scoring, normalization, and matching.

| Rule ID | Rule |
|---|---|
| VAL-001 | Supplier name is mandatory for submission. |
| VAL-002 | Supplier country is mandatory for submission. |
| VAL-003 | Supplier type is mandatory for submission. |
| VAL-004 | Business unit is mandatory for submission. |
| VAL-005 | Contact email is mandatory and must be syntactically email-like. |
| VAL-006 | Address or primary supplier site address is mandatory for submission. |
| VAL-007 | Tax registration must be present where applicable according to active `TAX_REQUIREMENT_CONFIG` rules. |
| VAL-008 | Expected annual spend, when provided, must be non-negative. |
| VAL-009 | Bank country mismatch is stored as a validation finding or risk input when bank information is available. |
| VAL-010 | Missing bank information does not block initial request creation, but can become a finding or risk input where payment setup requires it. |
| VAL-011 | Validation findings must include field code, severity, message, and blocking flag. |
| VAL-012 | Blocking validation findings move the request to `VALIDATION_FAILED`. |
| VAL-013 | No blocking validation findings move the request to `UNDER_REVIEW` after submission logic completes. |

## Workflow State Rules

ATP workflow logic is the source of truth for status transitions.

| From Status | Action | Actor | To Status | Rule |
|---|---|---|---|---|
| None | Create draft | Requester | `DRAFT` | A requester creates a new request. |
| `DRAFT` | Update draft | Requester owner | `DRAFT` | Editable values are saved without review routing. |
| `DRAFT` | Submit | Requester owner | `SUBMITTED` | Submission starts validation. |
| `VALIDATION_FAILED` | Correct and resubmit | Requester owner | `SUBMITTED` | Corrected request re-enters validation. |
| `SUBMITTED` | Validation fails | System | `VALIDATION_FAILED` | Blocking foundational findings are stored. |
| `SUBMITTED` | Validation passes | System | `UNDER_REVIEW` | Request becomes available to Reviewer. |
| `UNDER_REVIEW` | Accept | Reviewer | `APPROVED` | Human acceptance is required before Fusion submission. |
| `UNDER_REVIEW` | Reject | Reviewer | `REJECTED` | Reviewer decision and reason are stored. |
| `UNDER_REVIEW` | Mark duplicate | Reviewer | `DUPLICATE` | Existing supplier reference should be stored when available. |
| `UNDER_REVIEW` | Request correction | Reviewer | `CORRECTION_REQUIRED` | Request becomes visible to the requester with the correction reason and an Edit action. |
| `UNDER_REVIEW` | Apply justification-risk adjustment | Reviewer | `UNDER_REVIEW` | Reviewer adds `+3`, `+5`, or `+10` to the previously calculated deterministic risk score after reading Gemini's business-justification risk review. |
| `APPROVED` | Submit to Fusion | System/OIC path | `SUBMITTED_TO_FUSION` | Only approved requests can enter integration submission. |
| `SUBMITTED_TO_FUSION` | Fusion success | OIC callback | `CREATED_IN_FUSION` | Fusion supplier number is stored. |
| `SUBMITTED_TO_FUSION` | Technical failure | OIC callback | `INTEGRATION_FAILED` | Failure details and retry eligibility are stored. |
| `INTEGRATION_FAILED` | Retry accepted | Admin | `SUBMITTED_TO_FUSION` | Retry is allowed only for eligible technical failures and creates a new `INTEGRATION_JOB` row linked to the original job. |

## Review Rules

| Rule ID | Rule |
|---|---|
| REV-001 | AI output is advisory and cannot approve, reject, mark duplicate, or create suppliers. |
| REV-002 | Duplicate and high-risk findings require human review before Fusion submission. |
| REV-003 | Accept/approval requires a Reviewer action on a reviewable request. |
| REV-004 | Rejection requires a Reviewer reason. |
| REV-005 | When rejecting because the request is duplicate, the rejection should reference an existing supplier when one is available. |
| REV-006 | Requesting correction preserves the original request and writes an `ACTION_HISTORY` row with reason and actor. |
| REV-007 | Review decisions must be auditable in `ACTION_HISTORY` with actor, timestamp, action, status transition, and reason. |
| REV-008 | The Reviewer review page must show three primary action buttons for a reviewable request: Accept, Reject, and Send Correction. |
| REV-009 | Send Correction requires a correction reason before the action is accepted. |
| REV-010 | After Send Correction, the requester dashboard/detail view must show the correction reason and an Edit button. |
| REV-011 | The requester Edit button is shown only when the request is owned by that requester and status is `CORRECTION_REQUIRED` or `VALIDATION_FAILED`. |
| REV-012 | Gemini business-justification risk is advisory until a Reviewer confirms it with one of the allowed point buttons: `+3`, `+5`, or `+10`. |
| REV-013 | A Reviewer may leave Gemini's justification-risk finding unapplied if the business justification does not support the AI concern. |
| REV-014 | A request version can have at most one active justification-risk adjustment; changing the adjustment supersedes the previous active adjustment through audit rather than overwriting history. |
| REV-015 | Reviewer-applied justification-risk points are added to the deterministic score and capped at the configured maximum score for final risk-level classification. |
| REV-016 | Reviewer justification-risk adjustment actions must be auditable in `ACTION_HISTORY` and reference the points selected and reason used. |

## Bank Data Rules

| Rule ID | Rule |
|---|---|
| BANK-001 | Normal ORDS responses must not expose full bank account values. |
| BANK-002 | Normal display uses masked tax/bank values and bank account last four, such as `bank_account_last_four`. |
| BANK-003 | Matching uses `bank_account_fingerprint` or equivalent protected comparison value. |
| BANK-004 | Bank country must be stored when bank details are provided. |
| BANK-005 | Bank country mismatch is captured as a validation or risk input. |
| BANK-006 | Admin log views must not leak full bank values through payload or response summaries. |

## Supplier Reference Rules

| Rule ID | Rule |
|---|---|
| REF-001 | Seeded/mock and future Fusion-synced supplier references use `FUSION_SUPPLIER_REF`, `FUSION_SUPPLIER_TAX_REF`, `FUSION_SUPPLIER_SITE_REF`, and `FUSION_SUPPLIER_BANK_REF`. |
| REF-002 | Each supplier reference row stores Fusion identifiers, active status, and sync metadata where applicable. |
| REF-003 | Fusion remains the supplier master system of record. |
| REF-004 | ATP reference data is used for duplicate checking and reviewer evidence only. |
| REF-005 | Upsert behavior must avoid duplicate active reference rows for the same source supplier identifier. |

## Configuration Rules

| Rule ID | Rule |
|---|---|
| CFG-001 | `CONFIGURATION` stores small scalar key/value settings. Human-maintained business controls use structured configuration tables instead of JSON-valued rows. |
| CFG-002 | The active risky-country list is maintained by Admin in `HIGH_RISK_COUNTRY_CONFIG`; existing `HIGH_RISK_COUNTRY` configuration rows may be retained as legacy or fallback seed data only. |
| CFG-003 | Score thresholds are stored in `RISK_SCORE_BAND_CONFIG`. |
| CFG-004 | Tax applicability rules are stored in `TAX_REQUIREMENT_CONFIG`. |
| CFG-005 | Generic or vague justification phrases are stored in `GENERIC_JUSTIFICATION_PHRASE`. |
| CFG-006 | Business-unit/site mappings are stored in `BUSINESS_UNIT_SITE_MAPPING`. |
| CFG-007 | Only active configuration rows are used by business logic. |
| CFG-008 | Configuration updates must not rewrite historical `ACTION_HISTORY`, `AI_ASSESSMENT`, or `INTEGRATION_JOB` rows. |
| CFG-009 | Seeded risky-country entries are provided for the prototype and can be activated, deactivated, or updated by Admin for future assessments. |
| CFG-010 | Updating the risky-country list does not change the 100-point risk-weight total; it only changes whether the `HIGH_RISK_COUNTRY` rule applies to a supplier country. |

## Document Rules

| Rule ID | Rule |
|---|---|
| DOC-001 | ATP stores request document metadata, request version, latest flag, uploader, timestamp, and optional content placeholder. |
| DOC-002 | Production file content belongs in OCI Object Storage or a later configured storage layer. |
| DOC-003 | Document metadata must include request, document type, file name, content type, uploader, timestamp, and object reference when external storage is used. |
| DOC-004 | Missing expected documents can be represented as validation findings or risk inputs. |

## Integration Log and Retry Rules

| Rule ID | Rule |
|---|---|
| INT-001 | Each AI explanation, Fusion create, or supplier sync attempt creates an `INTEGRATION_JOB` row. |
| INT-002 | `INTEGRATION_JOB.integration_type` must be `AI_EXPLANATION`, `FUSION_CREATE`, or `SUPPLIER_SYNC`. |
| INT-003 | Integration jobs must store OIC instance ID when available, payload reference, response reference, error type, error message, retryable flag, attempt number, and timestamps. |
| INT-004 | Business validation failures are not technical integration failures and are not Admin-retryable. |
| INT-005 | Retry cannot bypass validation, duplicate review, risk review, or approval. |
| INT-006 | Retry eligibility is determined by failure type, current status, prior approval, and configurable retry limit. |
| INT-007 | Each accepted retry creates a new `INTEGRATION_JOB` row with `parent_job_id` pointing to the original job and `attempt_number` incremented. |
| INT-008 | Rejected retry attempts should be recorded in `ACTION_HISTORY` when they indicate unauthorized or invalid operational behavior. |
| INT-009 | Admin log screens read from `INTEGRATION_JOB` and display the retry chain by following `parent_job_id`. |

## AI Assessment Rules

| Rule ID | Rule |
|---|---|
| AI-001 | Each Gemini response is stored as a new `AI_ASSESSMENT` row. |
| AI-002 | Regenerating an AI summary never overwrites prior `AI_ASSESSMENT` rows. |
| AI-003 | Request detail views display the latest successful assessment by default. |
| AI-004 | `request_version` links the assessment to the request data version used for generation. |
| AI-005 | AI assessment history must include summary, recommended actions, justification quality, model name, status, and generated timestamp. |
| AI-006 | AI assessments are advisory and cannot change request status by themselves. |
| AI-007 | Gemini must return business-justification risk metadata when available: risk flag, rationale, suggested severity, and suggested points for Reviewer consideration. |
| AI-008 | Gemini suggested points are not applied until a Reviewer selects `+3`, `+5`, or `+10`; unsupported values are rejected by ATP/ORDS. |

## Dashboard and Query Rules

| Rule ID | Rule |
|---|---|
| DASH-001 | Requester dashboard returns only requests visible to the requester. |
| DASH-002 | Reviewer dashboard returns reviewable requests and request detail evidence needed for review. |
| DASH-003 | Admin dashboard returns integration failure, log, retry, and support diagnostic rows. |
| DASH-004 | Dashboard APIs support stable filters for business unit, country, supplier type, requester, status, risk level, and duplicate risk where available. |
| DASH-005 | ORDS response shapes must remain stable even when duplicate, risk, AI, or integration fields are not yet populated. |
| DASH-006 | Visual Builder should not be required to infer role-specific row ownership from raw tables. |
| DASH-007 | Requester dashboard rows for `CORRECTION_REQUIRED` requests must include correction reason summary and allowed action `EDIT`. |
| DASH-008 | Reviewer request detail responses for `UNDER_REVIEW` requests must include allowed actions `ACCEPT`, `REJECT`, and `SEND_CORRECTION`. |
| DASH-009 | Reviewer request detail responses must distinguish deterministic risk score, Gemini justification-risk advice, Reviewer-applied adjustment, and final score. |
| DASH-010 | Admin risk configuration responses must include the editable risky-country list and seeded/default status. |

## Audit Rules

| Rule ID | Rule |
|---|---|
| AUD-001 | Status changes are recorded in `ACTION_HISTORY`. |
| AUD-002 | Review decisions are recorded in `ACTION_HISTORY`. |
| AUD-003 | Integration attempts and retry attempts are recorded in `INTEGRATION_JOB`, with invalid retry actions recorded in `ACTION_HISTORY` when appropriate. |
| AUD-004 | AI summary generation timestamps and metadata are auditable through `AI_ASSESSMENT`. |
| AUD-005 | Action history records include actor, timestamp, action, request reference, status transition, and reason. |
| AUD-006 | `ACTION_HISTORY`, `AI_ASSESSMENT`, and `INTEGRATION_JOB` are append-oriented history tables and should not be edited as normal request data. |
| AUD-007 | Reviewer-applied justification-risk adjustments are auditable actions and must preserve selected points, actor, timestamp, request version, and rationale. |

## Testable Properties

PBT-01 applies during this Functional Design stage.

| Property ID | Category | Rule Area | Property |
|---|---|---|---|
| P-UOW002-001 | Stateful/invariant | Workflow | Generated valid workflow command sequences never create an invalid status transition. |
| P-UOW002-002 | Invariant | Workflow | A request cannot reach `SUBMITTED_TO_FUSION` or `CREATED_IN_FUSION` without prior `APPROVED` status. |
| P-UOW002-003 | Invariant | Permissions | Disallowed role/action combinations do not mutate protected state. |
| P-UOW002-004 | Round-trip | Persistence | Valid request payloads preserve supported values through write/read behavior, except documented normalization and derived fields. |
| P-UOW002-005 | Invariant | Bank masking | Normal read/dashboard responses never expose unmasked full bank values. |
| P-UOW002-006 | Idempotence | Supplier reference upsert | Replaying the same supplier reference source record does not create duplicate active references. |
| P-UOW002-007 | Invariant | Retry logs | `INTEGRATION_JOB` retry chains remain consistent with accepted retry attempts and rejected retry attempts do not create successful retry rows. |
| P-UOW002-008 | Invariant | AI assessment history | Regenerating an AI assessment appends a new `AI_ASSESSMENT` row and never overwrites prior rows. |
| P-UOW002-009 | Stateful/invariant | Correction flow | Requester Edit action is returned only for owned requests in editable statuses, including `CORRECTION_REQUIRED`. |
| P-UOW002-010 | Invariant | Justification-risk adjustment | Gemini output alone never changes risk score; only generated Reviewer actions with allowed values `3`, `5`, or `10` can affect final risk, and final displayed score remains within bounds. |
| P-UOW002-011 | Invariant | Risky-country configuration | Generated Admin country-list changes affect future `HIGH_RISK_COUNTRY` applicability without changing the deterministic risk-weight total. |

## Extension Compliance

| Extension Rule | Status | Rationale |
|---|---|---|
| PBT-01 | Compliant | Testable properties are identified above and carried forward to code generation planning. |
| PBT-02 through PBT-08 | N/A for this stage | These are enforced during Code Generation for generated tests. |
| PBT-09 | N/A for this stage | Framework selection belongs to NFR Requirements. |
| PBT-10 | N/A for this stage | Complementary example/PBT implementation belongs to Code Generation and Build/Test. |

## Content Validation

- No Mermaid diagrams are used.
- No ASCII diagrams are used.
- Markdown tables and lists are used for parser compatibility.
