# Requirements: Supplier Onboarding, Duplicate Detection & Risk Scoring

## Intent Analysis Summary

### User Request

Build a supplier onboarding solution based on the discovery transcript for a global manufacturing and services organization. The solution should standardize new supplier requests, detect possible duplicate suppliers, score supplier risk, provide AI-generated explanations and recommended actions, and submit approved suppliers to Oracle Fusion ERP through the Oracle integration stack.

### Request Type

New project.

### Scope Estimate

System-wide, cross-system implementation spanning:

- Oracle Visual Builder user interface
- Oracle ATP staging and request database
- ORDS REST APIs
- Oracle Integration Cloud integrations
- Oracle Fusion ERP supplier master integration
- Gemini-based AI explanation capability
- Duplicate detection, risk scoring, review workflow, dashboards, audit/logging, and testing

### Complexity Estimate

Complex. The project includes multiple personas, stateful request workflow, business validation, explainable matching logic, risk scoring, sensitive bank data handling, attachment upload, ERP integration, retry/error handling, and AI-generated advisory output.

### Delivery Target and Scope Tension

The answered verification file selects a production-ready implementation target. The same answers also accept phase-one local actor/role context instead of full enterprise identity wiring, skip the AIDLC security extension, and skip the AIDLC resiliency extension. These requirements therefore define a production-oriented functional solution with explicit phase-one constraints and go-live risks. Before real production deployment, identity, security, resiliency, monitoring, backup/recovery, and deployment controls must be revisited and approved.

## Source Inputs

- `Customer Requirement Discovery Call Transcript-Integration ERP.pdf`
- `aidlc-docs/inception/requirements/requirement-verification-questions.md`

## Stakeholders and Personas

## Prototype UI Role Mapping

The discovery transcript and AIDLC analysis identify several stakeholder concerns. For the current Visual Builder supervisor demo, these concerns are represented by three selectable UI roles:

| Prototype UI Role | Includes |
|---|---|
| Requester | Business users who create, correct, submit, and track supplier onboarding requests. |
| Reviewer | Procurement/master-data review, finance checks, compliance/risk checks, and supplier data governance concerns. |
| Admin | IT/support users who inspect OIC/Fusion logs, diagnose technical failures, view payload references/responses/errors/retry counts, and retry eligible failed requests. |

Finance, Compliance, and Supplier Data Governance remain valid business concerns, but they are represented through Reviewer. IT/Support is represented through Admin.

### Requester

Business user who submits new supplier onboarding requests and tracks request status.

### Procurement or Master Data Reviewer

User who reviews submitted supplier requests, validates data quality, reviews duplicate warnings, and approves, rejects, or requests correction.

### Finance User Concern (Merged Into Reviewer UI)

User concerned with supplier payment risk, supplier sites, bank country mismatch, duplicate bank accounts, Fusion supplier creation status, and downstream payables/reporting quality.

### Compliance or Risk Reviewer Concern (Merged Into Reviewer UI)

User who reviews supplier risk factors, high-risk country flags, missing tax information, missing documentation, vague business justification, duplicate indicators, and AI-generated recommendations.

### Admin or Support User

User who monitors OIC/Fusion integration logs, payload references, technical errors, retry count, response details, and failed supplier creation attempts.

## Business Objectives

- Replace email, spreadsheet, and service desk driven supplier onboarding with a controlled application.
- Improve supplier data quality before supplier creation.
- Reduce duplicate supplier creation in Oracle Fusion ERP.
- Make supplier request status visible to requesters, reviewers, and admins, with finance/compliance/governance concerns handled through Reviewer and IT/support concerns handled through Admin.
- Identify and explain supplier risk before approval.
- Ensure AI output remains advisory and human reviewers retain final decision authority.
- Integrate approved supplier creation with Oracle Fusion ERP through OIC.
- Support success, duplicate-risk, high-risk, validation-failure, and integration-failure demo and test scenarios.

## In Scope

