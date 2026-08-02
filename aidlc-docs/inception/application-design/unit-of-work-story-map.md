# Unit of Work Story Map

## Mapping Overview

This document maps each approved user story to the units of work that will deliver it.

Legend:

- Primary: unit owns the core implementation.
- Supporting: unit provides UI, storage, integration, test, or evidence support.

## Story-to-Unit Matrix

| Story | Story Name | Primary Unit | Supporting Units |
|---|---|---|---|
| US-001 | Create Supplier Request Draft | UOW-002 ATP/ORDS Supplier Request Foundation | UOW-001 Visual Builder Prototype UI |
| US-002 | Upload Supplier Documents | UOW-002 ATP/ORDS Supplier Request Foundation | UOW-001 Visual Builder Prototype UI, UOW-004 OIC/Fusion/Gemini Integration if Object Storage integration is configured there |
| US-003 | Submit Supplier Request for Validation | UOW-002 ATP/ORDS Supplier Request Foundation | UOW-003 Duplicate Detection and Risk Logic, UOW-001 Visual Builder Prototype UI |
| US-004 | Track Supplier Request Status | UOW-002 ATP/ORDS Supplier Request Foundation | UOW-001 Visual Builder Prototype UI, UOW-004 OIC/Fusion/Gemini Integration |
| US-005 | Correct and Resubmit Request | UOW-002 ATP/ORDS Supplier Request Foundation | UOW-003 Duplicate Detection and Risk Logic, UOW-001 Visual Builder Prototype UI |
| US-006 | Validate Supplier Request Data | UOW-003 Duplicate Detection and Risk Logic | UOW-002 ATP/ORDS Supplier Request Foundation |
| US-007 | Synchronize Existing Supplier Master Data | UOW-004 OIC/Fusion/Gemini Integration | UOW-002 ATP/ORDS Supplier Request Foundation |
| US-008 | Detect Potential Duplicate Suppliers | UOW-003 Duplicate Detection and Risk Logic | UOW-002 ATP/ORDS Supplier Request Foundation, UOW-005 Audit/Testability/Demo Evidence |
| US-009 | Calculate Explainable Supplier Risk | UOW-003 Duplicate Detection and Risk Logic | UOW-002 ATP/ORDS Supplier Request Foundation, UOW-005 Audit/Testability/Demo Evidence |
| US-010 | Generate AI Risk and Duplicate Explanation | UOW-004 OIC/Fusion/Gemini Integration | UOW-002 ATP/ORDS Supplier Request Foundation, UOW-003 Duplicate Detection and Risk Logic |
| US-011 | Regenerate AI Summary After Request Changes | UOW-004 OIC/Fusion/Gemini Integration | UOW-002 ATP/ORDS Supplier Request Foundation, UOW-003 Duplicate Detection and Risk Logic |
| US-012 | View Reviewer Work Queue | UOW-002 ATP/ORDS Supplier Request Foundation | UOW-001 Visual Builder Prototype UI, UOW-003 Duplicate Detection and Risk Logic |
| US-013 | Review Request Detail With Evidence | UOW-002 ATP/ORDS Supplier Request Foundation | UOW-001 Visual Builder Prototype UI, UOW-003 Duplicate Detection and Risk Logic, UOW-004 OIC/Fusion/Gemini Integration |
| US-014 | Approve Clean Supplier Request | UOW-002 ATP/ORDS Supplier Request Foundation | UOW-004 OIC/Fusion/Gemini Integration |
| US-015 | Reject or Mark Duplicate Supplier Request | UOW-002 ATP/ORDS Supplier Request Foundation | UOW-003 Duplicate Detection and Risk Logic, UOW-001 Visual Builder Prototype UI |
| US-016 | Request Correction From Requester | UOW-002 ATP/ORDS Supplier Request Foundation | UOW-001 Visual Builder Prototype UI, UOW-003 Duplicate Detection and Risk Logic |
| US-017 | Review Payment-Related Supplier Risk | UOW-003 Duplicate Detection and Risk Logic | UOW-002 ATP/ORDS Supplier Request Foundation, UOW-001 Visual Builder Prototype UI |
| US-018 | Review Compliance Risk | UOW-003 Duplicate Detection and Risk Logic | UOW-002 ATP/ORDS Supplier Request Foundation, UOW-004 OIC/Fusion/Gemini Integration, UOW-001 Visual Builder Prototype UI |
| US-019 | Mask Sensitive Bank Data | UOW-002 ATP/ORDS Supplier Request Foundation | UOW-003 Duplicate Detection and Risk Logic, UOW-001 Visual Builder Prototype UI |
| US-020 | Submit Approved Supplier to Fusion Through OIC | UOW-004 OIC/Fusion/Gemini Integration | UOW-002 ATP/ORDS Supplier Request Foundation |
| US-021 | Capture Successful Fusion Creation | UOW-004 OIC/Fusion/Gemini Integration | UOW-002 ATP/ORDS Supplier Request Foundation, UOW-001 Visual Builder Prototype UI |
| US-022 | Capture Fusion or OIC Failure | UOW-004 OIC/Fusion/Gemini Integration | UOW-002 ATP/ORDS Supplier Request Foundation, UOW-001 Visual Builder Prototype UI for Admin logs |
| US-023 | Retry Eligible Integration Failures | UOW-004 OIC/Fusion/Gemini Integration | UOW-002 ATP/ORDS Supplier Request Foundation, UOW-001 Visual Builder Prototype UI for Admin retry |
| US-024 | Demonstrate Required Supplier Scenarios | UOW-005 Audit, Testability, and Demo Evidence | UOW-001 Visual Builder Prototype UI, UOW-002 ATP/ORDS Supplier Request Foundation, UOW-003 Duplicate Detection and Risk Logic, UOW-004 OIC/Fusion/Gemini Integration |
| US-025 | Test Business Logic With Property-Based Tests | UOW-005 Audit, Testability, and Demo Evidence | UOW-003 Duplicate Detection and Risk Logic, UOW-004 OIC/Fusion/Gemini Integration |
| US-026 | Audit Review Decisions and Integration Attempts | UOW-002 ATP/ORDS Supplier Request Foundation | UOW-004 OIC/Fusion/Gemini Integration, UOW-005 Audit/Testability/Demo Evidence |

