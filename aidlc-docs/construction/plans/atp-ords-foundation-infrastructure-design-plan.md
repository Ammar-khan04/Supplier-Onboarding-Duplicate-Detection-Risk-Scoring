# Infrastructure Design Plan: UOW-002 ATP/ORDS Supplier Request Foundation

## Stage Context

This plan covers Construction Infrastructure Design for `UOW-002 ATP/ORDS Supplier Request Foundation`.

The infrastructure design maps the approved ATP/ORDS logical components to runnable local services and a future Oracle Cloud target. The immediate path is local Oracle Database Free plus ORDS so Visual Builder can bind to real REST APIs. The future target keeps the same boundaries: Visual Builder calls ORDS, ORDS delegates to ATP package logic, OIC handles Fusion/Gemini integration, and Fusion remains the supplier master source of truth.

## Source Artifacts Loaded

- `aidlc-docs/aidlc-state.md`
- `aidlc-docs/inception/requirements/requirements.md`
- `aidlc-docs/inception/application-design/unit-of-work.md`
- `aidlc-docs/inception/application-design/unit-of-work-dependency.md`
- `aidlc-docs/construction/atp-ords-foundation/functional-design/domain-entities.md`
- `aidlc-docs/construction/atp-ords-foundation/functional-design/business-rules.md`
- `aidlc-docs/construction/atp-ords-foundation/functional-design/business-logic-model.md`
- `aidlc-docs/construction/atp-ords-foundation/nfr-requirements/nfr-requirements.md`
- `aidlc-docs/construction/atp-ords-foundation/nfr-requirements/tech-stack-decisions.md`
- `aidlc-docs/construction/atp-ords-foundation/nfr-design/nfr-design-patterns.md`
- `aidlc-docs/construction/atp-ords-foundation/nfr-design/logical-components.md`
- `oracle/local/README.md`
- `oracle/local/docker-compose.yml`
- `oracle/local/db-init/01-schema.sql`
- `oracle/local/ords/sql/20-define-modules.sql`
- `.aidlc-rule-details/construction/infrastructure-design.md`
- `.aidlc-rule-details/common/content-validation.md`
- `.aidlc-rule-details/common/question-format-guide.md`
- `.aidlc-rule-details/extensions/testing/property-based/property-based-testing.md`

## Plan Checklist

- [x] Record NFR Design approval from the user instruction to proceed using reasonable assumptions.
- [x] Load AIDLC Infrastructure Design rules.
- [x] Load common process, session continuity, content validation, and question format rules.
- [x] Load enabled Property-Based Testing extension rules.
- [x] Load UOW-002 Functional Design artifacts.
- [x] Load UOW-002 NFR Requirements and NFR Design artifacts.
- [x] Load local Oracle Database Free and ORDS setup artifacts.
- [x] Evaluate deployment environment, compute, storage, messaging, networking, monitoring, and shared infrastructure categories.
- [x] Fill infrastructure decision answers from transcript, schemas, and existing setup artifacts.
- [x] Generate `aidlc-docs/construction/atp-ords-foundation/infrastructure-design/infrastructure-design.md`.
- [x] Generate `aidlc-docs/construction/atp-ords-foundation/infrastructure-design/deployment-architecture.md`.
- [x] Generate `aidlc-docs/construction/shared-infrastructure.md`.
- [x] Validate generated Markdown content for parser compatibility.
- [x] Update AIDLC state to Infrastructure Design Review.

## Infrastructure Decision Questions

The answers below are derived from the transcript, approved schemas, current Visual Builder prototype, and the local ORDS setup artifacts. The user authorized reasonable assumptions, so no separate blocking question file is required.

### Question 1
What deployment environment should UOW-002 target first?

A) Local developer/demo runtime using Oracle Database Free and ORDS containers, while preserving compatibility with future OCI ATP and managed ORDS deployment.

B) OCI-only deployment with no local runtime.

C) Static Visual Builder prototype only, with no backend runtime.

