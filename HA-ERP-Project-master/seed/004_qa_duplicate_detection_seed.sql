-- =============================================================================
-- Session 4: QA seed data for duplicate detection testing
-- Seeds all 5 reference cases from the technical design doc:
--   1. Exact tax duplicate          -> 45 duplicate points
--   2. Exact bank duplicate         -> 45 duplicate points
--   3. Similar supplier (POSSIBLE)  -> 10 duplicate points (score 70–84)
--   4. Similar supplier (STRONG)    -> 20 duplicate points (score >= 85)
--   5. No match                     -> 0 duplicate points
--   6. Inactive supplier            -> excluded from matching
--
-- Run AFTER: all schema scripts, seed/002_seed_configuration.sql,
--            and SUPPLIER_REFERENCE_PKG.sql have been deployed.
-- These rows are additive — they do not delete existing reference data.
-- =============================================================================

set define off
whenever sqlerror exit sql.sqlcode

prompt === Session 4 QA Reference Seed ===

-- ---------------------------------------------------------------------------
-- Case 1: EXACT TAX DUPLICATE
-- A Fusion supplier whose tax fingerprint matches a test request's tax number.
-- Submit a request with tax_registration_number = 'QA-TAX-EXACT-001'
-- Expected: 45 duplicate points, duplicate_level = 'EXACT'
-- ---------------------------------------------------------------------------
insert into fusion_supplier_ref (
  fusion_supplier_id, supplier_number, supplier_name, supplier_name_normalized,
  supplier_type, active, source_last_updated_at, last_seen_sync_id
) values (
  'QA-FUS-TAX-001', 'QA-SUP-TAX-001', 'Quantum Supplies Ltd',
  supplier_projection_pkg.normalize_text('Quantum Supplies Ltd'),
  'COMPANY', 'Y', systimestamp, 'QA-SEED-S4'
);

insert into fusion_supplier_tax_ref (
  fusion_tax_reference_id, fusion_supplier_id, country_code, tax_type,
  tax_id_fingerprint, tax_id_masked, active, source_last_updated_at, last_seen_sync_id
) values (
  'QA-TAX-001', 'QA-FUS-TAX-001', 'PK', 'NTN',
  supplier_projection_pkg.fingerprint('QA-TAX-EXACT-001'),
  supplier_projection_pkg.mask_identifier('QA-TAX-EXACT-001'),
  'Y', systimestamp, 'QA-SEED-S4'
);

insert into fusion_supplier_site_ref (
  fusion_supplier_site_id, fusion_supplier_id, site_name, country_code,
  address_line1, city, address_normalized, email_domain, phone_normalized,
  active, source_last_updated_at, last_seen_sync_id
) values (
  'QA-SITE-TAX-001', 'QA-FUS-TAX-001', 'Islamabad HQ', 'PK',
  '5 Blue Area', 'Islamabad',
  supplier_projection_pkg.normalize_text('5 Blue Area Islamabad PK'),
  'quantumsupplies.example', '922351234567',
  'Y', systimestamp, 'QA-SEED-S4'
);

-- ---------------------------------------------------------------------------
-- Case 2: EXACT BANK DUPLICATE
-- A Fusion supplier whose bank fingerprint matches a test request's bank account.
-- Submit a request with bank_account_raw = 'QA-BANK-EXACT-9900'
-- Expected: 45 duplicate points, duplicate_level = 'EXACT'
-- ---------------------------------------------------------------------------
insert into fusion_supplier_ref (
  fusion_supplier_id, supplier_number, supplier_name, supplier_name_normalized,
  supplier_type, active, source_last_updated_at, last_seen_sync_id
) values (
  'QA-FUS-BANK-001', 'QA-SUP-BANK-001', 'Delta Trading Company',
  supplier_projection_pkg.normalize_text('Delta Trading Company'),
  'COMPANY', 'Y', systimestamp, 'QA-SEED-S4'
);

insert into fusion_supplier_site_ref (
  fusion_supplier_site_id, fusion_supplier_id, site_name, country_code,
  address_line1, city, address_normalized, active,
  source_last_updated_at, last_seen_sync_id
) values (
  'QA-SITE-BANK-001', 'QA-FUS-BANK-001', 'Lahore Office', 'PK',
  '22 Gulberg Road', 'Lahore',
  supplier_projection_pkg.normalize_text('22 Gulberg Road Lahore PK'),
  'Y', systimestamp, 'QA-SEED-S4'
);

