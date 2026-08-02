# Application Design

## Overview

This design defines a high-level Oracle-native architecture for Supplier Onboarding, Duplicate Detection & Risk Scoring.

The design follows the approved Application Design Plan:

- ATP/ORDS-centered orchestration
- Gemini integration through OIC
- OCI Object Storage for attachment content with ATP metadata
- Resource-oriented ORDS APIs
- Separate duplicate detection and risk scoring components
- Oracle IAM subject/role context enforced by ORDS and ATP package logic
- Real OIC-to-Fusion design with mock Fusion fallback

Detailed business rules, scoring weights, match thresholds, field-level payload mappings, and test implementations are deferred to later AIDLC stages.

## Design Artifacts

- `components.md`: Component catalog, responsibilities, interfaces, and owned data.
- `component-methods.md`: High-level method signatures and conceptual interfaces.
- `services.md`: Service definitions and orchestration patterns.
- `component-dependency.md`: Dependency relationships, communication patterns, data flows, and risks.

## High-Level Architecture

### Presentation Layer

Oracle Visual Builder provides:

- Requester form and dashboard
- Reviewer queue and request detail page
- Duplicate, risk, validation, AI, and attachment display panels
- Finance, compliance, and supplier governance visibility through Reviewer
- OIC/Fusion log, retry, and diagnostic visibility through Admin

Visual Builder calls ORDS APIs and does not create suppliers in Fusion directly.

### API Layer

ORDS provides resource-oriented APIs for:

- Supplier requests
- Validation
- Duplicate matches
- Risk scores
- AI summaries
- Review actions
- Dashboards
- Attachments
- Integration logs
- Retries

ORDS also enforces phase-one Requester, Reviewer, and Admin behavior through actor subject IDs and app-role context. Local testing passes these values as request parameters; production identity integration is deferred.

### ATP Application/Data Layer

ATP stores:

- Supplier request data
- Workflow status
- Validation results
- Duplicate matches
- Risk scores
- AI summaries
- Review decisions
- Actor subject IDs for ownership and audit
- Supplier master reference data
- Attachment metadata/references
- Integration logs
- Audit records

ATP is staging and tracking only. Fusion remains the supplier master source of truth.

### Integration Layer

OIC handles:

- Supplier creation submission to Fusion
- Supplier master synchronization from Fusion to ATP
- Gemini AI explanation orchestration

Mock Fusion responses are allowed when real Fusion access is unavailable, but the design still follows the real OIC/Fusion integration pattern.

### External Services

- Oracle Fusion ERP: supplier master system of record.
- Gemini: advisory AI explanation and recommendations.
- OCI Object Storage: uploaded supplier document content.

## Primary Request Flow

1. Requester creates or edits a supplier request in Visual Builder.
2. Visual Builder calls ORDS APIs.
3. ORDS checks actor subject and app-role context, then writes request data to ATP.
4. Requester submits the request.
5. Validation Component checks business validation.
6. Duplicate Detection Component compares request data against Fusion-synced supplier reference data.
7. Risk Scoring Component consumes validation findings, duplicate factors, and request data.
8. OIC calls Gemini and stores advisory summary in ATP.
9. Reviewer reviews request evidence.
10. Reviewer approves, rejects, marks duplicate, or requests correction.
11. Approved requests are submitted to Fusion through OIC.
12. Fusion success or failure is stored in ATP and shown in dashboards.
13. Admin/support users can view integration logs and retry eligible technical failures.

## Component Summary

