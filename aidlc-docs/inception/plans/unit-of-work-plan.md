# Unit of Work Generation Plan

## Stage Context

This plan starts the Units Generation stage for the Supplier Onboarding, Duplicate Detection & Risk Scoring project.

The approved application design uses:

- Oracle Visual Builder for the three-role user interface: Requester, Reviewer, and Admin.
- ORDS as the REST API boundary.
- Oracle ATP as the staging, workflow, reference, scoring, review, audit, and integration tracking database.
- OIC for Fusion ERP supplier creation, Fusion supplier master synchronization, and Gemini orchestration.
- OCI Object Storage for document content, with ATP metadata and references.

ATP is not a separate AIDLC stage. ATP becomes one or more buildable units of work inside Units Generation and Construction.

## Recommended Direction

The recommended path is to make the ATP/ORDS foundation the first construction unit because the Visual Builder prototype already exists, and the remaining application behavior depends on persistent supplier request data, workflow state, validation results, duplicate evidence, risk scores, IAM subject/role authorization context, and integration logs.

## Plan Checklist

- [x] Load current AIDLC state and prior artifacts.
- [x] Confirm Application Design artifacts exist and were previously approved for generation.
- [x] Identify ATP as a construction unit rather than a standalone AIDLC stage.
- [x] Create unit decomposition questions using `[Answer]:` tags.
- [x] Collect answers for unit decomposition.
- [x] Analyze answers for contradictions, ambiguity, or missing decisions.
- [x] Resolve any required follow-up questions.
- [x] Generate `aidlc-docs/inception/application-design/unit-of-work.md` with unit definitions and responsibilities.
- [x] Generate `aidlc-docs/inception/application-design/unit-of-work-dependency.md` with dependency matrix.
- [x] Generate `aidlc-docs/inception/application-design/unit-of-work-story-map.md` mapping stories to units.
- [x] Document greenfield code organization strategy in `unit-of-work.md`.
- [x] Validate unit boundaries, dependencies, and story coverage.
- [x] Mark Units Generation planning complete after approval.

## Proposed Unit Candidates

The likely unit decomposition is:

| Unit | Purpose | Likely Construction Order |
|---|---|---|
| UOW-001 Visual Builder Prototype UI | Two-role requester/reviewer screens, demo interactions, and later ORDS bindings. | Already started; continue after backend contracts exist. |
| UOW-002 ATP/ORDS Supplier Request Foundation | ATP schema, IAM subject/role authorization context, supplier request persistence, workflow state, assessment storage, dashboards, and ORDS APIs. | First new construction unit. |
| UOW-003 Duplicate Detection and Risk Logic | Matching logic, risk scoring rules, explainable factors, and property-based tests. | After ATP foundation. |
| UOW-004 OIC, Fusion, and Gemini Integration | Supplier creation, Fusion master sync, Gemini advisory summary, mock fallback, retry/error logs. | After ATP foundation and core logic interfaces. |
| UOW-005 Audit, Testability, and Demo Evidence | Audit records, property-based testing harness, seeded scenarios, and build/test instructions. | Cross-cutting; completed with each unit and consolidated later. |

The final unit documents may merge or split these depending on your answers below.

## Unit Decomposition Questions

Please answer each question by filling in the letter after `[Answer]:`.

### Question 1
How should we decompose the build units?

A) Oracle-layer units: Visual Builder UI, ATP/ORDS foundation, duplicate/risk logic, OIC/Fusion/Gemini integration, and audit/testing evidence.

B) Backend-first units: ATP schema, ORDS APIs, OIC/Fusion integration, Visual Builder bindings, and tests.

C) Single prototype unit containing all Visual Builder, ATP, ORDS, OIC, Fusion, and Gemini work.

D) Other (please describe after the `[Answer]:` tag)

[Answer]: A

### Question 2
Which unit should we build next?

A) ATP/ORDS Supplier Request Foundation first.

B) Visual Builder-to-ORDS binding first.

C) OIC/Fusion supplier creation integration first.

D) Other (please describe after the `[Answer]:` tag)

[Answer]: A

### Question 3
Should ATP and ORDS be handled as one construction unit or separate units?

A) One combined ATP/ORDS unit because ORDS endpoints depend directly on ATP tables, views, and packages.

B) Separate ATP schema unit first, then a separate ORDS API unit.

C) Keep ORDS mocked for now and only prepare ATP documentation.

D) Other (please describe after the `[Answer]:` tag)

[Answer]: A

### Question 4
How should the first ATP unit handle Fusion supplier master data before real Fusion access is available?

A) Use seeded/mock Fusion supplier master reference data in ATP now, then replace or refresh it through OIC sync later.

B) Wait for real Fusion access before implementing duplicate reference data.

C) Design ATP tables for both mock and real Fusion sync from the start.

D) Other (please describe after the `[Answer]:` tag)

[Answer]: C

### Question 5
What should the ATP construction output include in this phase?

A) ATP schema scripts, lookup/seed data, PL/SQL package specs/bodies, ORDS endpoint definitions, and test artifacts.

B) ATP schema scripts and seed data only.

C) Documentation-only ATP setup instructions for manual creation in Oracle Console.

D) Other (please describe after the `[Answer]:` tag)

[Answer]: A

### Question 6
How should generated Oracle artifacts be organized in the workspace root?

A) Use Oracle-focused folders such as `oracle/atp/`, `oracle/ords/`, `oracle/oic/`, and `visual-builder/`.

B) Use generic source folders such as `src/`, `tests/`, and `config/`.

C) Keep generated artifacts grouped by AIDLC unit, such as `atp-ords-foundation/`, `integration-unit/`, and `ui-unit/`.

D) Other (please describe after the `[Answer]:` tag)

[Answer]: A

### Question 7
How should property-based testing be handled for the ATP/ORDS unit?

A) Include example-based and property-based test plans for duplicate detection, risk scoring, normalization, and payload transformation.

B) Document property-based tests now, but implement executable tests in a later construction step.

C) Disable property-based testing for ATP/ORDS, which would require updating the enabled AIDLC extension configuration.

D) Other (please describe after the `[Answer]:` tag)

[Answer]: A

## Answer Analysis

The selected answers are internally consistent and require no follow-up questions.

- The decomposition uses Oracle-layer units.
- ATP/ORDS is the first new construction target.
- ATP and ORDS are combined because ORDS handlers depend directly on ATP tables, views, and PL/SQL packages.
- Fusion supplier master reference data will support both seeded/mock records now and OIC-synced records later.
- ATP construction should produce executable schema scripts, seed data, PL/SQL package specs/bodies, ORDS endpoint definitions, and test artifacts.
- Generated Oracle artifacts will live in workspace-root folders such as `oracle/atp/`, `oracle/ords/`, `oracle/oic/`, and `visual-builder/`.
- Property-based testing remains enabled for duplicate detection, risk scoring, normalization, and payload transformation.

## Validation Notes

- No Mermaid diagrams are included in this file.
- No ASCII diagrams are included in this file.
- Question formatting follows the AIDLC question format guide with meaningful options and an explicit Other option.
- Property-Based Testing extension is enabled for this project. It is not directly enforced during Units Generation, but it will apply during Functional Design, NFR Requirements, Code Generation, and Build and Test for units with business logic or data transformations.

## Approval Gate

After all `[Answer]:` tags are filled, the answers will be analyzed for ambiguity. Then this plan can be approved for generation of:

- `unit-of-work.md`
- `unit-of-work-dependency.md`
- `unit-of-work-story-map.md`
