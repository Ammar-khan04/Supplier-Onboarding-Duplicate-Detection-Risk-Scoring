# Personas

## Persona Map

## Simplified Prototype UI Role Mapping

The persona map preserves the original business stakeholder concerns from the transcript. In the current Visual Builder prototype, these concerns are simplified into three selectable UI roles:

| Prototype UI Role | Mapped Personas |
|---|---|
| Requester | P-001 Business Requester |
| Reviewer | P-002 Procurement / Master Data Reviewer, P-003 Finance Concern, P-004 Compliance / Risk Concern, and P-006 Supplier Data Governance Concern |
| Admin | P-005 IT / Support Concern |

P-007 Internal System Actor remains non-human backend/system behavior and is not a UI role.

| Persona ID | Persona | Primary Goals | Related Stories |
|---|---|---|---|
| P-001 | Business Requester | Submit supplier requests, correct missing data, track status | US-001, US-002, US-003, US-004, US-005, US-016 |
| P-002 | Procurement / Master Data Reviewer | Review requests, assess duplicates, approve/reject/request correction | US-012, US-013, US-014, US-015, US-016 |
| P-003 | Finance Concern (Merged into Reviewer UI) | Understand payment-related risk and Fusion creation outcomes | US-017, US-020, US-021, US-022 |
| P-004 | Compliance / Risk Concern (Merged into Reviewer UI) | Review risk factors, duplicate indicators, and AI recommendations | US-009, US-010, US-011, US-018, US-019 |
| P-005 | Admin / IT Support | Monitor integration logs, diagnose failures, retry eligible failures | US-022, US-023, US-026 |
| P-006 | Supplier Data Governance Concern (Merged into Reviewer UI) | Maintain data quality, prevent duplicates, preserve supplier master integrity | US-007, US-008, US-013, US-015, US-024 |
| P-007 | Internal System Actor | Execute validation, scoring, matching, AI, ORDS, ATP, OIC, and Fusion integration behavior | US-006, US-007, US-008, US-009, US-010, US-020, US-021, US-022, US-025 |

## P-001: Business Requester

### Description

A business user from a business unit who needs a new supplier created for purchasing, services, or project work. Today this user may submit requests through email, spreadsheets, or service desk tickets.

### Goals

- Submit supplier requests through a guided application.
- Know what information is required.
- Upload required supplier documents.
- Track request status without emailing procurement or finance.
- Correct rejected or incomplete requests.
- Understand which existing supplier to use if the request is duplicate.

### Pain Points

- Current process is inconsistent and manual.
- Requesters do not know what happened to their supplier request.
- Vague or incomplete submissions cause back-and-forth delays.

### Success Criteria

- Requester can submit a complete request.
- Requester can see status changes.
- Requester can correct and resubmit when asked.
- Requester receives understandable duplicate or rejection information.

## P-002: Procurement / Master Data Reviewer

### Description

A reviewer responsible for validating supplier request quality before supplier creation in Oracle Fusion ERP.

### Goals

- Review submitted supplier requests efficiently.
- See missing data, validation issues, duplicate warnings, risk factors, and AI recommendations.
- Approve clean requests.
- Reject or mark duplicate requests.
- Request correction when data is incomplete.

### Pain Points

- Duplicate supplier creation causes downstream cleanup.
- Poor supplier data creates finance and reporting issues.
- Review decisions need clear supporting evidence.

### Success Criteria

- Reviewer can make a decision from one request detail page.
- Duplicate matches show reasons.
- Risk score is explainable.
- Fusion creation is only triggered after approval.

## P-003: Finance Concern (Merged into Reviewer UI)

### Description

A finance shared services user concerned with supplier payment accuracy, supplier sites, bank data, Fusion creation failures, and payables reporting.

### Goals

- Reduce payment and reporting issues caused by duplicate suppliers.
- Identify bank country mismatches and reused bank accounts.
- See Fusion supplier numbers after successful creation.
- Monitor requests stuck or failed during supplier creation.

### Pain Points

- Duplicate suppliers cause payments to wrong sites and messy spend analysis.
- Technical integration failures are hard to distinguish from bad business data.

### Success Criteria

- Payment-related warnings are visible.
- Fusion creation status is clear.
- Failed integrations show actionable information to reviewers handling support responsibilities.

## P-004: Compliance / Risk Concern (Merged into Reviewer UI)

### Description

A compliance or risk analyst responsible for reviewing supplier risk indicators before onboarding proceeds.

### Goals

- Identify risky suppliers early.
- Understand why a request is Low, Medium, High, or Critical risk.
- Review missing tax data, vague justification, high-risk country, bank mismatch, and duplicate indicators.
- Use AI explanations as decision support without giving AI decision authority.

### Pain Points

- Users may not understand risk scores without explanation.
- Missing tax, bank, and document information can slip through unnoticed.

### Success Criteria

- Risk score includes visible reasons.
- AI explains risk in plain business language.
- AI recommends actions without approving, rejecting, or creating suppliers.

## P-005: Admin / IT Support

### Description

An admin, IT, or integration support user who monitors OIC and Fusion supplier creation activity.

### Goals

- View OIC instance ID, payload references, responses, errors, timestamps, and retry counts.
- Distinguish business validation failures from technical failures.
- Retry eligible technical failures.
- Support realistic demo and operations visibility.

### Pain Points

- All failures are often treated as generic integration failures.
- Support users need enough detail to diagnose without exposing sensitive data broadly.

### Success Criteria

- Support dashboard shows technical failure details.
- Retry is controlled and auditable.
- Retry does not bypass review or duplicate/risk controls.

## P-006: Supplier Data Governance Concern (Merged into Reviewer UI)

### Description

A governance stakeholder responsible for supplier master data quality and duplicate prevention.

### Goals

- Prevent duplicate suppliers before Fusion creation.
- Ensure existing supplier master data is available for duplicate checking.
- See exact and fuzzy match reasons.
- Preserve Fusion as the source of truth.

### Pain Points

- Similar names, abbreviations, missing tax data, and repeated bank details create duplicate suppliers.
- Duplicate checks are weak if they only compare against new requests.

### Success Criteria

- Duplicate detection compares against Fusion-synced supplier master data in ATP.
- Matching reasons are explainable.
- Duplicate requests can reference the existing supplier.

## P-007: Internal System Actor

### Description

Non-human actor representing ATP, ORDS, OIC, Fusion, Gemini, duplicate detection, risk scoring, validation, and payload transformation components.

### Goals

- Persist supplier requests and workflow state.
- Validate supplier data.
- Detect duplicate risk.
- Score supplier risk.
- Generate advisory AI explanations.
- Submit approved suppliers to Fusion through OIC.
- Capture responses, errors, and logs.

### Success Criteria

- System behavior produces visible, auditable outcomes for human users.
- AI remains advisory.
- Fusion supplier creation only happens after approval.
- Testable logic has example-based and property-based coverage where applicable.
