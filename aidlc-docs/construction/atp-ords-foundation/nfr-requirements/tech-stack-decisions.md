# Tech Stack Decisions: UOW-002 ATP/ORDS Supplier Request Foundation

## Purpose

This document records the technology decisions needed by the NFR Requirements stage for UOW-002. These decisions guide NFR Design, Infrastructure Design, Code Generation, and Build/Test.

## Decision Summary

| Decision ID | Area | Decision | Rationale |
|---|---|---|---|
| TSD-UOW002-001 | Database | Oracle Autonomous Transaction Processing with SQL tables, constraints, indexes, views, and PL/SQL packages. | The transcript and application design identify ATP as the staging, workflow, validation, tracking, and log store. |
| TSD-UOW002-002 | API Layer | Oracle REST Data Services resource modules over ATP package/view behavior. | Visual Builder must call ORDS APIs and must not own workflow decisions or call Fusion directly. |
| TSD-UOW002-003 | UI Client | Oracle Visual Builder consumes stable ORDS responses and displays role-specific allowed actions. | Keeps Visual Builder as presentation layer while ATP/ORDS enforce role and workflow rules. |
| TSD-UOW002-004 | Workflow Logic | PL/SQL package/state-machine logic is the source of truth for request status transitions. | Functional Design approved ATP package logic as the workflow owner. |
| TSD-UOW002-005 | Role Model | Phase-one Requester, Reviewer, and Admin behavior is enforced through actor subject IDs, app-role context, and ORDS/ATP checks. | Matches approved three-role model and avoids trusting UI-only visibility. |
| TSD-UOW002-006 | Document Handling | ATP stores request document metadata, latest flags, uploader evidence, and optional content placeholders; production file bytes belong in OCI Object Storage or a later configured storage layer. | Keeps document evidence linked to the request while leaving production file storage to a dedicated storage layer. |
| TSD-UOW002-007 | Integration Logs | `INTEGRATION_JOB` is the integration work queue and attempt history table. | Supports Admin log views, retry lineage, payload references, response references, and error diagnostics. |
| TSD-UOW002-008 | AI History | `AI_ASSESSMENT` stores each Gemini response as append-only history. | Regenerated AI summaries must not overwrite history. |
| TSD-UOW002-009 | Action Audit | `ACTION_HISTORY` stores workflow status changes and reviewer decisions. | Consolidates auditable human/system action evidence in one place. |
| TSD-UOW002-010 | Configuration | `CONFIGURATION` stores small scalar key/value settings, while structured tables store risk rules, score bands, risky countries, tax requirements, generic phrases, and business-unit/site mappings. | Keeps thresholds, tax requirements, generic phrases, site mappings, risk weights, and Admin-managed risky countries adjustable without hiding business controls in JSON. |
| TSD-UOW002-011 | Property-Based Testing | Python `pytest` plus `hypothesis` is selected as the PBT framework. | Hypothesis supports custom generators, shrinking, reproducible seeds, and can drive ORDS APIs or database behavior through Python clients. |
| TSD-UOW002-012 | API Test Harness | Python `requests` for ORDS API tests and `oracledb` for database-level tests where direct database access is available. | Allows example and property tests to validate both REST contracts and ATP behavior. |
| TSD-UOW002-013 | Example Tests | `pytest` example-based tests plus SQL/PLSQL smoke checks generated during Code Generation. | Critical business flows need pinned examples in addition to PBT. |
| TSD-UOW002-014 | Browser Scenario Tests | Playwright remains appropriate for Visual Builder preview and UI scenario checks, but it is not the main PBT framework. | UI scenario tests complement API/database tests. |

## PBT-09 Framework Selection

PBT-09 requires a framework that supports custom domain generators, automatic shrinking, seed-based reproducibility, and integration with the project test runner.

Selected stack:

| Purpose | Tool |
|---|---|
| Test runner | `pytest` |
| Property-based framework | `hypothesis` |
| ORDS API client | `requests` |
| Oracle database client | `oracledb` |
| Optional UI scenario runner | Playwright |

## PBT-09 Verification

| Criterion | Decision |
|---|---|
| Custom generators for domain types | `hypothesis` strategies will generate supplier request payloads, role/action pairs, workflow commands, bank profile inputs, supplier reference rows, retry chains, and AI assessment events. |
| Automatic shrinking | `hypothesis` provides shrinking by default and must not be disabled in generated tests. |
| Seed-based reproducibility | Generated test instructions must record Hypothesis reproduction output and support deterministic profiles or CI seed logging. |
| Existing test runner integration | `hypothesis` integrates with `pytest`. |
| Dependency declaration | Code Generation must create dependency files for the test harness, including `pytest`, `hypothesis`, `requests`, and `oracledb` as needed. |

## Testing Implications for Code Generation

Code Generation must create:

- `tests/example/` for concrete lifecycle and API scenarios.
- `tests/property/` for PBT generators and property tests.
- A dependency file for Python test dependencies.
- Test configuration or instructions showing how to run PBT with shrinking and reproducibility.
- Example tests for create, submit, validation failure, review accept/reject/correction, correction resubmit, Admin log view, and retry.
- Property tests for workflow transitions, role permissions, request read/write preservation, bank masking, supplier reference upsert idempotence, retry chain invariants, AI assessment append-only history, dashboard visibility, and correction visibility.

## Oracle Implementation Implications

| Concern | Decision |
|---|---|
| SQL object organization | DDL belongs in `oracle/atp/schema/`. |
| PL/SQL organization | Package specs and bodies belong in `oracle/atp/packages/`. |
| Seed data | Configuration, risky countries, supplier references, and demo scenarios belong in `oracle/atp/seed/`. |
| ORDS modules | ORDS module/template/handler definitions belong in `oracle/ords/modules/`. |
| Integration placeholders | OIC/Fusion/Gemini design and payload artifacts belong in `oracle/oic/` when later units run. |
| Tests | Example tests belong in `tests/example/`; property tests belong in `tests/property/`. |

## Deferred Technology Decisions

| Deferred Area | Later Stage |
|---|---|
| Exact ATP connection method and wallet handling | Infrastructure Design / Code Generation |
| Exact ORDS deployment/import mechanism | Infrastructure Design / Code Generation |
| Production identity provider and SSO integration | NFR Design / Infrastructure Design / future production hardening |
| OCI Object Storage bucket and signed URL pattern | Infrastructure Design |
| OIC package/export details | UOW-004 Construction stages |
| Fusion supplier API payload specifics | UOW-004 Construction stages |
| Gemini authentication and model configuration | UOW-004 Construction stages |
| Centralized monitoring, alerting, backup, and DR | Infrastructure Design / Build-Test / future Operations |

## Extension Compliance

| Extension Rule | Status | Rationale |
|---|---|---|
| PBT-09 | Compliant | `pytest` plus `hypothesis` is selected and documented as the property-based testing stack. Required dependencies are specified for Code Generation. |
| Security Baseline | Disabled | No security-baseline rules are enforced, but transcript-specific security requirements remain in the NFR requirements. |
| Resiliency Baseline | Disabled | No resiliency-baseline rules are enforced, but transcript-specific reliability/retry requirements remain in the NFR requirements. |

## Content Validation

- No Mermaid diagrams are used.
- No ASCII diagrams are used.
- Markdown tables and lists are simple and parser-compatible.