- New supplier onboarding request lifecycle.
- Oracle Visual Builder application for request creation, review, dashboards, OIC/Fusion log visibility, retry visibility, and diagnostic/test views under the three-role prototype model.
- Oracle ATP staging database.
- ORDS REST API layer between Visual Builder and ATP.
- OIC integration for supplier creation in Fusion where access is available.
- Periodic OIC supplier master synchronization from Fusion into ATP for duplicate checking.
- Gemini-based AI risk and duplicate explanation.
- Business validation and risk scoring.
- Admin-managed risky-country list seeded with default risky-country entries for the prototype.
- Gemini business-justification risk review with human Reviewer confirmation before any added risk points are applied.
- Explainable duplicate detection with lightweight fuzzy matching.
- Actual supplier document attachment upload.
- One supplier with one supplier site.
- Reviewer approval, rejection, duplicate marking, and correction workflow.
- Integration logging, response tracking, and retry handling.
- Property-based testing for business logic and data transformations.

## Out of Scope

- Supplier merge functionality.
- Updating existing supplier master records.
- Full enterprise approval workflow engine.
- External sanctions screening or third-party supplier risk APIs.
- Email notifications.
- Multiple supplier sites in phase one.
- AI-driven approval, rejection, or supplier creation.
- AI-driven automatic risk-score mutation without Reviewer confirmation.
- ATP as the final supplier master source of truth.
- Production identity integration in phase one.
- AIDLC security extension enforcement.
- AIDLC resiliency extension enforcement.

## Assumptions

- Oracle Fusion ERP is the system of record for supplier master data.
- ATP is used for staging, validation, review, tracking, and logs only.
- OIC is the required integration layer for Fusion supplier create and supplier master sync.
- If Fusion access is unavailable during implementation or testing, mock responses may be used while preserving realistic OIC/Fusion payload structure.
- Gemini is the selected AI provider for explanations and recommendations.
- Local actor subject/role context is acceptable for phase one; production Oracle IAM integration is a known limitation.
- One supplier site is sufficient for phase one.
- Attachments are required for phase one.
- Security and resiliency extension rules are not enforced as AIDLC blocking constraints, but transcript-specific security and reliability requirements remain in scope.

## Functional Requirements

### Supplier Request Creation

| ID | Requirement |
|---|---|
| FR-001 | The system shall allow requesters to create new supplier onboarding requests in Oracle Visual Builder. |
| FR-002 | The request form shall guide users to provide required supplier information. |
| FR-003 | The system shall support saving supplier requests to ATP through ORDS APIs. |
| FR-004 | The UI shall not directly create suppliers in Oracle Fusion ERP. |
| FR-005 | Requesters shall be able to view the status of their own requests. |
| FR-006 | Requesters shall be able to correct and resubmit requests when a reviewer requests correction. |

### Supplier Request Data Capture

| ID | Requirement |
|---|---|
| FR-010 | The request shall capture supplier name. |
| FR-011 | The request shall capture supplier type. |
| FR-012 | The request shall capture supplier country. |
| FR-013 | The request shall capture supplier address. |
| FR-014 | The request shall capture contact person. |
| FR-015 | The request shall capture contact email. |
| FR-016 | The request shall capture phone number when available. |
| FR-017 | The request shall capture business unit. |
| FR-018 | The request shall capture requester identity. |
| FR-019 | The request shall capture business justification. |
| FR-020 | The request shall capture product or service category. |
| FR-021 | The request shall capture expected annual spend. |
| FR-022 | The request shall capture tax registration number where applicable. |
| FR-023 | The request shall capture bank information where available. |
| FR-024 | The request shall capture one supplier site. |
| FR-025 | The request shall support attachment upload for supplier documents. |
| FR-026 | The system shall capture metadata for uploaded supplier documents. |
| FR-027 | The system shall flag missing expected documents when applicable. |

### Request Status Lifecycle

| ID | Requirement |
|---|---|
| FR-030 | The system shall support Draft status. |
| FR-031 | The system shall support Submitted status. |
| FR-032 | The system shall support Validation Failed status. |
| FR-033 | The system shall support Under Review status. |
| FR-034 | The system shall support Approved status. |
| FR-035 | The system shall support Rejected status. |
| FR-036 | The system shall support Submitted to Fusion status. |
| FR-037 | The system shall support Created in Fusion status. |
| FR-038 | The system shall support Integration Failed status. |
| FR-039 | The system shall distinguish business validation failures from technical integration failures. |

### Validation

