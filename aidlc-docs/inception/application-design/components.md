# Application Components

## Design Direction

The application uses an Oracle-native layered design:

- Oracle Visual Builder provides role-specific screens and user interactions.
- ORDS exposes resource-oriented APIs.
- ATP stores staging data, workflow state, reference data, validation output, duplicate results, risk scores, AI summaries, audit records, and integration logs.
- OIC orchestrates Fusion supplier creation, Fusion supplier master synchronization, and Gemini calls.
- OCI Object Storage stores uploaded supplier documents, with metadata and references in ATP.

Detailed business rules are intentionally deferred to Functional Design.

## Component Catalog

| ID | Component | Purpose |
|---|---|---|
| C-001 | Visual Builder Application | Three-role UI for requester, reviewer, and admin; reviewer includes finance/compliance/governance concerns, while admin owns support logs and retry. |
| C-002 | IAM Subject Authorization Context | Actor subject IDs and Requester/Reviewer/Admin app-role context enforced by ORDS and ATP package logic. |
| C-003 | ORDS API Layer | Resource-oriented REST API boundary between Visual Builder and ATP-backed logic. |
| C-004 | Supplier Request Repository | ATP-backed storage for flattened supplier request, document, assessment, lifecycle, Fusion result, risk summary, and ownership data. |
| C-005 | Request Workflow Component | Controls request state transitions from Draft through Created in Fusion or Integration Failed. |
| C-006 | Validation Component | Produces business validation findings before review and before Fusion submission. |
| C-007 | Supplier Master Reference Component | Stores Fusion-synced supplier master reference data for duplicate checking. |
| C-008 | Duplicate Detection Component | Produces possible duplicate matches and match reasons. |
| C-009 | Risk Scoring Component | Produces Low, Medium, High, or Critical risk based on request, validation, duplicate factors, Admin risky-country configuration, and Reviewer-approved justification-risk adjustments. |
| C-010 | Gemini Explanation Component | Coordinates advisory AI summaries through OIC/Gemini and stores outputs plus business-justification risk metadata in ATP. |
| C-011 | Document Component | Stores supplier document metadata, latest flags, uploader evidence, and future object references in ATP. |
| C-012 | Review Decision Component | Records reviewer decisions and supports approve, reject, mark duplicate, and request correction actions. |
| C-013 | Dashboard Query Component | Provides requester dashboard data, reviewer work queue data, and admin support/log data. |
| C-014 | Supplier Creation Integration Component | OIC flow that submits approved supplier payloads to Fusion ERP, with mock fallback. |
| C-015 | Supplier Master Sync Component | OIC flow that synchronizes existing Fusion supplier master reference data into ATP. |
| C-016 | Integration Log and Retry Component | Stores OIC/Fusion attempts, errors, responses, retry count, and retry eligibility. |
| C-017 | Audit Component | Captures review decisions, AI summary timestamps, status changes, and integration activity. |
| C-018 | Testability Component | Defines test seams for duplicate detection, risk scoring, and payload transformation property-based tests. |

## Component Details

### C-001: Visual Builder Application

**Purpose**: Present the user-facing application.

**Responsibilities**:

- Render requester supplier request form.
- Render requester dashboard and status detail.
- Render reviewer queue and request detail.
- Render duplicate match, risk score, AI summary, validation findings, and document panels.
- Render reviewer-accessible OIC/Fusion logs, retry actions, and diagnostic/test views.
- Call ORDS APIs only; do not create suppliers directly in Fusion.

**Interfaces**:

- Calls C-003 ORDS API Layer.
- Uses role-aware responses from C-002/C-003 to show allowed actions.

**Owned Data**:

- UI state only. Persistent state belongs in ATP and OCI Object Storage.

### C-002: IAM Subject Authorization Context

**Purpose**: Provide backend-enforced Requester, Reviewer, and Admin behavior while production identity integration is deferred.

**Responsibilities**:

- Accept actor subject ID and app-role context from ORDS requests during local/prototype testing.
- Support requester, reviewer, and admin role checks in the prototype. Reviewer includes finance/compliance/governance responsibilities. Admin includes IT/support log and retry responsibilities.
- Allow ORDS handlers to enforce role-aware access and actions.
- Document that production Oracle IAM integration is a future deployment/hardening requirement.

**Interfaces**:

- Called by C-003 before executing protected actions.
- Referenced by C-013 for role-specific dashboard data.

**Owned Data**:

- No local role tables in the finalized schema.
- Stable subject IDs persisted in request ownership, action history, document upload, assessment adjustment, and configuration update columns.

### C-003: ORDS API Layer

**Purpose**: Provide resource-oriented REST APIs.

**Responsibilities**:

- Expose domain APIs for supplier requests, document metadata, validation/assessment projections, duplicates, risk, AI summaries, reviews, dashboards, integration logs/jobs, supplier references, risk configuration, high-risk countries, and retries.
- Call ATP packages, views, and tables.
- Enforce actor subject and app-role rules before protected actions.
- Normalize API responses for Visual Builder.

