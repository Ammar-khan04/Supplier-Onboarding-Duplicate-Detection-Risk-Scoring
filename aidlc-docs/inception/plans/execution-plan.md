# Execution Plan

## Detailed Analysis Summary

### Project Context

- **Project**: Supplier Onboarding, Duplicate Detection & Risk Scoring
- **Project type**: Greenfield
- **Approved requirements**: `aidlc-docs/inception/requirements/requirements.md`
- **Approved user stories**: `aidlc-docs/inception/user-stories/stories.md`
- **Delivery posture**: Production-ready selected in requirements answers, with phase-one limitations documented for local actor subject/role context and skipped security/resiliency extensions.

### Change Impact Assessment

- **User-facing changes**: Yes. The solution introduces Visual Builder experiences for Requester, Reviewer, and Admin. Finance/compliance/governance concerns are merged into Reviewer, while IT/support log and retry concerns are handled by Admin.
- **Structural changes**: Yes. The solution requires a new multi-layer architecture spanning Visual Builder, ORDS, ATP, OIC, Fusion ERP, and Gemini.
- **Data model changes**: Yes. New data structures are needed for flattened supplier requests, documents, request assessments, Fusion supplier references, AI assessments, action history, integration jobs, structured configuration, Fusion responses, and retry events.
- **API changes**: Yes. ORDS APIs are required for request list/create/read/update/submission, documents, review actions, AI regeneration, justification-risk adjustment, integration logs/jobs, supplier reference batch upsert, risk rules, high-risk countries, and retries.
- **NFR impact**: Yes. The solution includes sensitive bank data masking, auditability, traceability, error classification, retry handling, performance expectations, and property-based testing for business logic and transformations.

### Risk Assessment

- **Risk Level**: High
- **Risk Rationale**: The project is cross-system, user-facing, stateful, integration-heavy, and contains sensitive supplier/bank data. Requirements also include production-ready intent while security and resiliency extensions are skipped, creating go-live risk that must be surfaced in design.
- **Rollback Complexity**: Difficult for real Fusion integration; moderate for prototype or mock-only flows.
- **Testing Complexity**: Complex due to multi-persona workflows, duplicate/risk algorithms, attachment handling, AI summaries, OIC/Fusion success/failure paths, and property-based testing requirements.

## Workflow Visualization

Read this section instead of a rendered diagram.

**Already Done**

- Workspace Detection
  Greenfield project confirmed.
- Requirements Analysis
  Transcript converted into formal requirements.
- User Stories
  Personas and user stories generated and accepted.
- Workflow Planning
  Execution path created and approved.

**Skipped**

- Reverse Engineering
  Skipped because there is no existing application code.
- Operations
  Placeholder only in the current AIDLC workflow.

**Current Stage**

- Application Design Planning
  We are deciding high-level architecture choices before generating design artifacts.

**Next Inception Stages**

- Application Design
  Define components, services, APIs, dependencies, and communication patterns.
- Units Generation
  Break the project into buildable units.

**Construction Stages After Inception**

- Functional Design
  Define detailed behavior for each unit.
- NFR Requirements
  Define security, privacy, reliability, performance, auditability, and testing needs.
- NFR Design
  Convert those NFRs into concrete design decisions.
- Infrastructure Design
  Map the solution to Visual Builder, ATP, ORDS, OIC, Fusion, Gemini, and storage.
- Code Generation
  Create implementation artifacts, scripts, specs, logic, mocks, and tests.
- Build and Test
  Validate the required success and failure scenarios.

**Simple Flow**

Workspace Detection
-> Requirements Analysis
-> User Stories
-> Workflow Planning
-> Application Design
-> Units Generation
-> Functional Design
-> NFR Requirements
-> NFR Design
-> Infrastructure Design
-> Code Generation
-> Build and Test

## Phases to Execute

### Inception Phase

- [x] Workspace Detection - COMPLETED
  - **Rationale**: Workspace was classified as greenfield with no existing application code.
- [x] Reverse Engineering - SKIPPED
  - **Rationale**: No existing application codebase exists to reverse engineer.