| ID | Requirement |
|---|---|
| FR-050 | The system shall validate mandatory supplier name. |
| FR-051 | The system shall validate mandatory country. |
| FR-052 | The system shall validate mandatory supplier type. |
| FR-053 | The system shall validate mandatory business unit. |
| FR-054 | The system shall validate mandatory contact email. |
| FR-055 | The system shall validate mandatory address. |
| FR-056 | The system shall validate tax registration where applicable. |
| FR-057 | The system shall flag missing tax registration as a risk factor where tax registration is expected. |
| FR-058 | The system shall flag bank country mismatch when bank country differs from supplier country. |
| FR-059 | The system shall flag vague business justification for Gemini review and Reviewer-confirmed risk adjustment. |
| FR-060 | The system shall flag incomplete address as a validation or risk issue. |
| FR-061 | The system shall validate intended business unit or supplier site mapping before Fusion submission. |

### Duplicate Detection

| ID | Requirement |
|---|---|
| FR-070 | The system shall compare new supplier requests against existing supplier master data stored in ATP. |
| FR-071 | The system shall detect exact tax registration number matches. |
| FR-072 | The system shall treat tax registration match as a strong duplicate indicator. |
| FR-073 | The system shall detect exact bank account matches where bank account data is available. |
| FR-074 | The system shall treat bank account match as a serious warning. |
| FR-075 | The system shall compare supplier name similarity using lightweight fuzzy matching. |
| FR-076 | Supplier name matching shall normalize case, punctuation, common suffixes, and common abbreviations such as Ltd, Limited, and Inc. |
| FR-077 | The system shall consider country in duplicate detection. |
| FR-078 | The system shall consider address similarity where available. |
| FR-079 | The system shall consider email domain where available. |
| FR-080 | The system shall consider phone number where available. |
| FR-081 | The system shall calculate duplicate risk from the combination of matched fields. |
| FR-082 | The system shall show possible duplicate supplier matches on the request detail page. |
| FR-083 | The system shall show the fields or reasons that caused each possible duplicate match. |
| FR-084 | Duplicate detection shall run after submission before approval. |
| FR-085 | Real-time duplicate hints during data entry are desirable but not required for phase one. |

### Risk Scoring

| ID | Requirement |
|---|---|
| FR-090 | The system shall calculate an explainable supplier risk score. |
| FR-091 | The system shall classify risk as Low, Medium, High, or Critical. |
| FR-092 | Missing tax registration shall increase risk where tax registration is applicable. |
| FR-093 | Missing or incomplete bank details shall increase risk where bank details are expected. |
| FR-094 | Bank country mismatch shall increase risk. |
| FR-095 | High-risk supplier country shall increase risk based on an Admin-managed risky-country list seeded with default prototype entries. |
| FR-096 | Gemini shall review the business justification and flag whether the justification appears risky, vague, unsupported, or insufficient for onboarding. |
| FR-097 | Gemini justification risk shall not automatically change the risk score; a Reviewer must confirm the risk before extra points are applied. |
| FR-098 | Strong duplicate indicators such as same tax ID or same bank account shall increase risk materially. |
| FR-099 | The reviewer shall be able to see the reasons behind the risk level. |
| FR-100 | Reviewers shall be able to add `+3`, `+5`, or `+10` justification-risk points after reading the business justification and Gemini's advisory review. |
| FR-101 | The final displayed risk score shall combine the previously calculated deterministic score with the Reviewer-approved justification-risk adjustment, capped at the configured maximum score. |

### AI Explanation

| ID | Requirement |
|---|---|
| FR-110 | The system shall use Gemini to generate supplier risk explanations and recommended actions. |
| FR-111 | AI output shall summarize duplicate risk in plain business language. |
| FR-112 | AI output shall summarize missing or incomplete information. |
| FR-113 | AI output shall explain why a supplier is Low, Medium, High, or Critical risk. |
| FR-114 | AI output shall recommend reviewer actions such as request tax certificate, confirm bank details, or verify existing supplier. |
| FR-115 | AI shall not approve supplier requests. |
| FR-116 | AI shall not reject supplier requests. |
| FR-117 | AI shall not create suppliers in Fusion. |
| FR-118 | AI-generated summary and timestamp shall be stored with the supplier request in ATP. |
| FR-119 | Users shall be able to regenerate the AI summary when supplier request data changes. |
| FR-120 | AI output shall include business-justification risk metadata, including whether risk was flagged, rationale, and suggested severity or points for Reviewer consideration. |

