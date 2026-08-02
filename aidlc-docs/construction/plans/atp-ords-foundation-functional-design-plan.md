# Functional Design Plan: UOW-002 ATP/ORDS Supplier Request Foundation

## Supersession Note

This is a historical planning artifact. The user later supplied `/home/ammarkhan/Downloads/technical-design (2).md` as the finalized schema source during Code Generation Review. Current generated design and code use the finalized flattened request model, Oracle IAM subject-column assumptions, structured configuration tables, `/requests`, `/documents`, `/risk-rules`, and `/high-risk-countries` contracts. Use `aidlc-docs/construction/atp-ords-foundation/code/finalized-schema-reconciliation.md` and the updated functional design files as the current source of truth where this plan's earlier answer options conflict.

## Stage Context

This plan starts Construction Functional Design for `UOW-002 ATP/ORDS Supplier Request Foundation`.

The unit creates the database and REST foundation for:

- Supplier request persistence.
- Flattened supplier request fields, document metadata, assessment history, and status history.
- IAM subject/role authorization context for `Requester`, `Reviewer`, and `Admin`.
- Workflow state and review decision persistence.
- Foundational validation result storage.
- Supplier master reference storage for seeded/mock data now and OIC sync later.
- Integration log and retry metadata storage.
- Audit record storage.
- Dashboard/query surfaces and ORDS-facing API behavior.

This stage is technology-aware enough to define ATP/ORDS behavior, but it is still Functional Design. Actual SQL, PL/SQL, ORDS module definitions, seed scripts, and tests are generated later during Code Generation.

## Source Artifacts Loaded

- `aidlc-docs/inception/requirements/requirements.md`
- `aidlc-docs/inception/user-stories/stories.md`
- `aidlc-docs/inception/user-stories/personas.md`
- `aidlc-docs/inception/application-design/application-design.md`
- `aidlc-docs/inception/application-design/components.md`
- `aidlc-docs/inception/application-design/component-methods.md`
- `aidlc-docs/inception/application-design/services.md`
- `aidlc-docs/inception/application-design/component-dependency.md`
- `aidlc-docs/inception/application-design/unit-of-work.md`
- `aidlc-docs/inception/application-design/unit-of-work-dependency.md`
- `aidlc-docs/inception/application-design/unit-of-work-story-map.md`

## Plan Checklist

- [x] Load AIDLC Functional Design rules.
- [x] Load PBT extension rules because Property-Based Testing is enabled.
- [x] Load UOW-002 unit definition, dependencies, and story map.
- [x] Confirm UOW-002 owns ATP/ORDS foundation and precedes duplicate/risk and OIC/Fusion/Gemini units.
- [x] Create functional design questions with `[Answer]:` tags.
- [x] Collect answers for all functional design questions.
- [x] Analyze answers for contradictions, ambiguity, or missing decisions.
- [x] Resolve follow-up questions if any answer is unclear.
- [x] Generate `aidlc-docs/construction/atp-ords-foundation/functional-design/domain-entities.md`.
- [x] Generate `aidlc-docs/construction/atp-ords-foundation/functional-design/business-rules.md`.
- [x] Generate `aidlc-docs/construction/atp-ords-foundation/functional-design/business-logic-model.md`.
- [x] Include PBT-01 "Testable Properties" coverage in functional design artifacts.
- [x] Validate functional design completeness against assigned stories.
- [x] Update AIDLC state after Functional Design artifacts are generated.

## Planned Functional Design Artifacts

| Artifact | Purpose |
|---|---|
| `domain-entities.md` | Defines logical ATP entities, relationships, ownership, sensitive fields, and role-simulation data. |
| `business-rules.md` | Defines workflow, validation, role-permission, retry, audit, masking, and dashboard rules. |
| `business-logic-model.md` | Defines request lifecycle flows, package/API behavior, state transitions, and PBT testable properties. |

## Functional Design Questions

Please answer each question by filling in the letter after `[Answer]:`.

### Question 1
How detailed should the ATP relational domain model be for phase one?

A) Full normalized model with separate logical entities for request header, supplier detail, site, contact, bank metadata, attachments, status history, validation findings, duplicate results, risk results, review decisions, integration logs, audit records, role simulation, lookups, and supplier references.

B) Medium model with core request tables plus JSON columns for secondary details such as validation findings, duplicate/risk outputs, and integration details.

C) Minimal model with one main request table and a small number of supporting tables for status, roles, and logs.

D) Other (please describe after the `[Answer]:` tag)

[Answer]: A

### Question 2
Where should workflow state transition rules live?

A) ATP package/state-machine logic is the source of truth, with ORDS only exposing actions and Visual Builder only displaying returned state.

B) ORDS handlers own most workflow checks, with ATP tables storing only final status values.

C) Visual Builder controls phase-one state transitions, with ATP mainly storing submitted values.

D) Other (please describe after the `[Answer]:` tag)

[Answer]: A

### Question 3
How strict should role simulation be in the ATP/ORDS foundation?

A) Store prototype users and roles in ATP, and require ORDS/ATP checks for all protected actions: requester create/update/submit, reviewer review decisions, and admin logs/retry.

