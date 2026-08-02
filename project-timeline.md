# Supplier Onboarding — Project Timeline & Module Breakdown

> Living document. Tracks progress session by session from the current state forward.
> Last updated: 2026-07-31

---

## Project Scope (7 Areas)

| # | Area |
|---|---|
| 1 | Duplicate detection / validation (all cases from design doc) |
| 2 | Risk calculation (deterministic score + reviewer justification-vagueness adjustment + score→level mapping) |
| 3 | Admin editing of risk weights and high-risk-country list |
| 4 | Frontend surfacing of all of the above (Visual Builder) |
| 5 | OIC integrations (AI summary, Fusion supplier creation, Fusion reference sync) |
| 6 | Connecting ORDS to OIC |
| 7 | AI summary for the reviewer |

---

## Completed Sessions

### ✅ Session 1 — Dashboard + Document Upload (VBCS)

**Focus:** Visual Builder frontend wiring

- [x] Wired dashboard stats and filters to live ORDS data via `ArrayDataProvider2` + page-module functions (`computeDashboardStats`, `filterRequests`, `buildBusinessUnitOptions`)
- [x] Added `uploadDocument` operation to the VBCS `ORDS-Specification` service catalog
- [x] Added document-upload UI on the request form (metadata only; `add_document.p_document_content` is `null` in current ORDS handler — matches backend capability)
- [x] Fixed latent bug: `saveDraftChain` never captured `request_id` from create response → document upload could never be enabled after a draft save

**Deliverable:** Working dashboard wired to real data; document upload UI ready

---

### ✅ Session 2 — Backend Architecture Review + Plan

**Focus:** Mapping the full backend surface and producing the 7-point plan

- [x] Read and mapped `001_supplier_onboarding_module.sql` (ORDS routing) against the OpenAPI catalog
- [x] Reviewed all 8 PL/SQL packages: `supplier_auth_pkg`, `supplier_config_pkg`, `supplier_dashboard_pkg`, `supplier_integration_pkg`, `supplier_projection_pkg`, `supplier_request_pkg`, `supplier_review_pkg`, `supplier_validation_pkg`, `supplier_workflow_pkg`
- [x] Identified that `supplier_reference/batch` only handles header — child tables (tax/site/bank) have no population path
- [x] Identified VBCS gaps: Admin screen missing, AI regeneration button missing, `erp-master` tab stub
- [x] Produced the working plan document (`supplier-onboarding-plan.md`)

**Deliverable:** Full backend surface map; structured 7-point plan

---

### ✅ Session 3 — Duplicate Detection Deep Dive + Fixes

**Focus:** Reviewing and rewriting `supplier_validation_pkg` duplicate-detection section

**Bugs found and fixed:**
- [x] **Self-doubling score bug** — `add_risk()` was called with `l_duplicate_score` as both `p_applied_weight` and accumulator, doubling the value
- [x] **Exact-match double-counting** — if both tax and bank matched, code accumulated `45 + 45 = 90` instead of `max(45, 45) = 45`; fixed to take the greater of the two
- [x] **Duplicate component cap was config-dependent** — old cap relied on sum of all duplicate rule weights in config; fixed to a structural hard cap of 45 per design spec

**Missing pieces implemented:**
- [x] **Weighted multi-field formula** — `55×name + 20×address + 10×country + 10×email-domain + 5×phone` (normalized by available fields) — previously only name was compared
- [x] **Candidate identification** — `duplicate_matches_json` now records `fusion_supplier_number` and matched site ID for both exact and similarity paths
- [x] **Site country matching** — switched from header `country_code` to `site_country_code` (falling back to `country_code` if null) per design
- [x] **Active supplier join for exact lookups** — tax/bank exact match now also requires owning `FUSION_SUPPLIER_REF` to be active
- [x] **Dedicated name normalization** — strips legal suffixes (`LTD`, `LIMITED`, `INC`, `LLC`, `CORP`, `CO`) without touching `supplier_projection_pkg.normalize_text` (used for fingerprinting)

**Flagged / deferred:**
- [ ] `supplier_config_pkg.validate_risk_allocation` sum-to-100 check is architecturally incorrect → deferred to Session 5
- [ ] `add_document.p_document_content` always `null` from current ORDS handler → deferred (file bytes not in prototype scope)

**Deliverable:** Rewritten `supplier_validation_pkg` package body deployed and verified

---

## Upcoming Sessions

---

### ✅ Session 4 — Supplier Reference Batch: Child Table Extension

**Focus:** Filling the gap that blocks duplicate detection from ever producing a match in a fresh environment