### Review Workflow

| ID | Requirement |
|---|---|
| FR-130 | Reviewers shall be able to view submitted supplier requests. |
| FR-131 | Reviewers shall be able to approve a request. |
| FR-132 | Reviewers shall be able to reject a request. |
| FR-133 | Reviewers shall be able to mark a request as duplicate. |
| FR-134 | Reviewers shall be able to request correction. |
| FR-135 | Duplicate or high-risk requests shall require manual review before Fusion submission. |
| FR-136 | The system shall not automatically create a supplier solely because a request was submitted. |
| FR-137 | If a request is marked duplicate, the reviewer shall be able to reference the existing supplier to use instead. |
| FR-138 | Requesters shall be able to see the existing supplier reference when a request is rejected or closed as duplicate. |
| FR-139 | Reviewers shall be able to apply exactly one active justification-risk adjustment per request version when Gemini flags the business justification as risky. |
| FR-140 | Reviewer-applied justification-risk adjustments shall be auditable and shall not be overwritten by regenerated AI summaries. |

### Dashboard and Search

| ID | Requirement |
|---|---|
| FR-150 | The system shall provide a requester dashboard for request status tracking. |
| FR-151 | The system shall provide a reviewer dashboard for pending and under-review requests. |
| FR-152 | The dashboard shall show high-risk requests. |
| FR-153 | The dashboard shall show duplicate-risk requests. |
| FR-154 | The dashboard shall show recently created suppliers. |
| FR-155 | The dashboard shall show requests failed during Fusion creation. |
| FR-156 | Users shall be able to filter by business unit. |
| FR-157 | Users shall be able to filter by country. |
| FR-158 | Users shall be able to filter by supplier type. |
| FR-159 | Users shall be able to filter by requester. |
| FR-160 | Users shall be able to filter by request status. |
| FR-161 | Users shall be able to filter by risk level. |
| FR-162 | Users shall be able to filter by duplicate risk. |

### Fusion Integration Through OIC

| ID | Requirement |
|---|---|
| FR-180 | OIC shall handle supplier creation integration with Oracle Fusion ERP. |
| FR-181 | Approved supplier requests shall be transformed into Fusion-compatible supplier payloads. |
| FR-182 | The system shall submit approved supplier requests to Fusion through OIC. |
| FR-183 | Fusion response data shall be captured in ATP. |
| FR-184 | Successful supplier creation shall store the Fusion supplier number. |
| FR-185 | Fusion rejection or failure messages shall be visible to reviewers and admins, with detailed support diagnostics exposed to Admin. |
| FR-186 | Mock Fusion responses may be used when Fusion access is unavailable, while preserving realistic payload patterns. |
| FR-187 | The system shall not bypass OIC for Fusion supplier creation. |

### Supplier Master Sync

| ID | Requirement |
|---|---|
| FR-200 | OIC shall periodically synchronize existing Fusion supplier master reference data into ATP. |
| FR-201 | Synced supplier reference data shall support duplicate checking. |
| FR-202 | Duplicate detection shall compare new requests against existing supplier master reference data, not only against new requests. |
| FR-203 | Sync design shall include fields needed for duplicate detection, including name, tax ID, country, address, email domain, phone, bank reference, and supplier site where available. |

### Integration Logs and Retry

| ID | Requirement |
|---|---|
| FR-220 | The system shall store OIC instance ID for integration attempts. |
| FR-221 | The system shall store request payload reference. |
| FR-222 | The system shall store response details. |
| FR-223 | The system shall store error message. |
| FR-224 | The system shall store integration timestamp. |
| FR-225 | The system shall store retry count. |
| FR-226 | Admin users shall be able to view integration logs, including OIC instance ID, request payload reference, response, error message, timestamp, and retry count. |
| FR-227 | Admin users shall be able to retry eligible technical integration failures. |
| FR-228 | Corrected business validation failures may be resubmitted. |
| FR-229 | Retry shall not bypass duplicate-risk or high-risk review. |