**Interfaces**:

- Consumed by C-001.
- Calls C-002, C-004, C-005, C-006, C-008, C-009, C-010, C-011, C-012, C-013, and C-016.

**Owned Data**:

- No durable business data. API configuration and endpoint definitions only.

### C-004: Supplier Request Repository

**Purpose**: Store supplier request data in ATP.

**Responsibilities**:

- Store request header and lifecycle status.
- Store supplier attributes, contact, bank, site, requester, business unit, justification, category, and expected spend.
- Store references to documents, validation results, duplicate evidence, risk scores, AI summaries, review decisions, and integration logs.
- Preserve request history required for audit and status tracking.

**Interfaces**:

- Used by C-003, C-005, C-006, C-008, C-009, C-010, C-011, C-012, C-013, C-014, C-016, and C-017.

**Owned Data**:

- Supplier request records.
- Flattened supplier, site, contact, tax, bank, and business fields.
- Request status and owner fields.

### C-005: Request Workflow Component

**Purpose**: Control high-level supplier request state.

**Responsibilities**:

- Move requests through Draft, Submitted, Validation Failed, Under Review, Approved, Rejected, Submitted to Fusion, Created in Fusion, and Integration Failed.
- Prevent supplier creation before approval.
- Ensure correction and retry do not bypass validation, duplicate review, risk review, or approval rules.
- Expose status history for audit and dashboards.

**Interfaces**:

- Called by C-003 and C-012 for user actions.
- Called by C-014/C-016 for integration status updates.
- Reads and writes C-004 request state.

**Owned Data**:

- Status history.
- State transition audit entries.

### C-006: Validation Component

**Purpose**: Identify business validation issues.

**Responsibilities**:

- Validate mandatory fields.
- Flag incomplete address.
- Flag missing tax registration where applicable.
- Flag bank country mismatch.
- Flag generic or vague business-justification signals for Gemini review and Reviewer-confirmed risk adjustment.
- Validate supplier site or business unit mapping before Fusion submission.
- Store validation findings in `REQUEST_ASSESSMENT` for review and AI explanation.

**Interfaces**:

- Called by C-003 during submit/resubmit.
- Called by C-009 for risk scoring inputs.
- Called by C-010 for AI explanation inputs.

**Owned Data**:

- Assessment rows in `REQUEST_ASSESSMENT`.

### C-007: Supplier Master Reference Component

**Purpose**: Store existing supplier master reference data synchronized from Fusion.

**Responsibilities**:

- Store supplier name, tax ID, country, address, email domain, phone, masked bank reference, and site reference data where available.
- Provide searchable reference data for duplicate detection.
- Preserve Fusion as the system of record.

**Interfaces**:

- Loaded by C-015.
- Read by C-008.
- Referenced by C-012 when marking a request duplicate.

**Owned Data**:

- Fusion supplier reference records in ATP.
- Sync metadata.

### C-008: Duplicate Detection Component

**Purpose**: Identify possible duplicate suppliers.

**Responsibilities**:

- Match exact tax registration values.
- Match exact protected bank references where available.
- Normalize supplier names for lightweight fuzzy matching.
- Consider country, address, email domain, and phone where available.
- Produce duplicate match factors and reasons.
- Store duplicate match results in `REQUEST_ASSESSMENT` for review and risk scoring.

**Interfaces**:

- Reads C-004 and C-007.
- Produces outputs for C-009, C-010, C-012, and C-013.

**Owned Data**:

- Duplicate level and duplicate-match JSON evidence in `REQUEST_ASSESSMENT`.

### C-009: Risk Scoring Component

**Purpose**: Calculate explainable supplier risk.

**Responsibilities**:

- Consume request data, validation findings, duplicate factors, and configurable risk indicators.
- Produce Low, Medium, High, or Critical risk.
- Store deterministic score, final score, risk level, and contributing factors in `REQUEST_ASSESSMENT`.
- Read the Admin-managed risky-country list when applying the high-risk-country rule.
- Add Reviewer-approved Gemini justification-risk adjustment points to the deterministic score, capped at the configured maximum score.
- Preserve deterministic risk points separately from Reviewer-applied adjustment points for explainability.
- Keep duplicate detection separate by consuming duplicate outputs rather than performing duplicate matching itself.

**Interfaces**:

- Reads C-004, C-006, and C-008.
- Produces outputs for C-010, C-012, and C-013.

**Owned Data**:

- Risk fields and risk-factor JSON evidence in `REQUEST_ASSESSMENT`.

### C-010: Gemini Explanation Component

**Purpose**: Generate advisory AI summaries and recommended actions.

**Responsibilities**:

- Assemble request, validation, duplicate, and risk context for Gemini.
- Trigger OIC Gemini orchestration.
- Store generated summary, recommendation, model/provider metadata, and timestamp in ATP.
- Store Gemini's business-justification risk flag, rationale, suggested severity, and suggested adjustment points for Reviewer consideration.
- Support regeneration when request data changes.
- Enforce AI boundary: AI never approves, rejects, creates suppliers, or directly changes the numeric risk score.

