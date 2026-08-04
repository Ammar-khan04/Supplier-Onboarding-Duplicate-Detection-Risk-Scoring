# VB App Change Scratchpad

## Session — 2026-08-03

### Baseline
Starting from `claude_test_app-v4.zip` (clean extract).

---

## Round 1 — 4 Bug Fixes (JS + HTML only, no SQL changes)

### Bug 1 — `riskScoreToPercent` divides by 30 instead of 100
**File:** `item-1-start-page.js` line 160
- DB schema: `risk_score` is 0–100
- Old: `Math.round((score / 30) * 100)` — a score of 45 → 150%, gets clipped to 100%
- Fix: score is already 0–100, just clamp it directly

### Bug 2 — Duplicate level filter values don't match DB
**File:** `item-1-start-page.html` lines 194–198 (filter dropdown)
**File:** `item-1-start-page.js` lines 47–56 (badge class function)
- Old values: `CLEAR / MEDIUM / HIGH / EXACT_MATCH`
- DB constraint values: `NONE / POSSIBLE / STRONG / EXACT`
- Fix: rename option values + badge class cases to match DB

### Bug 3 — Integration log status values don't match DB
**File:** `item-1-start-page.js` lines 264–318 (`getLogStatusClass` + `computeAdminStats`)
**File:** `item-1-start-page.html` lines 759–763 (log status filter dropdown)
- Old: `PENDING / RUNNING / COMPLETED / SUCCESS / ERROR`
- DB values: `READY / CLAIMED / IN_PROGRESS / SUCCEEDED / FAILED / CANCELLED`
- Fix: update both functions and the HTML filter options

### Bug 4 — `formatIntegrationType` has phantom values
**File:** `item-1-start-page.js` lines 281–291
- Old: includes `AI_REGENERATION`, `DUPLICATE_CHECK`, `VALIDATION` — none of these exist in the DB
- DB `integration_type` values: `AI_EXPLANATION`, `FUSION_CREATE`, `SUPPLIER_SYNC`
- Fix: remove phantom keys, add `SUPPLIER_SYNC`
**File:** `item-1-start-page.html` lines 772–774 (log type filter dropdown)
- Remove phantom type options, add `SUPPLIER_SYNC`

---

### Status
- [x] JS fixes applied (`item-1-start-page.js`)
- [x] HTML fixes applied (`item-1-start-page.html`)
- [x] Zip created as `claude_test_app-v5.zip`

### Files Changed
| File | What changed |
|---|---|
| `item-1-start-page.js` | `getDuplicateBadgeClass`: CLEAR/MEDIUM/HIGH/EXACT_MATCH → NONE/POSSIBLE/STRONG/EXACT |
| `item-1-start-page.js` | `riskScoreToPercent`: removed `/30*100`, score is already 0–100 |
| `item-1-start-page.js` | `getLogStatusClass`: COMPLETED/RUNNING/SUCCESS/ERROR → SUCCEEDED/IN_PROGRESS/FAILED/CANCELLED |
| `item-1-start-page.js` | `formatIntegrationType`: removed AI_REGENERATION/DUPLICATE_CHECK/VALIDATION, added SUPPLIER_SYNC |
| `item-1-start-page.js` | `computeAdminStats`: PENDING/RUNNING/COMPLETED/SUCCESS/ERROR → READY/IN_PROGRESS/SUCCEEDED/FAILED |
| `item-1-start-page.html` | Duplicate level filter dropdown: CLEAR/MEDIUM/HIGH/EXACT_MATCH → NONE/POSSIBLE/STRONG/EXACT |
| `item-1-start-page.html` | Log status filter: PENDING/COMPLETED → READY/IN_PROGRESS/SUCCEEDED/FAILED/CANCELLED |
| `item-1-start-page.html` | Log type filter: removed AI_REGENERATION/DUPLICATE_CHECK/VALIDATION, added SUPPLIER_SYNC |

### No SQL or JSON chain changes made.

---

## Round 2 — Edit/Resubmit fix + Risk display fixes + Justification Adjustment UI

### Issue 1 — Requester edit creates new request instead of updating existing

**Root cause:** `viewRequestChain` sets `currentRequestId` on every "View" click.
Then `saveDraftChain` and `submitRequestChain` always call POST (create), ignoring `currentRequestId`.

**Fix (JSON chains only, minimal changes):**
- Add `currentRequestStatus` page variable to track the loaded request's status
- `viewRequestChain`: after populating, also set `currentRequestStatus` from response
- `saveDraftChain`: branch — if `currentRequestId` set AND status in (DRAFT/VALIDATION_FAILED/CORRECTION_REQUIRED) → PUT; else → POST
- `submitRequestChain`: same branch — update then submit existing; or create+submit new
- `onSelectNewRequest` / `onGoToNewRequest`: add a `clearRequestChain` step to zero `currentRequestId`+`currentRequestStatus` before switching tab

### Issue 2a — Risk factors show "△ —" instead of data

**Root cause:** DB `risk_factors_json` stores objects with keys:
`rule_code`, `configured_weight`, `applied_weight`, `evidence`

But HTML template reads: `factor_code || code`, `description || reason || label`, `points`

**Fix (HTML only):** Update factor template to read the correct DB field names:
- Label: `factor.data.rule_code`
- Description: `factor.data.evidence`
- Points: `factor.data.applied_weight`

### Issue 2b — Duplicate match shows "?%"

**Root cause:** DB `duplicate_matches_json` stores:
- EXACT: `match_type, tax_match, bank_match, fusion_supplier_number`
- SIMILARITY: `match_type, weighted_score, name_similarity, address_similarity, fusion_supplier_number, duplicate_points`

HTML reads `match_score || score` — neither exists in the DB JSON.

**Fix (HTML only):** 
- Score: use `match.data.weighted_score` (similarity) — for EXACT use 100
- Name: use `match.data.fusion_supplier_number` (no supplier name stored)
- Reason: build from `match.data.match_type`, `name_similarity`, `address_similarity`

### Issue 3 — Justification Risk Adjustment panel

**ORDS endpoint exists:** `POST /requests/:request_id/justification-risk-adjustment`
Body: `{ points: number, reason: string }`

**Need to add:**
1. OpenAPI spec entry for the new endpoint
2. Two new page variables: `justAdj` (object with points/reason), `justAdjBusy` (boolean)
3. HTML panel in reviewer detail (after AI Summary section, before Documents)
4. JSON event listener + chain for submitting adjustment

### Status
- [x] Issue 1 — Edit/resubmit flow (JSON chains)
- [x] Issue 2a — Risk factors (HTML + JS `factorIcon`/`factorSeverityClass`)
- [x] Issue 2b — Dup match score (HTML)
- [x] Issue 3 — Justification adjustment panel (HTML + JSON + OpenAPI + JS)
- [x] Zip updated: `claude_test_app-v5.zip`
