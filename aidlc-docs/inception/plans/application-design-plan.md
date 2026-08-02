# Application Design Plan

## Purpose

Create high-level application design artifacts for the Supplier Onboarding, Duplicate Detection & Risk Scoring solution.

This stage identifies components, responsibilities, interfaces, services, dependencies, and communication patterns. Detailed business logic is deferred to Functional Design during Construction.

## Source Artifacts

- `aidlc-docs/inception/requirements/requirements.md`
- `aidlc-docs/inception/user-stories/personas.md`
- `aidlc-docs/inception/user-stories/stories.md`
- `aidlc-docs/inception/plans/execution-plan.md`
- `Customer Requirement Discovery Call Transcript-Integration ERP.pdf`

## Design Scope

The design will cover:

- Oracle Visual Builder user-facing application
- ORDS API layer
- Oracle ATP staging, workflow, and reference data layer
- Supplier request workflow orchestration
- Validation component
- Duplicate detection component
- Risk scoring component
- Gemini AI explanation component
- Attachment handling component
- Review decision component
- OIC/Fusion supplier creation integration
- OIC/Fusion supplier master synchronization
- Integration logging and retry handling
- Dashboard/query components
- Testability boundaries for property-based testing

## Required Design Artifacts

- [x] Generate `aidlc-docs/inception/application-design/components.md` with component definitions and high-level responsibilities.
- [x] Generate `aidlc-docs/inception/application-design/component-methods.md` with method signatures and interface-level behavior.
- [x] Generate `aidlc-docs/inception/application-design/services.md` with service definitions and orchestration patterns.
- [x] Generate `aidlc-docs/inception/application-design/component-dependency.md` with dependency relationships and communication patterns.
- [x] Generate `aidlc-docs/inception/application-design/application-design.md` consolidating the design.
- [x] Validate component coverage against requirements and user stories.
- [x] Confirm detailed business rules are deferred to Functional Design.

## Planned Design Approach

Use an Oracle-native layered architecture:

1. **Presentation Layer**: Oracle Visual Builder pages and role-specific views.
2. **API Layer**: ORDS REST APIs exposing ATP-backed operations.
3. **Application/Data Logic Layer**: ATP tables, views, PL/SQL packages/procedures where appropriate, and ORDS handlers.
4. **Business Decision Components**: validation, duplicate detection, risk scoring, AI summary orchestration, review workflow.
5. **Integration Layer**: OIC integrations for Fusion supplier creation and supplier master synchronization.
6. **External Service Layer**: Gemini for advisory explanations and recommended actions.

## Execution Checklist

- [x] Read approved requirements, user stories, and execution plan.
- [x] Validate application design questions are answered and unambiguous.
- [x] Identify major functional components.
- [x] Define component responsibilities and owned data.
- [x] Define component interfaces and high-level methods.
- [x] Define orchestration services and service interactions.
- [x] Define component dependencies and communication patterns.
- [x] Define high-level data flow across Visual Builder, ORDS, ATP, OIC, Fusion, and Gemini.
- [x] Identify design constraints and known limitations.
- [x] Generate required application design artifacts.
- [x] Update AIDLC state and audit log.

## Application Design Questions

Please answer each question by filling in the letter choice after the `[Answer]:` tag. If none of the options match, choose `X` and describe your preference after the tag.

### Question 1
Where should most application/business orchestration logic live for phase one?

A) ATP/ORDS-centered design: ORDS APIs call ATP tables/views/packages for validation, duplicate detection, risk scoring, workflow state, and dashboard data

B) Visual Builder-centered design: Visual Builder handles most orchestration and calls simpler ATP/ORDS endpoints

C) External service-centered design: a separate backend service handles orchestration, while ATP stores data and ORDS exposes access

X) Other (please describe after [Answer]: tag below)

[Answer]: A 

### Question 2
How should Gemini AI integration be represented in the high-level design?

A) ORDS/ATP component calls Gemini directly or through a small backend adapter, then stores AI output in ATP

B) OIC orchestrates Gemini calls and writes AI output back to ATP

C) Gemini is represented as a mockable external AI explanation service in phase one, with final integration path decided later

X) Other (please describe after [Answer]: tag below)

[Answer]: B

### Question 3
How should attachment storage be designed?

A) Store uploaded files as ATP BLOBs with metadata in supplier document tables

B) Store files in OCI Object Storage, with metadata and references in ATP

C) Design both options, implement the simpler ATP BLOB approach first

X) Other (please describe after [Answer]: tag below)

[Answer]: B

### Question 4
How should ORDS APIs be organized?

A) Resource-oriented APIs by domain: requests, validation, duplicates, risk, AI summaries, reviews, dashboards, attachments, integration logs, retries

B) Screen-oriented APIs by Visual Builder page: requester form, requester dashboard, reviewer queue, request detail, reviewer OIC/Fusion log area

C) Minimal APIs only: broad generic endpoints with most behavior hidden in ATP packages

X) Other (please describe after [Answer]: tag below)

[Answer]: A

### Question 5
How should duplicate detection and risk scoring components be separated?

A) Separate components with clear interfaces: duplicate detection produces match factors; risk scoring consumes duplicate factors plus validation and request data

B) Single combined risk engine that handles validation, duplicate detection, and risk score together

C) Separate conceptually in documentation, but allow one implementation package for phase one

X) Other (please describe after [Answer]: tag below)

[Answer]: A

### Question 6
How should application-level role simulation be represented?

A) Role simulation table in ATP, with ORDS enforcing role-aware responses/actions for the prototype

B) Visual Builder-only role selection/simulation, with ORDS trusting the selected role for phase one

C) Document role simulation only and defer role behavior to later implementation

X) Other (please describe after [Answer]: tag below)

[Answer]: A

### Question 7
How should Fusion integration availability be handled in design?

A) Design real OIC-to-Fusion integrations first, with mock Fusion responses as fallback

B) Design mock Fusion integration first, with real OIC/Fusion mappings documented separately

C) Keep Fusion integration abstract until real Fusion API access is confirmed

X) Other (please describe after [Answer]: tag below)

[Answer]: A

## Approval Gate

After all `[Answer]:` tags are filled and validated, this plan requires explicit approval before application design artifacts are generated.
