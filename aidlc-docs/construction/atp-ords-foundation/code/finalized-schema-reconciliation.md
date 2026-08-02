# Finalized Schema Reconciliation

## Source

The user supplied `/home/ammarkhan/Downloads/technical-design (2).md` as the finalized schema source during Code Generation Review.

## Reconciliation Decisions

| Area | Finalized Decision |
|---|---|
| Identity | Oracle IAM owns users and roles. ATP stores subject IDs for ownership and audit. |
| Request data | Phase one keeps one requested site, contact, address, and bank account on `SUPPLIER_REQUEST`. |
| Documents | `REQUEST_DOCUMENT` stores supplier document metadata, request version, latest flag, uploader subject, and optional BLOB. |
| Assessment | `REQUEST_ASSESSMENT` stores validation results, duplicate matches, deterministic risk score, Reviewer adjustment points, final displayed risk score, risk level, risk factors, reference sync ID, and latest flag. |
| Fusion cache | Fusion reference matching uses `FUSION_SUPPLIER_REF`, `FUSION_SUPPLIER_TAX_REF`, `FUSION_SUPPLIER_SITE_REF`, and `FUSION_SUPPLIER_BANK_REF`. |
| AI history | `AI_ASSESSMENT` stores every Gemini response; regenerated summaries do not overwrite history. |
| Action audit | `ACTION_HISTORY` stores workflow status changes and reviewer decisions. |
| Integration | `INTEGRATION_JOB` stores OIC work queue rows, attempts, retries, payload references, response references, and errors. |
| Configuration | `CONFIGURATION` stores scalar generic settings. `RISK_RULE_CONFIG`, `RISK_SCORE_BAND_CONFIG`, `HIGH_RISK_COUNTRY_CONFIG`, `TAX_REQUIREMENT_CONFIG`, `BUSINESS_UNIT_SITE_MAPPING`, and `GENERIC_JUSTIFICATION_PHRASE` store human-readable business settings. |

## Explicit Supersessions

These earlier draft elements were removed from generated ATP/ORDS code:

| Removed Draft Element | Reason |
|---|---|
| `prototype_user`, `prototype_role`, `prototype_user_role`, `role_permission` | Final design uses Oracle IAM and stores stable IAM subjects, not local ATP role tables. |
| Separate request detail, contact, site, and bank tables | Final phase-one request model is flattened into `SUPPLIER_REQUEST`. |
| Separate validation, duplicate, and risk result tables | Final design consolidates deterministic results into `REQUEST_ASSESSMENT`. |
| Separate `reviewer_risk_adjustment` table | Final table set keeps one active Reviewer adjustment on `REQUEST_ASSESSMENT` and preserves each change in `ACTION_HISTORY`. |
| JSON-valued Admin configuration | Later user correction requires human-readable configuration tables. Final code uses scalar `CONFIGURATION` for simple settings and structured risk, score-band, high-risk-country, tax, phrase, and BU/site mapping tables. |
| `/supplier-requests` endpoints | Final ORDS contract uses `/requests`. |
| `/risky-countries` endpoints | Final ORDS contract uses `/high-risk-countries`. |

## Risk Model

The deterministic score follows the finalized formula:

```text
Risk score = active deterministic risk rules, with all active rule weights totaling 100.
```

Admin configuration updates are rejected if active risk weights do not total exactly 100. Gemini does not change this score by itself; the Reviewer adjustment endpoint can add `0`, `3`, `5`, or `10` points to the stored deterministic score, capped at 100.

## JSON Note

The database still uses JSON columns for generated assessment evidence such as validation results, duplicate matches, and risk factors. Admin-maintained business configuration does not use JSON-valued rows.

## Content Validation

- No Mermaid diagrams are used.
- No ASCII diagrams are used.
- Markdown tables and code fences are parser-compatible.
