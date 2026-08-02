# NFR Design Plan: UOW-002 ATP/ORDS Supplier Request Foundation

## Supersession Note

This is a historical planning artifact. Later finalized schema reconciliation replaced early token/hash and table-shape wording with protected fingerprint fields, structured configuration tables, and the finalized ORDS contract. Use the current NFR design, code summaries, and `finalized-schema-reconciliation.md` where older plan wording conflicts.

## Stage Context

This plan covers Construction NFR Design for `UOW-002 ATP/ORDS Supplier Request Foundation`.

NFR Design converts the approved NFR requirements into patterns and logical components for the Oracle ATP/ORDS foundation. The design remains implementation-oriented but does not generate SQL, PL/SQL, ORDS modules, or tests yet.

## Source Artifacts Loaded

- `aidlc-docs/aidlc-state.md`
- `aidlc-docs/construction/atp-ords-foundation/functional-design/domain-entities.md`
- `aidlc-docs/construction/atp-ords-foundation/functional-design/business-rules.md`
- `aidlc-docs/construction/atp-ords-foundation/functional-design/business-logic-model.md`
- `aidlc-docs/construction/atp-ords-foundation/nfr-requirements/nfr-requirements.md`
- `aidlc-docs/construction/atp-ords-foundation/nfr-requirements/tech-stack-decisions.md`
- `.aidlc-rule-details/construction/nfr-design.md`
- `.aidlc-rule-details/common/content-validation.md`
- `.aidlc-rule-details/common/question-format-guide.md`
- `.aidlc-rule-details/extensions/testing/property-based/property-based-testing.md`

## Plan Checklist

- [x] Record NFR Requirements approval.
- [x] Load AIDLC NFR Design rules.
- [x] Load common content validation and question format rules.
- [x] Load NFR Requirements artifacts.
- [x] Load Functional Design artifacts.
- [x] Evaluate resilience, scalability, performance, security, and logical component categories.
- [x] Create NFR Design decision questions with `[Answer]:` tags.
- [x] Fill answers from approved NFR Requirements and the user's instruction to move ahead.
- [x] Analyze answers for ambiguity and contradictions.
- [x] Generate `aidlc-docs/construction/atp-ords-foundation/nfr-design/nfr-design-patterns.md`.
- [x] Generate `aidlc-docs/construction/atp-ords-foundation/nfr-design/logical-components.md`.
- [x] Validate generated content for Markdown compatibility.
- [x] Update AIDLC state to NFR Design Review.

## NFR Design Decision Questions

The answers below are derived from the approved Functional Design and NFR Requirements. No unresolved NFR Design ambiguity remains for this stage.

### Question 1
Which resilience pattern should UOW-002 use for request state changes?

A) Transactional ATP package operations that update request state and append history/log records in one controlled operation.

B) UI-driven status changes with periodic cleanup of inconsistent state.

C) External queue-first orchestration for every state change in this unit.

X) Other (please describe after the `[Answer]:` tag)

[Answer]: A

### Question 2
How should retry behavior be represented?

A) Use `INTEGRATION_JOB` as a lightweight work queue and attempt history, with parent-child retry lineage and eligibility checks in ATP package logic.

B) Overwrite the latest failed job row when retry happens.

C) Let Admin retry any failed request regardless of business state.

X) Other (please describe after the `[Answer]:` tag)

[Answer]: A

### Question 3
What scalability pattern should dashboard and log endpoints use?

A) Indexed/filterable query views with limit and offset parameters for role dashboards and Admin logs.

B) Return all rows to Visual Builder and filter client-side.

C) Optimize only after real production traffic appears.

X) Other (please describe after the `[Answer]:` tag)

[Answer]: A

### Question 4
What performance pattern should be used for request detail responses?

A) Stable projection views or package-built JSON sections that return request detail, validation, evidence placeholders, history, integration summary, and allowed actions in predictable shapes.

B) Multiple unrelated raw table calls from Visual Builder.

C) One huge unfiltered table dump for every detail page.

X) Other (please describe after the `[Answer]:` tag)

[Answer]: A

### Question 5
What security pattern should protect role-specific actions?

A) ORDS handlers call ATP authorization guards before state mutation, and Visual Builder allowed actions are treated as display hints only.

B) Visual Builder role tabs are sufficient authorization for phase one.

C) Authorization is deferred until production identity integration exists.

X) Other (please describe after the `[Answer]:` tag)

[Answer]: A

### Question 6
What sensitive-data pattern should protect bank values?

A) Store and return masked display, last-four, bank country, and protected token/hash placeholders; use safe response views for normal UI and Admin logs.

B) Store and return full account values, relying on user discretion.

C) Do not store bank metadata at all.

X) Other (please describe after the `[Answer]:` tag)

[Answer]: A

### Question 7
What logical component pattern should ORDS use?

A) Resource-oriented ORDS modules that delegate workflow, validation, authorization, dashboard, and retry logic to ATP packages.

B) ORDS handlers contain most business logic directly.

C) Visual Builder calls ATP tables directly.

X) Other (please describe after the `[Answer]:` tag)

[Answer]: A

### Question 8
How should testability be designed into this unit?

A) Define package boundaries and test helpers that support example tests and Python `pytest` plus `hypothesis` property tests for state transitions, permissions, masking, retry, upsert, and history invariants.

B) Test only through manual UI walkthroughs.

C) Test only the DDL scripts compile.

X) Other (please describe after the `[Answer]:` tag)

[Answer]: A

## Answer Analysis

All eight answers select option A. These choices are consistent with the approved ATP/ORDS Functional Design and NFR Requirements:

- ATP package logic owns state and reliability patterns.
- ORDS exposes stable resource contracts and delegates decisions.
- Visual Builder stays a presentation layer.
- Backend role checks are mandatory in phase one.
- Bank values are masked or protected in normal views and logs.
- `ACTION_HISTORY`, `AI_ASSESSMENT`, and `INTEGRATION_JOB` remain append-oriented.
- PBT testability is designed into package and API boundaries, with implementation deferred to Code Generation.

No clarification file is required.

## Content Validation

- No Mermaid diagrams are used.
- No ASCII diagrams are used.
- Markdown tables and question blocks use simple parser-compatible formatting.
