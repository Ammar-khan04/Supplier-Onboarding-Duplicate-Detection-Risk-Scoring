# User Stories

## Story Generation Summary

Stories are organized by user journey, with personas mapped to each story. Acceptance criteria use Given/When/Then for workflow-oriented stories and checklist criteria for system/data stories. Requirement traceability IDs reference `aidlc-docs/inception/requirements/requirements.md`.

For the Visual Builder prototype, the UI exposes three selectable roles: `Requester`, `Reviewer`, and `Admin`. Finance, Compliance, and Supplier Data Governance story responsibilities are demonstrated through the merged Reviewer role. IT/Support responsibilities from the transcript are demonstrated through Admin.

## Epic 1: Supplier Request Intake and Status Tracking

### US-001: Create Supplier Request Draft

**As a** Business Requester  
**I want** to create a supplier request draft in the Visual Builder application  
**So that** I can provide supplier information through a controlled process instead of email or spreadsheets.

**Personas**: P-001  
**Traceability**: FR-001, FR-002, FR-003, FR-004, FR-010 through FR-024, NFR-UX-001

**Acceptance Criteria**

Given I am a requester  
When I open the supplier request form  
Then I can enter supplier name, supplier type, country, address, contact details, business unit, requester, justification, product/service category, expected annual spend, tax registration, bank information, and one supplier site.

Given I save the request before submission  
When the data is persisted  
Then the request is stored in ATP through ORDS and remains in Draft status.

Given the request is a draft  
When I review it later  
Then I can continue editing before submission.

### US-002: Upload Supplier Documents

**As a** Business Requester  
**I want** to upload supplier documents with the request  
**So that** reviewers can verify tax, registration, and supporting documentation.

**Personas**: P-001, P-004  
**Traceability**: FR-025, FR-026, FR-027, NFR-SEC-001, NFR-AUD-004

**Acceptance Criteria**

Given I am creating or editing a supplier request  
When I upload a document  
Then the system stores the attachment and captures document metadata.

Given expected documents are missing  
When the request is validated  
Then missing document indicators are visible to reviewers.

Given document metadata exists  
When a reviewer opens the request  
Then uploaded document names, types, and timestamps are visible without exposing unrelated sensitive data.

### US-003: Submit Supplier Request for Validation

**As a** Business Requester  
**I want** to submit my supplier request  
**So that** it can be validated, reviewed, and progressed toward supplier creation.

**Personas**: P-001  
**Traceability**: FR-030, FR-031, FR-032, FR-039, FR-050 through FR-061

**Acceptance Criteria**

Given my request is in Draft status  
When I submit it  
Then the system runs business validation before review.

Given required fields are missing  
When validation runs  
Then the request status becomes Validation Failed and the missing fields are shown.

Given validation passes  
When submission completes  
Then the request status becomes Submitted or Under Review.

### US-004: Track Supplier Request Status

**As a** Business Requester  
**I want** to view the lifecycle status of my supplier request  
**So that** I do not need to ask procurement, finance, or support for updates.

**Personas**: P-001  
**Traceability**: FR-005, FR-030 through FR-039, FR-150, NFR-REL-004, NFR-UX-003

**Acceptance Criteria**

Given I have submitted supplier requests  
When I open my dashboard  
Then I can see each request's current status.

Given a request has been created in Fusion  
When I view the request  
Then I can see the Fusion supplier number.

Given a request failed validation, was rejected, was marked duplicate, or failed integration  
When I view the request  
Then I can see a business-readable explanation of the status.

### US-005: Correct and Resubmit Request

**As a** Business Requester  
**I want** to correct a request when reviewers ask for changes  
**So that** I can fix missing or incorrect data without starting over.

**Personas**: P-001, P-002  
**Traceability**: FR-006, FR-134, FR-228, BR-010

**Acceptance Criteria**

Given a reviewer requests correction  
When I open the request  
Then I can see the correction reason.

Given I update the request data  
When I resubmit the request  
Then validation, duplicate detection, risk scoring, and review controls run again.

Given the previous issue was duplicate or high-risk related  
When I resubmit  
Then resubmission does not bypass manual review.

## Epic 2: Validation, Duplicate Detection, Risk Scoring, and AI Explanation

### US-006: Validate Supplier Request Data

**As the** Validation Service  
**I want** to identify business validation issues  
**So that** incomplete or invalid requests do not move forward unnoticed.

**Personas**: P-007, P-001, P-002  
**Traceability**: FR-039, FR-050 through FR-061, NFR-REL-001