X) Other (please describe after the `[Answer]:` tag)

[Answer]: A

### Question 2
What compute infrastructure should run ATP/ORDS for the immediate setup?

A) Two local containers: Oracle Database Free for the ATP-like database and an ORDS container for REST APIs.

B) One combined custom container that embeds database and API logic together.

C) No local compute; wait for a cloud tenancy.

X) Other (please describe after the `[Answer]:` tag)

[Answer]: A

### Question 3
What storage infrastructure should be used?

A) Docker or Podman named volume for local Oracle data, named volume for ORDS config, ATP tables for request/log/config data, and attachment metadata with object references rather than file bytes.

B) Flat files for all supplier request and log data.

C) Store attachment bytes and all request data directly in Visual Builder.

X) Other (please describe after the `[Answer]:` tag)

[Answer]: A

### Question 4
What messaging or queue infrastructure should UOW-002 use?

A) Use `INTEGRATION_JOB` in ATP as the phase-one work queue and attempt history for `AI_EXPLANATION`, `FUSION_CREATE`, and `SUPPLIER_SYNC`; OIC polling is a later integration responsibility.

B) Add a separate message broker in UOW-002.

C) Use only transient UI state for integration work.

X) Other (please describe after the `[Answer]:` tag)

[Answer]: A

### Question 5
What networking model should local ORDS use?

A) Localhost ports for Oracle listener, EM Express, and ORDS HTTP, with a private Compose network between database and ORDS containers.

B) Public internet exposure for local ORDS endpoints.

C) No network endpoints until production.

X) Other (please describe after the `[Answer]:` tag)

[Answer]: A

### Question 6
What monitoring and diagnostic infrastructure should be included now?

A) ORDS health endpoint, endpoint checker script, container logs, Admin diagnostic endpoints backed by `INTEGRATION_JOB`, and deferred centralized production observability.

B) Full enterprise monitoring, alerting, and incident response in UOW-002.

C) Manual inspection only, with no health endpoint or logs.

X) Other (please describe after the `[Answer]:` tag)

[Answer]: A

### Question 7
What shared infrastructure should be documented?

A) Shared local Oracle/ORDS runtime for UOW-001 Visual Builder binding, UOW-002 ATP/ORDS foundation, later UOW-003 risk/duplicate logic, UOW-004 integration writes, and UOW-005 evidence/testing.

B) No shared infrastructure because each unit should create its own database and API layer.

C) Shared UI files only.

X) Other (please describe after the `[Answer]:` tag)

[Answer]: A

## Answer Analysis

All infrastructure answers select option A. These answers align with the transcript and existing schema:

- Oracle Visual Builder consumes ORDS APIs.
- ATP/ORDS own request persistence, workflow, role checks, logs, configuration, and safe projections.
- OIC remains the integration layer for Fusion, supplier sync, and Gemini orchestration.
- The local setup already provides Oracle Database Free, ORDS, schema initialization, seed data, and endpoint definitions.
- `INTEGRATION_JOB` is intentionally both a small queue and an attempt history table, avoiding a separate broker in UOW-002.
- Attachments remain metadata/object references in ATP; object storage is documented as future shared infrastructure.
- Production identity, centralized observability, backup, disaster recovery, and formal OCI network hardening are deferred beyond this unit.

No unresolved infrastructure clarification remains for this stage.

## Content Validation Notes

- No Mermaid diagrams are used.
- No ASCII diagrams are used.
- Markdown tables, question blocks, and code references are parser-compatible.

## Extension Compliance Planning

| Extension Rule | Planned Handling |
|---|---|
| Property-Based Testing | N/A for Infrastructure Design implementation; preserve PBT test-run infrastructure needs for Code Generation and Build/Test. |
| Security Baseline | Disabled in `aidlc-state.md`; transcript-specific bank masking and backend role checks remain included. |
| Resiliency Baseline | Disabled in `aidlc-state.md`; transcript-specific retry lineage and controlled failure handling remain included. |