-- Bank fingerprint: normalize 'QA-BANK-EXACT-9900' -> strip non-alnum -> 'QABANKEXACT9900'
insert into fusion_supplier_bank_ref (
  fusion_bank_account_id, fusion_supplier_id, bank_country_code, currency_code,
  bank_account_fingerprint, bank_account_last_four, active,
  source_last_updated_at, last_seen_sync_id
) values (
  'QA-BANK-001', 'QA-FUS-BANK-001', 'PK', 'PKR',
  supplier_projection_pkg.fingerprint('QABANKEXACT9900'),
  '9900',
  'Y', systimestamp, 'QA-SEED-S4'
);

-- ---------------------------------------------------------------------------
-- Case 3: SIMILAR SUPPLIER — POSSIBLE (score 70–84 -> 10 points)
-- Name is recognisably similar but not a strong match.
-- Submit a request with supplier_name = 'Nexus Freight Services'
--   and site_country_code / country_code = 'AE'
-- Expected: ~10 duplicate points (depending on Jaro-Winkler score), level = 'POSSIBLE'
-- ---------------------------------------------------------------------------
insert into fusion_supplier_ref (
  fusion_supplier_id, supplier_number, supplier_name, supplier_name_normalized,
  supplier_type, active, source_last_updated_at, last_seen_sync_id
) values (
  'QA-FUS-SIM-001', 'QA-SUP-SIM-001', 'Nexus Freight Solutions',
  supplier_projection_pkg.normalize_text('Nexus Freight Solutions'),
  'COMPANY', 'Y', systimestamp, 'QA-SEED-S4'
);

insert into fusion_supplier_site_ref (
  fusion_supplier_site_id, fusion_supplier_id, site_name, country_code,
  address_line1, city, address_normalized, email_domain, phone_normalized,
  active, source_last_updated_at, last_seen_sync_id
) values (
  'QA-SITE-SIM-001', 'QA-FUS-SIM-001', 'Dubai Office', 'AE',
  '10 Sheikh Zayed Road', 'Dubai',
  supplier_projection_pkg.normalize_text('10 Sheikh Zayed Road Dubai AE'),
  'nexusfreight.example', '97143001234',
  'Y', systimestamp, 'QA-SEED-S4'
);

-- ---------------------------------------------------------------------------
-- Case 4: SIMILAR SUPPLIER — STRONG (score >= 85 -> 20 points)
-- Almost identical name in the same country with matching address city.
-- Submit a request with supplier_name = 'Pinnacle Construction Group'
--   and site_country_code / country_code = 'SA'
-- Expected: 20 duplicate points, level = 'STRONG'
-- ---------------------------------------------------------------------------
insert into fusion_supplier_ref (
  fusion_supplier_id, supplier_number, supplier_name, supplier_name_normalized,
  supplier_type, active, source_last_updated_at, last_seen_sync_id
) values (
  'QA-FUS-STR-001', 'QA-SUP-STR-001', 'Pinnacle Construction Group',
  supplier_projection_pkg.normalize_text('Pinnacle Construction Group'),
  'COMPANY', 'Y', systimestamp, 'QA-SEED-S4'
);

insert into fusion_supplier_site_ref (
  fusion_supplier_site_id, fusion_supplier_id, site_name, country_code,
  address_line1, city, address_normalized, email_domain, phone_normalized,
  active, source_last_updated_at, last_seen_sync_id
) values (
  'QA-SITE-STR-001', 'QA-FUS-STR-001', 'Riyadh Branch', 'SA',
  '77 King Fahd Road', 'Riyadh',
  supplier_projection_pkg.normalize_text('77 King Fahd Road Riyadh SA'),
  'pinnacleconst.example', '966112345678',
  'Y', systimestamp, 'QA-SEED-S4'
);

-- ---------------------------------------------------------------------------
-- Case 5: NO MATCH
-- Completely unrelated supplier in a different country.
-- Any request with a different country will not match this candidate.
-- Expected: 0 duplicate points, duplicate_level = 'NONE'
-- ---------------------------------------------------------------------------
insert into fusion_supplier_ref (
  fusion_supplier_id, supplier_number, supplier_name, supplier_name_normalized,
  supplier_type, active, source_last_updated_at, last_seen_sync_id
) values (
  'QA-FUS-NONE-001', 'QA-SUP-NONE-001', 'Totally Unrelated Vendor Inc',
  supplier_projection_pkg.normalize_text('Totally Unrelated Vendor Inc'),
  'COMPANY', 'Y', systimestamp, 'QA-SEED-S4'
);

