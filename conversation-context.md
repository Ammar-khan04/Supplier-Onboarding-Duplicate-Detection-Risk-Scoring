# Conversation Context — Supplier Onboarding Project
> Updated after every user prompt. Last updated: 2026-08-02T16:37

---

## Project Identity

- **Full name:** Supplier Onboarding, Duplicate Detection & Risk Scoring
- **Type:** Oracle-native prototype
- **Stack:** Oracle ATP (database) + ORDS (REST API) + VBCS (frontend) + OIC (integrations) + Gemini (AI) + Oracle Fusion ERP (system of record)
- **Workspace:** `/home/ammarkhan/Desktop/Work/Projects/Supplier Onboarding, Duplicate Detection & Risk Scoring/`
- **Canonical source:** `HA-ERP-Project-master/` subfolder (confirmed this session)

---

## Canonical File Locations

| Type | Path |
|---|---|
| Technical Design | `HA-ERP-Project-master/Docs/technical-design.md` |
| Requirements | `HA-ERP-Project-master/Docs/requirements.md` |
| User Stories | `HA-ERP-Project-master/Docs/stories.md` |
| Architecture Diagram | `HA-ERP-Project-master/Docs/Arch Diagram.drawio.png` |
| Package Specs | `HA-ERP-Project-master/Packages/ATP_PACKAGE_SPECS.sql` |
| Package Bodies (original) | `HA-ERP-Project-master/Packages/ATP_PACKAGE_BODIES.sql` |
| Session 4 Package | `HA-ERP-Project-master/Packages/SUPPLIER_REFERENCE_PKG.sql` |
| ORDS Module (original) | `HA-ERP-Project-master/ORDS Endpoints/001_supplier_onboarding_module.sql` |
| ORDS Batch Update | `HA-ERP-Project-master/ORDS Endpoints/002_supplier_reference_batch_update.sql` |
| Schema 001 | `HA-ERP-Project-master/Schemas/001_core_request_schema.sql` |
| Schema 002 | `HA-ERP-Project-master/Schemas/002_workflow_history_result_schema.sql` |
| Schema 003 | `HA-ERP-Project-master/Schemas/003_configuration_schema.sql` |
| Schema 004 | `HA-ERP-Project-master/Schemas/004_views_indexes.sql` |
| Seed 001 | `HA-ERP-Project-master/seed/001_seed_roles_permissions.sql` |
| Seed 002 | `HA-ERP-Project-master/seed/002_seed_configuration.sql` |
| Seed 003 | `HA-ERP-Project-master/seed/003_seed_supplier_reference_and_demo.sql` |
| Seed 004 (Session 4) | `HA-ERP-Project-master/seed/004_qa_duplicate_detection_seed.sql` |
| VB Prototype | `HA-ERP-Project-master/Development/claude_test_app-v4.zip` |
| Working Plan | `HA-ERP-Project-master/Development/supplier-onboarding-plan.md` |
| Project Timeline | `project-timeline.md` (workspace root) |
| This file | `conversation-context.md` (workspace root) |

---

## Architecture Summary

### Data model key tables
| Table | Purpose |
|---|---|
| `SUPPLIER_REQUEST` | One row per onboarding request; lifecycle from DRAFT to CREATED_IN_FUSION |
| `REQUEST_ASSESSMENT` | One row per validation run; holds risk score, dup level, JSON evidence |
| `AI_ASSESSMENT` | Gemini explanation per request version |
| `ACTION_HISTORY` | Full audit trail of every status transition |
| `INTEGRATION_JOB` | Job queue for OIC (AI_EXPLANATION, FUSION_CREATE, SUPPLIER_SYNC) |
| `FUSION_SUPPLIER_REF` | Header cache of Fusion suppliers for dup detection |
| `FUSION_SUPPLIER_TAX_REF` | Tax registration cache |
| `FUSION_SUPPLIER_SITE_REF` | Site / address cache (Jaro-Winkler matching here) |
| `FUSION_SUPPLIER_BANK_REF` | Bank account fingerprint cache |
| `RISK_RULE_CONFIG` | Admin-editable risk rule weights |
| `RISK_SCORE_BAND_CONFIG` | Admin-configurable score bands → LOW/MEDIUM/HIGH/CRITICAL |
| `HIGH_RISK_COUNTRY_CONFIG` | Admin-editable high-risk country list |

### Risk scoring model
- **Max score: 100** = Base (≤55) + Duplicate (≤45)
- **Duplicate rule:** strongest single exact indicator wins (tax OR bank, never summed)
- **Similarity formula:** (55×name + 20×address + 10×country + 10×email-domain + 5×phone) / available-weight-sum
- **Threshold:** ≥85 → STRONG (20 pts) | ≥70 → POSSIBLE (10 pts) | <70 → NONE

### Request lifecycle
DRAFT → SUBMITTED → UNDER_REVIEW → APPROVED → SUBMITTED_TO_FUSION → CREATED_IN_FUSION
                                ↓             ↓
                       VALIDATION_FAILED   INTEGRATION_FAILED
                       CORRECTION_REQUIRED
                       REJECTED
                       DUPLICATE