**Acceptance Criteria**

- Validation checks mandatory supplier name, country, supplier type, business unit, contact email, address, applicable tax registration, bank country mismatch, vague justification, incomplete address, and supplier site/business unit mapping.
- Validation results are stored in ATP.
- Business validation failures are distinguishable from technical integration failures.
- Validation output is visible in business language to requester and reviewer personas as appropriate.

### US-007: Synchronize Existing Supplier Master Data

**As the** Supplier Master Sync Process  
**I want** to synchronize supplier reference data from Fusion into ATP  
**So that** duplicate detection compares new requests against existing supplier master data.

**Personas**: P-006, P-007  
**Traceability**: FR-070, FR-200, FR-201, FR-202, FR-203

**Acceptance Criteria**

- OIC periodically synchronizes existing Fusion supplier reference data into ATP.
- Synced data includes fields needed for duplicate detection where available: supplier name, tax ID, country, address, email domain, phone, bank reference, and site data.
- Duplicate detection uses synced supplier master data, not only newly submitted requests.
- Fusion remains the supplier master source of truth.

### US-008: Detect Potential Duplicate Suppliers

**As the** Duplicate Detection Service  
**I want** to identify possible duplicate suppliers using exact and lightweight fuzzy matching  
**So that** reviewers can prevent duplicate supplier creation before Fusion submission.

**Personas**: P-006, P-007, P-002  
**Traceability**: FR-070 through FR-085, BR-003, BR-004, BR-005, NFR-AUD-001, NFR-TEST-002

**Acceptance Criteria**

- Exact tax registration matches are treated as strong duplicate indicators.
- Exact bank account matches are treated as serious warnings.
- Supplier name matching normalizes case, punctuation, common suffixes, and abbreviations such as Ltd, Limited, and Inc.
- Country, address similarity, email domain, and phone are considered where available.
- Duplicate match records include matched supplier reference, match factors, and reasons.
- Duplicate detection runs after submission before approval.
- Duplicate detection logic is covered by example-based and property-based tests.

### US-009: Calculate Explainable Supplier Risk

**As the** Risk Scoring Service  
**I want** to calculate a risk level with visible reasons  
**So that** reviewers can understand and act on supplier risk.

**Personas**: P-004, P-007, P-002  
**Traceability**: FR-090 through FR-099, BR-002, BR-006, BR-007, BR-008, NFR-AUD-002, NFR-TEST-003

**Acceptance Criteria**

- Risk is classified as Low, Medium, High, or Critical.
- Missing tax registration increases risk where applicable.
- Missing or incomplete bank details increase risk where bank data is expected.
- Bank country mismatch increases risk.
- Admin-managed high-risk country rules increase deterministic risk.
- Gemini reviews the business justification and flags risky, vague, unsupported, or insufficient justification as advisory output.
- Reviewer-confirmed business-justification risk can add `+3`, `+5`, or `+10` to the previously calculated deterministic risk score.
- High expected spend increases deterministic risk according to the configured spend bands.
- Strong duplicate indicators materially increase risk.
- Risk scoring output includes contributing factors.
- Risk output distinguishes deterministic points from Reviewer-applied Gemini justification adjustment points.
- Risk scoring logic is covered by example-based and property-based tests.

### US-010: Generate AI Risk and Duplicate Explanation

**As the** Gemini Explanation Service  
**I want** to generate advisory summaries and recommended actions  
**So that** reviewers can understand risk and duplicate reasons in plain business language.

**Personas**: P-004, P-007, P-002  
**Traceability**: FR-110 through FR-118, BR-009, NFR-UX-004, NFR-AUD-003

**Acceptance Criteria**

- Gemini receives request context, validation results, duplicate factors, and risk factors.
- The generated summary explains risk and duplicate reasons in short business-readable language.
- The generated recommendation suggests actions such as requesting tax certificate, confirming bank details, or verifying an existing supplier.
- Gemini evaluates the business justification and returns whether it appears risky, why it appears risky, and suggested severity for Reviewer consideration.
- AI output is stored with timestamp in ATP.
- AI output never approves, rejects, creates a supplier, or directly changes numeric risk score.

### US-010A: Reviewer Applies Gemini Justification Risk

**As a** Reviewer handling compliance/risk checks  
**I want** to decide whether Gemini's business-justification risk finding should add risk points  
**So that** the final score reflects human judgment rather than AI-only scoring.

**Personas**: P-004, P-002  
**Traceability**: FR-096, FR-097, FR-100, FR-101, FR-139, FR-140, BR-008, BR-009, BR-012

