# Domain Entities: UOW-002 ATP/ORDS Supplier Request Foundation

## Purpose

This document defines the logical domain entities for the ATP and ORDS foundation of the Supplier Onboarding, Duplicate Detection, and Risk Scoring application.

The design follows the finalized schema supplied in `/home/ammarkhan/Downloads/technical-design (2).md` and the generated Oracle objects under `oracle/atp/`.

## Final Design Decisions

- Use Oracle IAM for real users and roles; ATP stores stable subject IDs for ownership and audit.
- Use a flattened phase-one request model in `SUPPLIER_REQUEST` for supplier, address, contact, business unit, site, tax, bank, lifecycle, Fusion result, and risk summary fields.
- Store documents in `REQUEST_DOCUMENT`.
- Store validation results, duplicate evidence, deterministic risk, Reviewer justification-risk adjustment, and final displayed risk score in `REQUEST_ASSESSMENT`.
- Store every Gemini response in append-only `AI_ASSESSMENT` rows so regenerated summaries do not overwrite history.
- Store status changes and auditable Reviewer/Admin decisions in `ACTION_HISTORY`.
- Store OIC/Gemini/Fusion work queue entries, attempts, failures, and retry lineage in `INTEGRATION_JOB`.
- Store Admin-readable business configuration in structured tables, not JSON configuration blobs.
- Keep scalar fallback settings in `CONFIGURATION` only where a simple key/value is enough.

## Boundary

UOW-002 owns database and REST foundations. It does not own production Oracle IAM setup, final OIC integrations, Fusion credentials, Gemini prompt orchestration, attachment object storage, or later production operations hardening.

## Entity Catalog

### Identity and Access Context

| Entity or Context | Purpose | Key Attributes | Notes |
|---|---|---|---|
| Oracle IAM subject context | Identifies the authenticated actor. | `actor_subject_id`, `actor_roles` | In production this comes from IAM claims. In local ORDS testing these values are passed as request parameters. |
| `SUPPLIER_REQUEST` ownership fields | Persist request ownership and audit identity. | `requester_subject_id`, `requester_display_name`, `requester_email` | Requester visibility is enforced by requester subject ID. |
| History actor fields | Preserve who took protected actions. | `actor_subject_id`, `updated_by_subject_id`, `uploaded_by_subject_id`, `reviewer_adjusted_by_subject_id` | Used by `ACTION_HISTORY`, document uploads, config updates, and assessment adjustment evidence. |

Valid application roles are:

| Role | Meaning |
|---|---|
| `REQUESTER` | Creates, edits, submits, corrects, and tracks own supplier requests. |
| `REVIEWER` | Reviews supplier requests and performs Accept, Reject, Send Correction, and duplicate-related decisions. Finance, compliance, and supplier-data review concerns are merged into this role. |
| `ADMIN` | Views integration logs, technical failure details, retry counts, and retries eligible technical failures. Admin also maintains risk weights and risky-country configuration. |

### Supplier Request Core

| Entity | Purpose | Key Attributes | Relationships |
|---|---|---|---|
| `SUPPLIER_REQUEST` | Main request record and lifecycle owner. | `request_id`, `request_number`, `requester_subject_id`, `status`, `request_version`, `supplier_name`, `supplier_type`, `country_code`, `address_line1`, `city`, `contact_email`, `business_unit`, `business_justification`, `product_service_category`, `expected_annual_spend`, `tax_registration_number`, `tax_registration_fingerprint`, `bank_account_fingerprint`, `bank_account_last_four`, `site_name`, `site_country_code`, `risk_score`, `risk_level`, `duplicate_level`, `fusion_supplier_id`, `fusion_supplier_number` | Parent for documents, assessments, AI history, action history, and integration jobs. |
| `REQUEST_DOCUMENT` | Document metadata, request version, latest flag, uploader, and optional document BLOB. | `document_id`, `request_id`, `request_version`, `document_type`, `file_name`, `mime_type`, `document_content`, `is_latest`, `uploaded_by_subject_id`, `uploaded_at` | Child of `SUPPLIER_REQUEST`. Normal request views return metadata, not raw document bytes. |

