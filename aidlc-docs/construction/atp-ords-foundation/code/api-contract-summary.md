# API Contract Summary: UOW-002 ATP/ORDS Supplier Request Foundation

## Base URL

Local base URL:

```text
http://localhost:8080/ords/supplier-onboarding/v1/
```

The endpoint set has been reconciled with `/home/ammarkhan/Downloads/technical-design (2).md`, which is the finalized schema and API source for this pass.

## Identity

Oracle IAM owns real users and role assignments. ATP stores stable IAM subject IDs in audit and ownership columns.

For local QA, ORDS handlers accept these request parameters:

| Parameter | Purpose |
|---|---|
| `actor_subject_id` | Stable IAM subject ID, such as `REQ_AMINA_SUB`. |
| `actor_roles` | Comma-separated app roles, such as `REQUESTER`, `REVIEWER`, or `ADMIN`. |

These parameters are local/testing stand-ins for IAM claims.

## Requester Endpoints

| Method | Path | Purpose | Backing Logic |
|---|---|---|---|
| GET | `/requests` | Role-aware request list with `limit` and `offset`. | `request_dashboard_v` and package authorization helpers |
| POST | `/requests` | Create draft supplier request. | `supplier_request_pkg.create_request` |
| GET | `/requests/{request_id}` | Request detail with latest assessment, latest AI response, safe bank fields, and allowed actions. | `request_detail_safe_v` |
| PUT | `/requests/{request_id}` | Update editable draft, validation failed, or correction required request. | `supplier_request_pkg.update_request` |
| POST | `/requests/{request_id}/submit` | Submit or resubmit and run ATP deterministic assessment. | `supplier_request_pkg.submit_request` |
| POST | `/requests/{request_id}/documents` | Store latest document metadata and optional BLOB. | `supplier_request_pkg.add_document` |
| GET | `/requests/{request_id}/documents/{document_id}` | Retrieve document metadata for a request. | `REQUEST_DOCUMENT` |

## Reviewer Endpoints

| Method | Path | Purpose | Backing Logic |
|---|---|---|---|
| POST | `/requests/{request_id}/review` | Approve, reject, request correction, or mark duplicate. | `supplier_review_pkg.decide_request` |
| POST | `/requests/{request_id}/justification-risk-adjustment` | Apply Reviewer-confirmed `+3`, `+5`, or `+10` business-justification risk points after a successful Gemini assessment. | `supplier_review_pkg.apply_justification_risk_adjustment` |
| POST | `/requests/{request_id}/ai-regeneration` | Queue a new Gemini explanation job without overwriting older AI responses. | `INTEGRATION_JOB` |

Reviewer actions are available only for `UNDER_REVIEW` requests. Gemini output remains advisory by itself; numeric risk changes only when a Reviewer explicitly applies justification-risk points. The deterministic score remains stored separately from the final adjusted score.

## Admin Endpoints

| Method | Path | Purpose | Backing Logic |
|---|---|---|---|
| GET | `/integration-logs` | Admin support log view backed by integration job history. | `integration_log_safe_v` |
| POST | `/requests/{request_id}/retry` | Retry the latest eligible technical failure for a request. | `supplier_integration_pkg.retry_latest_failed_request_job` |
| GET | `/risk-rules` | Admin-readable risk rule list. | `risk_rule_config_v` |
| PUT | `/risk-rules/{rule_code}` | Update one risk rule and reject invalid max allocation. | `supplier_config_pkg.update_risk_rule` |
| GET | `/high-risk-countries` | Admin-maintained high-risk country list. | `high_risk_country_config_v` |
| PUT | `/high-risk-countries/{country_code}` | Activate, deactivate, or update a high-risk country. | `supplier_config_pkg.set_high_risk_country` |

Risk allocation follows the finalized model: maximum base risk is 55 and maximum duplicate contribution is 45.

## OIC-Facing Endpoints

| Method | Path | Purpose |
|---|---|---|
| GET | `/integration-jobs?type=AI_EXPLANATION&status=READY` | OIC polls AI explanation jobs. |
| GET | `/integration-jobs?type=FUSION_CREATE&status=READY` | OIC polls Fusion create jobs. |
| GET | `/integration-jobs?type=SUPPLIER_SYNC&status=READY` | OIC polls supplier sync jobs. |
| POST | `/integration-jobs/{job_id}/claim` | OIC claims a ready job. |
| PUT | `/integration-jobs/{job_id}/result` | OIC records success or failure. |
| POST | `/supplier-reference/batch` | OIC seeds or refreshes the local Fusion supplier reference cache. |

For the local ORDS 26.2 test stack, OIC-style `PUT /integration-jobs/{job_id}/result` is verified with query parameters such as `job_status`, `response_reference`, `error_type`, `error_message`, `retryable`, `fusion_supplier_id`, and `fusion_supplier_number`.

When the job is `AI_EXPLANATION`, the same result endpoint also accepts `ai_summary`, `ai_recommended_actions`, `justification_quality`, and `model_name`. A successful or failed AI result writes an append-only row in `AI_ASSESSMENT` and marks earlier rows for the request as not latest.

For the local ORDS 26.2 test stack, Requester `PUT /requests/{request_id}`, Admin `PUT /risk-rules/{rule_code}`, and Admin `PUT /high-risk-countries/{country_code}` are verified with query parameters. This avoids unreliable implicit form-body binding on these PUT handlers.

## Validation and Projection Rules

| Rule | API Behavior |
|---|---|
| Mandatory fields | Submission stores deterministic findings in `REQUEST_ASSESSMENT` and routes to `VALIDATION_FAILED` when blocked. |
| Missing bank data | Does not block initial submission, but contributes configured risk. |
| Provided bank data | Normal responses expose last four only; full values and fingerprints are not returned by safe views. |
| Correction required | Requester-owned rows return allowed action `EDIT`. |
| Duplicate evidence | Duplicate level and match evidence are stored in `REQUEST_ASSESSMENT.duplicate_matches_json`. |
| Gemini assessment | Stored append-only in `AI_ASSESSMENT`; regenerated summaries do not overwrite older rows. |
| Reviewer justification-risk adjustment | Requires a latest successful Gemini assessment, writes one active adjustment on the latest `REQUEST_ASSESSMENT`, updates the final displayed risk score, and records `APPLY_JUSTIFICATION_RISK` in `ACTION_HISTORY`. |
| Admin risky countries | Country-list changes affect future high-risk-country applicability without changing rule weight values. |
| Admin risk weights | Updates are rejected if active risk-rule weights do not total exactly 100. |

## Content Validation

- No Mermaid diagrams are used.
- No ASCII diagrams are used.
- Markdown tables and code references are parser-compatible.