**Interfaces**:

- Invoked through C-003/C-005 where needed.
- Uses OIC to call Gemini.
- Reads C-004, C-006, C-008, and C-009.
- Writes AI summaries to C-004-owned data structures.

**Owned Data**:

- AI summary records.
- AI prompt/response metadata.

### C-011: Document Component

**Purpose**: Manage supplier document metadata, upload references, and future storage integration.

**Responsibilities**:

- Store document metadata, request version, latest flag, uploader evidence, and optional content placeholder in ATP.
- Support future OCI Object Storage object references when file storage is added.
- Associate documents with supplier requests.
- Flag missing expected documents where applicable.
- Avoid exposing sensitive document content unnecessarily.

**Interfaces**:

- Called by C-003 from Visual Builder.
- Writes metadata into C-004-associated tables.
- Uses OCI Object Storage when that deferred storage integration is added.

**Owned Data**:

- Document metadata.
- Future Object Storage reference keys.

### C-012: Review Decision Component

**Purpose**: Support human review decisions.

**Responsibilities**:

- Approve requests.
- Reject requests.
- Mark requests duplicate and reference existing supplier.
- Request correction.
- Apply or decline Gemini business-justification risk adjustment buttons `+3`, `+5`, and `+10`.
- Record reviewer identity, decision, reason, and timestamp.
- Record justification-risk adjustments as auditable reviewer actions.
- Ensure approved requests are eligible for Fusion submission.

**Interfaces**:

- Called by C-003.
- Reads C-004, C-006, C-008, C-009, C-010, and C-011.
- Updates C-005 workflow state.
- Writes audit entries through C-017.

**Owned Data**:

- Review decision records.

### C-013: Dashboard Query Component

**Purpose**: Provide role-specific dashboard views.

**Responsibilities**:

- Provide requester status dashboard.
- Provide reviewer queue and filters.
- Provide Reviewer evidence views for finance, compliance, and supplier governance concerns.
- Provide admin support integration failure and retry views.
- Apply role-aware filtering.

**Interfaces**:

- Called by C-003.
- Reads C-004, C-006, C-008, C-009, C-010, C-012, and C-016.

**Owned Data**:

- Dashboard views/materialized query definitions, if used.

### C-014: Supplier Creation Integration Component

**Purpose**: Submit approved suppliers to Fusion through OIC.

**Responsibilities**:

- Receive or fetch approved supplier request data.
- Transform request data into Fusion-compatible payloads.
- Call Fusion supplier APIs/processes through OIC.
- Support realistic mock Fusion responses as fallback.
- Return supplier number or failure details.

**Interfaces**:

- Reads C-004.
- Updates C-005 workflow state.
- Writes C-016 integration logs.
- Calls Oracle Fusion ERP or mock Fusion endpoint.

**Owned Data**:

- OIC integration configuration.
- Payload mappings.
- Mock response definitions.

### C-015: Supplier Master Sync Component

**Purpose**: Synchronize existing Fusion supplier reference data into ATP.

**Responsibilities**:

- Periodically fetch supplier master reference data from Fusion through OIC.
- Transform reference fields for duplicate checking.
- Store reference data in C-007.
- Capture sync metadata and errors.

**Interfaces**:

- Calls Fusion through OIC.
- Writes C-007.
- Writes C-016 integration logs for sync failures.

**Owned Data**:

- Sync schedules and mappings.

### C-016: Integration Log and Retry Component

**Purpose**: Track OIC/Fusion attempts and support retry.

**Responsibilities**:

- Store OIC instance ID, payload reference, response, error message, timestamp, and retry count.
- Classify technical integration failures separately from business validation failures.
- Determine retry eligibility at a high level.
- Support retry actions for technical failures without bypassing review controls.

**Interfaces**:

- Called by C-003 for support actions.
- Written by C-014 and C-015.
- Updates C-005 workflow status where appropriate.

**Owned Data**:

- Integration log records.
- Retry event records.

### C-017: Audit Component

**Purpose**: Preserve traceability of important actions.

**Responsibilities**:

- Record status changes.
- Record review decisions.
- Record AI summary timestamps.
- Record integration attempts and retries.
- Support later audit/reporting needs.

**Interfaces**:

- Receives events from C-005, C-010, C-012, and C-016.
- Read by C-013 for support/admin visibility.

**Owned Data**:

- Audit event records.

### C-018: Testability Component

**Purpose**: Define seams for example-based and property-based testing.

**Responsibilities**:

- Identify pure business logic units for duplicate detection.
- Identify pure business logic units for risk scoring.
- Identify payload transformation invariants.
- Keep testable logic separated from UI and external service calls where practical.

**Interfaces**:

- Applies to C-008, C-009, and C-014.

**Owned Data**:

- Test scenarios and test data definitions in later Construction artifacts.