### Assessment and Review Results

| Entity | Purpose | Key Attributes | Relationships |
|---|---|---|---|
| `REQUEST_ASSESSMENT` | Latest and historical validation, duplicate, risk, and Reviewer-adjustment result for a request version. | `assessment_id`, `request_id`, `request_version`, `is_latest`, `validation_status`, `validation_results_json`, `duplicate_level`, `duplicate_matches_json`, `deterministic_risk_score`, `reviewer_adjustment_points`, `reviewer_adjustment_reason`, `reviewer_adjusted_by_subject_id`, `risk_score`, `risk_level`, `risk_factors_json`, `reference_sync_id`, `assessed_at` | Child of `SUPPLIER_REQUEST`. One latest assessment drives dashboard/detail risk display. |
| `AI_ASSESSMENT` | Append-only Gemini response history. | `ai_assessment_id`, `request_id`, `request_version`, `is_latest`, `summary`, `recommended_actions`, `justification_quality`, `model_name`, `status`, `generated_at` | Child of `SUPPLIER_REQUEST`. New AI generations append rows and mark older rows non-latest. |
| `ACTION_HISTORY` | Unified audit trail for workflow status changes, review decisions, corrections, duplicate outcomes, integration state changes, and risk-adjustment actions. | `action_history_id`, `request_id`, `action`, `from_status`, `to_status`, `reason`, `existing_supplier_id`, `actor_subject_id`, `action_at` | Child of `SUPPLIER_REQUEST`. |

### Supplier Master Reference

| Entity | Purpose | Key Attributes | Relationships |
|---|---|---|---|
| `FUSION_SUPPLIER_REF` | Local ATP copy of Fusion supplier header data for matching and review evidence. | `fusion_supplier_id`, `supplier_number`, `supplier_name`, `supplier_name_normalized`, `supplier_type`, `active`, `last_seen_sync_id`, `last_synced_at` | Parent for Fusion tax, site, and bank reference rows. |
| `FUSION_SUPPLIER_TAX_REF` | Protected tax identifiers from Fusion cache. | `fusion_tax_reference_id`, `fusion_supplier_id`, `country_code`, `tax_type`, `tax_id_fingerprint`, `tax_id_masked`, `active` | Child of `FUSION_SUPPLIER_REF`. |
| `FUSION_SUPPLIER_SITE_REF` | Site/address reference data from Fusion cache. | `fusion_supplier_site_id`, `fusion_supplier_id`, `site_name`, `site_number`, `country_code`, `address_line1`, `city`, `email_domain`, `phone_normalized`, `active` | Child of `FUSION_SUPPLIER_REF`. |
| `FUSION_SUPPLIER_BANK_REF` | Protected bank reference data from Fusion cache. | `fusion_bank_account_id`, `fusion_supplier_id`, `bank_country_code`, `currency_code`, `bank_account_fingerprint`, `bank_account_last_four`, `active` | Child of `FUSION_SUPPLIER_REF`. |

### Integration and Configuration