insert into fusion_supplier_site_ref (
  fusion_supplier_site_id, fusion_supplier_id, site_name, country_code,
  address_line1, city, address_normalized, active,
  source_last_updated_at, last_seen_sync_id
) values (
  'QA-SITE-NONE-001', 'QA-FUS-NONE-001', 'Frankfurt Office', 'DE',
  '3 Musterstrasse', 'Frankfurt',
  supplier_projection_pkg.normalize_text('3 Musterstrasse Frankfurt DE'),
  'Y', systimestamp, 'QA-SEED-S4'
);

-- ---------------------------------------------------------------------------
-- Case 6: INACTIVE SUPPLIER — must be excluded from all matching
-- Same name and country as Case 4 (Strong), but active = 'N'.
-- Expected: completely excluded from duplicate detection candidates.
-- ---------------------------------------------------------------------------
insert into fusion_supplier_ref (
  fusion_supplier_id, supplier_number, supplier_name, supplier_name_normalized,
  supplier_type, active, source_last_updated_at, last_seen_sync_id
) values (
  'QA-FUS-INACT-001', 'QA-SUP-INACT-001', 'Pinnacle Construction Group',
  supplier_projection_pkg.normalize_text('Pinnacle Construction Group'),
  'COMPANY', 'N',  -- INACTIVE
  systimestamp, 'QA-SEED-S4'
);

insert into fusion_supplier_site_ref (
  fusion_supplier_site_id, fusion_supplier_id, site_name, country_code,
  address_line1, city, address_normalized, active,
  source_last_updated_at, last_seen_sync_id
) values (
  'QA-SITE-INACT-001', 'QA-FUS-INACT-001', 'Old Riyadh Site', 'SA',
  '77 King Fahd Road', 'Riyadh',
  supplier_projection_pkg.normalize_text('77 King Fahd Road Riyadh SA'),
  'N',  -- INACTIVE site
  systimestamp, 'QA-SEED-S4'
);

insert into fusion_supplier_tax_ref (
  fusion_tax_reference_id, fusion_supplier_id, country_code, tax_type,
  tax_id_fingerprint, tax_id_masked, active, source_last_updated_at, last_seen_sync_id
) values (
  'QA-TAX-INACT-001', 'QA-FUS-INACT-001', 'SA', 'VAT',
  supplier_projection_pkg.fingerprint('SA-VAT-INACTIVE-999'),
  supplier_projection_pkg.mask_identifier('SA-VAT-INACTIVE-999'),
  'N',  -- INACTIVE tax ref
  systimestamp, 'QA-SEED-S4'
);

insert into fusion_supplier_bank_ref (
  fusion_bank_account_id, fusion_supplier_id, bank_country_code, currency_code,
  bank_account_fingerprint, bank_account_last_four, active,
  source_last_updated_at, last_seen_sync_id
) values (
  'QA-BANK-INACT-001', 'QA-FUS-INACT-001', 'SA', 'SAR',
  supplier_projection_pkg.fingerprint('SAIBANACTIVEINACT999'),
  '9999',
  'N',  -- INACTIVE bank ref
  systimestamp, 'QA-SEED-S4'
);

commit;

prompt === Session 4 QA Reference Seed Complete ===
prompt
prompt Test request fingerprints to use in submission tests:
prompt   Case 1 (exact tax):  tax_registration_number = 'QA-TAX-EXACT-001'
prompt   Case 2 (exact bank): bank_account_raw = 'QA-BANK-EXACT-9900'
prompt                        (normalized to 'QABANKEXACT9900' for fingerprint)
prompt   Case 3 (possible):   supplier_name ~ 'Nexus Freight Services', country_code = 'AE'
prompt   Case 4 (strong):     supplier_name = 'Pinnacle Construction Group', country_code = 'SA'
prompt   Case 5 (no match):   any supplier in a country with no matching reference data
prompt   Case 6 (inactive):   same as Case 4 but QA-FUS-INACT-001 must not appear in results