B) Store roles in ATP, but enforce most role visibility in Visual Builder only for the prototype.

C) Keep role simulation as hardcoded seed assumptions and defer enforcement until later.

D) Other (please describe after the `[Answer]:` tag)

[Answer]: A

### Question 4
Which validation behavior belongs in UOW-002 versus the later Duplicate/Risk unit?

A) UOW-002 handles foundational submit validation and storage of validation findings; UOW-003 later expands validation, duplicate detection, and risk scoring logic.

B) UOW-002 should implement all business validation, duplicate detection, and risk scoring immediately.

C) UOW-002 only stores request data and does not run any validation.

D) Other (please describe after the `[Answer]:` tag)

[Answer]: A

### Question 5
How should supplier bank information be represented in ATP functional design?

A) Store masked display value, last-four value, bank country, and a protected comparison token/hash placeholder; never expose full account number in normal views.

B) Store full bank account number in ATP for prototype simplicity, but mask it in the UI.

C) Store only free-text bank information and defer structured bank matching.

D) Other (please describe after the `[Answer]:` tag)

[Answer]: A

### Question 6
How should supplier master reference data be represented before real Fusion sync is available?

A) Use the same supplier reference entity for both seeded/mock records and future OIC-synced Fusion records, with source type and sync metadata fields.

B) Use separate mock supplier reference tables now and design real Fusion sync tables later.

C) Do not model supplier references until real Fusion access is available.

D) Other (please describe after the `[Answer]:` tag)

[Answer]: A

### Question 7
How should attachments be handled in this unit's functional design?

A) ATP stores document metadata and object references only; file content belongs in OCI Object Storage or a later configured storage layer.

B) ATP stores document metadata and BLOB content directly for phase one.

C) Defer attachment persistence until after core request workflow works.

D) Other (please describe after the `[Answer]:` tag)

[Answer]: A

### Question 8
How should Admin integration log and retry behavior be modeled?

A) Store each integration attempt with OIC instance ID, payload reference, response, error, timestamp, retry count, retry eligibility, and admin retry audit entries.

B) Store only the latest integration status and error message on the supplier request.

C) Store logs as unstructured text for prototype display only.

D) Other (please describe after the `[Answer]:` tag)

[Answer]: A

### Question 9
What dashboard/query behavior should UOW-002 own?

A) UOW-002 owns requester, reviewer, and admin dashboard query models, with role-filtered rows and stable ORDS response shapes for Visual Builder.

B) UOW-002 only exposes raw tables/views, and Visual Builder performs dashboard filtering.

C) Dashboard queries are deferred until after request create/submit works.

D) Other (please describe after the `[Answer]:` tag)

[Answer]: A

### Question 10
Which testable properties should UOW-002 explicitly identify for PBT-01?

A) Identify properties for workflow state transitions, role permission checks, idempotent retry/log updates where applicable, masking/token invariants, and request read/write round-trip behavior.

B) Identify only role permission and status transition properties; leave masking and read/write properties for later.

C) Mark UOW-002 as having no PBT-applicable properties because duplicate/risk logic is in UOW-003.

D) Other (please describe after the `[Answer]:` tag)

[Answer]: A

## Validation Notes

- No Mermaid diagrams are included in this plan.
- No ASCII diagrams are included in this plan.
- Question formatting follows the AIDLC question format guide with meaningful options and an explicit Other option.
- PBT-01 is applicable during Functional Design because UOW-002 contains stateful workflow, role-permission logic, masking/token invariants, and data transformations between ORDS payloads and ATP persistence.

## Answer Analysis

All ten answers selected option A. The selected answers are internally consistent and align to the final-version target:

- ATP owns the normalized persistence model and workflow source of truth.
- ORDS exposes controlled actions and stable response shapes.
- Visual Builder remains a presentation layer.
- Prototype roles are stored and enforced through ATP/ORDS.
- UOW-002 owns foundational validation and storage while UOW-003 later expands duplicate detection and risk logic.
- Sensitive bank data is represented through masked values, last-four values, and protected fingerprints in the finalized implementation.
- Seeded/mock and future OIC-synced supplier master records share one reference model.
- Attachment content is kept outside ATP while ATP stores metadata and object references.
- Admin integration logs and retry audits are structured.
- PBT-01 properties are explicitly identified for workflow, permissions, masking, retry/log behavior, and request persistence.

No follow-up question file is required.

## PBT Compliance Planning

| Rule | Planned Handling |
|---|---|
| PBT-01 | Functional Design artifacts will include a `Testable Properties` section for each UOW-002 component or explicitly mark no properties with rationale. |
| PBT-02 through PBT-08 | Not enforced until Code Generation, but candidate properties will be captured now where applicable. |
| PBT-09 | Enforced in NFR Requirements, not this stage. |
| PBT-10 | Enforced in Code Generation and Build/Test; functional design will preserve example-based scenario needs. |

## Next Action After Answers

After all `[Answer]:` tags are completed, the answers will be analyzed for ambiguity. Then the Functional Design artifacts for `atp-ords-foundation` can be generated.