| Entity | Purpose | Key Attributes | Notes |
|---|---|---|---|
| `INTEGRATION_JOB` | OIC/Gemini/Fusion work queue and attempt history. Each retry is a new row linked to the original job. | `job_id`, `parent_job_id`, `request_id`, `integration_type`, `status`, `attempt_number`, `oic_instance_id`, `payload_reference`, `response_reference`, `error_type`, `error_message`, `retryable`, `correlation_id`, timestamps | Used by OIC polling and Admin log/retry views. |
| `CONFIGURATION` | Scalar key/value configuration for simple settings. | `config_type`, `config_key`, `config_value`, `active`, `description`, `updated_by_subject_id`, `updated_at` | Human-maintained structured business controls use dedicated tables below. |
| `RISK_RULE_CONFIG` | Admin-maintained deterministic risk rules and weights. | `rule_code`, `component`, `rule_name`, `condition_description`, `weight_points`, `active`, `display_order`, `updated_by_subject_id`, `updated_at` | Active rule weights must total exactly 100. |
| `RISK_SCORE_BAND_CONFIG` | Risk level thresholds. | `risk_level`, `min_score`, `max_score`, `active`, `display_order`, `updated_by_subject_id`, `updated_at` | Defines Low, Medium, High, and Critical score ranges. |
| `HIGH_RISK_COUNTRY_CONFIG` | Admin-maintained risky-country list seeded with prototype defaults. | `country_code`, `reason`, `source_name`, `effective_date`, `active`, `updated_by_subject_id`, `updated_at` | Country list changes affect future high-risk-country applicability without changing rule weights. |
| `TAX_REQUIREMENT_CONFIG` | Country/type tax applicability settings. | `country_code`, `supplier_type`, `required`, `reason`, `active`, `updated_by_subject_id`, `updated_at` | Used by foundational validation. |
| `BUSINESS_UNIT_SITE_MAPPING` | Business-unit to intended-site mapping. | `business_unit`, `site_name`, `site_country_code`, `active`, `updated_by_subject_id`, `updated_at` | Supports site/business-unit validation and defaults. |
| `GENERIC_JUSTIFICATION_PHRASE` | Human-readable generic justification phrase list. | `phrase_key`, `phrase_text`, `severity`, `active`, `updated_by_subject_id`, `updated_at` | Helps flag low-quality business justifications. |

Allowed `INTEGRATION_JOB.integration_type` values:

| Value | Meaning |
|---|---|
| `AI_EXPLANATION` | Gemini explanation or regenerated AI assessment request. |
| `FUSION_CREATE` | Supplier creation submission through OIC/Fusion. |
| `SUPPLIER_SYNC` | Supplier master reference synchronization. |

Allowed `INTEGRATION_JOB.status` values:

| Value | Meaning |
|---|---|
| `READY` | Job is available for OIC polling. |
| `CLAIMED` | OIC has claimed the job. |
| `IN_PROGRESS` | OIC/Fusion/Gemini processing is underway. |
| `SUCCEEDED` | Integration attempt completed successfully. |
| `FAILED` | Integration attempt failed and may be retryable if marked so. |
| `CANCELLED` | Job was cancelled. |

## Request Status Model

| Status | Meaning |
|---|---|
| `DRAFT` | Initial editable request state before submission. |
| `SUBMITTED` | Requester submitted the request and validation is starting. |
| `VALIDATION_FAILED` | Foundational validation failed and requester correction is required. |
| `UNDER_REVIEW` | Request passed foundational validation and awaits Reviewer decision. |
| `CORRECTION_REQUIRED` | Reviewer requested changes; requester can see the correction reason and edit the request. |
| `REJECTED` | Reviewer rejected the request. |
| `DUPLICATE` | Reviewer closed the request as an existing-supplier duplicate. |
| `APPROVED` | Reviewer approved the request for Fusion submission. |
| `SUBMITTED_TO_FUSION` | Approved request has been sent through the integration path. |
| `CREATED_IN_FUSION` | Fusion creation succeeded and supplier number was captured. |
| `INTEGRATION_FAILED` | Technical integration failure occurred after approval. |

## Risk Model

| Area | Rule |
|---|---|
| Deterministic allocation | Active `RISK_RULE_CONFIG.weight_points` values must total exactly 100. |
| Base component | Seeded base rules total 55 points. |
| Duplicate component | Seeded duplicate-related rules total 45 points. |
| Score bands | `RISK_SCORE_BAND_CONFIG` maps the final score to Low, Medium, High, or Critical. |
| Risky countries | `HIGH_RISK_COUNTRY_CONFIG` changes whether the high-risk-country rule applies; it does not change that rule's weight. |
| Gemini justification review | Gemini may flag a risky business justification and give rationale, but cannot change the numeric score directly. |
| Reviewer adjustment | Reviewer can add `+3`, `+5`, or `+10` points through the adjustment endpoint; final score is capped at 100. |

## Relationship Summary