### PL/SQL packages
| Package | Responsibility |
|---|---|
| `supplier_auth_pkg` | Role checking, request access assertions |
| `supplier_config_pkg` | Risk rule weights, high-risk countries, tax requirements |
| `supplier_dashboard_pkg` | Dashboard and integration log projections |
| `supplier_integration_pkg` | OIC job create / claim / complete lifecycle |
| `supplier_projection_pkg` | normalize_text, fingerprint (SHA-256), mask_identifier, risk_level, allowed_actions |
| `supplier_request_pkg` | create/update/submit request, add_document |
| `supplier_review_pkg` | decide_request, apply_justification_risk_adjustment |
| `supplier_validation_pkg` | assess_request — full validation + duplicate detection + risk scoring |
| `supplier_workflow_pkg` | Status transition guard, write_action, transition_request |
| `supplier_reference_pkg` | NEW (Session 4) — batch upsert of all 4 Fusion reference tables |

---

## Conversation History

### Pre-session — Sessions 1–3 (already complete at conversation start)

**Session 1 — Dashboard + Document Upload (VBCS)**
- Wired dashboard stats/filters to live ORDS data via ArrayDataProvider2
- Added uploadDocument operation to VBCS service catalog
- Fixed saveDraftChain bug: never captured request_id from create response

**Session 2 — Backend Architecture Review + Plan**
- Mapped all ORDS routes against OpenAPI catalog
- Reviewed all 8 PL/SQL packages
- Identified: supplier-reference/batch only handles header (child tables empty)
- Identified VBCS gaps: Admin screen missing, AI regen button missing
- Produced supplier-onboarding-plan.md

**Session 3 — Duplicate Detection Deep Dive + Fixes (deployed and verified)**
- Fixed self-doubling score bug in add_risk()
- Fixed exact-match double-counting (tax+bank was summing to 90, now takes max)
- Fixed duplicate component cap (was config-dependent, now hard-capped at 45)
- Implemented full weighted multi-field formula (name/address/country/email/phone)
- Added candidate identification in duplicate_matches_json
- Fixed site country matching (uses site_country_code, falls back to country_code)
- Added active-supplier join for exact lookups
- Added dedicated normalize_supplier_name_for_matching() (strips LTD, LLC, etc.)
- Added json_escape() helper

---

### Prompt: "are u looking at this folder as well? HA-ERP-Project-master"
- AI found folder at HA-ERP-Project-master/ inside the workspace
- Confirmed it contains canonical source files (packages, schemas, ORDS module, seed data, docs, VB prototype)
- AI was not reading from this folder before — now confirmed as ground truth

### Prompt: "1" (read the package bodies)
- Read all 1,905 lines of ATP_PACKAGE_BODIES.sql + 309 lines of ATP_PACKAGE_SPECS.sql
- Key findings:
  - All packages are clean and correct
  - Session 3 fixes ARE present in canonical file (confirmed)
  - validate_risk_allocation is still architecturally broken (sums all weights to 100 — wrong)
  - apply_justification_risk_adjustment is correct (pre-confirmed for Session 5)
  - risk_level() reads from risk_score_band_config_v (correct)
  - base_currency_amount uses conversion_rate=1 / USD assumed (acceptable for prototype)
  - INCOMPLETE_ADDRESS uses 3 quality components with ceiling formula (correct)

### Prompt: "okay continue" — Session 4 executed

Files created:
1. HA-ERP-Project-master/Packages/SUPPLIER_REFERENCE_PKG.sql
   - New PL/SQL package: process_batch(), upsert_supplier(), upsert_tax_row(), upsert_site_row(), upsert_bank_row()
   - Incremental sync safe: omitted rows NOT deactivated
   - Per-row error isolation: rejected rows counted, never rollback header
   - Returns: syncId, headerUpserted, taxUpserted, siteUpserted, bankUpserted, rejected

2. HA-ERP-Project-master/ORDS Endpoints/002_supplier_reference_batch_update.sql
   - Replaces header-only POST /supplier-reference/batch handler
   - Reads :body (full JSON), calls supplier_reference_pkg.process_batch()
   - Returns JSON with all upsert counts + error handling

3. HA-ERP-Project-master/seed/004_qa_duplicate_detection_seed.sql
   - Case 1: Exact tax match (QA-TAX-EXACT-001) → 45 pts
   - Case 2: Exact bank match (QA-BANK-EXACT-9900) → 45 pts
   - Case 3: Similar POSSIBLE (Nexus Freight Services, country AE) → ~10 pts
   - Case 4: Similar STRONG (Pinnacle Construction Group, country SA) → 20 pts
   - Case 5: No match (Totally Unrelated Vendor Inc, country DE)
   - Case 6: Inactive supplier (same as Case 4 but active=N) → excluded

project-timeline.md updated: Session 4 marked complete.

