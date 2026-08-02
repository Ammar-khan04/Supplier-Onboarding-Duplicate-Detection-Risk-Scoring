# Unit of Work Dependencies

## Dependency Summary

| Unit | Depends On | Used By | Dependency Type |
|---|---|---|---|
| UOW-001 Visual Builder Prototype UI | UOW-002 API contracts for live binding | Requester, Reviewer, and Admin users | REST/API dependency |
| UOW-002 ATP/ORDS Supplier Request Foundation | None for initial build | UOW-001, UOW-003, UOW-004, UOW-005 | Foundational database/API dependency |
| UOW-003 Duplicate Detection and Risk Logic | UOW-002 request/reference/result structures | UOW-001, UOW-004, UOW-005 | Business logic dependency |
| UOW-004 OIC, Fusion, and Gemini Integration | UOW-002 request/log structures and UOW-003 risk/duplicate outputs | UOW-001, UOW-005 | Integration dependency |
| UOW-005 Audit, Testability, and Demo Evidence | UOW-002, UOW-003, UOW-004, and UOW-001 | Supervisor demo and build/test stage | Cross-cutting evidence dependency |

## Construction Order

1. UOW-002 ATP/ORDS Supplier Request Foundation
2. UOW-003 Duplicate Detection and Risk Logic
3. UOW-004 OIC, Fusion, and Gemini Integration
4. UOW-001 Visual Builder Prototype UI binding completion
5. UOW-005 Audit, Testability, and Demo Evidence consolidation

The Visual Builder prototype already exists, but live service binding should wait until UOW-002 exposes stable ORDS contracts.

## Dependency Details

### UOW-002 Before UOW-003

Duplicate detection and risk scoring need:

- Supplier request records.
- Supplier site, contact, tax, address, business unit, category, spend, and bank metadata.
- Fusion supplier reference records, seeded now and sync-ready later.
- Result tables for duplicate matches, match factors, risk scores, and risk factors.
- PL/SQL or ORDS execution surfaces for running and reading logic outputs.

### UOW-002 Before UOW-004

OIC, Fusion, and Gemini integration need:

- Approved request data to transform.
- Status values for `Approved`, `Submitted to Fusion`, `Created in Fusion`, and `Integration Failed`.
- Integration log tables.
- Retry metadata.
- AI summary storage.
- Supplier master reference tables for OIC sync output.

### UOW-003 Before Parts of UOW-004

Gemini advisory summaries should receive:

- Validation findings.
- Duplicate factors.
- Risk factors.
- Current request data.

Fusion supplier creation can be mocked before all Gemini behavior exists, but final reviewer evidence should include UOW-003 outputs.

### UOW-002 Before UOW-001 Live Binding

Visual Builder live binding needs:

- Request create/update/submit endpoints.
- Dashboard endpoints.
- Request detail endpoints.
- Review action endpoints.
- Integration log endpoints.
- Attachment metadata endpoints.

Until those are available, Visual Builder can remain a static or semi-interactive prototype.

### UOW-005 Across All Units

Audit and testability need evidence from every unit:

- UOW-002 provides audit tables and base lifecycle logs.
- UOW-003 provides duplicate/risk PBT evidence.
- UOW-004 provides payload transformation and integration failure scenario evidence.
- UOW-001 provides supervisor demo visibility.

## Interface Contracts by Unit

| Producer | Consumer | Contract |
|---|---|---|
| UOW-002 | UOW-001 | ORDS JSON endpoints for requests, dashboards, reviews, logs, and metadata. |
| UOW-002 | UOW-003 | ATP tables/views/packages for request data and supplier reference data. |
| UOW-003 | UOW-002 | Stored validation, duplicate, and risk outputs. |
| UOW-002 | UOW-004 | Approved request data and integration log persistence. |
| UOW-004 | UOW-002 | Fusion response, AI summary, supplier sync, and integration status updates. |
| UOW-003 | UOW-004 | Risk and duplicate context for Gemini advisory prompts. |
| UOW-005 | All units | Test, audit, and demo evidence expectations. |

## Shared Data Ownership

| Data Area | Owning Unit | Notes |
|---|---|---|
| Supplier request header/details | UOW-002 | Source data for all downstream logic. |
| Supplier site/contact/bank metadata | UOW-002 | Bank display must remain masked in normal views. |
| IAM subject and app-role authorization context | UOW-002 | Requester, Reviewer, and Admin behavior for the prototype and future IAM claims. |
| Status history | UOW-002 | Used by dashboards, audit, and integration handling. |
| Validation findings | UOW-003 produces; UOW-002 stores | UOW-002 may implement minimal required checks for submit flow. |
| Duplicate matches and factors | UOW-003 produces; UOW-002 stores | Used by reviewer UI, AI, and risk scoring. |
| Risk scores and factors | UOW-003 produces; UOW-002 stores | Used by reviewer UI and AI. |
| AI summaries | UOW-004 produces; UOW-002 stores | Advisory only; no automatic decision authority. |
| Fusion supplier references | UOW-004 sync produces; UOW-002 stores | UOW-002 seeds mock/reference data before real sync. |
| Integration logs | UOW-004 produces; UOW-002 stores | Used by Admin retry/support views. |
| Audit records | UOW-002 stores; UOW-005 verifies | Covers statuses, decisions, AI timestamps, and integration attempts. |

## Risk and Mitigation Matrix

| Risk | Affected Units | Mitigation |
|---|---|---|
| Real Fusion access unavailable | UOW-004, UOW-003, UOW-002 | UOW-002 supports seeded/mock supplier reference data and UOW-004 supports mock Fusion responses. |
| ORDS contracts unstable while UI is being built | UOW-001, UOW-002 | Build UOW-002 first, then bind Visual Builder to stable endpoints. |
| Duplicate/risk logic coupled too tightly to UI | UOW-001, UOW-003 | Keep matching and scoring logic behind ATP/ORDS services, not inside Visual Builder. |
| Sensitive bank values exposed | UOW-002, UOW-003, UOW-001 | Store/display masked values in normal views and revisit deeper protection during NFR Design. |
| PBT requirements missed | UOW-003, UOW-004, UOW-005 | Carry PBT rules into Functional Design, Code Generation, and Build and Test. |
| ATP becomes final supplier master by accident | UOW-002, UOW-004 | Keep Fusion as system of record; ATP stores staging, references, logs, and status only. |

## PBT Compliance Summary for Units Generation

| Rule | Status | Rationale |
|---|---|---|
| PBT-01 | N/A for this stage | Functional Design will identify testable properties per unit. |
| PBT-02 through PBT-08 | N/A for this stage | Code and test generation have not started. |
| PBT-09 | N/A for this stage | NFR Requirements will select the framework. |
| PBT-10 | N/A for this stage | Code Generation and Build/Test will enforce complementary example and property tests. |

No blocking PBT findings apply during Units Generation.
