# Deployment Architecture: UOW-002 ATP/ORDS Supplier Request Foundation

## Purpose

This document defines the deployment architecture for the ATP/ORDS supplier request foundation. It covers the local runtime used for ORDS setup now and the future Oracle Cloud alignment for later deployment.

Local deployment has been created and verified with Docker Compose. Oracle Database Free and ORDS expose the local API at `http://localhost:8080/ords/supplier-onboarding/v1/` when the stack is running.

## Deployment Environments

| Environment | Status | Purpose | Infrastructure |
|---|---|---|---|
| Local developer/demo | Created and verified | Run Oracle Database Free and ORDS locally for API checks and Visual Builder binding. | Docker Compose, Oracle Database Free container, ORDS container, named volumes. |
| Oracle Cloud development | Future | Host a reachable ATP/ORDS endpoint for cloud Visual Builder and integration testing. | Oracle ATP, ORDS, Visual Builder, optional OCI Object Storage, OIC. |
| Production | Deferred | Hardened deployment with identity, networking, monitoring, backup, DR, and security controls. | Requires later production design and approvals. |

## Local Deployment Components

| Component | Runtime Name | Responsibility | Source |
|---|---|---|---|
| Oracle Database Free | `supplier-oracle-db` / `oracle-db` | ATP-like database, schema storage, seed data, local SQL execution. | `container-registry.oracle.com/database/free:latest` |
| ORDS | `supplier-ords` / `ords` | HTTP REST layer for Visual Builder and API tests. | Local Dockerfile under `oracle/local/ords/` |
| Database init scripts | Mounted read-only | Create app schema, tables, indexes, views, and seed data. | `oracle/local/db-init/` |
| ORDS init scripts | Mounted read-only | Enable schema and define local ORDS modules. | `oracle/local/ords/sql/` |
| Oracle data volume | `oracle-data` | Persist local database files. | Compose named volume |
| ORDS config volume | `ords-config` | Persist ORDS install/config marker. | Compose named volume |
| Private network | `supplier-net` | Allow ORDS to connect to database by service name. | Compose network |

## Local Runtime Flow

Local startup proceeds in this order:

1. `start-local-oracle-ords.sh` creates `.env` from `.env.example` if missing.
2. `preflight-local-oracle-ords.sh` checks required files, Compose availability, daemon access, `curl`, and port availability.
3. Compose starts the Oracle Database Free container.
4. Oracle Database Free executes scripts in `oracle/local/db-init/` during first setup.
5. Compose waits for the database health check.
6. Compose starts the ORDS container.
7. ORDS entrypoint waits for database listener connectivity.
8. ORDS installs local configuration, enables `SUPPLIER_APP`, and runs module definition scripts.
9. ORDS serves HTTP on port `8080` inside the container.
10. `check-local-oracle-ords.sh` calls the configured local endpoint set.

## Local Network and Ports

| Consumer | Endpoint | Notes |
|---|---|---|
| SQL tools and DB tests | `localhost:${DB_PORT}/FREEPDB1` | Default `DB_PORT` is `1521`. |
| Local browser/admin | `https://localhost:${EM_PORT}/em/` | Default `EM_PORT` is `5500`. |
| Visual Builder preview and API tests | `http://localhost:${ORDS_PORT}/ords/supplier-onboarding/v1/` | Default `ORDS_PORT` is `8080`. |
| ORDS container to database | `oracle-db:1521/FREEPDB1` | Private Compose network. |

Environment variables:

| Variable | Default | Purpose |
|---|---|---|
| `ORACLE_PWD` | `LocalOracle12345` | Local `SYS` and `SYSTEM` password. |
| `ORDS_PUBLIC_USER_PASSWORD` | `OrdsPublic12345` | Local ORDS public proxy password. |
| `APP_USER` | `SUPPLIER_APP` | Project schema name. |
| `APP_PASSWORD` | `SupplierApp12345` | Project schema password. |
| `DB_SERVICE` | `FREEPDB1` | Oracle PDB service. |
| `DB_PORT` | `1521` | Host database listener port. |
| `EM_PORT` | `5500` | Host EM Express port. |
| `ORDS_PORT` | `8080` | Host ORDS HTTP port. |

These defaults are local development values only.

## ORDS Deployment Details

The local ORDS image:

- Uses `eclipse-temurin:21-jre-jammy`.
- Installs `curl`, `netcat-openbsd`, and `unzip`.
- Downloads ORDS latest ZIP.
- Downloads SQLcl latest ZIP.
- Adds ORDS and SQLcl to `PATH`.
- Runs `entrypoint.sh`.

The ORDS entrypoint:

- Requires `ORACLE_PWD` and `ORDS_PUBLIC_USER_PASSWORD`.
- Waits for the database listener.
- Runs `ords install` if the config marker does not exist.
- Enables the app schema through `10-enable-schema.sql`.
- Defines the module through `20-define-modules.sql`.
- Starts ORDS on HTTP port `8080`.

## Database Deployment Details

The local database container:

- Uses Oracle Database Free latest container image.
- Exposes listener port `1521` to configurable host `DB_PORT`.
- Exposes EM Express port `5500` to configurable host `EM_PORT`.
- Mounts `oracle/local/db-init/` into the image setup directory.
- Persists data in `oracle-data`.

First-run scripts:

| Script | Purpose |
|---|---|
| `00-create-app-user.sql` | Creates `SUPPLIER_APP` using local environment password assumptions. |
| `01-schema.sql` | Creates finalized request, document, assessment, AI, action, integration, risk, config, and Fusion reference structures. |
| `02-seed.sql` | Seeds configuration, risky countries, supplier reference data, demo requests, assessments, AI rows, action history, and integration jobs. |