**Acceptance Criteria**

Given Gemini flags the business justification as risky  
When I open the Reviewer request detail page  
Then I can read the original business justification, Gemini's rationale, and the current deterministic risk score.

Given I agree that the justification risk should affect the score  
When I choose `+3`, `+5`, or `+10`  
Then the selected points are added to the previously calculated deterministic score and the final risk level is recalculated.

Given I do not agree with Gemini's finding  
When I continue review without selecting an adjustment  
Then Gemini's finding remains advisory and no justification-risk points are added.

Given I apply a justification-risk adjustment  
When the action is saved  
Then the adjustment, selected points, reason, actor, and timestamp are auditable and not overwritten by later AI regeneration.

### US-011: Regenerate AI Summary After Request Changes

**As a** Reviewer handling compliance/risk checks  
**I want** the AI summary to be regenerated after request data changes  
**So that** the recommendation reflects the current supplier request.

**Personas**: P-004, P-002  
**Traceability**: FR-119, NFR-AUD-003

**Acceptance Criteria**

Given request data has changed  
When an authorized user regenerates the AI summary  
Then the system creates a new AI summary from the latest request, validation, duplicate, and risk data.

Given a summary is regenerated  
When the request detail is viewed  
Then the latest summary and timestamp are visible.

Given prior summaries exist  
When audit history is reviewed  
Then the system preserves enough history or timestamp context to know what recommendation was available at review time.

## Epic 3: Review and Supplier Governance

### US-012: View Reviewer Work Queue

**As a** Procurement / Master Data Reviewer  
**I want** a dashboard of supplier requests awaiting action  
**So that** I can focus on pending, high-risk, duplicate-risk, and failed requests.

**Personas**: P-002  
**Traceability**: FR-151 through FR-162, NFR-UX-002

**Acceptance Criteria**

Given I am a reviewer  
When I open the dashboard  
Then I can see pending and under-review requests.

Given dashboard filters are available  
When I filter by business unit, country, supplier type, requester, request status, risk level, or duplicate risk  
Then the list updates accordingly.

Given high-risk or duplicate-risk requests exist  
When I view the dashboard  
Then those requests are visible as review priorities.

### US-013: Review Request Detail With Evidence

**As a** Procurement / Master Data Reviewer  
**I want** to see request details, validation issues, duplicate matches, risk score, AI summary, and attachments on one detail view  
**So that** I can make an informed review decision.

**Personas**: P-002, P-004, P-006  
**Traceability**: FR-082, FR-083, FR-099, FR-111 through FR-114, FR-130, NFR-UX-002, NFR-AUD-001, NFR-AUD-002

**Acceptance Criteria**

Given I open a submitted supplier request  
When validation, duplicate, risk, and AI results exist  
Then I can see the request details, validation findings, duplicate match reasons, risk factors, AI summary, and uploaded documents.

Given possible duplicate suppliers exist  
When I inspect the duplicate section  
Then I can see why each supplier matched.

Given risk factors exist  
When I inspect the risk section  
Then I can see the factors contributing to the risk level.

### US-014: Approve Clean Supplier Request

**As a** Procurement / Master Data Reviewer  
**I want** to approve a clean supplier request  
**So that** the supplier can be submitted to Fusion through OIC.

**Personas**: P-002  
**Traceability**: FR-131, FR-135, FR-136, FR-180 through FR-187, BR-001

**Acceptance Criteria**

Given a request has passed validation and review  
When I approve it  
Then the request status becomes Approved.

Given the request is approved  
When integration processing begins  
Then the request is submitted to Fusion through OIC and not directly from the UI.

Given a request has unresolved duplicate or high-risk warnings  
When I try to approve it  
Then the system requires deliberate reviewer action and does not auto-create the supplier.

### US-015: Reject or Mark Duplicate Supplier Request

**As a** Procurement / Master Data Reviewer  
**I want** to reject or mark a supplier request as duplicate  
**So that** duplicate suppliers are not created in Fusion.

**Personas**: P-002, P-006, P-001  
**Traceability**: FR-132, FR-133, FR-137, FR-138, BR-003

**Acceptance Criteria**

Given I determine the request is invalid or duplicate  
When I reject or mark it duplicate  
Then the system records my decision and reason.

Given I mark a request duplicate  
When an existing supplier should be used  
Then I can reference the existing supplier.

Given the requester views the closed request  
When an existing supplier reference exists  
Then the requester can see which supplier should be used instead.

