# Role Scope Review: Supplier Onboarding Portal

## Purpose

This review reconciles the Oracle Visual Builder prototype roles against the AIDLC artifacts, discovery transcript, and supervisor-demo role model.

## Source Documents Checked

- `aidlc-docs/inception/requirements/requirements.md`
- `aidlc-docs/inception/user-stories/personas.md`
- `aidlc-docs/inception/user-stories/stories.md`
- `aidlc-docs/inception/business-flow.md`
- `aidlc-docs/inception/application-design/application-design.md`
- `aidlc-docs/inception/application-design/components.md`
- `aidlc-docs/inception/application-design/services.md`

## Final Prototype UI Roles

| UI Role | Function | Prototype Access |
|---|---|---|
| Requester | Creates supplier onboarding requests, uploads/provides evidence, corrects requests, resubmits, and tracks status. | Dashboard, New Request, View status |
| Reviewer | Handles procurement/master-data review, duplicate review, risk review, approval/rejection/correction, payment checks, tax/document checks, and supplier governance concerns. | Dashboard, ERP Supplier Master, Review, Compare |
| Admin | Handles IT/support responsibilities from the transcript: OIC/Fusion integration logs, technical failure diagnostics, payload reference review, retry count visibility, and retry of eligible failed requests. | Dashboard, OIC & Fusion Logs, Property-Based Tests, Retry |

## Merged Roles

The AIDLC docs originally identify several specialist roles. For the updated prototype, business review concerns are merged into Reviewer, while transcript-defined IT/support responsibilities are split into Admin.

| Original Persona | Prototype UI Decision | Responsibility After Mapping |
|---|---|---|
| Procurement / Master Data Reviewer | Kept as Reviewer | Reviews request evidence and makes approve/reject/duplicate/correction decisions. |
| Finance User | Merged into Reviewer | Reviewer checks payment risk, bank-country mismatch, reused bank indicators, and Fusion supplier status. |
| Compliance / Risk Reviewer | Merged into Reviewer | Reviewer checks tax registration, documents, high-risk country, risk factors, and AI recommendations. |
| IT / Support Admin | Kept as Admin | Admin sees OIC/Fusion logs, OIC instance ID, payload references, responses, error messages, timestamps, retry counts, and retry controls. |
| Supplier Data Governance Lead | Merged into Reviewer viewpoint | Reviewer considers supplier master integrity and duplicate prevention. |
| Internal System Actor | Not a UI role | Backend/system behavior only: validation, matching, scoring, Gemini, ORDS, ATP, OIC, and Fusion. |

## Access Rules

- Requester can create and submit supplier requests.
- Requester cannot see ERP master comparison, OIC/Fusion logs, Property-Based Tests, Review, Compare, or Retry.
- Reviewer cannot create new supplier requests.
- Reviewer can see review, payment, compliance, duplicate, risk, and supplier master evidence.
- Admin cannot create or approve supplier requests.
- Admin can see integration logs, support diagnostics, retry count, OIC/Fusion error context, and retry eligible technical failures.
- Gemini remains advisory only.
- OIC/Fusion creation still requires reviewer approval.
- Retry still cannot bypass validation, duplicate review, risk review, or approval.

## Property-Based Testing Placement

Property-Based Testing remains valid because the AIDLC extension is enabled for business logic and transformations. In the prototype role model, it appears under Admin as a diagnostic/testing work area, not as a requester or business-reviewer workflow.

## Phase-One Limitation

The current prototype uses UI role selection plus local actor subject/role request parameters. The local ATP/ORDS backend enforces protected actions for the current scope. Before production go-live, those local parameters must be replaced by Oracle IAM claims and enterprise identity integration.

## Verification Artifact

- `aidlc-docs/oracle-vbcs-admin-role-source-render.png`