### Prompt: "how do i check how much usage limit i have left? and how quickly will it run out if i run a playwright mcp"
- AI cannot see usage quota
- Check aistudio.google.com → Settings → Usage (or billing dashboard)
- Playwright MCP quota impact: DOM snapshots = high, multi-step loops = multiplies fast, targeted tasks = low
- Advice: keep tasks short and targeted

### Prompt: "record the context of the entire conversation in an MD file as well / Record it after every prompt / and now continue as well"
- Created this file (conversation-context.md)
- Instruction: update after every subsequent prompt
- Next: continuing with Session 5

---

## Current State (as of 2026-08-02T16:37)

### Sessions
| Session | Topic | Status |
|---|---|---|
| 1 | Dashboard + Document Upload (VBCS) | Complete |
| 2 | Backend Architecture Review + Plan | Complete |
| 3 | Duplicate Detection Deep Dive + Fixes | Complete |
| 4 | Supplier Reference Batch (child tables) | Complete |
| 5 | Risk Calculation Phase | IN PROGRESS |
| 6 | Admin VBCS Screen | Not started |
| 7 | AI Regeneration Button | Not started |
| 8 | OIC Integration Flows | Not started |
| 9 | Cloud ATP/ORDS Migration | Not started |
| 10 | Formal Build and Test Docs | Not started |

### Next: Session 5 — Risk Calculation Phase

5a — Fix validate_risk_allocation (currently wrong: sums ALL weights to 100)
  Fix: sum of active BASE weights <= 55 AND no single DUPLICATE weight > 45
5b — Review apply_justification_risk_adjustment → PRE-CONFIRMED CORRECT
5c — Confirm risk_level() band mapping → PRE-CONFIRMED CORRECT
5d — Confirm expected-spend calculation → PRE-CONFIRMED (USD assumed, conversion_rate=1)
5e — Confirm INCOMPLETE_ADDRESS ceiling formula → PRE-CONFIRMED CORRECT

Only real code change needed: validate_risk_allocation + update_risk_rule() in supplier_config_pkg.

---

## Known Issues / Deferred Items

| Item | Status | Deferred to |
|---|---|---|
| validate_risk_allocation wrong sum-to-100 check | IN PROGRESS (Session 5) | Session 5 |
| add_document — p_document_content always null from ORDS | Deferred | Not in prototype scope |
| Real currency conversion for base_currency_amount | Deferred | Not in prototype scope |
| End-to-end duplicate detection test (post Session 4 seed) | Pending deployment | After Session 4 deploy |

---

## Batch Payload Format (Session 4 reference)

POST /ha_v1/supplier-reference/batch

{
  "syncId": "SYNC-20260716-01",
  "fullSnapshot": false,
  "suppliers": [
    {
      "fusionSupplierId": "FUS-1001",
      "supplierNumber": "SUP-1001",
      "supplierName": "Atlas Packaging LLC",
      "supplierType": "COMPANY",
      "active": "Y",
      "sourceLastUpdatedAt": "2026-07-16T10:00:00Z",
      "taxRegistrations": [
        {
          "fusionTaxReferenceId": "TAX-1001",
          "countryCode": "PK",
          "taxType": "NTN",
          "taxRegistrationNumber": "PK-NTN-445566",
          "active": "Y"
        }
      ],
      "sites": [
        {
          "fusionSupplierSiteId": "SITE-1001",
          "siteName": "Karachi Main",
          "siteNumber": "KHI-01",
          "countryCode": "PK",
          "addressLine1": "12 Industrial Area",
          "city": "Karachi",
          "contactEmail": "info@atlaspack.example",
          "phone": "+92 21 1234567",
          "active": "Y"
        }
      ],
      "bankAccounts": [
        {
          "fusionBankAccountId": "BANK-1001",
          "bankCountryCode": "PK",
          "currencyCode": "PKR",
          "bankAccountNumber": "PK-IBAN-445566778899",
          "active": "Y"
        }
      ]
    }
  ]
}

---

### Prompt: "record the context..." + "continue" — Session 5 executed

**5a — validate_risk_allocation FIX (the only real code change in Session 5)**

Old code (wrong):
  sum(all active weights) must = 100

New code (correct):
  Check 1: sum of active BASE weights <= 55
  Check 2: max single active DUPLICATE weight <= 45

Files changed:
- HA-ERP-Project-master/Packages/ATP_PACKAGE_BODIES.sql
  (validate_risk_allocation procedure patched in-place)
- HA-ERP-Project-master/Packages/SUPPLIER_CONFIG_PKG_SESSION5_FIX.sql
  (standalone patch script — deploy this to the running DB)

5b–5e — All pre-confirmed correct from the Session 3 full package read. No code changes needed.

project-timeline.md updated: Session 5 marked complete.
conversation-context.md updated.

Current state after Session 5:
Sessions 1–5 complete.
Next: Session 6 — Admin VBCS Screen (Risk Weights + High-Risk Countries)
