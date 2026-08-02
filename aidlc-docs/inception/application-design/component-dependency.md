# Component Dependencies

## Dependency Summary

| Component | Depends On | Used By |
|---|---|---|
| C-001 Visual Builder Application | C-003 | Human users |
| C-002 IAM Subject Authorization Context | C-004 | C-003, C-013 |
| C-003 ORDS API Layer | C-002, C-004 through C-016 | C-001 |
| C-004 Supplier Request Repository | ATP | C-005 through C-017 |
| C-005 Request Workflow Component | C-004, C-017 | C-003, C-012, C-014, C-016 |
| C-006 Validation Component | C-004 | C-003, C-005, C-009, C-010 |
| C-007 Supplier Master Reference Component | ATP, C-015 | C-008, C-012 |
| C-008 Duplicate Detection Component | C-004, C-007 | C-009, C-010, C-012, C-013 |
| C-009 Risk Scoring Component | C-004, C-006, C-008 | C-010, C-012, C-013 |
| C-010 Gemini Explanation Component | C-004, C-006, C-008, C-009, OIC, Gemini | C-012, C-013 |
| C-011 Document Component | OCI Object Storage, C-004 | C-001, C-012 |
| C-012 Review Decision Component | C-004, C-005, C-006, C-008, C-009, C-010, C-011, C-017 | C-003 |
| C-013 Dashboard Query Component | C-004, C-006, C-008, C-009, C-010, C-012, C-016 | C-003, C-001 |
| C-014 Supplier Creation Integration Component | C-004, C-005, C-016, OIC, Fusion/mock Fusion | C-012 |
| C-015 Supplier Master Sync Component | OIC, Fusion | C-007 |
| C-016 Integration Log and Retry Component | C-004, C-005, C-014, C-015, C-017 | C-003, C-013 |
| C-017 Audit Component | ATP | C-005, C-010, C-012, C-016 |
| C-018 Testability Component | C-008, C-009, C-014 | Construction testing artifacts |

## Communication Patterns

### Visual Builder to ORDS

- Protocol: HTTPS REST
- Payload style: JSON for business objects and metadata
- File handling: upload flow uses ORDS plus OCI Object Storage reference handling
- Security model: phase-one actor subject and app-role context is passed to ORDS and checked by ATP package logic. The prototype exposes Requester, Reviewer, and Admin. Finance/compliance/governance concerns are merged into Reviewer; IT/support log and retry concerns are handled by Admin.

### ORDS to ATP

- Pattern: ORDS handlers call ATP tables, views, and PL/SQL packages/procedures.
- Responsibility: ORDS exposes APIs; ATP-backed packages implement state changes and query composition.
- Transaction handling: request state changes and related records should be committed consistently by ATP logic.

### ATP/ORDS to OIC

- Pattern: ORDS or ATP-driven process triggers OIC for supplier creation and Gemini summary generation.
- Responsibility: OIC handles external orchestration and writes results back to ATP.
- Failure handling: integration failures are written to Integration Log and Retry records.

### OIC to Fusion

- Pattern: OIC calls Fusion supplier APIs/processes for approved supplier creation and supplier master sync.
- Fallback: mock Fusion responses are allowed when real Fusion access is unavailable.
- Source of truth: Fusion remains the supplier master system of record.

### OIC to Gemini

- Pattern: OIC calls Gemini for advisory explanation generation.
- Inputs: request context, validation findings, duplicate factors, and risk factors.
- Outputs: summary, recommendations, timestamp, provider metadata.
- Decision boundary: Gemini output is advisory only.

### Attachment Storage

- File content: OCI Object Storage.
- Metadata: ATP.
- UI access: Visual Builder receives metadata and controlled links/references through ORDS.

## Data Flow by Scenario

### Create and Submit Request

1. Visual Builder sends request data to ORDS.
2. ORDS validates actor subject and app-role context through ATP package logic.
3. Supplier Request Repository stores request in ATP.
4. Workflow Component sets Draft or Submitted status.
5. Validation Component runs business validation.
6. Duplicate Detection Component reads Fusion-synced reference data.
7. Risk Scoring Component consumes validation and duplicate outputs.
8. Gemini Explanation Component triggers OIC/Gemini and stores AI summary.
9. Dashboard Query Component exposes current state to requester and reviewer views.

### Review and Approval

1. Reviewer opens request detail in Visual Builder.
2. ORDS returns request, validation, duplicate, risk, AI, and document metadata.
3. Reviewer submits review action.
4. Review Decision Component records decision.
5. Workflow Component updates status.
6. If approved, Supplier Creation Integration Component can submit through OIC.

### Fusion Creation

1. Supplier Creation Integration Component gathers approved request data.
2. OIC transforms request data into Fusion payload.
3. OIC calls Fusion or mock Fusion fallback.
4. Integration Log Component stores request/response/error details.
5. Workflow Component updates status to Created in Fusion or Integration Failed.
6. Dashboard Query Component exposes final status.

### Supplier Master Sync

1. OIC runs scheduled supplier master sync.
2. Fusion returns supplier reference records.
3. Supplier Master Sync Component transforms data.
4. Supplier Master Reference Component upserts reference records in ATP.
5. Duplicate Detection Component uses updated reference data for future requests.

## Dependency Risks

| Risk | Affected Components | Mitigation in Design |
|---|---|---|
| Fusion access unavailable | C-014, C-015 | Use realistic mock Fusion responses while preserving OIC integration pattern. |
| Gemini access unavailable | C-010 | Keep Gemini call behind OIC orchestration so a mock AI service can be substituted during testing. |
| Local actor parameters differ from production identity | C-002, C-003 | Document as a phase-one limitation and isolate role checks behind the authorization package. |
| Sensitive bank data exposure | C-004, C-008, C-013 | Store/display masked values in normal views and defer full data-protection design to NFR Design. |
| Duplicate/risk logic becomes hard to test | C-008, C-009 | Keep duplicate detection and risk scoring separated and property-testable. |
| Object Storage integration complexity | C-011 | Store metadata/references in ATP and keep file content outside request workflow state. |