**Problem:** `POST /supplier-reference/batch` currently only upserts `FUSION_SUPPLIER_REF` (header). `FUSION_SUPPLIER_TAX_REF`, `FUSION_SUPPLIER_SITE_REF`, and `FUSION_SUPPLIER_BANK_REF` are never populated, so duplicate detection always returns "no match."

**Tasks:**
- [x] Extend `POST /supplier-reference/batch` ORDS handler and PL/SQL to accept and upsert child arrays: `taxRegistrations`, `sites`, and `bankAccounts` in the same payload (payload structure already specified in the design doc)
- [x] Implement normalization in the upsert path:
  - Tax: normalize → generate `tax_id_fingerprint` (SHA-256 / HMAC), mask for display
  - Site: normalize address → populate `address_normalized`, extract `email_domain`, normalize `phone_normalized`
  - Bank: normalize account number → generate `bank_account_fingerprint`, retain `bank_account_last_four`
- [x] Implement `last_seen_sync_id` and incremental-sync deactivation logic (omitted child rows are NOT deleted during incremental sync)
- [x] Update ORDS response to return `syncId` + header/tax/site/bank upsert counts + rejected records
- [x] Seed QA reference data for all 5 design-doc test cases:
  - Exact tax duplicate → 45 duplicate points
  - Exact bank duplicate → 45 duplicate points
  - Similar supplier (same country, similar name/address) → 10 or 20 points
  - No match → 0 points
  - Inactive supplier/site/bank → excluded from matching
- [ ] Run duplicate-detection end-to-end test against seeded data; verify `duplicate_matches_json` output

**Deliverable:** Fully functional `supplier-reference/batch` with child table support; duplicate detection produces real results in a fresh environment

---

### ✅ Session 5 — Risk Calculation Phase

**Focus:** Completing and validating the deterministic risk scoring pipeline and admin configurability

#### 5a — Fix `validate_risk_allocation` in `supplier_config_pkg`
- [x] Review current logic — enforces all active weights sum to exactly 100 (architecturally wrong: base rules additive ≤55, duplicate rules "take the strongest" ≤45)
- [x] Fix to enforce: sum of active BASE weights ≤ 55; no single DUPLICATE weight > 45; API rejects config changes that would breach these bounds
- [x] Verify fix does not break existing config-related package calls
  - `update_risk_rule()` still calls `validate_risk_allocation` after every change — call path unchanged

#### 5b — Review `apply_justification_risk_adjustment`
- [x] Read `supplier_review_pkg.apply_justification_risk_adjustment` line by line
- [x] Confirm `reviewer_adjustment_points` (allowed: 0, 3, 5, 10) is correctly added to `deterministic_risk_score` → `risk_score`
- [x] Confirm `risk_score` is written to both `REQUEST_ASSESSMENT` and parent `SUPPLIER_REQUEST`
- [x] Confirm `reviewer_adjusted_by_subject_id` and `reviewer_adjusted_at` are captured
- [x] Confirm resubmission resets the adjustment
  - All confirmed correct from Session 3 full read of ATP_PACKAGE_BODIES.sql

#### 5c — Band-to-level mapping
- [x] Confirm `supplier_projection_pkg.risk_level` reads from `risk_score_band_config_v` (admin-configurable)
- [x] Confirm band is applied to final `risk_score` (after reviewer adjustment), not `deterministic_risk_score`

#### 5d — Expected-spend calculation
- [x] Confirm ATP converts `expected_annual_spend` to USD at submission and stores converted amount + conversion rate
  - Confirmed: `conversion_rate = 1` (USD assumed, no real FX — acceptable for prototype)
- [x] Confirm `HIGH_EXPECTED_SPEND` banded scoring: <100k=0, 100k–250k=2, 250k–500k=3, ≥500k=5
- [x] Verify `risk_factors_json` evidence includes band and applied weight

#### 5e — Address completeness calculation
- [x] Confirm `INCOMPLETE_ADDRESS` uses ceiling formula: `ceiling(max_weight × missing / expected)`, evaluated only after mandatory fields pass
- [x] Confirm evidence stored: 3 quality components (address_line2, postal_code, contact_phone)

**Deliverable:** Risk scoring pipeline fully correct and validated; `validate_risk_allocation` enforces correct architectural bounds

---

### 🔲 Session 6 — Admin VBCS Screen (Risk Weights + High-Risk Countries)

**Focus:** Building the missing Admin frontend (backend ORDS endpoints already exist and are verified)