## Non-Functional Requirements

### Security and Privacy

| ID | Requirement |
|---|---|
| NFR-SEC-001 | Bank data shall be handled carefully and not exposed unnecessarily. |
| NFR-SEC-002 | Full bank account numbers shall not be displayed in normal UI views. |
| NFR-SEC-003 | When bank account display is needed, only masked values such as last four digits shall be shown. |
| NFR-SEC-004 | The design shall explain how sensitive bank information would be protected in a real implementation. |
| NFR-SEC-005 | Phase-one access control shall use local actor subject/role context through ORDS/ATP checks. |
| NFR-SEC-006 | Production identity integration shall be documented as a limitation of phase one. |

### Reliability and Error Handling

| ID | Requirement |
|---|---|
| NFR-REL-001 | The system shall distinguish business validation errors from technical integration errors. |
| NFR-REL-002 | Technical failures shall be retryable by authorized admins in the prototype. |
| NFR-REL-003 | Fusion or OIC failure details shall be captured for support diagnosis. |
| NFR-REL-004 | Request status shall remain understandable to business users even when integration fails. |
| NFR-REL-005 | The system shall avoid losing request state during validation, review, approval, or integration transitions. |

### Usability

| ID | Requirement |
|---|---|
| NFR-UX-001 | Request submission shall be simple enough for business users. |
| NFR-UX-002 | Review screens shall show risk, duplicate matches, missing data, and recommended actions clearly. |
| NFR-UX-003 | Users shall not need to interpret raw integration errors unless they are admins handling support diagnostics. |
| NFR-UX-004 | AI summaries shall be short, plain-language, and business-readable. |

### Explainability and Auditability

| ID | Requirement |
|---|---|
| NFR-AUD-001 | Duplicate detection decisions shall show matching fields and reasons. |
| NFR-AUD-002 | Risk score shall show contributing factors. |
| NFR-AUD-003 | AI-generated summaries shall be stored with timestamp. |
| NFR-AUD-004 | Reviewer decisions shall be auditable. |
| NFR-AUD-005 | Integration attempts shall be auditable. |

### Performance and Volume

| ID | Requirement |
|---|---|
| NFR-PERF-001 | The prototype shall support at least a few hundred existing supplier records. |
| NFR-PERF-002 | The prototype shall support 50 to 100 supplier requests. |
| NFR-PERF-003 | The design shall not hardcode logic to a tiny fixed dataset. |
| NFR-PERF-004 | Duplicate detection should remain responsive for expected prototype volumes. |

### Testing

| ID | Requirement |
|---|---|
| NFR-TEST-001 | Property-based testing shall be enforced for business logic and data transformations. |
| NFR-TEST-002 | Duplicate detection shall include example-based tests and property-based tests. |
| NFR-TEST-003 | Risk scoring shall include example-based tests and property-based tests. |
| NFR-TEST-004 | Payload transformation logic shall include property-based tests where round-trip or invariant properties are identifiable. |
| NFR-TEST-005 | UI and integration flows shall include scenario tests for success, duplicate-risk, high-risk, validation-failure, and integration-failure cases. |

## Data Requirements

### Primary Entities

- Supplier request
- Supplier site
- Supplier contact
- Supplier bank information
- Supplier document attachment
- Existing supplier master reference
- Validation result
- Duplicate match
- Risk score
- AI summary
- Review decision
- Integration log
- Fusion response
- Retry event

### Sample Data Requirements

The implementation shall include or support test data for:

- Clean new supplier
- Duplicate by exact tax registration number
- Duplicate by similar supplier name
- Missing tax registration
- Bank country mismatch
- Incomplete address
- Same bank account as an existing supplier
- Vague business justification with high expected spend
- Gemini-flagged risky business justification where the Reviewer applies `+3`, `+5`, or `+10`
- Seeded risky-country list that Admin can edit during the prototype
- Fusion creation failure caused by missing site or invalid business unit mapping

## Business Rules