## Unit Story Backlog

### UOW-001 Visual Builder Prototype UI

| Story | Role |
|---|---|
| US-001 | Supporting UI for create draft. |
| US-002 | Supporting UI for document upload metadata/display. |
| US-003 | Supporting UI for submit action. |
| US-004 | Supporting UI for requester status tracking. |
| US-012 | Supporting UI for reviewer work queue. |
| US-013 | Supporting UI for reviewer evidence detail. |
| US-015 | Supporting UI for reject/duplicate action. |
| US-016 | Supporting UI for correction flow. |
| US-017 | Supporting UI for payment risk warnings. |
| US-018 | Supporting UI for compliance risk evidence. |
| US-019 | Supporting UI for masked bank display. |
| US-021 | Supporting UI for supplier number display. |
| US-022 | Supporting Admin UI for failure details. |
| US-023 | Supporting Admin UI for retry action. |
| US-024 | Supporting demo scenario visibility. |

### UOW-002 ATP/ORDS Supplier Request Foundation

| Story | Role |
|---|---|
| US-001 | Primary persistence and request create/update API. |
| US-002 | Primary supplier document metadata persistence and API contract. |
| US-003 | Primary submit workflow, status transition, and validation result storage. |
| US-004 | Primary status tracking and dashboard/query APIs. |
| US-005 | Primary correction/resubmit workflow state. |
| US-006 | Supporting validation result persistence and foundational validation execution surface. |
| US-007 | Supporting supplier reference storage for sync output. |
| US-008 | Supporting duplicate match storage and request/reference access. |
| US-009 | Supporting risk score storage and request data access. |
| US-010 | Supporting AI summary storage. |
| US-011 | Supporting regenerated AI summary storage and timestamps. |
| US-012 | Primary reviewer dashboard/query API. |
| US-013 | Primary request detail aggregation API. |
| US-014 | Primary approval workflow state. |
| US-015 | Primary reject/duplicate/correction decision persistence. |
| US-016 | Primary correction workflow state. |
| US-019 | Primary masked bank storage/display contract. |
| US-020 | Supporting approved request source data. |
| US-021 | Supporting Fusion response and supplier number storage. |
| US-022 | Supporting integration failure status and log storage. |
| US-023 | Supporting retry count and retry audit persistence. |
| US-024 | Supporting seeded demo data. |
| US-026 | Primary audit tables and audit write surfaces. |

### UOW-003 Duplicate Detection and Risk Logic

| Story | Role |
|---|---|
| US-003 | Supporting validation, duplicate, and risk execution after submit. |
| US-005 | Supporting revalidation and rescoring after correction. |
| US-006 | Primary business validation logic. |
| US-008 | Primary duplicate detection logic. |
| US-009 | Primary risk scoring logic. |
| US-013 | Supporting evidence details for reviewer. |
| US-017 | Primary payment-related risk factors. |
| US-018 | Primary compliance risk factors. |
| US-019 | Supporting protected bank matching without exposing full values. |
| US-024 | Supporting demo scenario outcomes. |
| US-025 | Primary PBT logic coverage for normalization, duplicate detection, and risk scoring. |

### UOW-004 OIC, Fusion, and Gemini Integration

| Story | Role |
|---|---|
| US-007 | Primary Fusion supplier master sync. |
| US-010 | Primary Gemini AI explanation flow. |
| US-011 | Primary AI regeneration flow. |
| US-014 | Supporting supplier creation after approval. |
| US-020 | Primary OIC-to-Fusion creation flow. |
| US-021 | Primary success response handling. |
| US-022 | Primary failure capture. |
| US-023 | Primary retry handling. |
| US-024 | Supporting integration failure demo scenario. |
| US-025 | Supporting PBT for payload transformations. |
| US-026 | Supporting integration attempt audit details. |

### UOW-005 Audit, Testability, and Demo Evidence

| Story | Role |
|---|---|
| US-008 | Supporting PBT and evidence for duplicate detection. |
| US-009 | Supporting PBT and evidence for risk scoring. |
| US-020 | Supporting payload transformation test evidence. |
| US-024 | Primary seeded/demo scenario coverage. |
| US-025 | Primary PBT strategy and evidence consolidation. |
| US-026 | Supporting audit verification evidence. |

## Story Coverage Validation

| Validation Item | Result |
|---|---|
| All stories US-001 through US-026 assigned to at least one unit | Pass |
| ATP/ORDS first unit has sufficient scope for database/API construction | Pass |
| Duplicate/risk logic separated from UI | Pass |
| Fusion/Gemini/OIC integration separated from ATP foundation | Pass |
| Property-based testing carried forward | Pass |
| Three-role Requester/Reviewer/Admin model preserved | Pass |
