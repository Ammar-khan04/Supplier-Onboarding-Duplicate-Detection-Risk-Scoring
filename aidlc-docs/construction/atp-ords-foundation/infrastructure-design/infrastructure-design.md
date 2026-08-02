# Infrastructure Design: UOW-002 ATP/ORDS Supplier Request Foundation

## Purpose

This document maps the approved UOW-002 ATP/ORDS logical design to infrastructure services and runtime responsibilities.

The immediate objective is to move toward a runnable local ORDS setup that supports Visual Builder binding and backend API testing. The future deployment target remains Oracle Cloud aligned: Oracle Visual Builder calls ORDS, ORDS exposes ATP-backed APIs, ATP stores request workflow data, OIC handles Fusion/Gemini integration, and Fusion remains the supplier master source of truth.

## Infrastructure Scope

UOW-002 infrastructure owns:

- Local Oracle Database Free runtime that represents ATP for development and supervisor demo setup.
- Local ORDS runtime exposing supplier onboarding REST endpoints.
- Database volumes and ORDS configuration volumes.
- Local schema initialization, seed data, and ORDS module installation scripts.
- Health checks and endpoint verification scripts.
- Runtime boundaries for Visual Builder, later duplicate/risk logic, OIC/Fusion/Gemini flows, Admin logs, and tests.

UOW-002 infrastructure does not own:

- Production OCI tenancy provisioning.
- Production identity federation or SSO.
- Production backup, disaster recovery, alerting, or incident response runbooks.
- OIC integration deployment packages.
- Fusion supplier API credentials.
- Gemini credentials or model configuration.
- Attachment object storage implementation beyond metadata/object-reference design.

## Assumption-Based Infrastructure Decisions

| Category | Decision | Source and Rationale |
|---|---|---|
| Deployment environment | Use local Oracle Database Free plus ORDS containers now; keep OCI ATP/ORDS compatibility later. | The user asked to move toward ORDS setup, and `oracle/local/` already contains containerized database and ORDS setup artifacts. |
| Cloud/platform alignment | Oracle stack: Visual Builder, ATP, ORDS, OIC, Fusion ERP, and Gemini through OIC. | Approved requirements and transcript-derived architecture. |
| Compute | Two local services: `oracle-db` and `ords`. | Matches `oracle/local/docker-compose.yml` and keeps database/API separation clear. |
| Storage | Named volume for Oracle data, named volume for ORDS config, ATP tables for durable request/log/config data. | Matches local Compose setup and finalized schema. |
| Attachments | Store metadata and object references in ATP; file bytes belong to OCI Object Storage or a later configured storage layer. | Approved Functional Design and NFR decisions. |
| Messaging | Use `INTEGRATION_JOB` as the small work queue and attempt history. | Approved schema and integration log design. |
| Networking | Localhost exposes Oracle listener, EM Express, and ORDS; containers communicate over a private Compose network. | Matches local setup and keeps prototype networking simple. |
| Monitoring | Use health endpoint, endpoint checker script, container logs, and Admin log endpoints. | Meets phase-one observability without adding production operations scope. |
| Role enforcement | Oracle IAM subject/role context is enforced by ORDS/ATP checks. Local tests pass actor subject and roles as request parameters. | Visual Builder role tabs are not the authorization boundary. |
| Testing | Use Python `pytest`, `hypothesis`, `requests`, and `oracledb` during Code Generation and Build/Test. | PBT is enabled and framework selection is approved. |

## Service Mapping