| Component | Role in Design |
|---|---|
| Visual Builder Application | User-facing screens and actions. |
| IAM Subject Authorization Context | Actor subject IDs and Requester/Reviewer/Admin role context checked by ATP/ORDS. |
| ORDS API Layer | REST boundary and role-aware API actions. |
| Supplier Request Repository | Flattened ATP supplier request, document, assessment, status, and owner data. |
| Request Workflow Component | Status transitions and workflow rules. |
| Validation Component | Business validation findings. |
| Supplier Master Reference Component | Fusion-synced reference supplier data. |
| Duplicate Detection Component | Duplicate candidates and match reasons. |
| Risk Scoring Component | Explainable risk level and factors. |
| Gemini Explanation Component | Advisory AI summary orchestration. |
| Document Component | Request document metadata and future Object Storage references. |
| Review Decision Component | Human approval, rejection, duplicate, correction decisions. |
| Dashboard Query Component | Role-specific list and filter data. |
| Supplier Creation Integration Component | OIC-to-Fusion supplier creation. |
| Supplier Master Sync Component | OIC-to-Fusion supplier reference sync. |
| Integration Log and Retry Component | Failure details and retry controls. |
| Audit Component | Status, review, AI, and integration traceability. |
| Testability Component | Property-based testing boundaries for logic and transformations. |

## Design Decisions

### DD-001: ATP/ORDS-Centered Orchestration

Business orchestration lives mainly in ATP-backed logic exposed through ORDS. Visual Builder remains a presentation layer.

**Reason**: The transcript asks for Visual Builder UI, ATP staging, and ORDS APIs. Keeping orchestration behind ORDS makes the workflow more consistent and testable.

### DD-002: Gemini Through OIC

Gemini calls are represented as OIC-orchestrated external service calls, with results written back to ATP.

**Reason**: OIC is already the integration layer. This keeps external calls centralized and mockable.

### DD-003: OCI Object Storage for Attachments

Attachment content is stored in OCI Object Storage. ATP stores metadata and object references.

**Reason**: This avoids overloading ATP with binary document content and better matches a scalable Oracle architecture.

### DD-004: Resource-Oriented ORDS APIs

APIs are organized by resources and domains rather than by UI screen.

**Reason**: Resource APIs are reusable across requester, reviewer, and admin dashboards. In the prototype, finance/compliance/governance responsibilities are exposed through Reviewer, while IT/support log and retry responsibilities are exposed through Admin.

### DD-005: Separate Duplicate Detection and Risk Scoring

Duplicate detection produces match facts. Risk scoring consumes those facts plus validation and request data.

**Reason**: This improves explainability, testability, and future change control.

### DD-006: IAM Subject Context Through ORDS

Prototype calls pass actor subject and app-role context to ORDS, and ATP package logic enforces protected actions.

**Reason**: This is stronger than Visual Builder-only role selection while still matching the finalized decision that Oracle IAM owns real users and roles.

### DD-007: Real Fusion Design With Mock Fallback

The design targets real OIC-to-Fusion integration, with mock Fusion responses when real access is unavailable.

**Reason**: The transcript requires a realistic integration pattern and permits mock payloads for prototype constraints.

## Known Limitations

- Production identity integration is deferred.
- Security and resiliency extensions are disabled by requirement answers.
- Sensitive data protection needs deeper treatment in NFR Design.
- Fusion API details must be validated against the customer's environment.
- Gemini availability and authentication must be confirmed during Infrastructure Design or Code Generation.
- Multi-site supplier support is out of scope for phase one.

## Traceability Coverage

This design covers:

- Supplier request creation and tracking: FR-001 through FR-006, FR-030 through FR-039
- Data capture and supplier documents: FR-010 through FR-027
- Validation: FR-050 through FR-061
- Duplicate detection: FR-070 through FR-085
- Risk scoring: FR-090 through FR-099
- AI explanation: FR-110 through FR-119
- Review workflow: FR-130 through FR-138
- Dashboards: FR-150 through FR-162
- OIC/Fusion creation: FR-180 through FR-187
- Supplier master sync: FR-200 through FR-203
- Integration logs and retry: FR-220 through FR-229
- Security/privacy: NFR-SEC-001 through NFR-SEC-006
- Reliability/error handling: NFR-REL-001 through NFR-REL-005
- Usability, auditability, performance, and testing NFRs

## Next AIDLC Stage

After this design is approved, the next stage is Units Generation. That stage will split the design into buildable units for Construction.