#### 6a — Risk Rule Weight Editor
- [ ] Build Admin tab/page with table of all `RISK_RULE_CONFIG` rows
- [ ] Show: `rule_code`, `rule_name`, `component` (BASE / DUPLICATE), `weight_points`, `active`
- [ ] Allow inline editing of `weight_points` and `active` flag per row
- [ ] Show running totals: "Active BASE total: X / 55" and "Max DUPLICATE weight: Y / 45"
- [ ] Disable Save if totals exceed bounds (client-side guard; server enforces too)
- [ ] Wire to `PUT /risk-rules/{rule_code}`

#### 6b — High-Risk Country List Editor
- [ ] Build table of `HIGH_RISK_COUNTRY_CONFIG` rows: `country_code`, `reason`, `source_name`, `effective_date`, `active`
- [ ] Allow toggling `active` and editing `reason` per row; allow adding new entries
- [ ] Wire to `PUT /high-risk-countries/{country_code}`

#### 6c — Score Band Display (read-only)
- [ ] Display current `RISK_SCORE_BAND_CONFIG` bands on Admin screen for reference

**Deliverable:** Fully functional Admin screen in VBCS for risk rule and high-risk country management

---

### 🔲 Session 7 — Reviewer Screen: AI Regeneration Button

**Focus:** One remaining VBCS Reviewer-screen gap

**Tasks:**
- [ ] Add "Regenerate AI Summary" button to Reviewer request-detail screen
- [ ] Wire to `POST /requests/{requestId}/ai-regeneration`
- [ ] Show loading state while new AI job is queued
- [ ] Refresh AI summary area after regeneration (show "Pending" until OIC processes the job)
- [ ] Confirm backend: `ai-regeneration` handler creates new `AI_EXPLANATION` job and sets latest `AI_ASSESSMENT` status to `PENDING` for current request version

**Deliverable:** Reviewer can trigger a fresh Gemini explanation from the UI

---

### 🔲 Session 8 — OIC Integration Flows

**Focus:** Designing and implementing the three OIC integration flows connecting the backend to Gemini and Fusion ERP

> Note: Mock endpoints can be used while real Fusion/OIC access is unavailable. The ORDS job-queue API surface is already implemented.

#### 8a — AI Explanation Flow (OIC → Gemini → ORDS)
- [ ] Design OIC scheduled integration: poll `GET /integration-jobs?type=AI_EXPLANATION&status=READY`
- [ ] Claim job: `POST /integration-jobs/{jobId}/claim`
- [ ] Strip/mask bank and sensitive data before sending to Gemini
- [ ] Call Gemini with versioned structured-JSON prompt (request data, validation findings, duplicate reasons, risk factors)
- [ ] Parse Gemini response: extract `ai_summary`, `ai_recommended_actions`, `justification_quality`, `model_name`
- [ ] Return result: `PUT /integration-jobs/{jobId}/result` with `status=SUCCESS`
- [ ] Handle AI failure: store `status=FAILED` — does NOT block manual review
- [ ] Confirm ATP stores output in `AI_ASSESSMENT` and marks job complete

#### 8b — Fusion Supplier Creation Flow (OIC → Fusion ERP → ORDS)
- [ ] Design OIC scheduled integration: poll `GET /integration-jobs?type=FUSION_CREATE&status=READY`
- [ ] Claim job; transform ORDS payload into Fusion supplier REST payload
- [ ] Call Fusion supplier creation API
- [ ] On success: return `fusionSupplierId`, `fusionSupplierNumber` → ATP transitions to `CREATED_IN_FUSION`, queues `SUPPLIER_SYNC` refresh job
- [ ] On failure: return `errorType`, `errorMessage`, `retryable` → ATP transitions to `INTEGRATION_FAILED`
- [ ] Confirm idempotency: `request_id` + `job_id` as idempotency reference; retry creates new logged attempt, does not bypass approval

#### 8c — Fusion Supplier Master Sync Flow (Fusion → OIC → ORDS)
- [ ] Design OIC scheduled integration (nightly + immediate post-creation)
- [ ] Read new/changed Fusion suppliers, tax registrations, sites, and bank accounts
- [ ] Send in batches to `POST /supplier-reference/batch` (extended in Session 4)
- [ ] Handle incremental sync: omitted child rows are NOT treated as deleted
- [ ] Record sync result (`syncId`, counts, errors) in `INTEGRATION_JOB` for Admin visibility
- [ ] Immediate post-creation sync: after `FUSION_CREATE` succeeds, queue `SUPPLIER_SYNC` so new supplier is detectable before nightly run

**Deliverable:** All three OIC flows designed; mock-endpoint versions runnable locally; real-Fusion versions ready for credential configuration

---

### 🔲 Session 9 — Cloud ATP/ORDS Migration + Visual Builder Cloud Wiring