| ID | Rule |
|---|---|
| BR-001 | Supplier creation in Fusion requires reviewer approval. |
| BR-002 | High-risk supplier requests require manual review. |
| BR-003 | Duplicate-risk supplier requests require manual review. |
| BR-004 | Same tax registration number is a strong duplicate indicator. |
| BR-005 | Same bank account is a serious warning and may indicate critical duplicate or compliance risk. |
| BR-006 | Missing tax registration increases risk where applicable. |
| BR-007 | Bank country mismatch increases risk. |
| BR-008 | Vague or risky business justification can increase risk only after a Reviewer confirms Gemini's advisory finding and selects `+3`, `+5`, or `+10`. |
| BR-009 | AI recommendations are advisory only and never mutate workflow state or numeric risk score by themselves. |
| BR-010 | Retry may be used for technical failures but shall not bypass business review. |
| BR-011 | Admin users can maintain the active risky-country list; seeded prototype countries are provided but can be activated, deactivated, added, or updated. |
| BR-012 | Reviewer justification-risk adjustments are added to the previously calculated deterministic score and capped at the configured maximum score for final risk-level classification. |

## Integration Requirements

### Visual Builder to ATP

- Visual Builder shall use ORDS APIs for supplier request create, read, update, submit, review, dashboard, duplicate match, risk score, AI summary, attachment, and integration log operations.

### ATP to Gemini

- The system shall send supplier request context, validation results, risk factors, and duplicate reasons to Gemini for explanation generation.
- The system shall store Gemini output, business-justification risk metadata, and timestamp in ATP.

### ATP to OIC

- Approved supplier request data shall be made available to OIC for Fusion supplier creation.
- Integration status and responses shall be written back to ATP.

### OIC to Fusion

- OIC shall transform approved requests into Fusion supplier payloads.
- OIC shall call Fusion supplier-related APIs or processes when access is available.
- OIC shall periodically synchronize existing supplier master reference data from Fusion to ATP.

## Acceptance Criteria

### End-to-End Success Scenario

- A requester submits a complete supplier request.
- Validation passes.
- Duplicate detection returns no serious duplicate risk.
- Risk score is Low or acceptable for approval.
- AI summary explains the risk and recommended action.
- Reviewer approves the request.
- OIC submits the request to Fusion.
- Fusion returns a supplier number.
- The request status becomes Created in Fusion.
- Requester can see the final status and supplier number.

### Duplicate-Risk Scenario

- A requester submits a supplier similar to an existing supplier.
- Duplicate detection identifies possible matches.
- The request detail page shows match reasons.
- AI explains why the request may be duplicate.
- Reviewer can reject or mark duplicate and reference the existing supplier.

### High-Risk Scenario

- A supplier request contains missing tax registration, bank country mismatch, vague justification, high expected spend, or high-risk country.
- Risk score becomes Medium, High, or Critical depending on configured rules.
- AI explains the risk and recommends follow-up actions.
- Request cannot be submitted to Fusion without manual review.

### Integration-Failure Scenario

- An approved request is submitted to Fusion through OIC.
- Fusion or OIC returns an error.
- The system stores integration log details.
- The request status becomes Integration Failed.
- Support user can view error details and retry when appropriate.

## Known Limitations and Risks

- Production-ready delivery was selected, but phase-one role handling uses application-level simulation, not production identity integration.
- Security extension rules are skipped, despite sensitive bank data being in scope.
- Resiliency extension rules are skipped, despite integration retry and error-handling needs.
- Gemini integration availability must be confirmed during design or implementation.
- Real Fusion access may not be available; mock responses may be required.
- Exact Fusion supplier API payload shape must be validated against the customer's Fusion environment.
- One supplier site is implemented in phase one; multi-site supplier complexity is deferred.

## Extension Compliance Summary

| Extension | Status | Requirements Impact |
|---|---|---|
| Security Baseline | Disabled per answered questions | Transcript-specific security requirements remain included: bank masking, sensitive data care, and phase-one auth limitation documentation. |
| Resiliency Baseline | Disabled per answered questions | Transcript-specific reliability requirements remain included: integration logs, retry count, visible failures, and business vs technical error separation. |
| Property-Based Testing | Enabled | PBT requirements are included for duplicate detection, risk scoring, and data transformation logic. |

## Next Stage Recommendation

User Stories should execute next because the project contains multiple personas, business workflows, reviewer decisions, dashboard needs, integration failure handling, and user-visible status changes.