### US-016: Request Correction From Requester

**As a** Procurement / Master Data Reviewer  
**I want** to request correction instead of rejecting a request  
**So that** requesters can fix missing or unclear information.

**Personas**: P-002, P-001  
**Traceability**: FR-006, FR-134, FR-228

**Acceptance Criteria**

Given a request has missing or unclear information  
When I request correction  
Then the system records the correction reason and updates status appropriately.

Given a requester corrects and resubmits  
When validation runs again  
Then the request re-enters the controlled validation, duplicate, risk, and review flow.

Given correction is requested for high-risk or duplicate-related reasons  
When the request is resubmitted  
Then approval is still required before Fusion submission.

## Epic 4: Reviewer Payment, Compliance, and Sensitive Data Visibility

### US-017: Review Payment-Related Supplier Risk

**As a** Reviewer handling finance/payment checks  
**I want** to see payment-related warnings such as bank country mismatch and reused bank account  
**So that** I can reduce payment and payables reporting issues.

**Personas**: P-003  
**Traceability**: FR-058, FR-073, FR-074, FR-093, FR-094, BR-005, BR-007

**Acceptance Criteria**

Given a request includes bank data  
When bank country differs from supplier country  
Then the system flags the mismatch for review.

Given a bank account matches an existing supplier reference  
When duplicate detection runs  
Then the system treats the match as a serious warning.

Given payment-related warnings exist  
When finance or reviewer users inspect the request  
Then the warnings are visible with clear reasons.

### US-018: Review Compliance Risk

**As a** Reviewer handling compliance/risk checks  
**I want** to see high-risk country, missing tax registration, vague justification, and duplicate risk factors  
**So that** I can recommend appropriate follow-up before approval.

**Personas**: P-004  
**Traceability**: FR-057, FR-059, FR-095, FR-096, FR-097, FR-098, FR-113, FR-114, BR-002, BR-006, BR-008

**Acceptance Criteria**

Given a request has compliance risk factors  
When I view the request  
Then the system shows each risk reason and the overall risk level.

Given AI recommendations exist  
When I review the risk summary  
Then recommendations remain advisory and do not make a decision for me.

Given Gemini flags the business justification as risky  
When I compare Gemini's rationale to the submitted business justification  
Then I can apply `+3`, `+5`, or `+10` extra risk points, or leave the score unchanged if I disagree.

Given the request is high risk  
When approval is considered  
Then manual review is required before Fusion submission.

### US-019: Mask Sensitive Bank Data

**As a** Reviewer handling compliance/risk checks  
**I want** bank data to be masked in normal views  
**So that** sensitive supplier financial data is not exposed unnecessarily.

**Personas**: P-003, P-004, P-005  
**Traceability**: NFR-SEC-001, NFR-SEC-002, NFR-SEC-003, NFR-SEC-004

**Acceptance Criteria**

- Full bank account numbers are not displayed in normal UI views.
- If bank account display is needed, only masked values such as last four digits are shown.
- Duplicate detection may use protected underlying values, but user-visible duplicate reasons do not expose full sensitive values.
- The design documents how sensitive bank information would be protected in a real implementation.

## Epic 5: Fusion Integration, Failure Handling, and Retry

### US-020: Submit Approved Supplier to Fusion Through OIC

**As the** OIC Integration Process  
**I want** to transform approved supplier requests into Fusion-compatible payloads  
**So that** approved suppliers can be created in Oracle Fusion ERP.

**Personas**: P-007, P-003, P-005  
**Traceability**: FR-180 through FR-187, NFR-TEST-004

**Acceptance Criteria**

- Only approved requests are eligible for Fusion submission.
- OIC transforms ATP request data into Fusion-compatible supplier payloads.
- The UI does not directly create suppliers in Fusion.
- Mock Fusion responses may be used when real access is unavailable.
- Payload transformation logic includes property-based tests where round-trip or invariant properties are identifiable.

### US-021: Capture Successful Fusion Creation

**As a** Admin handling Fusion creation status  
**I want** successful Fusion creation to return and display the supplier number  
**So that** users know the supplier is available in the system of record.

**Personas**: P-003, P-001, P-007  
**Traceability**: FR-036, FR-037, FR-183, FR-184

**Acceptance Criteria**

Given Fusion supplier creation succeeds  
When OIC receives the response  
Then ATP stores the Fusion response and supplier number.

Given the supplier number is stored  
When requesters or reviewers view the request  
Then they can see the Created in Fusion status and supplier number.

