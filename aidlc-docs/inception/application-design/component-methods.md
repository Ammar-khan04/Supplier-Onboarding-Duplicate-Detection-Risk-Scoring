# Component Methods

## Scope

This document defines high-level method signatures and interfaces. Detailed business rules, field-level validation, scoring weights, fuzzy matching thresholds, and payload mappings will be specified during Functional Design and Construction.

Types are conceptual and will be mapped to PL/SQL records, JSON payloads, ORDS handlers, OIC payloads, or Visual Builder service bindings during implementation.

## Shared Conceptual Types

| Type | Purpose |
|---|---|
| `SupplierRequestInput` | Request data from Visual Builder. |
| `SupplierRequest` | Persisted supplier request. |
| `SupplierRequestId` | Unique request identifier. |
| `UserContext` | Actor subject ID and app-role context resolved from Oracle IAM claims in production, or local ORDS request parameters during prototype testing. |
| `ValidationResult` | Validation status, messages, and field-level findings. |
| `DuplicateMatchResult` | Candidate duplicate suppliers and match reasons. |
| `RiskScoreResult` | Risk level, score/factors, and rationale. |
| `AISummaryResult` | Gemini summary, recommended actions, timestamp, and metadata. |
| `ReviewDecisionInput` | Review action, reason, user, and optional existing supplier reference. |
| `DocumentMetadata` | Uploaded or referenced document metadata. |
| `IntegrationResult` | Fusion/OIC response status, supplier number, error, and integration job reference. |
| `DashboardFilter` | Role-specific filter criteria. |

## C-001: Visual Builder Application

| Method | Purpose | Input | Output |
|---|---|---|---|
| `renderSupplierRequestForm()` | Display create/edit supplier request form. | `UserContext`, optional `SupplierRequestId` | UI page state |
| `submitSupplierRequest()` | Submit entered request data through ORDS. | `SupplierRequestInput` | `SupplierRequest` |
| `renderRequesterDashboard()` | Show requester-owned requests and statuses. | `UserContext`, `DashboardFilter` | Dashboard rows |
| `renderReviewerQueue()` | Show review work queue. | `UserContext`, `DashboardFilter` | Dashboard rows |
| `renderRequestDetail()` | Show request details, validations, duplicates, risk, AI summary, documents, and actions. | `UserContext`, `SupplierRequestId` | Detail page state |
| `renderAdminDashboard()` | Show integration failures, OIC/Fusion logs, retry counts, and retry actions for Admin. | `UserContext`, `DashboardFilter` | Admin dashboard rows |

## C-002: IAM Subject Authorization Context

| Method | Purpose | Input | Output |
|---|---|---|---|
| `resolveUserContext(actorSubjectId, actorRoles)` | Resolve actor subject and app-role context. | actor subject ID, role list | `UserContext` |
| `hasPermission(userContext, action, requestId)` | Check whether action is allowed. | `UserContext`, action, optional `SupplierRequestId` | Boolean decision |
| `listAllowedActions(userContext, requestId)` | Return allowed UI/API actions for a request. | `UserContext`, `SupplierRequestId` | Action list |

## C-003: ORDS API Layer

