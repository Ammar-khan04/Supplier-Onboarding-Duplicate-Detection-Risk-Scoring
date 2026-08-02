# NFR Requirements Plan: UOW-002 ATP/ORDS Supplier Request Foundation

## Supersession Note

This is a historical planning artifact. Later finalized schema reconciliation replaced early role-simulation/table-shape assumptions with Oracle IAM subject-column assumptions and the finalized ATP/ORDS contract. Use the current NFR requirements, NFR design, code summaries, and `finalized-schema-reconciliation.md` where older plan wording conflicts.

## Stage Context

This plan covers Construction NFR Requirements for `UOW-002 ATP/ORDS Supplier Request Foundation`.

The unit owns the Oracle ATP and ORDS foundation for supplier request persistence, workflow state, role enforcement, foundational validation, dashboard query models, supplier document metadata, Fusion supplier reference storage, action history, AI assessment history, integration job logs, configuration, and retry metadata.

## Source Artifacts Loaded

- `aidlc-docs/aidlc-state.md`
- `aidlc-docs/inception/requirements/requirements.md`
- `aidlc-docs/inception/plans/execution-plan.md`
- `aidlc-docs/inception/application-design/services.md`
- `aidlc-docs/inception/application-design/component-dependency.md`
- `aidlc-docs/inception/application-design/unit-of-work.md`
- `aidlc-docs/construction/atp-ords-foundation/functional-design/domain-entities.md`
- `aidlc-docs/construction/atp-ords-foundation/functional-design/business-rules.md`
- `aidlc-docs/construction/atp-ords-foundation/functional-design/business-logic-model.md`
- `.aidlc-rule-details/construction/nfr-requirements.md`
- `.aidlc-rule-details/extensions/testing/property-based/property-based-testing.md`

## Plan Checklist

- [x] Load AIDLC NFR Requirements rules.
- [x] Load common AIDLC process, continuity, content validation, and question format rules.
- [x] Load PBT extension rules because Property-Based Testing is enabled.
- [x] Confirm Functional Design is complete for UOW-002.
- [x] Analyze UOW-002 functional design for NFR drivers.
- [x] Create NFR decision questions with `[Answer]:` tags.
- [x] Fill NFR decision answers from approved transcript-derived requirements and the user's instruction to move forward.
- [x] Analyze answers for ambiguity or contradictions.
- [x] Generate `aidlc-docs/construction/atp-ords-foundation/nfr-requirements/nfr-requirements.md`.
- [x] Generate `aidlc-docs/construction/atp-ords-foundation/nfr-requirements/tech-stack-decisions.md`.
- [x] Include PBT-09 framework selection in tech-stack decisions.
- [x] Validate generated content for Markdown compatibility.
- [x] Update AIDLC state to NFR Requirements Review.

## NFR Decision Questions

The answers below are derived from approved prior AIDLC artifacts and the user's instruction to move forward. No unresolved NFR ambiguity remains for this stage.

### Question 1
What delivery posture should UOW-002 use for NFRs?

A) Production-oriented foundation with phase-one limitations documented for role simulation, disabled security/resiliency extensions, and mockable integrations.

B) Demo-only foundation optimized for visual walkthroughs, with minimal backend NFRs.

C) Full enterprise production hardening including identity federation, security baseline enforcement, resiliency baseline enforcement, and formal operations controls in this unit.

X) Other (please describe after the `[Answer]:` tag)

[Answer]: A

### Question 2
What performance and volume target should guide the ATP/ORDS foundation?

A) Support the approved prototype volume of 50 to 100 supplier requests and at least a few hundred supplier reference records, while avoiding hardcoded tiny data assumptions and designing queries for growth.

B) Support only a handful of records for supervisor demonstration.

C) Support enterprise-scale production volume immediately, including thousands of concurrent users and millions of supplier records.

X) Other (please describe after the `[Answer]:` tag)

[Answer]: A

### Question 3
How should security and privacy be handled in UOW-002?

A) Enforce phase-one role simulation through ATP/ORDS, mask bank data in normal responses and logs, avoid full bank exposure, and document production identity and deeper protection as later hardening.

B) Trust Visual Builder role visibility only and defer backend authorization.

C) Implement full production IAM, encryption key management, and security baseline controls in this unit.

X) Other (please describe after the `[Answer]:` tag)

[Answer]: A

### Question 4
What reliability model should UOW-002 use?

A) Use transaction-safe ATP state changes, append-oriented history/log tables, clear business-vs-technical error classification, and Admin retry only for eligible technical failures.

B) Store only the latest request status and overwrite prior log data.

C) Implement full disaster recovery and high-availability runbooks in this unit.

X) Other (please describe after the `[Answer]:` tag)

[Answer]: A

### Question 5
Which property-based testing framework should be selected for UOW-002 and later units?

A) Python `pytest` plus `hypothesis` as the property-based harness, driving ORDS APIs and ATP/PLSQL behavior through `requests` and `oracledb` where available.

B) JavaScript `fast-check` only, focused on Visual Builder/client-side logic.

C) No PBT framework for UOW-002 because the main logic is in PL/SQL.

X) Other (please describe after the `[Answer]:` tag)

[Answer]: A

### Question 6
What testing posture should UOW-002 carry into Code Generation?

A) Combine example-based scenario tests with property-based tests for workflow transitions, role permissions, request persistence, bank masking, retry chains, supplier reference upserts, AI assessment history, and correction visibility.

B) Use only manual UI testing through Visual Builder.

C) Use only SQL smoke tests for table creation.

X) Other (please describe after the `[Answer]:` tag)

[Answer]: A

### Question 7
How should observability and auditability be represented in this unit?

A) Use `ACTION_HISTORY`, `AI_ASSESSMENT`, and `INTEGRATION_JOB` as append-oriented evidence sources, expose Admin diagnostics through ORDS, and keep production monitoring as a later infrastructure/operations concern.

B) Store diagnostic messages only in transient UI state.

C) Implement full centralized observability tooling in this unit.

X) Other (please describe after the `[Answer]:` tag)

[Answer]: A

### Question 8
What should be the maintainability approach for UOW-002?

A) Keep business rules in ATP packages, expose stable resource-oriented ORDS APIs, separate generated schema/package/seed/ORDS/test folders, and keep Visual Builder as a client of ORDS contracts.

B) Put most workflow logic in Visual Builder for speed.

C) Put most workflow logic in OIC integrations.

X) Other (please describe after the `[Answer]:` tag)

[Answer]: A

## Answer Analysis

All eight answers select option A. These choices align with the approved requirements and functional design:

- UOW-002 is a production-oriented Oracle ATP/ORDS foundation with phase-one limitations.
- Backend role enforcement is required even though production identity integration is deferred.
- Bank data must be masked in normal views and logs.
- State changes, review actions, AI assessments, and integration attempts must be append-oriented and auditable.
- Retry must never bypass validation, duplicate/risk review, or approval.
- PBT is enabled, and PBT-09 is satisfied by selecting Python `pytest` plus `hypothesis` as the property-based testing framework.

No clarification file is required.

## Content Validation

- No Mermaid diagrams are used.
- No ASCII diagrams are used.
- Markdown tables and question blocks use simple parser-compatible formatting.
