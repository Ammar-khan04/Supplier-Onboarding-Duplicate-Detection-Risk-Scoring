# Shared Infrastructure

## Purpose

This document records infrastructure shared across the Supplier Onboarding, Duplicate Detection, and Risk Scoring construction units.

The shared infrastructure centers on a single ATP/ORDS foundation. UOW-002 creates and exposes this foundation first so later units can write duplicate/risk outputs, OIC/Fusion/Gemini results, Visual Builder bindings, and test evidence through stable database and REST contracts.

## Shared Runtime Strategy

| Shared Runtime Area | Owner | Consumers |
|---|---|---|
| Oracle database schema | UOW-002 | UOW-001, UOW-003, UOW-004, UOW-005 |
| ORDS API boundary | UOW-002 | Visual Builder, tests, OIC integrations |
| Supplier request lifecycle | UOW-002 | Visual Builder, duplicate/risk logic, integration flows |
| IAM subject and role authorization context | UOW-002 | Visual Builder, tests |
| Integration job queue/history | UOW-002 | OIC/Fusion/Gemini integration, Admin dashboard, tests |
| AI assessment history | UOW-002 | Gemini integration, Reviewer UI, Admin logs, tests |
| Risk and configuration tables | UOW-002 now; UOW-003 extends logic | Reviewer UI, Admin risk rules, tests |
| Document metadata | UOW-002 | Visual Builder, future object storage flow |

## Unit Consumers

| Unit | Shared Infrastructure Usage |
|---|---|
| UOW-001 Visual Builder Prototype UI | Consumes ORDS endpoints for dashboards, forms, review actions, Admin logs, risk rules, and risky-country maintenance. |
| UOW-002 ATP/ORDS Supplier Request Foundation | Owns the shared database, API modules, local runtime setup, and schema/seed foundation. |
| UOW-003 Duplicate Detection and Risk Logic | Reads request/reference data and writes validation, duplicate, risk, risk-factor, and final-risk outputs through UOW-002 structures. |
| UOW-004 OIC, Fusion, and Gemini Integration | Reads/writes `INTEGRATION_JOB`, request data, supplier sync records, Fusion results, and `AI_ASSESSMENT` through ORDS/ATP. |
| UOW-005 Audit, Testability, and Demo Evidence | Uses shared logs, histories, seed data, example tests, property tests, and endpoint checks. |

## Shared Local Development Infrastructure

The shared local runtime is located at `oracle/local/`.

| Artifact | Shared Purpose |
|---|---|
| `docker-compose.yml` | Starts Oracle Database Free and ORDS together. |
| `.env` | Stores local development passwords and port settings. |
| `db-init/` | Initializes app schema and seed data. |
| `ords/` | Builds and runs ORDS plus SQLcl. |
| `scripts/preflight-local-oracle-ords.sh` | Verifies prerequisites before startup. |
| `scripts/start-local-oracle-ords.sh` | Starts the local stack when Docker/Podman Compose is available. |
| `scripts/check-local-oracle-ords.sh` | Checks core ORDS endpoints. |
| `scripts/stop-local-oracle-ords.sh` | Stops or resets local services. |

Current local status: Docker Compose is available, and the local Oracle Database Free plus ORDS stack has been created and verified for the current endpoint set.

## Shared Endpoint Base

Local ORDS base:

```text
http://localhost:8080/ords/supplier-onboarding/v1/
```

This base is shared by:

- Visual Builder service connections.
- Python example tests.
- Python property-based tests.
- OIC polling or callback design in later UOW-004 work.
- Admin support and diagnostic views.

## Shared Data Ownership Rules

| Data Area | Rule |
|---|---|
| Supplier request source data | UOW-002 owns persistence; other units read/write through approved interfaces. |
| Duplicate outputs | UOW-003 owns calculation; UOW-002 owns storage. |
| Risk outputs | UOW-003 owns calculation; UOW-002 owns storage and Reviewer adjustment structures. |
| Gemini outputs | UOW-004 owns prompt/orchestration; UOW-002 owns `AI_ASSESSMENT` storage. |
| Fusion supplier creation results | UOW-004 owns integration; UOW-002 owns request status and `INTEGRATION_JOB` persistence. |
| Supplier master references | UOW-004 owns sync; UOW-002 owns reference storage. |
| Audit/action history | UOW-002 owns durable action history; UOW-005 verifies evidence. |

## Shared Security and Privacy Rules

- Visual Builder consumes ORDS only.
- Backend role checks are required before protected mutations.
- Normal responses must not expose full bank account values.
- Admin logs expose references and diagnostics, not unrestricted sensitive payload contents.
- Local `.env` credentials are development-only.
- Production identity, secrets, TLS, network hardening, backup, and monitoring require later production design.

## Shared Testing Infrastructure

| Test Area | Shared Infrastructure Need |
|---|---|
| Example lifecycle tests | Local ORDS base URL and seeded request/user data. |
| Property-based workflow tests | Resettable or seeded database state and package/API test boundaries. |
| Permission invariants | Actor subject IDs, app-role context, and protected ORDS/ATP mutations. |
| Bank masking invariants | Seeded and generated bank metadata with masked output checks. |
| Retry lineage invariants | `INTEGRATION_JOB` rows with parent-child relationships. |
| AI history invariants | Multiple `AI_ASSESSMENT` rows per request/version. |
| Justification-risk invariants | `AI_ASSESSMENT`, `REQUEST_ASSESSMENT` reviewer adjustment fields, `ACTION_HISTORY`, and final risk projection. |
| Risky-country invariants | `HIGH_RISK_COUNTRY_CONFIG` and `RISK_RULE_CONFIG` allocation checks. |

## Future Shared Infrastructure Candidates

| Candidate | Owning Stage or Unit |
|---|---|
| OCI Object Storage bucket for supplier documents | Later infrastructure/code generation or UOW-004/UOW-005 support. |
| OIC connections and integrations | UOW-004. |
| Fusion ERP REST connection | UOW-004. |
| Gemini connection and prompt configuration | UOW-004. |
| Centralized monitoring and alerting | Future Infrastructure/Operations hardening. |
| Production identity provider integration | Future production hardening. |

## Extension Compliance

| Extension Rule | Status | Rationale |
|---|---|---|
| Property-Based Testing | N/A for Shared Infrastructure document | This document preserves infrastructure needs for future PBT execution but does not generate tests. |
| Security Baseline | Disabled | Disabled in `aidlc-state.md`; transcript-specific security rules remain documented. |
| Resiliency Baseline | Disabled | Disabled in `aidlc-state.md`; transcript-specific retry and error handling remain documented. |

No blocking extension findings apply to shared infrastructure.

## Content Validation

- No Mermaid diagrams are used.
- No ASCII diagrams are used.
- Markdown tables, lists, and code fences are parser-compatible.
