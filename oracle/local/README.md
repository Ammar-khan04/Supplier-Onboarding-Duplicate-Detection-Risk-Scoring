# Local Oracle Database Free and ORDS Setup

This folder contains the local container-based setup for the Supplier Onboarding, Duplicate Detection, and Risk Scoring ATP/ORDS foundation.

It creates:

- Oracle Database Free local database.
- Project app schema `SUPPLIER_APP`.
- Finalized ATP tables generated from `oracle/atp/schema/`.
- Oracle IAM subject-column model for ownership and audit; no ATP app-user or app-role tables.
- Flattened `SUPPLIER_REQUEST` and versioned `REQUEST_DOCUMENT`.
- `REQUEST_ASSESSMENT` for deterministic validation, duplicate evidence, and risk scoring history.
- Fusion reference-cache tables for local duplicate matching.
- Append-oriented `AI_ASSESSMENT`, `ACTION_HISTORY`, and `INTEGRATION_JOB`.
- Configuration storage and readable Admin/API views.
- Package-backed ORDS module generated from `oracle/ords/modules/`.

## Prerequisites

Install a container runtime before running this setup:

- Docker Engine with Docker Compose, or
- Podman plus compose compatibility.

Docker install reference:

- Docker Engine on Ubuntu: https://docs.docker.com/engine/install/ubuntu/

Oracle references:

- Oracle Database Free container image: https://www.oracle.com/database/free/get-started/
- ORDS installation and Docker image notes: https://docs.oracle.com/en/database/oracle/oracle-rest-data-services/25.3/ordig/installing-and-configuring-oracle-rest-data-services.html

## Start

From this directory:

```bash
cp .env.example .env
./scripts/preflight-local-oracle-ords.sh
./scripts/start-local-oracle-ords.sh
```

The first startup can take several minutes because the Oracle database image is downloaded and the database is created.

The startup script accepts Docker Compose, standalone `docker-compose`, Podman Compose, or standalone `podman-compose`. If ports conflict, adjust `DB_PORT`, `EM_PORT`, or `ORDS_PORT` in `.env` before starting.

If the Oracle database container is already running from the database-only flow, the ORDS preflight reuses its `DB_PORT` and `EM_PORT` instead of treating those ports as conflicts.

## Database-Only Start

Use this when you only need the Oracle database container, schema, and seed data:

```bash
cp .env.example .env
./scripts/start-local-oracle-db.sh
./scripts/install-local-oracle-schema.sh
./scripts/check-local-oracle-db.sh
```

The first run pulls the Oracle Database Free image and creates the local database volume. The init scripts then create `SUPPLIER_APP`, load the formal schema from `../atp/schema/`, and load seed data from `../atp/seed/`.

On some Docker Desktop/LinuxKit hosts, Oracle Database Free 26ai can fail first startup with `ORA-27180: failed to create memory protection key`. If that appears in the database logs, run:

```bash
./scripts/fix-local-oracle-mpk.sh
./scripts/install-local-oracle-schema.sh
./scripts/check-local-oracle-db.sh
```

The fix script persists the local Oracle startup parameter in the database volume and restarts only the database container.

## Local URLs

| Service | URL or connect string |
|---|---|
| Oracle PDB | `localhost:1521/FREEPDB1` |
| Oracle EM Express | `https://localhost:5500/em/` |
| ORDS base | `http://localhost:8080/ords/supplier-onboarding/v1/` |
| Health | `http://localhost:8080/ords/supplier-onboarding/v1/health` |
| Requests | `http://localhost:8080/ords/supplier-onboarding/v1/requests` |
| Request detail | `http://localhost:8080/ords/supplier-onboarding/v1/requests/1?actor_subject_id=REQ_AMINA_SUB&actor_roles=REQUESTER` |
| Risk rules | `http://localhost:8080/ords/supplier-onboarding/v1/risk-rules` |
| High-risk countries | `http://localhost:8080/ords/supplier-onboarding/v1/high-risk-countries` |
| Admin integration logs | `http://localhost:8080/ords/supplier-onboarding/v1/integration-logs?actor_subject_id=ADM_LINDA_SUB&actor_roles=ADMIN` |
| OIC integration jobs | `http://localhost:8080/ords/supplier-onboarding/v1/integration-jobs?type=AI_EXPLANATION&status=READY` |

## Local QA Identity Parameters

Oracle IAM owns real authentication and role assignment. Local ORDS examples use request parameters as IAM-claim stand-ins:

| Subject | Roles | Purpose |
|---|---|---|
| `REQ_AMINA_SUB` | `REQUESTER` | Requester demo identity. |
| `REV_PRIYA_SUB` | `REVIEWER` | Reviewer demo identity. |
| `ADM_LINDA_SUB` | `ADMIN` | Admin demo identity. |

## Local Credentials

Defaults are in `.env.example`.

| User | Purpose | Password source |
|---|---|---|
| `SYS` / `SYSTEM` | Local database administration | `ORACLE_PWD` |
| `SUPPLIER_APP` | Project schema and ORDS-enabled schema | `APP_PASSWORD` |
| `ORDS_PUBLIC_USER` | ORDS runtime proxy user | `ORDS_PUBLIC_USER_PASSWORD` |

These are local development defaults only. Do not reuse them for cloud ATP or production.

## Environment Variables

| Variable | Purpose |
|---|---|
| `ORACLE_PWD` | Local `SYS` and `SYSTEM` password. |
| `ORDS_PUBLIC_USER_PASSWORD` | Local ORDS runtime proxy password. |
| `APP_USER` | Project schema name, default `SUPPLIER_APP`. |
| `APP_PASSWORD` | Local project schema password. |
| `DB_SERVICE` | Oracle PDB service, default `FREEPDB1`. |
| `DB_PORT` | Host Oracle listener port, default `1521`. |
| `EM_PORT` | Host Oracle EM Express port, default `5500`. |
| `ORDS_PORT` | Host ORDS HTTP port, default `8080`. |
| `ORDS_DB_POOL` | Optional ORDS connection pool name. Leave empty for the local single-pool route used by `http://localhost:8080/ords/supplier-onboarding/v1/`. |

## Check

After startup:

```bash
./scripts/check-local-oracle-db.sh
./scripts/check-local-oracle-ords.sh
```

The DB checker verifies the container health and confirms the project schema is reachable through SQL*Plus inside the container. The ORDS checker calls the finalized REST endpoints and reports whether ORDS is responding.

If ORDS routing includes an unwanted pool prefix, rebuild the ORDS image after this repository update and recreate only the ORDS config volume:

```bash
docker compose stop ords
docker compose rm -f ords
docker volume rm local_ords-config
docker compose up -d --build ords
```

## Reset

To remove the containers and local database volume:

```bash
./scripts/stop-local-oracle-ords.sh --volumes
```

Run `./scripts/start-local-oracle-ords.sh` again to recreate the database from the init scripts.

To stop the containers without deleting the local database volume:

```bash
./scripts/stop-local-oracle-ords.sh
```

## Notes

- Admin/API views expose risk rules, score bands, and high-risk countries as readable columns.
- Gemini is advisory by itself; only a Reviewer-confirmed justification-risk adjustment can change the final displayed score.
- Deterministic risk is base risk capped at 55 plus duplicate contribution capped at 45.
- The ORDS module delegates protected mutation endpoints to PL/SQL packages generated under `oracle/atp/packages/`.

## Content Validation

- No Mermaid diagrams are used.
- No ASCII diagrams are used.
- Markdown tables and code fences are parser-compatible.