- [x] Requirements Analysis - COMPLETED
  - **Rationale**: Discovery transcript and verification answers were converted into formal requirements.
- [x] User Stories - COMPLETED
  - **Rationale**: Multi-persona workflows required user-centered stories and acceptance criteria.
- [x] Workflow Planning - IN REVIEW
  - **Rationale**: This document defines the remaining AIDLC path.
- [ ] Application Design - EXECUTE
  - **Rationale**: New application components, service responsibilities, business rules, integration boundaries, and data/API relationships must be designed before construction.
- [ ] Units Generation - EXECUTE
  - **Rationale**: The project must be decomposed into buildable units across UI, database, APIs, duplicate detection, risk scoring, AI explanation, OIC/Fusion integration, attachments, dashboards, logs, retry, and testing.

### Construction Phase

- [ ] Functional Design - EXECUTE
  - **Rationale**: Business workflows and rules need detailed per-unit behavior for submission, validation, duplicate detection, risk scoring, review, AI explanation, Fusion submission, failure handling, and retry.
- [ ] NFR Requirements - EXECUTE
  - **Rationale**: The approved requirements include security/privacy, auditability, reliability/error handling, performance/volume, usability, and property-based testing expectations.
- [ ] NFR Design - EXECUTE
  - **Rationale**: NFRs must be translated into design decisions such as bank masking, audit fields, status/error handling, retry controls, testing strategy, and data protection limitations.
- [ ] Infrastructure Design - EXECUTE
  - **Rationale**: The solution must map to Oracle Visual Builder, ATP, ORDS, OIC, Fusion ERP, Gemini, attachment storage, integration scheduling, and environment configuration.
- [ ] Code Generation - EXECUTE
  - **Rationale**: Implementation artifacts are required after design, including database scripts, API definitions, application logic, integration payloads/mocks, test data, and test suites.
- [ ] Build and Test - EXECUTE
  - **Rationale**: The system must be validated against success, duplicate-risk, high-risk, validation-failure, correction, integration-failure, retry, and property-based testing scenarios.

### Operations Phase

- [ ] Operations - PLACEHOLDER
  - **Rationale**: Current AIDLC workflow treats operations as future deployment and monitoring workflow. Production-readiness gaps should be revisited before go-live.

## Stages to Execute

1. Application Design
2. Units Generation
3. Functional Design
4. NFR Requirements
5. NFR Design
6. Infrastructure Design
7. Code Generation
8. Build and Test

## Stages to Skip

1. Reverse Engineering
   - **Reason**: Greenfield workspace with no existing application code.
2. Operations
   - **Reason**: Placeholder stage in current AIDLC workflow.

## Estimated Timeline

- **Executable remaining stages**: 8
- **Prototype-oriented estimate from transcript**: approximately 3 weeks
- **Production-readiness caveat**: The selected production-ready target is not fully satisfied by local actor subject/role parameters and skipped security/resiliency extensions. Oracle IAM, security, resilience, deployment, monitoring, backup, and recovery hardening are required before real go-live.

## Success Criteria

### Primary Goal

Deliver a supplier onboarding solution that standardizes supplier requests, detects duplicate risk, scores supplier risk, explains findings with Gemini, supports human review, and submits approved suppliers to Oracle Fusion ERP through OIC.

### Key Deliverables

- Application design for Oracle Visual Builder, ATP, ORDS, OIC, Fusion ERP, and Gemini.
- Unit breakdown for parallel or staged construction.
- Functional designs for each unit.
- NFR requirements and design covering privacy, auditability, errors, retry, testing, and performance.
- Infrastructure design mapped to Oracle services and integration boundaries.
- Implementation artifacts for database, APIs, UI, integration payloads/mocks, business logic, and tests.
- Build and test evidence for required demo and failure scenarios.

### Quality Gates

- Requirements approved.
- User stories approved.
- Execution plan approved.
- Application design approved.
- Units approved.
- Per-unit design artifacts approved where required.
- Generated code passes build and tests.
- Duplicate detection, risk scoring, and payload transformation include property-based tests where applicable.
- Demo scenarios pass end to end.
