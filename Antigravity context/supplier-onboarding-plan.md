# Supplier Onboarding — Working Plan & Status

Living document. I update this whenever we finish or change scope on a piece of work.
Last updated: this session (duplicate detection pass).

## Scope reminder (from the original ask)

1. Duplicate detection/validation (all cases from the design doc)
2. Risk calculation (deterministic score + reviewer justification-vagueness adjustment) + score→level mapping
3. Admin editing of risk weights and the high-risk-country list
4. Frontend surfacing of all of the above
5. OIC integrations (AI summary, Fusion supplier creation, Fusion reference sync)
6. Connecting ORDS to OIC
7. AI summary for the reviewer

## Current backend inventory (as of the package bodies/specs upload)

Real PL/SQL exists and is more complete than first assumed. Packages:

- `supplier_auth_pkg` — role checks (`has_role`, `require_role`, `assert_request_access`). Looked complete.
- `supplier_config_pkg` — config lookups, `risk_rule_weight`, `risk_component_total`, `is_high_risk_country`, `is_tax_required`, `validate_risk_allocation`, `update_risk_rule`, `set_high_risk_country`. Backing tables: `risk_rule_config`, `risk_score_band_config`, `high_risk_country_config`, `tax_requirement_config`, generic `configuration`.
- `supplier_dashboard_pkg` — queue/log projections (not yet reviewed in depth).
- `supplier_integration_pkg` — job queue: `create_job`, `claim_job`, `complete_job`, `retry_job`, `retry_latest_failed_request_job`. This is the OIC polling contract.
- `supplier_projection_pkg` — `normalize_text` (uppercase + strip non-alphanumeric, used for BOTH name normalization and fingerprinting), `fingerprint` (SHA-256 over normalized text — **not HMAC**, flagged below), `mask_identifier`, `risk_level` (reads `risk_score_band_config_v`, so band→level mapping is already admin-configurable — good), `allowed_actions`.
- `supplier_request_pkg` — `create_request`/`update_request` (populate `supplier_name_normalized`, `address_normalized`, `tax_registration_fingerprint`, `bank_account_fingerprint` at write time), `submit_request` (orchestrates status transition + calls `supplier_validation_pkg.assess_request` + creates the `AI_EXPLANATION` job), `add_document`.
- `supplier_review_pkg` — `decide_request`, `apply_justification_risk_adjustment` (not yet reviewed in depth).
- `supplier_validation_pkg` — `assess_request`. **This is where duplicate detection + deterministic risk scoring live.** Reviewed in depth this session — see findings below.
- `supplier_workflow_pkg` — status transition + action-history writer.

ORDS routing (`001_supplier_onboarding_module.sql`) is complete and matches the OpenAPI catalog: requests CRUD/submit/review/documents, `justification-risk-adjustment`, `ai-regeneration`, `retry`, `integration-jobs` (list/claim/result), `integration-logs`, `action-history`, `risk-rules` (get/put), `high-risk-countries` (get/put), `supplier-reference/batch` (currently **header-only** — see gap below).

VBCS frontend (v4 zip) already has: dashboard (wired to real data), Reviewer decision screen (risk score bar, `risk_factors_json`/`duplicate_matches_json` breakdown, AI summary display, read-only), Integration Logs, Action History, quick filters, document upload (metadata only). Missing: Admin screen (risk weights / high-risk countries), an "AI regeneration" trigger button, and the `erp-master` tab is still a stub.

## Session log