Given Fusion is the system of record  
When supplier creation succeeds  
Then ATP remains a staging and tracking store, not the master source.

### US-022: Capture Fusion or OIC Failure

**As a** Admin handling integration support  
**I want** integration failures to be captured with useful diagnostic details  
**So that** I can understand and resolve supplier creation failures.

**Personas**: P-005, P-007  
**Traceability**: FR-038, FR-155, FR-185, FR-220 through FR-226, NFR-REL-001, NFR-REL-003, NFR-AUD-005

**Acceptance Criteria**

- Integration logs store OIC instance ID, payload reference, response details, error message, timestamp, and retry count.
- Technical integration errors are distinguishable from business validation errors.
- Request status becomes Integration Failed when OIC or Fusion supplier creation fails.
- Admins handling support diagnostics can view failure details without requiring requesters to interpret raw integration errors.

### US-023: Retry Eligible Integration Failures

**As a** Admin handling integration support  
**I want** to retry eligible technical failures  
**So that** temporary OIC or Fusion issues can be resolved without recreating supplier requests.

**Personas**: P-005  
**Traceability**: FR-227, FR-228, FR-229, BR-010, NFR-REL-002

**Acceptance Criteria**

Given a request failed due to a technical integration issue  
When I retry it  
Then retry count is incremented and the retry attempt is logged.

Given a request failed due to business validation issues  
When correction is needed  
Then retry alone cannot bypass validation or review.

Given a request has duplicate-risk or high-risk warnings  
When retry is attempted  
Then retry does not bypass required manual review.

## Epic 6: Dashboards, Demo Coverage, and Testability

### US-024: Demonstrate Required Supplier Scenarios

**As a** Reviewer handling supplier data governance  
**I want** sample data and demo scenarios to cover realistic supplier cases  
**So that** the prototype proves value beyond a happy path.

**Personas**: P-006, P-002, P-004, P-003  
**Traceability**: NFR-PERF-001, NFR-PERF-002, NFR-PERF-003, NFR-TEST-005

**Acceptance Criteria**

- Demo/test data includes a clean new supplier.
- Demo/test data includes duplicate by exact tax registration number.
- Demo/test data includes duplicate by similar supplier name.
- Demo/test data includes missing tax registration.
- Demo/test data includes bank country mismatch.
- Demo/test data includes incomplete address.
- Demo/test data includes same bank account as an existing supplier.
- Demo/test data includes vague business justification with high expected spend.
- Demo/test data includes Fusion creation failure caused by missing site or invalid business unit mapping.

### US-025: Test Business Logic With Property-Based Tests

**As a** Quality / Engineering Stakeholder  
**I want** duplicate detection, risk scoring, and transformation logic to have property-based tests  
**So that** business rules hold across broad input ranges, not only hand-picked examples.

**Personas**: P-007  
**Traceability**: NFR-TEST-001, NFR-TEST-002, NFR-TEST-003, NFR-TEST-004

**Acceptance Criteria**

- Duplicate detection includes property-based tests for normalization and matching invariants.
- Risk scoring includes property-based tests for score bounds, classification consistency, and factor preservation.
- Payload transformation includes property-based tests for identifiable round-trip or invariant properties.
- Example-based tests remain in place for business-critical scenarios.
- Property-based testing does not replace user workflow and integration scenario testing.

### US-026: Audit Review Decisions and Integration Attempts

**As a** Admin handling audit and integration support  
**I want** review decisions and integration attempts to be auditable  
**So that** business and support teams can reconstruct what happened to a supplier request.

**Personas**: P-005, P-002, P-004  
**Traceability**: NFR-AUD-003, NFR-AUD-004, NFR-AUD-005, FR-118, FR-220 through FR-226

**Acceptance Criteria**

- Reviewer decisions record decision type, decision reason, user, and timestamp.
- AI summaries record output and timestamp.
- Integration attempts record OIC instance ID, payload reference, response, error, timestamp, and retry count.
- Audit information supports status explanations for requesters and diagnostics for reviewers handling support responsibilities.

## INVEST Review

| Criterion | Result |
|---|---|
| Independent | Stories are scoped so they can be reasoned about individually, with dependencies expressed through acceptance criteria and traceability. |
| Negotiable | Stories describe user value and behavior, not final implementation design. |
| Valuable | Each story maps to a persona or internal actor producing user-visible value. |
| Estimable | Stories are bounded by workflow, capability, or system behavior. |
| Small | Most stories represent one coherent capability or user decision point. |
| Testable | Every story includes acceptance criteria and requirement traceability. |
