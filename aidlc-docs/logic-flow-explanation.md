# Logic Flow Explanation: Supplier Onboarding Portal

## Purpose

This document explains how the major project logic works for the Oracle Visual Builder supplier onboarding prototype and the full AIDLC-designed implementation.

## Current Prototype Logic

The current Visual Builder prototype demonstrates the workflow, roles, screens, validations, and decision points. The ATP/ORDS backend foundation now exists locally and is ready to be bound to Visual Builder service connections; OIC/Fusion/Gemini live cloud wiring remains future work.

| Logic Area | Current Prototype Behavior |
|---|---|
| Role selection | Uses role buttons to simulate Requester, Reviewer, and Admin. Finance, Compliance, and governance responsibilities are merged into Reviewer. IT Support responsibilities are represented by Admin. |
| Role-based visibility | Shows or hides tabs and actions depending on selected role. |
| Request form validation | Uses browser-native validation for required fields, email format, numeric spend, and optional numeric bank account. |
| Dashboard data | Uses static demo records to show success, duplicate, high-risk, finance review, and Fusion error scenarios. |
| Review/compare/retry actions | Demonstrates which role should see which action; backend API endpoints now exist locally for current-scope request, review, retry, log, risk, and country configuration flows. |
| Property-Based Tests tab | Demonstrates the testing requirement; automated property and example tests now exist under `tests/`. |

## Full Designed Logic

The full implementation is designed around Oracle Visual Builder, ORDS APIs, ATP-backed logic, OIC orchestration, Fusion ERP, and Gemini advisory explanations.

## 1. Role and Permission Logic

The role logic answers: "Who is allowed to do what?"

In the full design:

1. A user opens the Visual Builder application.
2. ORDS resolves a `UserContext`, including the actor subject ID and app-role context.
3. ORDS checks permissions before allowing protected actions.
4. Visual Builder displays only the actions returned as allowed.
5. ATP records actor subject IDs on request ownership, action history, document, assessment, and configuration update evidence.

Example:

| Role | Allowed Actions |
|---|---|
| Requester | Create draft, edit own request, submit, correct, resubmit, view own status |
| Reviewer | View submitted requests, review duplicate/risk/payment/compliance evidence, approve, reject, mark duplicate, and request correction |
| Admin | Inspect OIC/Fusion logs, view OIC instance ID, payload references, responses, errors, timestamps, retry counts, diagnostic/test evidence, and retry eligible technical failures |

Important: UI hiding is not enough for production. The real implementation must enforce the same rules through ORDS/ATP.

For the prototype, Finance, Compliance, and Supplier Data Governance responsibilities are merged into Reviewer. IT Support responsibilities are handled by Admin.

## 2. Request Lifecycle Logic

The request lifecycle controls the state of each supplier onboarding request.

Main status path:

1. `Draft`
2. `Submitted`
3. `Validation Failed` or `Under Review`
4. `Approved`, `Rejected`, `Duplicate`, or `Correction Requested`
5. `Submitted to Fusion`
6. `Created in Fusion` or `Integration Failed`

Key rule:

- Submission never creates a supplier directly in Fusion.
- Fusion creation only happens after human reviewer approval.
- Correction, resubmission, and retry do not bypass validation, duplicate checks, risk review, or approval.

## 3. Validation Logic

Validation answers: "Is the submitted supplier request complete enough to review or send to Fusion?"

The validation component checks:

- Supplier name is present.
- Supplier type is present.
- Country is present.
- Address is present and complete enough.
- Contact email is present and correctly formatted.
- Business unit is present.
- Requester is captured.
- Product or service category is captured.
- Expected annual spend is numeric and present.
- Tax registration is present where applicable.
- Supplier site or intended business unit is captured.
- Bank details are optional at initial request, but validated if provided.
- Bank country mismatch is flagged if bank country differs from supplier country.
- Expected documents are present where applicable.
- Business justification is not too vague.

Output:

- A `ValidationResult` is stored in ATP.
- Field-level findings are shown to requesters and reviewers.
- If blocking required data is missing, status becomes `Validation Failed`.

## 4. Duplicate Detection Logic

Duplicate detection answers: "Does this supplier look like one that already exists?"

Data source:

- Existing supplier master data is synchronized from Oracle Fusion ERP into ATP through OIC.
- Duplicate detection compares new requests against this Fusion-synced reference data, not only against new requests.

Matching factors:

| Factor | Meaning |
|---|---|
| Same tax registration | Strong duplicate indicator |
| Same bank account or protected bank reference | Serious duplicate/payment risk warning |
| Similar supplier name | Fuzzy duplicate indicator |
| Same country | Supporting evidence |
| Similar address | Supporting evidence |
| Same email domain | Supporting evidence |
| Same phone number | Supporting evidence |

Name normalization:

- Convert to consistent case.
- Remove punctuation.
- Normalize common suffixes like `Ltd`, `Limited`, `Inc`, and similar legal endings.
- Compare normalized names for similarity.

Example:

`ABC Technologies Ltd.` may be compared against `ABC Tech Limited`.

Output:

- A `DuplicateMatchResult` stores candidate suppliers, match factors, and reasons.
- The system flags possible duplicates but does not automatically reject them.
- A human reviewer decides whether to approve, reject, mark duplicate, or request correction.

## 5. Risk Scoring Logic