### Session 1 — Dashboard + document upload (VBCS)
- Wired dashboard stats/filters to live ORDS data via a client-side `ArrayDataProvider2` + page-module functions (`computeDashboardStats`, `filterRequests`, `buildBusinessUnitOptions`) instead of a raw `ServiceDataProvider`, so filtering/stats need no extra REST calls.
- Added `uploadDocument` operation to the VBCS `ORDS-Specification` service catalog and a document-upload UI on the request form (metadata only — confirmed this session that `add_document`'s `p_document_content` is hardcoded to `null` in the ORDS handler today, so this matches current backend capability. Revisit if/when file bytes get wired through.)
- Fixed a latent bug: `saveDraftChain` never captured `request_id` from the create response, so document upload could never be enabled after a draft save. Fixed.

### Session 2 — Backend architecture review + plan (this doc's first version)
- Read `001_supplier_onboarding_module.sql` (ORDS routing) and the updated OpenAPI catalog to map the full backend surface.
- Produced the 7-point plan above. Flagged that I hadn't seen the actual PL/SQL package bodies yet.

### Session 3 — Duplicate detection deep dive (in progress)
Reviewed `supplier_validation_pkg.assess_request`'s duplicate-detection section line by line. Findings:

**Real bugs found (both currently "masked" by other code, but fragile):**
1. **Self-doubling score bug.** In the non-exact-similarity branch, `add_risk(...)` was called with `l_duplicate_score` as *both* `p_applied_weight` and the `p_score` accumulator, so `add_risk` doubled it (`p_score := p_score + p_applied_weight`). The very next line immediately overwrote `l_duplicate_score` with the correct value, so there was no visible effect *today* — but it would silently break if that override line were ever touched.
2. **Exact-match double-counting.** If both an exact tax match *and* an exact bank match were found, the code called `add_risk` twice into the same `l_duplicate_score` accumulator, summing both weights (e.g. 45+45=90) instead of taking the single strongest indicator, which the design explicitly calls out: *"If both exact values match, the duplicate component is 45, not 90."* This was only invisible because the final `least(l_duplicate_score, risk_component_total('DUPLICATE'))` cap happened to clamp it back down — but only if that config total is coincidentally low enough. Fixed to take the greater of the two, matching the design.

**Missing pieces vs. the design doc:**
3. The weighted formula (`55×name + 20×address + 10×country + 10×email-domain + 5×phone`, normalized by whichever fields are actually available) was **not implemented at all** — only name similarity was being compared. Address, email-domain, and phone were dead weight in the doc. Implemented all four inputs now, with the "available fields only" normalization so a candidate isn't penalized for missing optional data on either side.
4. **No candidate identification.** `duplicate_matches_json` only stored counts/scores, never *which* Fusion supplier matched (no `supplier_number`, no site ID). A reviewer had no way to see who the possible duplicate actually was. Fixed — now records `fusion_supplier_number` and the matched site ID for both the exact and similarity paths.
5. Eligibility/country matching was done against the request's **header** `country_code`, but per the design, Fusion site matching should be against the **site being registered** (`site_country_code`), since a supplier's billing country and the new site's country aren't guaranteed to be the same. Switched to `site_country_code` (falling back to `country_code` if null).
6. Exact tax/bank lookups only checked the child reference row's own `active` flag, not whether the *owning* Fusion supplier is still active. A deactivated supplier with a stale-but-still-active tax/bank ref row could produce a false-positive exact match. Fixed — now joins back to `fusion_supplier_ref` and requires both active.
7. Supplier-name normalization for duplicate comparison reuses `supplier_projection_pkg.normalize_text`, which is also used for tax/bank **fingerprinting** — so I did not touch it (changing it would silently change what counts as an exact tax/bank match, which is a much bigger blast radius than duplicate name-matching). Instead I added a separate, dedicated name-normalization step *inside* the duplicate-detection helper that additionally strips common legal-entity suffixes (`LTD`, `LIMITED`, `INC`, `LLC`, `CORP`, `CO`), matching the design's specific instruction, without touching fingerprint-relevant normalization anywhere else.

**Gap that blocks duplicate detection from ever firing (flagging, not yet fixed):**
8. `POST /supplier-reference/batch` only merges into `FUSION_SUPPLIER_REF` (the supplier header table). There is currently **no ORDS endpoint or PL/SQL path that populates `FUSION_SUPPLIER_TAX_REF`, `FUSION_SUPPLIER_SITE_REF`, or `FUSION_SUPPLIER_BANK_REF`.** Duplicate detection code queries all three, but they'd stay empty forever with the current API surface. This needs either (a) extending `supplier-reference/batch` to accept optional site/tax/bank child arrays in the same call, or (b) three new batch endpoints. This is squarely part of the upcoming **SUPPLIER_SYNC OIC flow** design (item 5 in the plan) — flagging now so it's not forgotten, will size it properly when we get to OIC flows.

9. **Duplicate-component cap was config-dependent and fragile.** The old code capped the duplicate score at `supplier_config_pkg.risk_component_total('DUPLICATE')`, i.e. the *sum* of `EXACT_TAX_ID_MATCH` + `EXACT_BANK_MATCH` + `DUPLICATE_SIMILARITY`'s configured weights. Since the design treats these three as mutually-exclusive alternatives (never summed), that sum has no real meaning as a cap — it only "worked" as long as the configured weights happened to add up to exactly 45. Fixed: the duplicate component is now capped at a **structural 45**, per the design's fixed architecture (`base ≤55 + duplicate ≤45 = 100`), independent of whatever individual duplicate-rule weights an admin configures. This is scoped tightly to `assess_request`'s own cap — I did not touch `supplier_config_pkg` itself.

**Still open, deferred to the "risk calculation" phase (not touched this session):**
10. `supplier_config_pkg.validate_risk_allocation` enforces that *all* active `risk_rule_config` weights (across every component) sum to exactly 100. Given finding #9 above, this check's premise looks off in the same way: base rules (≤55, additive) and duplicate rules (≤45, "take the strongest") shouldn't need to sum together to one shared total of 100 for the config to be valid — the doc's own example weights (`EXACT_TAX_ID_MATCH=45` + `EXACT_BANK_MATCH=45` + `DUPLICATE_SIMILARITY=20` alone is already 110) would likely fail this check today. Left untouched since it's in `supplier_config_pkg`, which the admin-weight-editing phase owns, not duplicate detection — but it's the same root issue as #9, so worth fixing in the same pass when we get there.
11. `add_document`'s `p_document_content` is always `null` from the current ORDS handler — actual file bytes are never stored today, only metadata. Fine for now, just flagged for whenever "real" document storage matters.

**Delivered this session:** rewritten `supplier_validation_pkg` package body (duplicate-detection section) — see `supplier_validation_pkg_body.sql`. Deploy by running it after the existing specs/other bodies (it only replaces this one package, nothing else).

## Next up (not started yet)
- Extend `supplier-reference/batch` (or add new endpoints) to populate `FUSION_SUPPLIER_TAX_REF`/`SITE_REF`/`BANK_REF` — needed before duplicate detection can produce anything but "no match" in a fresh environment.
- Risk calculation phase: review `apply_justification_risk_adjustment`, confirm how `deterministic_risk_score` + `reviewer_adjustment_points` combine into `risk_score`, resolve the `validate_risk_allocation` sum-to-100 question, confirm band-mapping admin UI.
- Admin frontend screen (risk weights + high-risk countries) — backend ready, nothing built on the VBCS side yet.
- OIC integration flows (AI_EXPLANATION, FUSION_CREATE, SUPPLIER_SYNC) + ORDS↔OIC connectivity.
- AI regeneration button on the Reviewer screen.