| Logical Component | Infrastructure Service | Local Implementation | Future OCI Implementation |
|---|---|---|---|
| Request Core Tables | Oracle database | Oracle Database Free container, `SUPPLIER_APP` schema | Oracle ATP schema |
| IAM Subject Authorization Context | Oracle IAM plus ATP package checks | Local actor parameters interpreted by `supplier_auth_pkg` | Oracle IAM claims plus ATP/ORDS authorization checks |
| Workflow Package | PL/SQL in database | Generated package-backed local DB logic | PL/SQL package in ATP |
| Authorization Package | PL/SQL plus ORDS handlers | Generated in later Code Generation | PL/SQL plus ORDS privilege/handler checks |
| Validation Package | PL/SQL in database | Generated in later Code Generation | PL/SQL package in ATP |
| Review Package | PL/SQL in database | Generated package-backed review, correction, duplicate, and adjustment logic | PL/SQL package in ATP |
| Integration Job Package | Oracle database plus ORDS | `INTEGRATION_JOB` table and starter Admin endpoints | ATP queue table read/written by OIC through ORDS |
| Configuration Package | Oracle database plus ORDS | `CONFIGURATION`, `RISK_RULE_CONFIG`, `RISK_SCORE_BAND_CONFIG`, `HIGH_RISK_COUNTRY_CONFIG` | ATP-backed configuration APIs |
| Safe Projection Views | Oracle views/packages | Starter views and ORDS queries | ATP views/packages exposed through ORDS |
| ORDS Resource Modules | ORDS service | ORDS container at `/ords/supplier-onboarding/v1/` | Managed ORDS or configured ORDS fronting ATP |
| Visual Builder Binding | REST client | Browser/Visual Builder preview calls local ORDS endpoints when accessible | Visual Builder service connections to deployed ORDS |
| Attachment Metadata | Oracle database | `request_document` rows with object references | ATP rows with OCI Object Storage object references |
| Attachment Bytes | Object storage | Deferred; may use local placeholder references | OCI Object Storage bucket with controlled access pattern |
| Test Harness | Python runtime | Local test runner calling ORDS and/or database | CI runner or developer machine test harness |

## Local Runtime Design

The local runtime is under `oracle/local/`.

| Resource | Local Name | Purpose |
|---|---|---|
| Database service | `oracle-db` | Runs Oracle Database Free and executes schema/seed initialization scripts. |
| ORDS service | `ords` | Builds ORDS plus SQLcl image, installs/configures ORDS, enables schema, defines local REST modules. |
| Compose network | `supplier-net` | Private container network between ORDS and database. |
| Database volume | `oracle-data` | Persists Oracle data files between container restarts. |
| ORDS config volume | `ords-config` | Persists ORDS installation/configuration marker and runtime settings. |
| Database init scripts | `oracle/local/db-init/` | Creates app user, schema objects, and seed data. |
| ORDS init scripts | `oracle/local/ords/sql/` | Enables `SUPPLIER_APP` for ORDS and defines local modules. |
| Startup script | `oracle/local/scripts/start-local-oracle-ords.sh` | Creates `.env`, runs preflight, starts services with Docker/Podman Compose. |
| Preflight script | `oracle/local/scripts/preflight-local-oracle-ords.sh` | Checks required files, Compose runtime, daemon access, curl, and ports. |
| Endpoint checker | `oracle/local/scripts/check-local-oracle-ords.sh` | Calls starter ORDS endpoints after startup. |
| Stop/reset script | `oracle/local/scripts/stop-local-oracle-ords.sh` | Stops services and optionally removes volumes. |

## Local Ports

| Port Variable | Default | Service | Notes |
|---|---:|---|---|
| `DB_PORT` | `1521` | Oracle listener | Used for SQLcl, SQL*Plus, and database-level tests. |
| `EM_PORT` | `5500` | Oracle EM Express | Local admin UI if supported by the container image. |
| `ORDS_PORT` | `8080` | ORDS HTTP | Visual Builder and API tests call this port. |

The preflight script checks these ports before startup.

## ORDS Base Contract

Local base URL:

```text
http://localhost:8080/ords/supplier-onboarding/v1/
```

Current local endpoints represented in the generated ORDS module:

| Endpoint | Purpose |
|---|---|
| `GET /` | Service metadata and available-resource summary. |
| `GET /health` | ORDS health check. |
| `GET /requests` | Role-aware request list with `limit` and `offset`. |
| `POST /requests` | Create a draft supplier request. |
| `GET /requests/{requestId}` | Request detail with safe projections and allowed actions. |
| `PUT /requests/{requestId}` | Update an editable draft, validation-failed, or correction-required request. |
| `POST /requests/{requestId}/submit` | Submit or resubmit and run deterministic assessment. |
| `POST /requests/{requestId}/documents` | Store request document metadata and optional content placeholder. |
| `GET /requests/{requestId}/documents/{documentId}` | Return document metadata for a request. |
| `POST /requests/{requestId}/review` | Reviewer Accept, Reject, Send Correction, or Duplicate decision. |
| `POST /requests/{requestId}/justification-risk-adjustment` | Apply `+3`, `+5`, or `+10` after Reviewer confirmation. |
| `POST /requests/{requestId}/ai-regeneration` | Queue a new Gemini explanation job. |
| `POST /requests/{requestId}/retry` | Admin retry for the latest eligible technical failure. |
| `GET /integration-logs` | Admin integration diagnostics. |
| `GET /integration-jobs` | OIC-pollable integration jobs filtered by type/status. |
| `POST /integration-jobs/{jobId}/claim` | OIC claims a ready job. |
| `PUT /integration-jobs/{jobId}/result` | OIC records Fusion/Gemini/sync success or failure. |
| `POST /supplier-reference/batch` | Upsert Fusion supplier reference cache records. |
| `GET /risk-rules` | Admin risk weight configuration and allocation evidence. |
| `PUT /risk-rules/{ruleCode}` | Update a risk rule, rejecting any active allocation that does not total exactly 100. |
| `GET /high-risk-countries` | Admin-maintained risky-country list. |
| `PUT /high-risk-countries/{countryCode}` | Add, activate, deactivate, or update a risky-country entry. |

## Data and Storage Infrastructure

| Data Area | Storage Target | Design Rule |
|---|---|---|
| Supplier request data | `SUPPLIER_REQUEST` | Flattened phase-one request model. |
| Workflow/action history | `ACTION_HISTORY` | Append-oriented. |
| Gemini response history | `AI_ASSESSMENT` | Append regenerated summaries; never overwrite. |
| Reviewer AI-risk adjustment | `REQUEST_ASSESSMENT reviewer adjustment fields` | Preserve points, actor, request version, AI assessment, and score impact. |
| Integration work and attempts | `INTEGRATION_JOB` | Queue plus attempt history with retry lineage. |
| Risk configuration | `RISK_RULE_CONFIG`, `RISK_SCORE_BAND_CONFIG`, `HIGH_RISK_COUNTRY_CONFIG` | Structured tables for strict configuration. |
| Mixed configuration | `CONFIGURATION` plus structured config tables | Scalar key/value settings and readable tables for business-maintained configuration. |
| Document metadata | `REQUEST_DOCUMENT` | Store metadata, request version, latest flag, uploader, and optional content placeholder. |
| Attachment bytes | Object storage later | Do not store file bytes in request workflow tables. |

## Security and Privacy Infrastructure

Phase-one infrastructure uses local development passwords and local request parameters to stand in for Oracle IAM claims. This is acceptable for local setup and supervisor demonstration, not production.

Required infrastructure guardrails:

- ORDS is the API boundary for Visual Builder.
- Visual Builder does not call database tables directly.
- Generated ATP/ORDS code enforces Requester, Reviewer, and Admin protected actions through package checks.
- Normal responses must expose only masked bank values and last-four values.
- Admin log endpoints expose payload and response references, not unrestricted sensitive payload contents.
- `.env` values are local development credentials only and must not be reused for cloud ATP or production.

Production hardening deferred beyond this UOW includes identity federation, wallet handling, network restrictions, TLS/certificate policy, secret management, and formal security baseline review.

## Reliability and Retry Infrastructure

The infrastructure design supports reliability through database-centered transaction boundaries and append-oriented evidence:

- Oracle database owns durable state.
- ORDS handlers call package logic for state mutation.
- `ACTION_HISTORY` records status and reviewer decisions.
- `INTEGRATION_JOB` records each integration attempt.
- Retry creates a new `INTEGRATION_JOB` row linked to the original job through `parent_job_id`.
- Admin retry is limited to eligible technical failures and cannot bypass validation, review, or approval.
- Gemini justification-risk output is advisory until a Reviewer adjustment row is recorded.

Production resiliency features such as DR, backups, multi-region failover, centralized alerting, and SLO reporting are deferred.

## Observability Infrastructure

Local observability is intentionally lightweight:

- `GET /health` confirms ORDS is responding.
- `check-local-oracle-ords.sh` verifies the local ORDS endpoint set.
- Container runtime logs provide database and ORDS startup diagnostics.
- Admin ORDS endpoints expose `INTEGRATION_JOB`, `ACTION_HISTORY`, `AI_ASSESSMENT`, and `REQUEST_ASSESSMENT reviewer adjustment fields` evidence.

Future production observability should add centralized log collection, alerting, metrics, dashboarding, and audit export controls.

## ORDS Setup Path

The local ORDS setup path is:

1. Install Docker Compose or Podman Compose on the local machine.
2. Review `oracle/local/.env` and adjust local ports if needed.
3. Run `./scripts/preflight-local-oracle-ords.sh` from `oracle/local/`.
4. Run `./scripts/start-local-oracle-ords.sh` from `oracle/local/`.
5. Wait for Oracle Database Free to finish first startup.
6. Run `./scripts/check-local-oracle-ords.sh`.
7. Bind Visual Builder service connections to `http://localhost:8080/ords/supplier-onboarding/v1/` where browser access to localhost is available.

Current status: local Docker-based Oracle Database Free and ORDS setup has been created and verified. The latest endpoint, Postman/Newman, Python property/example, demo seed, and database evidence checks passed during the Build/Test support pass.

## Code Generation Implications

Code Generation should use this infrastructure design to generate or formalize:

- `oracle/atp/schema/` DDL files, based on the finalized schema.
- `oracle/atp/packages/` PL/SQL package specs and bodies for workflow, authorization, validation, review, dashboard, integration, configuration, and projection behavior.
- `oracle/atp/seed/` seed data.
- `oracle/ords/modules/` package-backed ORDS module definitions.
- `oracle/local/` Docker Compose, ORDS image, local schema mirror, and helper scripts.
- `tests/example/` API and database lifecycle tests.
- `tests/property/` Hypothesis generators and properties.
- Test/dependency files for `pytest`, `hypothesis`, `requests`, and `oracledb`.
- Visual Builder service binding notes for local ORDS endpoints.

## Infrastructure Risks and Mitigations

| Risk | Impact | Mitigation |
|---|---|---|
| Docker/Podman Compose unavailable or daemon stopped | Local ORDS stack cannot start. | Preflight fails clearly before startup and local setup instructions document Docker startup. |
| Local port conflict | ORDS or database cannot bind default ports. | Adjust `DB_PORT`, `EM_PORT`, or `ORDS_PORT` in `.env`. |
| Oracle image download delay | First startup can take several minutes. | Document wait time and use health check before ORDS install. |
| ORDS package-backed handlers differ between local and cloud ORDS binding behavior | Some PUT body parameters can bind differently by runtime. | Local Postman/API docs use query parameters for verified PUT handlers; cloud deployment should retest service connection binding. |
| Visual Builder cannot reach localhost from cloud-hosted designer | Browser preview may need local browser access or deployed ORDS URL. | Use local browser testing for localhost or deploy ORDS to a reachable environment later. |
| Attachment bytes not yet implemented | Upload can store metadata but not actual file bytes. | Add OCI Object Storage or local object-reference strategy in a later stage/unit. |

## Extension Compliance

| Extension Rule | Status | Rationale |
|---|---|---|
| Property-Based Testing | N/A for Infrastructure Design | PBT implementation is enforced in Code Generation and Build/Test. This design preserves test-run infrastructure and dependency expectations. |
| PBT-01 | Previously compliant | Functional Design identified UOW-002 properties. |
| PBT-09 | Previously compliant | NFR Requirements selected Python `pytest` plus `hypothesis`. |
| PBT-02 through PBT-08 | N/A for this stage | These apply when property tests are generated. |
| PBT-10 | N/A for this stage | Complementary example/PBT implementation applies during Code Generation and Build/Test. |
| Security Baseline | Disabled | Disabled in `aidlc-state.md`; transcript-specific bank masking and backend role checks remain included. |
| Resiliency Baseline | Disabled | Disabled in `aidlc-state.md`; transcript-specific retry lineage and error classification remain included. |

No blocking extension findings apply to Infrastructure Design.

## Content Validation

- No Mermaid diagrams are used.
- No ASCII diagrams are used.
- Markdown tables, lists, and code fences are parser-compatible.