**Focus:** Moving the local prototype to Oracle Cloud infrastructure

#### 9a — Cloud ATP Migration
- [ ] Provision Oracle ATP cloud instance
- [ ] Run schema DDL scripts (`001–004_*.sql`) against cloud ATP schema
- [ ] Run seed data scripts against cloud ATP
- [ ] Deploy PL/SQL packages and ORDS module to cloud ATP

#### 9b — Cloud ORDS Configuration
- [ ] Configure ORDS on cloud ATP or standalone ORDS instance
- [ ] Enable HTTPS; configure SSL/TLS
- [ ] Configure Oracle IAM authentication for ORDS endpoints
- [ ] Test all 41 Postman endpoints against cloud ORDS

#### 9c — Visual Builder Cloud Wiring
- [ ] Update Visual Builder service connections from `localhost:8080` to cloud ORDS base URL
- [ ] Configure Oracle IAM roles (Requester, Reviewer, Admin) in Visual Builder
- [ ] Wire `actor_subject_id` and `actor_roles` headers from IAM identity to ORDS calls
- [ ] Run Visual Builder smoke tests against cloud backend

#### 9d — OIC Cloud Configuration
- [ ] Configure OIC integration connections to cloud ORDS endpoints
- [ ] Configure OIC → Gemini connection (API key / credential)
- [ ] Configure OIC → Fusion ERP connection
- [ ] Deploy OIC integration flows from Session 8
- [ ] Run end-to-end smoke test: submit → AI explanation → reviewer approval → Fusion creation → sync

**Deliverable:** Fully cloud-hosted prototype with Visual Builder, ORDS, ATP, OIC, Gemini, and Fusion ERP connected end-to-end

---

### 🔲 Session 10 — Formal Build & Test Instructions + Final Documentation

**Focus:** Completing the formal AIDLC Build and Test stage

**Tasks:**
- [ ] Generate `aidlc-docs/construction/build-and-test/build-instructions.md`
- [ ] Generate `aidlc-docs/construction/build-and-test/unit-test-instructions.md`
- [ ] Generate `aidlc-docs/construction/build-and-test/integration-test-instructions.md`
- [ ] Generate `aidlc-docs/construction/build-and-test/performance-test-instructions.md`
- [ ] Generate `aidlc-docs/construction/build-and-test/build-and-test-summary.md`
- [ ] Present Build and Test stage for formal AIDLC approval gate
- [ ] Update `project-progress-summary.md` and `aidlc-state.md` to reflect final state
- [ ] Archive deliverables: updated Postman collection, Visual Builder export, schema + seed scripts, OIC flow definitions

**Deliverable:** Complete AIDLC Build and Test stage; fully documented and packaged prototype

---

## Module Dependency Map

```
Session 4 (batch child tables)
    └── required by → Session 8c (SUPPLIER_SYNC) and any meaningful dup detection QA

Session 5 (risk calculation)
    └── feeds into → Session 6 (Admin UI shows correct weight bounds)

Session 6 (Admin VBCS screen)
    └── depends on → Session 5 (correct weight validation logic)

Session 7 (AI regen button)
    └── depends on → Session 8a end-to-end (UI-only shell can be built independently first)

Session 8a/8b/8c (OIC flows)
    └── 8c depends on → Session 4 (batch child tables must exist)
    └── 8a/8b can proceed independently

Session 9 (cloud migration)
    └── depends on → Sessions 4–8 being complete or stable

Session 10 (Build & Test docs)
    └── depends on → Session 9 (cloud end-to-end must be verified first)
```

---

## Quick Status Summary

| Session | Topic | Status |
|---|---|---|
| Session 1 | Dashboard + Document Upload (VBCS) | ✅ Complete |
| Session 2 | Backend Architecture Review + Plan | ✅ Complete |
| Session 3 | Duplicate Detection Deep Dive + Fixes | ✅ Complete |
| Session 4 | Supplier Reference Batch — Child Table Extension | ✅ Complete |
| Session 5 | Risk Calculation Phase | ✅ Complete |
| Session 6 | Admin VBCS Screen (Risk Weights + High-Risk Countries) | 🔲 Not started |
| Session 7 | Reviewer Screen — AI Regeneration Button | 🔲 Not started |
| Session 8 | OIC Integration Flows (AI, Fusion Create, Sync) | 🔲 Not started |
| Session 9 | Cloud ATP/ORDS Migration + Visual Builder Cloud Wiring | 🔲 Not started |
| Session 10 | Formal Build & Test Instructions + Final Documentation | 🔲 Not started |
