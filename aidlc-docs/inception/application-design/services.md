# Services and Orchestration

## Service Model

The application is organized around resource-oriented services exposed through ORDS and orchestration flows handled by ATP packages and OIC integrations.

Visual Builder is the presentation layer. It should call services and render results, not own the business workflow.

## Service Catalog

| ID | Service | Primary Components | Purpose |
|---|---|---|---|
| S-001 | Supplier Request Service | C-003, C-004, C-005 | Create, update, submit, and retrieve supplier requests. |
| S-002 | Validation Service | C-006, C-004, C-005 | Validate request data and update validation state. |
| S-003 | Duplicate Detection Service | C-008, C-007, C-004 | Produce duplicate candidates and match reasons. |
| S-004 | Risk Scoring Service | C-009, C-006, C-008, C-004 | Produce explainable supplier risk level and factors, including Admin risky-country rules and Reviewer-approved justification-risk adjustments. |
| S-005 | AI Explanation Service | C-010, OIC, Gemini | Generate and store advisory AI summaries, recommendations, and business-justification risk metadata. |
| S-006 | Document Service | C-011, OCI Object Storage, C-004 | Upload or reference documents and store metadata/references. |
| S-007 | Review Service | C-012, C-005, C-017 | Approve, reject, mark duplicate, or request correction. |
| S-008 | Dashboard Service | C-013 | Return role-specific dashboard data. |
| S-009 | Supplier Creation Integration Service | C-014, C-016, OIC, Fusion | Submit approved suppliers to Fusion and store responses. |
| S-010 | Supplier Master Sync Service | C-015, C-007, OIC, Fusion | Sync existing Fusion supplier references into ATP. |
| S-011 | Integration Support Service | C-016, C-005, C-017 | View logs and retry eligible technical failures. |
| S-012 | Audit Service | C-017 | Record auditable status, review, AI, and integration events. |

## Orchestration Patterns

### Request Draft Creation

1. Visual Builder calls `POST /requests`.
2. ORDS resolves actor subject and app-role context.
3. Supplier Request Repository creates Draft request in ATP.
4. Workflow Component records Draft status.
5. Response returns request ID and editable fields to Visual Builder.

### Request Submission

1. Visual Builder calls `POST /requests/{id}/submit`.
2. ORDS verifies requester permission.
3. Workflow Component starts submission.
4. Validation Service runs validation.
5. If validation fails, status becomes `Validation Failed`.
6. If validation passes, Duplicate Detection Service runs.
7. Risk Scoring Service calculates deterministic risk from active configuration, including the Admin-managed risky-country list.
8. AI Explanation Service triggers Gemini through OIC and stores business-justification risk metadata for Reviewer consideration.
9. Workflow Component moves request to `Under Review`.

### AI Summary Generation

1. ORDS queues AI summary generation through `POST /requests/{id}/ai-regeneration`.
2. Gemini Explanation Component builds request context from ATP data.
3. OIC calls Gemini using the prepared context.
4. OIC writes summary, recommended actions, justification risk flag, rationale, suggested severity, and suggested points back to ATP.
5. Audit Service records summary timestamp.
6. Visual Builder displays the latest stored summary.

### Reviewer Decision

1. Reviewer opens request detail through Visual Builder.
2. Dashboard/Request services return request, validation, duplicate, risk, AI, and attachment data.
3. If Gemini flags business justification risk, Reviewer can apply no adjustment or choose `+3`, `+5`, or `+10`.
4. Review Service records any justification-risk adjustment and recomputes the final displayed risk score from the deterministic score plus the Reviewer adjustment.
5. Reviewer chooses approve, reject, mark duplicate, or request correction.
6. Review Service records decision and reason.
7. Workflow Component updates request status.
8. If approved, Supplier Creation Integration Service becomes eligible to submit to Fusion.

### Fusion Supplier Creation

1. Supplier Creation Integration Service selects approved request.
2. Workflow Component marks request `Submitted to Fusion`.
3. OIC transforms ATP request data into Fusion supplier payload.
4. OIC calls Fusion supplier API/process.
5. On success, Fusion supplier number is stored and status becomes `Created in Fusion`.
6. On failure, Integration Log and Retry Component stores error details and status becomes `Integration Failed`.

### Integration Failure Retry

1. Admin views failed integration in the OIC/Fusion log area.
2. ORDS checks admin permission for retry/support actions.
3. Integration Support Service checks retry eligibility.
4. If retry is eligible, retry event is logged and OIC call is attempted again.
5. Retry never bypasses validation, duplicate review, risk review, or approval.

### Supplier Master Synchronization

1. OIC scheduled process fetches Fusion supplier master reference data.
2. Supplier Master Sync Service transforms Fusion data into ATP reference format.
3. Supplier Master Reference Component stores/upserts reference records.
4. Duplicate Detection Service uses these records for future requests.
5. Sync metadata and failures are logged.

## Service Boundaries

### Visual Builder Boundary

Visual Builder owns:

- Page layouts
- User interactions
- Client-side required-field hints
- Display of API responses

Visual Builder does not own:

- Final workflow state
- Duplicate detection
- Risk scoring
- AI summary generation
- Fusion supplier creation

### ORDS Boundary

ORDS owns:

- REST API exposure
- Request/response shape
- Role-aware API action enforcement
- Calling ATP packages/views/procedures

ORDS does not own:

- Long-running OIC orchestration
- Fusion supplier master source data
- Object file storage content

### ATP Boundary

ATP owns:

- Staging data
- Workflow state
- Validation results
- Duplicate results
- Risk scores
- AI summaries
- Review decisions
- Integration logs
- Actor subject IDs for ownership, audit, and local authorization context

ATP does not own:

- Final supplier master truth after creation
- Uploaded binary object storage content when using OCI Object Storage

### OIC Boundary

OIC owns:

- Fusion supplier creation orchestration
- Fusion supplier master synchronization
- Gemini call orchestration
- Payload transformations for external calls

OIC does not own:

- User-facing workflow decisions
- Human approvals
- Persistent supplier request state outside integration messages

## Service Design Constraints

- AI remains advisory and never performs review decisions.
- Gemini can flag business-justification risk, but only the Reviewer can add `+3`, `+5`, or `+10` to the risk score.
- Supplier creation in Fusion requires reviewer approval.
- UI does not call Fusion directly.
- Duplicate detection produces match facts; risk scoring consumes those facts.
- Local actor/role request parameters are phase-one only and must be replaced by Oracle IAM claims before production go-live.
- Mock Fusion responses must preserve realistic payload and error patterns.