Risk scoring answers: "How risky is this supplier request and why?"

Inputs:

- Supplier request fields
- Validation findings
- Duplicate match results
- Bank and tax indicators
- Expected annual spend
- Country risk rules
- Business justification quality

Risk factors include:

- Missing tax registration where applicable
- Missing or incomplete bank details where expected
- Bank country mismatch
- High-risk supplier country
- Vague business justification
- High expected annual spend with weak justification
- Same tax registration as an existing supplier
- Same bank account or bank reference as an existing supplier
- Strong duplicate indicators

Output:

- A `RiskScoreResult` with level: `Low`, `Medium`, `High`, or `Critical`.
- Contributing factors are stored and shown to reviewers.

Important: The exact numeric weights and thresholds are not finalized yet. The AIDLC docs explicitly defer detailed scoring weights to Functional Design and Construction.

## 6. Gemini AI Explanation Logic

AI explanation answers: "Can the system explain the risk and duplicate findings in plain business language?"

Flow:

1. ATP/ORDS gathers request data, validation findings, duplicate reasons, and risk factors.
2. OIC sends this context to Gemini.
3. Gemini returns a short advisory summary and recommended follow-up actions.
4. The result is stored in ATP with timestamp and metadata.
5. Visual Builder displays the latest summary.

Gemini can:

- Explain duplicate risk.
- Explain missing or incomplete information.
- Explain why the supplier is Low, Medium, High, or Critical risk.
- Recommend actions such as request tax certificate, confirm bank details, or verify an existing supplier.

Gemini cannot:

- Approve the request.
- Reject the request.
- Create the supplier in Fusion.
- Override reviewer decisions.

## 7. Review Decision Logic

Review logic answers: "What does the human reviewer decide after seeing the evidence?"

Reviewer actions:

- Approve
- Reject
- Mark duplicate
- Request correction

Rules:

- High-risk requests require manual review.
- Duplicate-risk requests require manual review.
- If a request is marked duplicate, the reviewer can reference the existing supplier to use instead.
- If correction is requested, the requester updates the same request and resubmits it.
- Resubmission reruns validation, duplicate detection, risk scoring, and AI explanation.

Output:

- Review decision is stored in ATP.
- Audit records capture decision type, reason, user, and timestamp.
- Workflow status changes accordingly.

## 8. Fusion Creation Logic Through OIC

Fusion creation answers: "How does an approved request become a real supplier?"

Flow:

1. Reviewer approves the request.
2. Supplier Creation Integration Service selects the approved request.
3. OIC transforms ATP request data into a Fusion-compatible supplier payload.
4. OIC calls Oracle Fusion ERP.
5. Fusion returns success or failure.
6. ATP stores the Fusion response.

Success result:

- Fusion supplier number is stored.
- Request status becomes `Created in Fusion`.
- Requester and reviewer can see the final status. Admin can inspect related integration logs and retry context.

Failure result:

- Request status becomes `Integration Failed`.
- Error details, response details, payload reference, OIC instance ID, timestamp, and retry count are stored.
- Admin can diagnose the failure in the prototype.

## 9. Integration Log and Retry Logic

Retry logic answers: "Can the admin recover from a technical integration failure in the prototype?"

Stored log fields:

- OIC instance ID
- Payload reference
- Fusion response details
- Error message
- Timestamp
- Retry count
- Retry eligibility

Retry is allowed only for technical failures such as:

- OIC timeout
- Fusion API temporarily unavailable
- Network or integration service issue

Retry is not allowed to bypass:

- Missing business data
- Duplicate-risk review
- High-risk review
- Reviewer approval
- Validation failures requiring requester correction

## 10. Audit Logic

Audit logic answers: "Can we reconstruct what happened?"

The audit component records:

- Status changes
- Validation outcomes
- Duplicate match results
- Risk score outputs
- AI summary generation
- Review decisions
- Fusion submission attempts
- Integration responses and errors
- Retry attempts

This protects traceability for requesters, reviewers, and admins. Finance and compliance concerns are included under Reviewer; IT support concerns are handled by Admin.

## 11. Property-Based Testing Logic

Property-Based Testing verifies that business logic holds across many generated inputs, not only hand-picked examples.

Expected PBT areas:

- Duplicate detection normalization and matching invariants
- Risk scoring score bounds and classification consistency
- Fusion payload transformation invariants

Examples:

- Normalizing a supplier name twice should produce the same normalized name.
- Risk score should never fall outside its allowed numeric range once ranges are defined.
- Adding a serious duplicate factor should not lower the supplier risk level.
- Payload transformation should preserve required supplier identity fields.

Property-Based Testing is valid for engineering quality, but it is not a requester or business-reviewer workflow. In the prototype it is exposed under Admin as a diagnostic/testing area.

## Supervisor Summary

The solution logic works as a controlled supplier onboarding pipeline:

1. Requester captures supplier data.
2. System validates completeness.
3. System checks for duplicates against Fusion-synced supplier master data.
4. System calculates explainable risk.
5. Gemini explains the findings but does not decide.
6. Human reviewer approves, rejects, marks duplicate, or requests correction.
7. Approved suppliers are submitted to Fusion through OIC.
8. Admin handles technical failures through logs and controlled retry in the prototype.
9. Audit and tests keep the process traceable and reliable.