| Method | Purpose | Input | Output |
|---|---|---|---|
| `GET /` | Return service index and available resources. | None | Service metadata |
| `GET /health` | Return local ORDS/API health. | None | Health payload |
| `GET /requests` | Return role-filtered requester, reviewer, or admin dashboard rows. | `DashboardFilter`, `UserContext` | Dashboard rows |
| `POST /requests` | Create draft request. | `SupplierRequestInput`, `UserContext` | Request ID |
| `GET /requests/{id}` | Read request detail, validation, duplicate, risk, AI, and allowed-action data. | `SupplierRequestId`, `UserContext` | Request detail payload |
| `PUT /requests/{id}` | Update editable draft, validation-failed, or correction-required request fields. | `SupplierRequestInput`, `UserContext` | Update status |
| `POST /requests/{id}/submit` | Submit or resubmit request. | `SupplierRequestId`, `UserContext` | Workflow result |
| `POST /requests/{id}/documents` | Upload or record document metadata. | File/object reference, metadata, `UserContext` | Document ID |
| `GET /requests/{id}/documents/{document_id}` | Read document metadata. | `SupplierRequestId`, document ID, `UserContext` | `DocumentMetadata` |
| `POST /requests/{id}/ai-regeneration` | Queue Gemini advisory-summary regeneration. | `SupplierRequestId`, `UserContext` | Integration job ID |
| `POST /requests/{id}/justification-risk-adjustment` | Apply Reviewer-confirmed `+3`, `+5`, or `+10` business-justification risk points. | `SupplierRequestId`, points, reason, `UserContext` | Adjusted risk result |
| `POST /requests/{id}/review` | Record approve, reject, duplicate, or correction action. | `ReviewDecisionInput`, `UserContext` | Workflow result |
| `GET /integration-logs` | Admin-accessible integration log view. | `DashboardFilter`, `UserContext` | Integration log rows |
| `GET /integration-jobs` | OIC polling endpoint for ready or completed jobs. | Job type, status, limit | Job rows |
| `POST /integration-jobs/{job_id}/claim` | Let OIC claim a ready job. | OIC instance, correlation ID | Claim status |
| `PUT /integration-jobs/{job_id}/result` | Let OIC write success/failure and response metadata. | Job result fields | Result status |
| `POST /requests/{id}/retry` | Admin retries the latest eligible technical failure for a request. | `SupplierRequestId`, `UserContext` | Retry job ID |
| `POST /supplier-reference/batch` | OIC upserts Fusion supplier reference records for duplicate matching. | Supplier reference payload | Upsert result |
| `GET /risk-rules` | Admin reads active risk rule weights. | `UserContext` | Risk rule rows |
| `PUT /risk-rules/{rule_code}` | Admin updates risk rule weight/active state, enforcing total weight of 100. | Rule code, weight, active flag, `UserContext` | Update status |
| `GET /high-risk-countries` | Admin reads high-risk country configuration. | `UserContext` | Country rows |
| `PUT /high-risk-countries/{country_code}` | Admin adds, activates, deactivates, or updates a high-risk country. | Country code, reason, source, active flag, `UserContext` | Update status |

## C-004: Supplier Request Repository

| Method | Purpose | Input | Output |
|---|---|---|---|
| `createDraft(input, userContext)` | Persist new draft request. | `SupplierRequestInput`, `UserContext` | `SupplierRequestId` |
| `updateDraft(requestId, input, userContext)` | Update editable draft or correction request. | `SupplierRequestId`, `SupplierRequestInput`, `UserContext` | `SupplierRequest` |
| `getRequest(requestId)` | Load request header and detail data. | `SupplierRequestId` | `SupplierRequest` |
| `saveStatus(requestId, status, reason)` | Persist status transition. | `SupplierRequestId`, status, reason | Status event |
| `linkDocument(requestId, documentMetadata)` | Associate stored document metadata to request. | `SupplierRequestId`, `DocumentMetadata` | Link result |

## C-005: Request Workflow Component

| Method | Purpose | Input | Output |
|---|---|---|---|
| `submitRequest(requestId, userContext)` | Move request from Draft/correction into validation and review flow. | `SupplierRequestId`, `UserContext` | Workflow result |
| `markValidationFailed(requestId, validationResult)` | Set validation failure state. | `SupplierRequestId`, `ValidationResult` | Workflow result |
| `markUnderReview(requestId)` | Set request as ready for human review. | `SupplierRequestId` | Workflow result |
| `markApproved(requestId, decisionInput)` | Mark request approved. | `SupplierRequestId`, `ReviewDecisionInput` | Workflow result |
| `markRejected(requestId, decisionInput)` | Mark request rejected. | `SupplierRequestId`, `ReviewDecisionInput` | Workflow result |
| `markDuplicate(requestId, decisionInput)` | Mark request duplicate with existing supplier reference. | `SupplierRequestId`, `ReviewDecisionInput` | Workflow result |
| `requestCorrection(requestId, decisionInput)` | Return request to requester for correction. | `SupplierRequestId`, `ReviewDecisionInput` | Workflow result |
| `markSubmittedToFusion(requestId, integrationJobId)` | Mark request in Fusion submission progress. | `SupplierRequestId`, integration job ID | Workflow result |
| `markCreatedInFusion(requestId, supplierNumber, integrationResult)` | Mark successful Fusion creation. | `SupplierRequestId`, supplier number, `IntegrationResult` | Workflow result |
| `markIntegrationFailed(requestId, integrationResult)` | Mark technical integration failure. | `SupplierRequestId`, `IntegrationResult` | Workflow result |

## C-006: Validation Component