| Parent | Child | Cardinality |
|---|---|---|
| `SUPPLIER_REQUEST` | `REQUEST_DOCUMENT` | Zero-to-many. |
| `SUPPLIER_REQUEST` | `REQUEST_ASSESSMENT` | Zero-to-many, with one latest assessment per request version. |
| `SUPPLIER_REQUEST` | `AI_ASSESSMENT` | Zero-to-many. |
| `SUPPLIER_REQUEST` | `ACTION_HISTORY` | Zero-to-many. |
| `SUPPLIER_REQUEST` | `INTEGRATION_JOB` | Zero-to-many. |
| `INTEGRATION_JOB` | `INTEGRATION_JOB` | Zero-to-many self-reference through `parent_job_id` for retries. |
| `FUSION_SUPPLIER_REF` | `FUSION_SUPPLIER_TAX_REF` | Zero-to-many. |
| `FUSION_SUPPLIER_REF` | `FUSION_SUPPLIER_SITE_REF` | Zero-to-many. |
| `FUSION_SUPPLIER_REF` | `FUSION_SUPPLIER_BANK_REF` | Zero-to-many. |

## Sensitive Data Rules

- Normal UI and dashboard responses must never expose full bank account numbers.
- ATP stores bank account content as encrypted/protected data plus a fingerprint and last four digits.
- Tax and bank matching use fingerprints, not raw values in normal projections.
- `tax_registration_masked` and `bank_account_last_four` are safe for normal Reviewer/Admin display.
- Admin users can inspect integration payload references, responses, errors, and retry lineage, but not unrestricted sensitive bank values.

## Entity Ownership by Unit

| Unit | Entity Ownership |
|---|---|
| UOW-002 | Owns the implemented ATP entities, persistence contract, ORDS contract, status model, IAM-subject authorization checks, foundational validation storage, dashboard projection, `AI_ASSESSMENT`, `ACTION_HISTORY`, `INTEGRATION_JOB`, and configuration tables. |
| UOW-003 | Later duplicate/risk algorithm expansion can write through UOW-002 assessment and reference structures. |
| UOW-004 | Later Fusion, OIC, Gemini, and supplier master sync integrations write through UOW-002 structures. |
| UOW-001 | Visual Builder reads and writes through ORDS only; it does not own durable entities. |

## Testable Properties

PBT-01 applies to this unit.

| Component Area | Property Category | Property to Carry Forward |
|---|---|---|
| Request persistence | Round-trip | A valid request payload written through the API and read back through the detail API preserves all supported non-derived fields, subject to documented normalization and masking. |
| Workflow state | Stateful/invariant | Generated valid command sequences must never move a request to Fusion-created states without prior approval. |
| Role permissions | Invariant | For every generated role/action pair, disallowed actions do not mutate request, review, retry, or log state. |
| Bank masking | Invariant | Normal read/dashboard responses never reveal full bank account values and always preserve last-four/masked display constraints. |
| Integration retry log | Idempotence/invariant | `INTEGRATION_JOB` retry chains remain consistent with the number of accepted retry actions; rejected retries do not create successful retry rows. |
| Supplier reference upsert | Idempotence | Applying the same supplier reference sync record twice does not create duplicate active reference rows for the same Fusion source identifier. |
| AI assessment history | Invariant | Regenerating a Gemini assessment appends an `AI_ASSESSMENT` row and does not overwrite prior assessment rows. |
| Reviewer justification risk | Invariant | Gemini justification risk metadata never changes numeric risk until a Reviewer applies `+3`, `+5`, or `+10`; final score remains within the configured score maximum. |
| Risk configuration | Invariant | Active risk-rule weights total exactly 100 after any accepted Admin update. |
| Correction visibility | Stateful/invariant | A requester sees an Edit action only for owned requests in `DRAFT`, `VALIDATION_FAILED`, or `CORRECTION_REQUIRED`. |

## Content Validation

- No Mermaid diagrams are used.
- No ASCII diagrams are used.
- Markdown tables are syntactically simple and use escaped code formatting only for logical entity names.
