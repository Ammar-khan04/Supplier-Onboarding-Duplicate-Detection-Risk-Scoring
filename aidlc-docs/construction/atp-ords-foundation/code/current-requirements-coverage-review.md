# Current Requirements Coverage Review

## Review Scope

This review checks the current UOW-002 ATP/ORDS Supplier Request Foundation against the active AIDLC requirements, user stories, functional design, finalized schema source, and Visual Builder-facing API contract.

## Verdict

| Area | Result |
|---|---|
| Current UOW-002 backend/database scope | Approved after final fix |
| Blocking requirement misses | None remaining |
| Final issue found during review | Reviewer justification-risk adjustment was documented and UI-facing, but missing from backend ORDS/package implementation |
| Final issue resolution | Implemented `POST /requests/{request_id}/justification-risk-adjustment`, `REQUEST_ASSESSMENT` adjustment fields, final score recalculation, and `ACTION_HISTORY` audit |

## Covered Requirements

| Requirement Area | Coverage Evidence |
|---|---|
| Request creation and edit | `/requests` create/update, `SUPPLIER_REQUEST`, role-aware ownership checks |
| Required supplier fields | `SUPPLIER_REQUEST` captures supplier name, type, country, address, contact, email, phone, business unit, requester, justification, category, spend, tax, bank metadata, and one site |
| Attachment metadata | `/requests/{request_id}/documents`, `REQUEST_DOCUMENT` latest metadata |
| Submit and validation | `/requests/{request_id}/submit`, `supplier_validation_pkg`, `REQUEST_ASSESSMENT.validation_results_json` |
| Duplicate foundation | Fusion reference cache tables and `REQUEST_ASSESSMENT.duplicate_matches_json` |
| Risk scoring foundation | `RISK_RULE_CONFIG`, `RISK_SCORE_BAND_CONFIG`, `HIGH_RISK_COUNTRY_CONFIG`, deterministic score, final score, and risk level |
| Admin risk weights | `/risk-rules`, active weights must total exactly 100 |
| Admin risky-country maintenance | `/high-risk-countries`, seeded entries plus activate/deactivate/update |
| Gemini history | `/requests/{request_id}/ai-regeneration`, OIC-style result write, append-only `AI_ASSESSMENT` |
| Reviewer justification-risk adjustment | `/requests/{request_id}/justification-risk-adjustment`, one active adjustment on latest `REQUEST_ASSESSMENT`, audited in `ACTION_HISTORY` |
| Reviewer decisions | `/requests/{request_id}/review`, approve, reject, request correction, and mark duplicate |
| Correction flow | `CORRECTION_REQUIRED`, requester `EDIT` allowed action, resubmit support |
| Fusion create queue | Approved requests create `FUSION_CREATE` `INTEGRATION_JOB` rows |
| OIC job handling | `/integration-jobs`, claim/result, success/failure handling, retry lineage |
| Supplier reference sync foundation | `/supplier-reference/batch`, Fusion supplier/tax/site/bank reference tables |
| Admin logs | `/integration-logs`, safe integration diagnostics |
| Sensitive bank handling | Safe views expose last four only; fingerprints/raw bank data are not returned in normal list/detail responses |
| Local runtime | Docker Compose Oracle Database Free and ORDS at `http://localhost:8080/ords/supplier-onboarding/v1/` |

## Verification Evidence

| Check | Latest Result |
|---|---|
| Python script syntax | Passed for `test-local-ords-endpoints.py` and `seed-demo-data-via-ords.py` |
| ORDS smoke check | Passed for base, health, requests, discovered request detail, risk rules, high-risk countries, integration logs, and integration jobs |
| Live ORDS persistence test | Passed with token `T1784715944` |
| Live justification adjustment proof | `ADJUSTMENT_POINTS=5`, `JUSTIFICATION_ACTION_ROWS=1` |
| Demo seed through ORDS | Passed with token `DEMO1784715959` |
| Demo justification adjustment proof | `DEMO_ADJUSTMENT_POINTS=5` |
| Database object health | `INVALID_OBJECTS=0` |
| Current application table count | `TABLE_COUNT=17` |
| Assessment adjustment columns | `ADJUSTMENT_COLUMNS=5` |
| Pytest suite execution | Passed in workspace `.venv`: 24 tests passed, including 11 property tests and 13 example API tests |

## Deferred By Design

| Deferred Area | Reason |
|---|---|
| Full duplicate/risk algorithm expansion | Belongs to later duplicate and risk logic units beyond the ATP/ORDS foundation |
| Real Gemini prompt orchestration | UOW-002 stores AI jobs/results; OIC/Gemini orchestration is a later integration unit |
| Real Fusion payload transformation | UOW-002 queues and records Fusion create jobs; final OIC/Fusion mapping is a later integration unit |
| Visual Builder live service binding | Backend endpoints are ready; live cloud binding is a later wiring/deployment activity |
| Production IAM/security/resiliency hardening | Phase one uses local actor subject/role request parameters as an IAM stand-in, and skipped AIDLC security/resiliency extensions by prior answers |
| Cloud ATP/ORDS migration | Local stack is verified; cloud deployment remains the next practical implementation step |

## Approval Conclusion

After the final justification-risk adjustment fix and verification run, the current UOW-002 Code Generation scope covers the active requirements assigned to this phase. Remaining items are intentionally future-stage or future-unit work, not missing UOW-002 blockers.

## Content Validation

- No Mermaid diagrams are used.
- No ASCII diagrams are used.
- Markdown tables are parser-compatible.