| Method | Purpose | Input | Output |
|---|---|---|---|
| `validateForSubmission(requestId)` | Run business validation after submission. | `SupplierRequestId` | `ValidationResult` |
| `validateForFusionSubmission(requestId)` | Confirm data is sufficient before Fusion submission. | `SupplierRequestId` | `ValidationResult` |
| `storeValidationResult(requestId, validationResult)` | Persist validation findings in `REQUEST_ASSESSMENT`. | `SupplierRequestId`, `ValidationResult` | Save result |
| `getValidationResult(requestId)` | Retrieve latest validation result. | `SupplierRequestId` | `ValidationResult` |

## C-007: Supplier Master Reference Component

| Method | Purpose | Input | Output |
|---|---|---|---|
| `upsertSupplierReference(fusionSupplierPayload)` | Store or update Fusion-synced supplier reference. | Fusion supplier data | Reference ID |
| `searchReferenceCandidates(requestId)` | Find supplier reference candidates for duplicate matching. | `SupplierRequestId` | Candidate list |
| `getExistingSupplier(referenceId)` | Retrieve existing supplier reference details. | Reference ID | Supplier reference |
| `recordSyncMetadata(syncMetadata)` | Store supplier master sync metadata on Fusion reference rows and integration jobs. | Sync metadata | Sync evidence |

## C-008: Duplicate Detection Component

| Method | Purpose | Input | Output |
|---|---|---|---|
| `runDuplicateDetection(requestId)` | Generate duplicate candidates and match factors. | `SupplierRequestId` | `DuplicateMatchResult` |
| `normalizeSupplierName(name)` | Normalize names for lightweight fuzzy matching. | Supplier name | Normalized name |
| `compareCandidate(request, supplierReference)` | Compare request against one supplier reference. | Request, supplier reference | Match factor result |
| `storeDuplicateMatches(requestId, duplicateMatchResult)` | Persist duplicate findings in `REQUEST_ASSESSMENT`. | `SupplierRequestId`, `DuplicateMatchResult` | Save result |
| `getDuplicateMatches(requestId)` | Retrieve latest duplicate results. | `SupplierRequestId` | `DuplicateMatchResult` |

## C-009: Risk Scoring Component

| Method | Purpose | Input | Output |
|---|---|---|---|
| `calculateRiskScore(requestId)` | Generate risk level and factors. | `SupplierRequestId` | `RiskScoreResult` |
| `collectRiskInputs(requestId)` | Gather request, validation, duplicate, and configurable risk inputs. | `SupplierRequestId` | Risk input model |
| `storeRiskScore(requestId, riskScoreResult)` | Persist risk result in `REQUEST_ASSESSMENT`. | `SupplierRequestId`, `RiskScoreResult` | Save result |
| `getRiskScore(requestId)` | Retrieve latest risk result. | `SupplierRequestId` | `RiskScoreResult` |

## C-010: Gemini Explanation Component

| Method | Purpose | Input | Output |
|---|---|---|---|
| `prepareAIContext(requestId)` | Build prompt context from request, validation, duplicate, and risk data. | `SupplierRequestId` | AI context payload |
| `requestGeminiSummary(requestId)` | Trigger OIC flow for Gemini summary. | `SupplierRequestId` | `AISummaryResult` |
| `storeAISummary(requestId, aiSummaryResult)` | Persist AI output and timestamp. | `SupplierRequestId`, `AISummaryResult` | Save result |
| `getLatestAISummary(requestId)` | Retrieve latest AI summary. | `SupplierRequestId` | `AISummaryResult` |

## C-011: Document Component

| Method | Purpose | Input | Output |
|---|---|---|---|
| `createUploadReference(requestId, fileMetadata)` | Prepare object storage upload reference. | `SupplierRequestId`, file metadata | Upload reference |
| `storeDocumentMetadata(requestId, objectReference, metadata)` | Store document metadata and any object reference in ATP. | Request ID, object reference, metadata | `DocumentMetadata` |
| `listDocuments(requestId)` | Retrieve document metadata for request. | `SupplierRequestId` | Document list |
| `flagMissingDocuments(requestId)` | Identify expected documents not yet provided. | `SupplierRequestId` | Missing document findings |

## C-012: Review Decision Component