## Visual Builder Binding Architecture

Visual Builder should bind to ORDS, not directly to database tables.

| Visual Builder Area | ORDS Dependency |
|---|---|
| Requester dashboard | `GET /requests` with requester actor context. |
| New request form | `POST /requests` and `PUT /requests/{id}`. |
| Submit action | `POST /requests/{id}/submit`. |
| Request documents | `POST /requests/{id}/documents` and `GET /requests/{id}/documents/{document_id}`. |
| Reviewer queue and detail | `GET /requests`, `GET /requests/{id}` with Reviewer actor context. |
| Reviewer adjustment buttons | `POST /requests/{id}/justification-risk-adjustment`. |
| Reviewer AI regeneration | `POST /requests/{id}/ai-regeneration`. |
| Reviewer accept/reject/correction | `POST /requests/{id}/review`. |
| Admin risk rules | `GET /risk-rules`, `PUT /risk-rules/{rule_code}`. |
| Admin risky countries | `GET /high-risk-countries`, `PUT /high-risk-countries/{country_code}`. |
| Admin logs and retry | `GET /integration-logs`, `POST /requests/{id}/retry`. |
| OIC worker calls | `GET /integration-jobs`, `POST /integration-jobs/{job_id}/claim`, `PUT /integration-jobs/{job_id}/result`, `POST /supplier-reference/batch`. |

Browser limitation: if the Visual Builder designer is cloud-hosted, it may not be able to call `localhost` from Oracle's server side. Local browser preview can call localhost if the service connection runs from the browser. A reachable deployed ORDS URL will be needed for cloud-side service testing.

## Future OCI Deployment Alignment

Future OCI development deployment should preserve the same component boundaries:

| Local Runtime | Future OCI Equivalent |
|---|---|
| Oracle Database Free container | Oracle Autonomous Transaction Processing |
| ORDS container | Managed/configured ORDS for ATP |
| Local `.env` | OCI secrets, wallet/config, or secure deployment variables |
| Compose named volumes | ATP-managed storage and ORDS configuration |
| Local object references | OCI Object Storage object names or URLs |
| Local health script | Health checks, synthetic API checks, and monitoring alerts |
| Local Admin logs | Admin dashboard plus centralized observability if approved |

Production-specific additions remain deferred:

- IAM/SSO integration.
- Network security rules and private endpoint choices.
- TLS/certificate management.
- Secret management.
- Backup and restore procedures.
- Monitoring, alerting, and audit export.
- Formal DR and incident response.

## Startup, Check, Stop, and Reset Commands

From `oracle/local/`:

```bash
./scripts/preflight-local-oracle-ords.sh
./scripts/start-local-oracle-ords.sh
./scripts/check-local-oracle-ords.sh
./scripts/stop-local-oracle-ords.sh
```

Reset local containers and volumes:

```bash
./scripts/stop-local-oracle-ords.sh --volumes
./scripts/start-local-oracle-ords.sh
```

Latest local verification result from this machine:

```text
Oracle Database Free and ORDS checks passed.
Postman/Newman endpoint run passed with 41 requests, 17 assertions, and 0 failures.
Python property and example tests passed with 24 total tests in the workspace .venv.
Demo seed through ORDS passed and wrote request, document, assessment, AI, action, integration, supplier reference, risk-rule, and high-risk-country evidence.
```

No local runtime blocker is currently recorded. Port conflicts can still occur if another Oracle or ORDS process is already bound to `1521`, `5500`, or `8080`.

## Deployment Validation

Before considering local deployment healthy:

| Validation | Expected Result |
|---|---|
| Preflight | Required files exist; Compose runtime exists; daemon is reachable; ports are free. |
| Compose YAML parse | `docker-compose.yml` parses successfully. |
| Database health check | Oracle responds to `select 1 from dual`. |
| ORDS install | ORDS config marker exists after first install. |
| ORDS health | `GET /health` returns an OK status. |
| Endpoint check | Request, config, risk, AI, action, adjustment, and integration endpoints respond. |
| Sensitive data check | Normal endpoints do not expose full bank account values. |
| Risk adjustment check | Unsupported values other than `3`, `5`, and `10` are rejected. |

## Infrastructure Limitations

| Limitation | Status |
|---|---|
| Local Docker/Compose availability | Resolved for this workspace; keep Docker running before startup/check scripts. |
| ORDS package-backed business APIs | Resolved during Code Generation for current scope. |
| Production identity integration absent | Deferred by approved scope. |
| Attachment object storage not provisioned | Deferred beyond local ATP/ORDS foundation. |
| OIC/Fusion/Gemini live connectivity absent | UOW-004 responsibility. |
| Production monitoring/DR absent | Future infrastructure or operations hardening. |

## Extension Compliance

| Extension Rule | Status | Rationale |
|---|---|---|
| Property-Based Testing | N/A for Infrastructure Design | This document preserves the runtime and dependency expectations for future test execution. |
| PBT-02 through PBT-08 | N/A for this stage | These are enforced when tests are generated. |
| PBT-10 | N/A for this stage | Example and PBT test execution is handled in Code Generation and Build/Test. |
| Security Baseline | Disabled | Security Baseline is disabled in `aidlc-state.md`. |
| Resiliency Baseline | Disabled | Resiliency Baseline is disabled in `aidlc-state.md`. |

No blocking extension findings apply to Deployment Architecture.

## Content Validation

- No Mermaid diagrams are used.
- No ASCII diagrams are used.
- Markdown tables, lists, and code fences are parser-compatible.