| Method | Purpose | Input | Output |
|---|---|---|---|
| `approveRequest(requestId, decisionInput)` | Approve request for Fusion submission. | `SupplierRequestId`, `ReviewDecisionInput` | Workflow result |
| `rejectRequest(requestId, decisionInput)` | Reject request. | `SupplierRequestId`, `ReviewDecisionInput` | Workflow result |
| `markRequestDuplicate(requestId, decisionInput)` | Close request as duplicate with optional existing supplier reference. | `SupplierRequestId`, `ReviewDecisionInput` | Workflow result |
| `requestCorrection(requestId, decisionInput)` | Send request back for correction. | `SupplierRequestId`, `ReviewDecisionInput` | Workflow result |
| `recordDecision(requestId, decisionInput)` | Persist review decision for audit. | `SupplierRequestId`, `ReviewDecisionInput` | Decision record |

## C-013: Dashboard Query Component

| Method | Purpose | Input | Output |
|---|---|---|---|
| `getRequesterDashboard(filter, userContext)` | Return requester-visible request rows. | `DashboardFilter`, `UserContext` | Dashboard rows |
| `getReviewerDashboard(filter, userContext)` | Return reviewer queue rows. | `DashboardFilter`, `UserContext` | Dashboard rows |
| `getRiskDashboard(filter, userContext)` | Return high-risk and duplicate-risk rows. | `DashboardFilter`, `UserContext` | Dashboard rows |
| `getAdminDashboard(filter, userContext)` | Return failed integration, OIC/Fusion log, and retry rows. | `DashboardFilter`, `UserContext` | Dashboard rows |

## C-014: Supplier Creation Integration Component

| Method | Purpose | Input | Output |
|---|---|---|---|
| `submitApprovedSupplier(requestId)` | Start OIC supplier create flow. | `SupplierRequestId` | `IntegrationResult` |
| `buildFusionSupplierPayload(requestId)` | Transform request data into Fusion payload. | `SupplierRequestId` | Fusion payload |
| `handleFusionSuccess(requestId, fusionResponse)` | Persist supplier number and success status. | `SupplierRequestId`, Fusion response | Workflow result |
| `handleFusionFailure(requestId, fusionError)` | Persist failure details and status. | `SupplierRequestId`, Fusion error | Workflow result |
| `useMockFusionResponse(requestId, scenario)` | Return realistic mock Fusion response when real access is unavailable. | `SupplierRequestId`, scenario | Mock response |

## C-015: Supplier Master Sync Component

| Method | Purpose | Input | Output |
|---|---|---|---|
| `runSupplierMasterSync()` | Start scheduled Fusion-to-ATP reference sync. | Schedule context | Sync result |
| `fetchFusionSuppliers(syncCursor)` | Fetch supplier reference records from Fusion. | Sync cursor | Supplier batch |
| `transformSupplierReference(fusionSupplier)` | Convert Fusion supplier data to ATP reference format. | Fusion supplier | Supplier reference |
| `storeSupplierReferenceBatch(batch)` | Upsert reference records in ATP. | Supplier reference batch | Save result |

## C-016: Integration Log and Retry Component

| Method | Purpose | Input | Output |
|---|---|---|---|
| `createIntegrationJob(requestId, integrationType)` | Create an `INTEGRATION_JOB` row before OIC work. | `SupplierRequestId`, integration type | Integration job ID |
| `recordIntegrationResponse(jobId, response)` | Store response details. | Job ID, response | Job update |
| `recordIntegrationError(jobId, error)` | Store error details. | Job ID, error | Job update |
| `isRetryEligible(jobId)` | Determine high-level technical retry eligibility. | Job ID | Boolean decision |
| `retryIntegration(jobId, userContext)` | Retry eligible technical failure by creating a child `INTEGRATION_JOB` row. | Job ID, `UserContext` | Retry result |

## C-017: Audit Component

| Method | Purpose | Input | Output |
|---|---|---|---|
| `recordStatusChange(requestId, fromStatus, toStatus, reason)` | Audit status transition. | Request ID, statuses, reason | Audit record |
| `recordReviewDecision(requestId, decisionInput)` | Audit human decision. | Request ID, decision input | Audit record |
| `recordAIEvent(requestId, aiSummaryResult)` | Audit AI summary generation. | Request ID, AI result | Audit record |
| `recordRetryEvent(jobId, userContext, result)` | Audit retry attempt. | Job ID, user, retry result | Audit record |

## C-018: Testability Component

| Method | Purpose | Input | Output |
|---|---|---|---|
| `defineDuplicateDetectionProperties()` | Identify PBT properties for matching logic. | None | Property list |
| `defineRiskScoringProperties()` | Identify PBT properties for scoring logic. | None | Property list |
| `definePayloadTransformationProperties()` | Identify PBT properties for Fusion payload transformation. | None | Property list |
